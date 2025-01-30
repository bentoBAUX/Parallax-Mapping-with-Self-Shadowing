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
            Tags
            {
                "LightMode"="ForwardBase"
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

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

            v2f vert(appdata vx)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(vx.vertex);
                o.worldPos = mul(unity_ObjectToWorld, vx.vertex).xyz;

                o.uv = vx.uv * _MainTex_ST.xy + _MainTex_ST.zw;
                half3 worldNormal = UnityObjectToWorldNormal(vx.normal);
                half3 worldTangent = mul((float3x3)unity_ObjectToWorld, vx.tangent);

                half3 bitangent = cross(worldNormal, worldTangent);
                half3 worldBitangent = mul((float3x3)unity_ObjectToWorld, bitangent);

                o.TBN = float3x3(worldTangent, worldBitangent, worldNormal);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half3 v = normalize(_WorldSpaceCameraPos - i.worldPos);
                float2 texCoords = SteepParallaxMapping(_Height,i.uv, float3(-v.x, -v.z, v.y), _NumberOfLayers, _HeightScale);
                
                // Blinn Phong
                half4 c = tex2D(_MainTex, texCoords) * _DiffuseColour;
                half3 normalMap = UnpackNormal(tex2D(_Normal, texCoords));
                normalMap.xy *= _NormalStrength;

                half3 n = normalize(mul(transpose(i.TBN), normalMap));
                half3 l = normalize(_WorldSpaceLightPos0.xyz);
                half3 h = normalize(l + v);

                float Ia = _k.x;
                float Id = _k.y * saturate(dot(n, l));
                float Is = _k.z * pow(saturate(dot(h, n)), _SpecularExponent);

                float3 skyboxColor = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, float3(0,1,0)).rgb;

                float3 ambient = Ia * c * (UNITY_LIGHTMODEL_AMBIENT + skyboxColor * 0.2);
                float3 diffuse = Id * c * _LightColor0.rgb;
                float3 specular = Is * _LightColor0.rgb;

                float3 finalColor = ambient + diffuse + specular;

                i.color = fixed4(finalColor, 1.0);

                return i.color;
            }
            ENDCG

        }
    }
}