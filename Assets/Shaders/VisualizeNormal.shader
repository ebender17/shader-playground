Shader "Unlit/VisualizeNormal"
{
    Properties
    {
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

            float _Value;

            struct MeshData
            {
                float4 vertex : POSITION;
                float3 normals : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD0;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                // o.normal = v.normals;
                // o.normal = UnityObjectToWorldNormal(v.normals); // convert to world space
                o.normal = mul((float3x3)unity_ObjectToWorld, v.normals); // convert to world space, same as above
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                return float4(saturate(i.normal), 1);
            }
            ENDCG
        }
    }
}
