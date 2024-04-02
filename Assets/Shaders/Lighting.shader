Shader "Unlit/Lighting"
{
    Properties
    {
        _Albedo("Albedo", 2D) = "white" {}
        [NoScaleOffset] _NormalMap("NormalMap", 2D) = "bump" {}
        _NormalIntensity("Normal Intensity", Range(0, 0.2)) = 0.1
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

            sampler2D _Albedo;
            sampler2D _NormalMap;
            float _NormalIntensity;
            float4 _Albedo_ST;
            float4 _Color;
            float _Gloss;

            struct MeshData
            {
                float4 vertex : POSITION;
                float4 normal : NORMAL;
                float4 tangent : TANGENT; // xyz = tangent direction, w = tangent sign
                float2 uv : TEXCOORD0;
            };

            struct Interpolators
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float3 tangent : TEXCOORD2;
                float3 bitangent : TEXCOORD3;
                float3 wPos : TEXCOORD4;
            };

            Interpolators vert (MeshData v)
            {
                Interpolators o;
                o.vertex = UnityObjectToClipPos(v.vertex); // local space to clip space
                o.uv = TRANSFORM_TEX(v.uv, _Albedo);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.tangent = UnityObjectToWorldDir(v.tangent.xyz);
                o.bitangent = cross(o.normal, o.tangent);
                o.bitangent *= v.tangent.w * unity_WorldTransformParams.w; // correctly handle flipping/mirroring
                o.wPos = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target
            {
                float3 albedo = tex2D(_Albedo, i.uv).rgb;
                float3 surfaceColor = albedo * _Color.rgb;

                float3 tangentSpaceNormal = UnpackNormal(tex2D(_NormalMap, i.uv));
                tangentSpaceNormal = normalize(lerp(float3(0, 0, 1), tangentSpaceNormal, _NormalIntensity));

                float3x3 mtxTangentToWorld = {
                    i.tangent.x, i.bitangent.x, i.normal.x,
                    i.tangent.y, i.bitangent.y, i.normal.y,
                    i.tangent.z, i.bitangent.z, i.normal.z,
                };
                float3 worldSpaceNormal = mul(mtxTangentToWorld, tangentSpaceNormal);
                
                // diffuse lighting
                // float3 N = normalize(i.normal);
                float3 L = _WorldSpaceLightPos0.xyz; // actually a direction
                float3 lambert = saturate(dot(worldSpaceNormal, L));
                float3 diffuseLight = lambert * _LightColor0.xyz;

                // specular lighting
                float3 V = normalize(_WorldSpaceCameraPos - i.wPos);
                float3 H = normalize(L + V);
                float3 specularLight = saturate(dot(H, worldSpaceNormal)) * (lambert > 0); // blinn-pong
                float specularExponent = exp2(_Gloss * 11) + 2;
                specularLight = pow(specularLight, specularExponent) * _Gloss;
                specularLight *= _LightColor0.xyz;

                return float4(diffuseLight * surfaceColor + specularLight, 1);
            }
            ENDCG
        }
    }
}
