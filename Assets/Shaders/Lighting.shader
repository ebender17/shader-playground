Shader "Unlit/Lighting"
{
    Properties
    {
        _Color("Color", Color) = (1, 1, 1, 1)
        _Gloss("Gloss", Range(0, 1)) = 1
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
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            float4 _Color;
            float _Gloss;

            struct MeshData
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 wPos : TEXCOORD2;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                // diffuse lighting
                float3 N = normalize(i.normal);
                float3 L = _WorldSpaceLightPos0.xyz; // actually a direction
                float3 lambert = saturate(dot(N, L));
                float3 diffuseLight = lambert * _LightColor0.xyz;

                // specular lighting
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
                float3 H = normalize(L + V);
                float3 specularLight = saturate(dot(H, N)) * (lambert > 0); // blinn-pong
                float specularExponent = exp2(_Gloss * 11) + 2;
                specularLight = pow(specularLight, specularExponent) * _Gloss;
                specularLight *= _LightColor0.xyz;

                return float4(diffuseLight * _Color + specularLight, 1);
            }
            ENDCG
        }
    }
}
