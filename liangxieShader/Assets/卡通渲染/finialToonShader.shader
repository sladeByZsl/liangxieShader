Shader "CustomShader/finialToonShader"
{
    Properties
    {
        _Diffuse("Diffuse",Color) = (1,1,1,1)
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            Cull Front
            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float3 worldNormal:TEXCOORD0;
                float4 pos: SV_POSITION; 
            };

            float4 _Diffuse; 

            v2f vert (appdata v)
            {    
                v2f o;

                // 获取法线
                float3 normal = v.normal;

                // 顶点加 0.0.2 倍的法线
                v.vertex.xyz += normal * 0.02;

                // 转换坐标到
                o.pos = UnityObjectToClipPos(v.vertex);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {    
                return fixed4(0,0,0,1);
            }
            ENDCG
        }

        Pass
        {
            Tags { "LightMode" = "ForwardBase"}
            Cull Back

            CGPROGRAM

            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float3 worldNormal:TEXCOORD0;
                float4 pos: SV_POSITION; 
            };

            float4 _Diffuse; 

            v2f vert (appdata v)
            {    
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                // 表面法线                
                o.worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // 顶点到光源方向                
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);

                float NdotL = 0.5 + 0.5 * dot(i.worldNormal, worldLight);

                if (NdotL > 0.9)
                {
                    NdotL = 1;
                } 
                else if (NdotL > 0.5)
                {
                    NdotL = 0.6;
                } 
                else if (NdotL > 0.2)
                {
                    NdotL = 0.3;
                } 
                else 
                {
                    NdotL = 0.1;
                }

                // Cdiffuse = (Clight * Mdiffuse)max(0,N^*L^)
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * NdotL;

                return fixed4(ambient + diffuse,1.0);
            }
            ENDCG
        }
    }
}