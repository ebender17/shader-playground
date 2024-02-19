Shader "Unlit/WorldSpace"
{
    Properties
    {
        _GrassTex ("Texture", 2D) = "white" {}
        _DirtTex ("Texture", 2D) = "white" {}
        _Pattern ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
            };

            sampler2D _GrassTex;
            float4 _GrassTex_ST;
            
            sampler2D _Pattern;
            sampler2D _DirtTex;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.worldPos = mul(UNITY_MATRIX_M, v.vertex); // object to world
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _GrassTex);
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float2 topDownProjection = i.worldPos.xz;
                fixed4 grass = tex2D(_GrassTex, topDownProjection);
                fixed4 dirt = tex2D(_DirtTex, topDownProjection);
                fixed4 pattern = tex2D(_Pattern, i.uv).x;

                float4 finalColor = lerp(grass, dirt, pattern);
                return finalColor;
            }
            ENDCG
        }
    }
}
