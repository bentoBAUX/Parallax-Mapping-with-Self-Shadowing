Shader "bentoBAUX/Reactive Line Shader"
{
    Properties
    {
        _ColorBefore ("Before Collision Color", Color) = (1,1,1,1) // White
        _ColorAfter ("After Collision Color", Color) = (1,1,0,1) // Yellow
        _SurfaceHitUV ("Surface Hit Fraction", Range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata_t
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            float4 _ColorBefore;
            float4 _ColorAfter;
            float _SurfaceHitUV; // Where the first hit happens

            v2f vert (appdata_t v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // Check if the current point is before or after the first hit
                return (i.uv.x < _SurfaceHitUV) ? _ColorBefore : _ColorAfter;
            }
            ENDCG
        }
    }
}
