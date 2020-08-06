Shader "Custom/MyFirstLight"
{
	Properties{
		_Tint("Tint", Color) = (1, 1, 1, 1)
		_MainTex("Texture", 2D) = "white" {}
		_Smoothness("Smoothness", Range(0, 1)) = 0.5
			_SpecularTint("Specular", Color) = (0.5, 0.5, 0.5)
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
				float _Smoothness;
				float4 _SpecularTint;

				struct appdata {
					float4 position : POSITION;
					float3 normal : NORMAL;
					float2 uv : TEXCOORD0;
					
				};

				struct v2f {
					float4 position : SV_POSITION;
					float2 uv : TEXCOORD0;
					float3 normal : TEXCOORD1;
					float3 worldPos : TEXCOORD2;
				};

				v2f vert(appdata v) {
					v2f i;
					i.position = UnityObjectToClipPos(v.position);
					i.worldPos = mul(unity_ObjectToWorld, v.position);
					i.normal = UnityObjectToWorldNormal(v.normal);
					i.uv = TRANSFORM_TEX(v.uv, _MainTex);
					return i;
				}

				float4 frag(v2f i) : SV_TARGET {
					i.normal = normalize(i.normal);
					float3 lightDir = _WorldSpaceLightPos0.xyz;
					float3 viewDir = normalize(_WorldSpaceCameraPos-i.worldPos);
					//float3 reflectionDir = reflect(-lightDir,i.normal);
					float3 reflectionDir = normalize(lightDir + viewDir);
					float3 lightColor = _LightColor0.rgb;
					float3 albedo = tex2D(_MainTex, i.uv).rgb * _Tint.rgb;
					float3 diffuse = albedo * lightColor * DotClamped(lightDir, i.normal);
					float3 specular = _SpecularTint.rgb * lightColor * pow(
						DotClamped(reflectionDir, i.normal),
						_Smoothness * 100
					);
					return float4(diffuse +specular,1);
				}

				ENDCG
			}
	}
}
