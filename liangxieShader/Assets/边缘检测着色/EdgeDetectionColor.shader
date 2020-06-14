Shader "Custom/EdgeDetectionColor"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        //边缘检测的精细度
        _EdgeFactor("EdgeFactor",Range(0,0.25)) = 0.01

        //边缘颜色
        _EdgeColor("EdgeColor",Color) = (0,0,0,1)

        //背景颜色 
        _BgColor("BgColor",Color) = (1,1,1,1)

        // 显示背景还是贴图  
        _BgFactor("BgFactor",Range(0,1)) = 1

        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
    }

    SubShader
    {
        Tags
        { 
            "Queue"="Transparent" 
            "IgnoreProjector"="True" 
            "RenderType"="Transparent" 
            "PreviewType"="Plane"
            "CanUseSpriteAtlas"="True"
        }

        Cull Off
        Lighting Off
        ZWrite Off
        Blend One OneMinusSrcAlpha

        Pass
        {
        CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile _ PIXELSNAP_ON
            #include "UnityCG.cginc"

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float2 texcoord  : TEXCOORD0;
            };

            fixed4 _Color;

            v2f vert(appdata_t IN)
            {
                v2f OUT;
                OUT.vertex = UnityObjectToClipPos(IN.vertex);
                OUT.texcoord = IN.texcoord;
                OUT.color = IN.color * _Color;
                #ifdef PIXELSNAP_ON
                OUT.vertex = UnityPixelSnap (OUT.vertex);
                #endif

                return OUT;
            }

            sampler2D _MainTex;
            sampler2D _AlphaTex;
            float _AlphaSplitEnabled;


            // 亮度
            fixed l(fixed4 color)
            {
                return  0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b; 
            }

            float _EdgeFactor;

            float4 _BgColor;
            float4 _EdgeColor;
            float _BgFactor;


            fixed4 SampleSpriteTexture (float2 uv)
            {
                // 水平卷积核、竖直卷积核
                float offset = _EdgeFactor;

                // 左上
                half edgeX = l(tex2D (_MainTex, float2(uv.x - offset,uv.y - offset))) * -1;
                // 上
                edgeX += l(tex2D(_MainTex,float2(uv.x,uv.y - offset))) * 0;
                // 右上
                edgeX += l(tex2D(_MainTex,float2(uv.x + offset,uv.y + offset))) * -1;
                // 左
                edgeX += l(tex2D(_MainTex,float2(uv.x - offset,uv.y))) * -2;
                // 中
                edgeX += l(tex2D(_MainTex,float2(uv.x,uv.y))) * 0;
                // 右
                edgeX += l(tex2D(_MainTex,float2(uv.x + offset,uv.y))) * 2;
                // 左下
                edgeX += l(tex2D (_MainTex, float2(uv.x - offset,uv.y + offset))) * 1;
                // 下
                edgeX += l(tex2D(_MainTex,float2(uv.x,uv.y + offset))) * 0;
                // 右下
                edgeX += l(tex2D(_MainTex,float2(uv.x,uv.y - offset))) * 1;


                // 左上
                half edgeY = l(tex2D (_MainTex, float2(uv.x - offset,uv.y - offset))) * -1;
                // 上
                edgeY += l(tex2D(_MainTex,float2(uv.x,uv.y - offset))) * -2;
                // 右上
                edgeY += l(tex2D(_MainTex,float2(uv.x + offset,uv.y + offset))) * -1;
                // 左
                edgeY += l(tex2D(_MainTex,float2(uv.x - offset,uv.y))) * 0;
                // 中
                edgeY += l(tex2D(_MainTex,float2(uv.x,uv.y))) * 0;
                // 右
                edgeY += l(tex2D(_MainTex,float2(uv.x + offset,uv.y))) * 0;
                // 左下
                edgeY += l(tex2D (_MainTex, float2(uv.x - offset,uv.y + offset))) * 1;
                // 下
                edgeY += l(tex2D(_MainTex,float2(uv.x,uv.y + offset))) * 2;
                // 右下
                edgeY += l(tex2D(_MainTex,float2(uv.x,uv.y - offset))) * 1;

                half edge = abs(edgeX) + abs(edgeY);

#if UNITY_TEXTURE_ALPHASPLIT_ALLOWED
                if (_AlphaSplitEnabled)
                    color.a = tex2D (_AlphaTex, uv).r;
#endif //UNITY_TEXTURE_ALPHASPLIT_ALLOWED

                float4 texColor = tex2D(_MainTex,uv);

                float4 bgColor = lerp(texColor,_BgColor,_BgFactor);

                return lerp(bgColor,_EdgeColor,edge);
            }



            fixed4 frag(v2f IN) : SV_Target
            {
                fixed4 c = SampleSpriteTexture (IN.texcoord) * IN.color;
                c.rgb *= c.a;
                return c;
            }
        ENDCG
        }
    }
}
