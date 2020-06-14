Shader "Custom/outline"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        // 描边的颜色
        _OutlineColor("OutlineColor",Color) = (0,0,0,1)

        // 描边的宽度
        _OutlineWidth("OutlineWidth",Range(0,0.25)) = 0.01

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

            float _OutlineWidth;
            float4 _OutlineColor;

            fixed4 SampleSpriteTexture (float2 uv)
            {
                // 水平卷积核、竖直卷积核
                float offset = _OutlineWidth;

                // 左上
                half edgeX = tex2D (_MainTex, float2(uv.x - offset,uv.y - offset)).a * -1;
                // 上
                edgeX += tex2D(_MainTex,float2(uv.x,uv.y - offset)).a * 0;
                // 右上
                edgeX += tex2D(_MainTex,float2(uv.x + offset,uv.y + offset)).a * -1;
                // 左
                edgeX += tex2D(_MainTex,float2(uv.x - offset,uv.y)).a * -2;
                // 中
                edgeX += tex2D(_MainTex,float2(uv.x,uv.y)).a * 0;
                // 右
                edgeX += tex2D(_MainTex,float2(uv.x + offset,uv.y)).a * 2;
                // 左下
                edgeX += tex2D (_MainTex, float2(uv.x - offset,uv.y + offset)).a * 1;
                // 下
                edgeX += tex2D(_MainTex,float2(uv.x,uv.y + offset)).a * 0;
                // 右下
                edgeX += tex2D(_MainTex,float2(uv.x,uv.y - offset)).a * 1;


                // 左上
                half edgeY = tex2D (_MainTex, float2(uv.x - offset,uv.y - offset)).a * -1;
                // 上
                edgeY += tex2D(_MainTex,float2(uv.x,uv.y - offset)).a * -2;
                // 右上
                edgeY += tex2D(_MainTex,float2(uv.x + offset,uv.y + offset)).a * -1;
                // 左
                edgeY += tex2D(_MainTex,float2(uv.x - offset,uv.y)).a * 0;
                // 中
                edgeY += tex2D(_MainTex,float2(uv.x,uv.y)).a * 0;
                // 右
                edgeY += tex2D(_MainTex,float2(uv.x + offset,uv.y)).a * 0;
                // 左下
                edgeY += tex2D(_MainTex, float2(uv.x - offset,uv.y + offset)).a * 1;
                // 下
                edgeY += tex2D(_MainTex,float2(uv.x,uv.y + offset)).a * 2;
                // 右下
                edgeY += tex2D(_MainTex,float2(uv.x,uv.y - offset)).a * 1;

                half edge = abs(edgeX) + abs(edgeY);

#if UNITY_TEXTURE_ALPHASPLIT_ALLOWED
                if (_AlphaSplitEnabled)
                    color.a = tex2D (_AlphaTex, uv).r;
#endif //UNITY_TEXTURE_ALPHASPLIT_ALLOWED

                float4 texColor = tex2D(_MainTex,uv);

                return lerp(texColor,_OutlineColor,edge);
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
