Shader "Custom/MyLight"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_Diffuse("Diffuse", Color) = (1, 1, 1, 1)
		_Specular("Specular",Color) = (1,1,1,1)
		_Gloss ("Gloss",Range(8,256)) = 20
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

            struct appdata
            {
                float4 position : POSITION;
                float2 uv : TEXCOORD0;
				float3 normal:NORMAL;
            };

            struct v2f
            {
				float4 position : SV_POSITION;
                float2 uv : TEXCOORD0;
				float3 normal : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
			fixed4 _Diffuse;
			fixed4 _Specular;
			float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.position = UnityObjectToClipPos(v.position);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				o.worldPos= mul(unity_ObjectToWorld, v.position);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT;
				fixed3 worldLightDir = normalize(_WorldSpaceLightPos0.xyz);
				fixed3 worldNormal = normalize(i.normal);

				fixed3 viewDir = normalize(_WorldSpaceCameraPos.xyz-i.worldPos.xyz);
				fixed3 halfDir = normalize(worldLightDir+viewDir);
				fixed3 specular = _LightColor0.rgb*_Specular.rgb*pow(saturate(dot(worldNormal, halfDir)), _Gloss);

				//fixed4 halfLambert= 0.5*dot(worldNormal, worldLightDir) + 0.5;
				fixed4 halfLambert = dot(worldNormal,worldLightDir);
				fixed3 diffuse = _LightColor0.rgb*_Diffuse.rgb*halfLambert*tex2D(_MainTex, i.uv).rgb;

                fixed3 col = diffuse+ ambient+ specular;
				return fixed4(col.rgb, 1);
            }
            ENDCG
        }
    }
}
