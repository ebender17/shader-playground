Shader "Unlit/Ripple"
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
            
            float GetWave(float2 uv)
            {
                float2 uvsCentered = uv * 2 - 1; // range of -1 to 1
                float radialDistance = length(uvsCentered);
                float wave = cos((radialDistance - _Time.y * _Speed) * TAU * 5) * 0.5 + 0.5;
                wave *= 1 - radialDistance; // fade towards the edges
                return wave;
            }

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                v.vertex.y = GetWave(v.uv0);
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                o.uv = v.uv0;
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                return GetWave(i.uv);
            }
            ENDCG
        }
    }
}
