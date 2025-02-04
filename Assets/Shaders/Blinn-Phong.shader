Shader "Lighting/Blinn-Phong"
{
    Properties
    {
        [Header(Colours)][Space(10)]
        _DiffuseColour("Diffuse Colour", Color) = (1,1,1,1)
        _MainTex("Albedo (RGB)", 2D) = "white" {}

        [Header(Normal)][Space(10)]
        [Normal]_Normal("Normal Map", 2D) = "bump" {}
        _NormalStrength("Normal Strength", Range(0,20)) = 1

        [Header(Parallax Mapping)][Space(10)]
        _Height("Height Map", 2D) = "height"{}
        _NumberOfLayers("Number of Layers", Integer) = 100
        _HeightScale("Height scale", Range(0,1)) = 0.1

        [Header(Blinn Phong)][Space(10)]
        _SpecularExponent("Specular Exponent", Float) = 80
        _k ("Coefficients (Ambient, Diffuse, Specular)", Vector) = (0.5,0.5,0.8)
    }
    SubShader
    {

        Pass
        {
            Name "ForwardBase"
            Tags
            {
                "LightMode"="ForwardBase"
            }

            Cull Off // Disable back-face culling to ensure lighting applies to both sides
            Blend SrcAlpha OneMinusSrcAlpha // Alpha blending for transparency support
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "Parallax-Mapping.hlsl"

            uniform fixed4 _DiffuseColour;

            uniform sampler2D _MainTex;
            uniform half4 _MainTex_ST;

            uniform sampler2D _Normal;
            uniform half _NormalStrength;

            uniform sampler2D _Height;
            uniform int _NumberOfLayers;
            uniform float _HeightScale;

            uniform float3 _k;
            uniform float _SpecularExponent;

            uniform fixed4 _LightColor0;

            struct appdata
            {
                half4 vertex: POSITION;
                half3 normal: NORMAL;
                half2 uv: TEXCOORD0;
                half4 tangent: TANGENT;
            };

            struct v2f
            {
                half4 pos: SV_POSITION;
                half3 worldPos: TEXCOORD0;
                half2 uv: TEXCOORD1;
                half3x3 TBN : TEXCOORD2;
                half4 color: COLOR0;
            };

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

            fixed4 frag(v2f i) : SV_Target
            {
                half3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
                half3 l = normalize(_WorldSpaceLightPos0.xyz);

                half3 l_TS = normalize(mul(i.TBN, l));
                float2 texCoords = ParallaxMapping(_Height, i.uv, float3(-v.x, -v.z, v.y), _NumberOfLayers,
                                                        _HeightScale);
                float parallaxShadows = ParallaxShadow(_Height, texCoords, l_TS, _NumberOfLayers, _HeightScale);

                // Blinn Phong
                half4 c = tex2D(_MainTex, texCoords) * _DiffuseColour;
                half3 normalMap = UnpackNormal(tex2D(_Normal, texCoords));
                normalMap.xy *= _NormalStrength;
                normalMap.z = sqrt(1.0 - saturate(dot(normalMap.xy, normalMap.xy))); // Re-normalize normal

                half3 n = normalize(mul(transpose(i.TBN), normalMap));
                half3 h = normalize(l + v);

                float Ia = _k.x;
                float Id = _k.y * saturate(dot(n, l));
                float Is = _k.z * pow(saturate(dot(h, n)), _SpecularExponent);


                float3 ambientSH = ShadeSH9(float4(n, 1));
                float3 ambient = Ia * c * ambientSH;
                float3 diffuse = Id * c * _LightColor0.rgb;
                float3 specular = Is * _LightColor0.rgb;

                float3 finalColor = ambient + (diffuse + specular) * parallaxShadows;

                return fixed4(finalColor, 1.0);
            }
            ENDHLSL

        }

        Pass
        {
            Name "ForwardAdd"
            Tags
            {
                "LightMode"="ForwardAdd"
            }

            Cull Off // Disables back-face culling to ensure proper lighting on both sides
            Blend One One // Additive blending mode (adds this pass's lighting to the previous result)

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows // Enable full shadows support for additional lights


            #include "UnityCG.cginc"
            #include "Parallax-Mapping.hlsl"
            #include "AutoLight.cginc"  // Includes light attenuation calculations


            uniform fixed4 _DiffuseColour;

            uniform sampler2D _MainTex;
            uniform half4 _MainTex_ST;

            uniform sampler2D _Normal;
            uniform half _NormalStrength;

            uniform sampler2D _Height;
            uniform int _NumberOfLayers;
            uniform float _HeightScale;

            uniform float3 _k;
            uniform float _SpecularExponent;

            uniform fixed4 _LightColor0;

            struct appdata
            {
                half4 vertex: POSITION;
                half3 normal: NORMAL;
                half2 uv: TEXCOORD0;
                half4 tangent: TANGENT;
            };

            struct v2f
            {
                half4 pos: SV_POSITION;
                half3 worldPos: TEXCOORD0;
                half2 uv: TEXCOORD1;
                half3x3 TBN : TEXCOORD2;
                LIGHTING_COORDS(6, 7)
            };

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

                UNITY_TRANSFER_LIGHTING(o, v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half3 v = normalize(_WorldSpaceCameraPos - i.worldPos);

                half3 l;
                half atten;
                if (_WorldSpaceLightPos0.w == 0.0)
                {
                    // Directional light: no attenuation, use normalized direction
                    l = normalize(_WorldSpaceLightPos0.xyz);
                    atten = 1.0;
                }
                else
                {
                    // Point light: calculate attenuation based on distance
                    l = normalize(_WorldSpaceLightPos0.xyz - i.worldPos);
                    atten = LIGHT_ATTENUATION(i);
                }


                half3 l_TS = normalize(mul(i.TBN, l));
                float2 texCoords = SteepParallaxMapping(_Height, i.uv, float3(-v.x, -v.z, v.y), _NumberOfLayers,
                                                        _HeightScale);
                float parallaxShadows = ParallaxShadow(_Height, texCoords, l_TS, _NumberOfLayers, _HeightScale);

                // Blinn Phong
                half4 c = tex2D(_MainTex, texCoords) * _DiffuseColour;
                half3 normalMap = UnpackNormal(tex2D(_Normal, texCoords));
                normalMap.xy *= _NormalStrength;
                normalMap.z = sqrt(1.0 - saturate(dot(normalMap.xy, normalMap.xy))); // Re-normalize normal

                half3 n = normalize(mul(transpose(i.TBN), normalMap));
                half3 h = normalize(l + v);

                float Id = _k.y * saturate(dot(n, l)) * atten;
                float Is = _k.z * pow(saturate(dot(h, n)), _SpecularExponent) * atten;

                float3 diffuse = Id * c * _LightColor0.rgb;
                float3 specular = Is * _LightColor0.rgb;

                float3 finalColor = (diffuse + specular) * parallaxShadows;

                return fixed4(finalColor, 1.0);
            }
            ENDHLSL

        }
    }
    Fallback "Diffuse"

}