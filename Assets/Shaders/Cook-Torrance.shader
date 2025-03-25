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
        [Toggle(USESTEEP)] _UseSteep("Steep Parallax", Float) = 0
        [Toggle(USESHADOWS)] _UseShadows("Enable Shadows", Float) = 0
        [Toggle(TRIMEDGES)] _TrimEdges("Trim Edges", Float) = 0


        [Header(Cook Torrance)][Space(10)]
        _Metallic ("Metallic", Range(0, 1)) = 0.5
        _RefractiveIndex ("Refractive Index", Range(1, 5)) = 2.5
    }

    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        Pass
        {
            // This pass handles the base lighting for the MAIN directional light.

            Name "ForwardBase"

            Tags
            {
                "LightMode" = "ForwardBase"
            }

            Cull Off // Disable back-face culling to ensure lighting applies to both sides
            Blend SrcAlpha OneMinusSrcAlpha // Alpha blending for transparency support

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase
            #pragma shader_feature USESTEEP
            #pragma shader_feature USESHADOWS
            #pragma shader_feature TRIMEDGES

            #include "UnityCG.cginc"
            #include "Parallax-Mapping.hlsl"
            #include "AutoLight.cginc"  // Includes light attenuation calculations

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
                LIGHTING_COORDS(5, 6)
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
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent));
                float3 worldBitangent = normalize(cross(worldNormal, worldTangent) * v.tangent.w);

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

                // Convert into tangent space
                half3 v_TS = normalize(mul(i.TBN, v));
                half3 l_TS = normalize(mul(i.TBN, l));

                float2 texCoords;
                float parallaxShadows;

                #ifdef USESTEEP
                texCoords = SteepParallaxMapping(_Height, i.uv, v_TS, _NumberOfLayers, _HeightScale);
                #else
                texCoords = ParallaxMapping(_Height, i.uv, v_TS, _HeightScale);
                #endif

                #ifdef USESHADOWS
                parallaxShadows = ParallaxShadow(_Height, texCoords, l_TS, _NumberOfLayers, _HeightScale);
                #else
                parallaxShadows = 1;
                #endif

                #ifdef TRIMEDGES
                if (texCoords.x > 1.0 || texCoords.y > 1.0 || texCoords.x < 0.0 || texCoords.y < 0.0)
                    discard;
                #endif

                half4 c = tex2D(_MainTex, texCoords) * _DiffuseColour;
                half3 normalMap = UnpackNormal(tex2D(_Normal, texCoords));
                normalMap.xy *= _NormalStrength;
                normalMap.z = sqrt(1.0 - saturate(dot(normalMap.xy, normalMap.xy))); // Re-normalize normal


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
                float C2 = cosPhi >= 0
                               ? 0.45 * (sigmaSqr / (sigmaSqr + 0.09)) *
                               sin(alpha)
                               : 0.45 * (sigmaSqr / (sigmaSqr + 0.09)) * (
                                   sin(alpha) - pow(
                                       (2.0 * beta) / UNITY_PI, 3.0));
                float C3 = 0.125 * (sigmaSqr / (sigmaSqr + 0.09)) *
                    pow((4.0 * alpha * beta) / (UNITY_PI * UNITY_PI), 2);

                float3 L1 = c * E0 * cos(theta_i) * (C1 + (C2 * cosPhi * tan(beta)) + (C3 * (1.0 - abs(cosPhi)) *
                    tan((alpha + beta) / 2.0)));
                float3 L2 = 0.17 * (c * c) * E0 * cos(theta_i) * (sigmaSqr / (sigmaSqr + 0.13)) * (1.0 - cosPhi *
                    pow((2.0 * beta) / UNITY_PI, 2.0));

                float3 L = saturate(L1 + L2);

                // Cook-Torrance: https://en.wikipedia.org/wiki/Specular_highlight#Cook–Torrance_model
                float NdotH = saturate(dot(n, h));
                float a = acos(NdotH);
                float m = clamp(sigmaSqr, 0.01, 1);
                float exponent = exp(-tan(a) * tan(a) / (m * m));
                float D = clamp(exponent / (UNITY_PI * m * m * pow(NdotH, 4)), 1e-4, 1e50);
                // Clamp to get rid of a visual artefact

                float F0 = ((_RefractiveIndex - 1) * (_RefractiveIndex - 1)) / ((_RefractiveIndex + 1) * (
                    _RefractiveIndex + 1));
                float F = F0 + (1 - F0) * pow(1 - clamp(dot(v, h), 0, 1), 5);

                float G1 = 2 * dot(h, n) * dot(n, v) / dot(v, h);
                float G2 = 2 * dot(h, n) * dot(n, l) / dot(v, h);
                float G = min(1, min(G1, G2));

                float specular = ((D * G * F) / (4 * dot(n, l)) * dot(n, v)) * _LightColor0;

                float3 ambientSH = ShadeSH9(float4(n, 1));
                fixed3 ambient = c * ambientSH;

                float3 result = saturate(lerp(L, specular, _Metallic));
                return float4(ambient + result * parallaxShadows, 1.0);
            }
            ENDHLSL
        }

        Pass
        {
            Name "ForwardAdd"

            Tags
            {
                "LightMode" = "ForwardAdd"
            }

            Cull Off // Disables back-face culling to ensure proper lighting on both sides
            Blend One One // Additive blending mode (adds this pass's lighting to the previous result)

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdadd_fullshadows // Enable full shadows and attenuation support for additional lights
            #pragma shader_feature USESTEEP
            #pragma shader_feature USESHADOWS
            #pragma shader_feature TRIMEDGES

            #include "UnityCG.cginc"
            #include "Parallax-Mapping.hlsl"
            #include "AutoLight.cginc"  // Includes light attenuation calculations

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
                LIGHTING_COORDS(5, 6)
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
            uniform float _LightRange;

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                half3 worldNormal = UnityObjectToWorldNormal(v.normal);
                half3 worldTangent = normalize(mul((float3x3)unity_ObjectToWorld, v.tangent));
                float3 worldBitangent = normalize(cross(worldNormal, worldTangent) * v.tangent.w);

                o.TBN = float3x3(worldTangent, worldBitangent, worldNormal);

                UNITY_TRANSFER_LIGHTING(o, v.vertex);
                return o;
            }

            float phi(float x, float y)
            {
                return atan2(y, x);
            }

            float3 calculateIrradiance(float3 l, float3 n)
            {
                return _LightColor0.rgb * saturate(dot(n, l));
            }

            float4 frag(v2f i) : SV_Target
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

                // Convert into tangent space
                half3 v_TS = normalize(mul(i.TBN, v));
                half3 l_TS = normalize(mul(i.TBN, l));

                float2 texCoords;
                float parallaxShadows;

                #ifdef USESTEEP
                texCoords = SteepParallaxMapping(_Height, i.uv, v_TS, _NumberOfLayers, _HeightScale);
                #else
                texCoords = ParallaxMapping(_Height, i.uv, v_TS, _HeightScale);
                #endif

                #ifdef USESHADOWS
                parallaxShadows = ParallaxShadow(_Height, texCoords, l_TS, _NumberOfLayers, _HeightScale);
                #else
                parallaxShadows = 1;
                #endif

                #ifdef TRIMEDGES
                if (texCoords.x > 1.0 || texCoords.y > 1.0 || texCoords.x < 0.0 || texCoords.y < 0.0)
                    discard;
                #endif

                half4 c = tex2D(_MainTex, texCoords) * _DiffuseColour;
                half3 normalMap = UnpackNormal(tex2D(_Normal, texCoords));
                normalMap.xy *= _NormalStrength;
                normalMap.z = sqrt(1.0 - saturate(dot(normalMap.xy, normalMap.xy))); // Re-normalize normal


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
                float C2 = cosPhi >= 0 ? 0.45 * (sigmaSqr / (sigmaSqr + 0.09)) * sin(alpha) : 0.45 * (sigmaSqr / (sigmaSqr + 0.09)) * (sin(alpha) - pow((2.0 * beta) / UNITY_PI, 3.0));
                float C3 = 0.125 * (sigmaSqr / (sigmaSqr + 0.09)) * pow((4.0 * alpha * beta) / (UNITY_PI * UNITY_PI), 2);

                float3 L1 = c * E0 * cos(theta_i) * (C1 + (C2 * cosPhi * tan(beta)) + (C3 * (1.0 - abs(cosPhi)) * tan((alpha + beta) / 2.0)));
                float3 L2 = 0.17 * (c * c) * E0 * cos(theta_i) * (sigmaSqr / (sigmaSqr + 0.13)) * (1.0 - cosPhi * pow((2.0 * beta) / UNITY_PI, 2.0));
                float3 L = saturate(L1 + L2);

                // Cook-Torrance: https://en.wikipedia.org/wiki/Specular_highlight#Cook–Torrance_model
                float NdotH = saturate(dot(n, h));
                float a = acos(NdotH);
                float m = clamp(sigmaSqr, 0.01, 1);
                float exponent = exp(-tan(a) * tan(a) / (m * m));
                float D = clamp(exponent / (UNITY_PI * m * m * pow(NdotH, 4)), 1e-4, 1e50); // Clamp to get rid of a visual artefact

                float F0 = ((_RefractiveIndex - 1) * (_RefractiveIndex - 1)) / ((_RefractiveIndex + 1) * (
                    _RefractiveIndex + 1));
                float F = F0 + (1 - F0) * pow(1 - clamp(dot(v, h), 0, 1), 5);

                float G1 = 2 * dot(h, n) * dot(n, v) / dot(v, h);
                float G2 = 2 * dot(h, n) * dot(n, l) / dot(v, h);
                float G = min(1, min(G1, G2));

                float specular = ((D * G * F) / (4 * dot(n, l)) * dot(n, v));

                float3 result = saturate(lerp(L, specular, _Metallic)) * parallaxShadows * atten;
                return float4(result, 1.0);
            }
            ENDHLSL
        }
    }
}