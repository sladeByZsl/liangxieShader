Shader "Custom/MyFirstLight"
{
	Properties{
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Texture", 2D) = "white" {}
	}

		SubShader{

			Pass {
				Tags {
					"LightMode" = "ForwardBase"
				}

				CGPROGRAM

				#pragma vertex vert
				#pragma fragment frag

				#include "UnityStandardBRDF.cginc"

				float4 _Tint;
				sampler2D _MainTex;
				float4 _MainTex_ST;

				struct appdata {
					float4 position : POSITION;
					float3 normal : NORMAL;
					float2 uv : TEXCOORD0;
				};

				struct v2f {
					float4 position : SV_POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : TEXCOORD1;
				};

				v2f vert(appdata v) {
					v2f i;
					i.position = UnityObjectToClipPos(v.position);
					i.normal = UnityObjectToWorldNormal(v.normal);
					i.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return i;
				}

				float4 frag(v2f i) : SV_TARGET {
					i.normal = normalize(i.normal);
					float3 lightDir = _WorldSpaceLightPos0.xyz;
					float3 lightColor = _LightColor0.rgb;
					float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
					float3 diffuse = albedo * lightColor * DotClamped(lightDir, i.normal);
					return float4(diffuse, 1);
				}

				ENDCG
			}
	}
}
