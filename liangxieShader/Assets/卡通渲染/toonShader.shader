Shader "CustomShader/toonShader"    
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
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float4 pos: SV_POSITION; 
                float3 color : Color;
            };

            float4 _Diffuse;

            v2f vert (appdata v)
            {
                v2f o;

                o.pos = UnityObjectToClipPos(v.vertex);

                // 环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;
                // 表面法线
                fixed3 worldNormal = normalize(mul(v.normal,(float3x3)unity_WorldToObject));
                // 顶点到光源方向  
                fixed3 worldLight = normalize(_WorldSpaceLightPos0.xyz);


                //_LightColor0.rgb 对应 C light
                //_Diffuse.rgb 对应 M diffuse
                //max(0,n^*l^) 对应 saturate(dot(worldNormal,worldLight))
                //Cdiffuse = (Clight * Mdiffuse)max(0,N^*L^)
                //而余弦值的范围为 -1 到 1，所以 saturate 方法截取掉了 -1 到 0 的部分
                //fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLight));

                //***********************此处是狗啃了的顶点卡通渲染

                float NdotL=0.5+0.5*dot(worldNormal,worldLight);
                /*if(NdotL>0.9)
                {
                    NdotL=1;
                }
                else if(NdotL>0.5)
                {
                    NdotL=0.6;
                }
                else
                {
                    NdotL=0;
                }*/
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * NdotL;

                o.color = ambient + diffuse;

                return o;
            }


            float4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color,1.0);
            }
            ENDCG
        }
    
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

                // 转换坐标到裁剪坐标
                o.pos = UnityObjectToClipPos(v.vertex);

                return o;
            }

            float4 frag (v2f i) : SV_Target
            {    
                return fixed4(0,0,0,1);
            }
            ENDCG
        }
    }
}
