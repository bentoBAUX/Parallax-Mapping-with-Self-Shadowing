Shader "Lighting/Cook-Torrance"
{
    Properties
    {
        [Header(Colours)][Space(10)]
        _DiffuseColour("Diffuse Colour", Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}

        [Header(Roughness)][Space(10)]
        _Roughness("Roughness Map", 2D) = "roughness"{}
        _sigma ("Roughness Factor", Range(0,1)) = 0.8

        [Header(Normal)][Space(10)]
        [Normal]_Normal("Normal Map", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Range(0,20)) = 1

        [Header(Parallax Mapping)][Space(10)]
        _Height("Height Map", 2D) = "height"{}
        _NumberOfLayers("Number of Layers", Integer) = 100
        _HeightScale("Height scale", Range(0,1)) = 0.1

        [Header(Cook Torrance)][Space(10)]
        _Metallic ("Metallic", Range(0, 1)) = 0.5
        _RefractiveIndex ("Refractive Index", Range(1, 5)) = 2.5
    }

    SubShader
    {
        Tags
        {
            "LightMode"="ForwardBase"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Parallax-Mapping.hlsl"

            struct appdata
            {
                float4 vertex: POSITION;
                float3 normal: NORMAL;
                half2 uv: TEXCOORD0;
                half4 tangent: TANGENT;
            };

            struct v2f
            {
                float4 pos: SV_POSITION;
                float3 worldPos: TEXCOORD0;
                half2 uv: TEXCOORD1;
                half3x3 TBN : TEXCOORD2;
                half4 color: COLOR0;
            };

            uniform fixed4 _DiffuseColour;

            uniform sampler2D _MainTex;
            uniform half4 _MainTex_ST;

            uniform sampler2D _Roughness;
            uniform float _sigma;

            uniform sampler2D _Normal;
            uniform half _NormalStrength;

            uniform sampler2D _Height;
            uniform int _NumberOfLayers;
            uniform float _HeightScale;

            uniform float _Metallic;
            uniform float _RefractiveIndex;
            uniform fixed4 _LightColor0;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;

                o.uv = v.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half3 worldTangent = mul((float3x3)unity_ObjectToWorld, v.tangent);

                half3 bitangent = cross(worldNormal, worldTangent);
                half3 worldBitangent = mul((float3x3)unity_ObjectToWorld, bitangent);

                o.TBN = float3x3(worldTangent, worldBitangent, worldNormal);
                return o;
            }

            float phi(float x, float y)
            {
                return atan2(y, x);
            }

            float3 calculateIrradiance(float3 l, float3 n)
            {
                return _LightColor0.rgb * saturate(dot(n, l)); // LightColor multiplied by NdotL
            }

            float4 frag(v2f i) : SV_Target
            {
                half3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 l = normalize(_WorldSpaceLightPos0.xyz);

                float2 texCoords = SteepParallaxMapping(_Height,i.uv, float3(-v.x, -v.z, v.y), _NumberOfLayers, _HeightScale);
                float shadow = Shadow(_Height, texCoords, l,_NumberOfLayers,_HeightScale);

                half4 c = tex2D(_MainTex, texCoords) * _DiffuseColour;
                half3 normalMap = UnpackNormal(tex2D(_Normal, texCoords));
                normalMap.xy *= _NormalStrength;

                half3 n = normalize(mul(transpose(i.TBN), normalMap));
                half3 r = 2.0 * dot(l, n) * n - l;
                half3 h = normalize(l + v);

                float3 E0 = calculateIrradiance(l, n);

                float NdotL = saturate(dot(n, l));
                float NdotV = saturate(dot(n, v));

                float theta_i = acos(dot(l, n));
                float theta_r = acos(dot(r, n));

                float3 Lproj = normalize(l - n * NdotL);
                float3 Vproj = normalize(v - n * NdotV + 1);
                float cosPhi = dot(Lproj, Vproj);

                float alpha = max(theta_i, theta_r);
                float beta = min(theta_i, theta_r);

                half3 roughnessValue = tex2D(_Roughness, texCoords).r;
                float sigmaSqr = _sigma * _sigma * roughnessValue;

                // Oren-Nayar: https://en.wikipedia.org/wiki/Oren–Nayar_reflectance_model

                float C1 = 1 - 0.5 * (sigmaSqr / (sigmaSqr + 0.33));
                float C2 = cosPhi >= 0? 0.45 * (sigmaSqr / (sigmaSqr + 0.09)) * sin(alpha): 0.45 * (sigmaSqr / (sigmaSqr + 0.09)) * (sin(alpha) - pow((2.0 * beta) / UNITY_PI, 3.0));
                float C3 = 0.125 * (sigmaSqr / (sigmaSqr + 0.09)) * pow((4.0 * alpha * beta) / (UNITY_PI * UNITY_PI), 2);

                float3 L1 = c * E0 * cos(theta_i) * (C1 + (C2 * cosPhi * tan(beta)) + (C3 * (1.0 - abs(cosPhi)) *
                    tan((alpha + beta) / 2.0)));
                float3 L2 = 0.17 * (c * c) * E0 * cos(theta_i) * (sigmaSqr / (sigmaSqr + 0.13)) * (1.0 - cosPhi *
                    pow((2.0 * beta) / UNITY_PI, 2.0));

                float3 L = saturate(L1+L2);

                // Cook-Torrance: https://en.wikipedia.org/wiki/Specular_highlight#Cook–Torrance_model

                float NdotH = saturate(dot(n, h));
                float a = acos(NdotH);
                float m = clamp(sigmaSqr, 0.01, 1);
                float exponent = exp(-tan(a) * tan(a) / (m * m));
                float D = clamp(exponent / (UNITY_PI * m * m * pow(NdotH, 4)), 1e-4, 1e50); // Clamp to get rid of a visual artefact

                float F0 = ((_RefractiveIndex - 1) * (_RefractiveIndex - 1)) / ((_RefractiveIndex + 1) * (_RefractiveIndex + 1));
                float F = F0 + (1 - F0) * pow(1 - clamp(dot(v, h), 0, 1), 5);

                float G1 = 2 * dot(h, n) * dot(n, v) / dot(v, h);
                float G2 = 2 * dot(h, n) * dot(n, l) / dot(v, h);
                float G = min(1, min(G1, G2));

                float specular = ((D * G * F) / (4 * dot(n, l)) * dot(n, v)) * _LightColor0 ;

                float3 skyboxColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, float3(0,1,0)).rgb;
                fixed3 ambient = 0.07 * (UNITY_LIGHTMODEL_AMBIENT + _LightColor0 + skyboxColor);

                return float4(ambient + lerp(L, specular, _Metallic) * shadow, 1.0);
            }
            ENDCG
        }
    }
}