Shader "Unlit/Fresnel"
{
    Properties
    {
        _Color ("Color", Color) = (1, 1, 1, 1)
        _FresnelColor ("FresnelColor", Color) = (1, 1, 1, 1)
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

            float4 _Color;
            float4 _FresnelColor;

            struct MeshData
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
                float3 wPos : TEXCOORD2;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float3 N = normalize(i.normal);
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
                float fresnel = 1 - dot(V, N);
                float4 outColor = lerp(_Color, _FresnelColor, fresnel);
                return (outColor);
            }
            ENDCG
        }
    }
}
