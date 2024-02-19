Shader "Unlit/WavePattern"
{
    Properties
    {
        _Speed("Speed", Range(0, 0.1)) = 0.1
        _ColorA ("ColorA", Color) = (1, 1, 1, 1)
        _ColorB ("ColorB", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags { 
            "RenderType"="Transparent"
            "Queue"="Transparent"
        }

        Pass
        {
            ZWrite Off // Do not write to the depth buffer
            Blend One One // Additive blending
            Cull Off

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            #define TAU 6.2831853

            float _Speed;
            float4 _ColorA;
            float4 _ColorB;

            struct MeshData
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normals : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                o.uv = v.uv;
                o.normal = v.normals;
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float yOffset = cos(i.uv.x * TAU * 8) * 0.01;
                float value = cos((i.uv.y + yOffset - _Time.y * _Speed) * TAU * 5) * 0.5 + 0.5;
                value *= 1 - i.uv.y; // fade toward the top

                float topBottomRemover = (abs(i.normal.y) < 0.999);
                float waves = value * topBottomRemover;
                float4 gradient = lerp(_ColorA, _ColorB, i.uv.y);
                return gradient * waves;
            }
            ENDCG
        }
    }
}
