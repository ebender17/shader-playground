Shader "Unlit/VertexOffset"
{
    Properties
    {
        _Speed("Speed", Range(0, 0.1)) = 0.1
        _WaveAmpltiude ("Wave Amplitude", Range(0, 0.2)) = 0.2
    }
    SubShader
    {
        Tags { 
            "RenderType"="Opaque"
            "Queue"="Geometry"
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.2831853

            float _Speed;
            float _WaveAmpltiude;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv0 : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                float wave = cos((v.uv0.y - _Time.y * _Speed) * TAU * 5);
                float wave2 = cos((v.uv0.x - _Time.y * _Speed) * TAU * 5);
                v.vertex.y = wave * wave2 * _WaveAmpltiude;
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                o.uv = v.uv0;
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                return float4(i.uv.xxx, 1);
            }
            ENDCG
        }
    }
}
