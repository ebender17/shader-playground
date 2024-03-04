Shader "Unlit/HealthBar"
{
    Properties
    {
        [NoScaleOffset] _MainTex ("Texture", 2D) = "white" {}
        _Health("Health", Range(0, 1)) = 0.5
        _BorderSize("Border Size", Range(0, 0.5)) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Health;
            float _BorderSize;

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv, _MainTex;
                return o;
            }

            float InverseLerp(float a, float b, float v)
            {
                return (v-a)/(b-a);
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                // rounded corner clipping
                float2 transformedCoords = i.uv;
                transformedCoords.x *= 8;
                float2 pointOnLineSegment = float2(clamp(transformedCoords.x, 0.5, 7.5), 0.5);
                float sdf = distance(transformedCoords, pointOnLineSegment) * 2 - 1;
                clip(-sdf);

                // border
                float borderSDF = sdf + _BorderSize;
                float partialDerivative = fwidth(borderSDF);
                float borderMask = 1 - saturate(borderSDF/partialDerivative);

                // sample the texture
                float healthbarMask = _Health > i.uv.x;
                float3 healthbarColor = tex2D(_MainTex, float2(_Health, i.uv.y));

                if(_Health < 0.2)
                {
                    float flash = cos(_Time.y * 4) * 0.4 + 1; // goes from 0.9 to 1.1
                    healthbarColor *= flash;
                }

                return float4(healthbarColor * healthbarMask * borderMask, 1);
            }
            ENDCG
        }
    }
}
