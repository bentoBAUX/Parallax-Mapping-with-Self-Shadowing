Shader "bentoBAUX/DottedLine"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _DotSpacing ("Dot Spacing (World)", Float) = 0.5
        _DotSize ("Dot Size", Float) = 0.3
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent" }
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite Off
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata_t
            {
                float4 vertex : POSITION;
                float3 uv : TEXCOORD1; // Store world position
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float uv : TEXCOORD0;
            };

            float4 _Color;
            float _DotSpacing;
            float _DotSize;

            v2f vert(appdata_t v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv = v.uv;

                return o;
            }

            half4 frag(v2f i) : SV_Target
            {
                // Repeat the pattern based on world space distance
                float pattern = frac(i.uv / _DotSpacing);

                // If pattern is outside the "dot size" threshold, discard pixel
                if (pattern > _DotSize) discard;

                return _Color; // Render dot
            }
            ENDCG
        }
    }
}
