Shader "Custom/Blur"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)
        [MaterialToggle] PixelSnap ("Pixel snap", Float) = 0
        //模糊程度
        _Blur("Blur",Range(0,1)) = 0.01
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
            float _Blur;

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

            // 声明与 Properties 同名变量（自动接收 Proeprty 值）
            float _GrayFactor;

            fixed4 SampleSpriteTexture (float2 uv)
            {
                fixed4 color = tex2D (_MainTex, uv);
                //1/16,如果不除这个数就会有点重影
                //因为 _Blur 范围为 0 ~ 1，_Blur 实际上是 uv 的偏移值，而 uv 的偏移范围也是从 0 ~ 1，只是为了获取相邻像素而做的偏移没必要大到 0 ~ 1。只要偏移值的范围控制在 0 ~ 0.1 左右即可
                float distance = _Blur * 0.0625f;
                fixed4 leftColor = tex2D(_MainTex,float2(uv.x - distance,uv.y));
                fixed4 rightColor = tex2D(_MainTex,float2(uv.x + distance,uv.y));
                fixed4 topColor = tex2D(_MainTex,float2(uv.x,uv.y + distance));
                fixed4 bottomColor = tex2D(_MainTex,float2(uv.x,uv.y - distance));

                 // 求和
                color = color * 4 + leftColor + rightColor + topColor + bottomColor;
                //系数加一起必须是1
                color = color * 0.125;

#if UNITY_TEXTURE_ALPHASPLIT_ALLOWED
                if (_AlphaSplitEnabled)
                    color.a = tex2D (_AlphaTex, uv).r;
#endif //UNITY_TEXTURE_ALPHASPLIT_ALLOWED

                return color;
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
