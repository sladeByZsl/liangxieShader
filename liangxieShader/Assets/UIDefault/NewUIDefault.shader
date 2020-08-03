Shader "Custom/NewUIDefaultShader"
{
    Properties
    {
        [PerRendererData]_MainTex ("Texture", 2D) = "white" {}
        _Ref("Stencil Ref",int) = 0
        [Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("Stencil Comp",int) = 0
        [Enum(UnityEngine.Rendering.StencilOp)]_StencilOp("Stencil OP",int) = 0
        _ColorMask("ColorMask",int) = 15


        /* Flowlight */
        _FlowlightColor("Flowlight Color", Color) = (1, 0, 0, 1)
        _Lengthlitandlar("LangthofLittle and Large", range(0,0.5)) = 0.005
        _MoveSpeed("MoveSpeed", float) = 5
        _Power("Power", float) = 1
        _LargeWidth("LargeWidth", range(0,0.005)) = 0.0035
        _LittleWidth("LittleWidth", range(0,0.001)) = 0.002
        _WidthRate("WidthRate",float) = 0
        _XOffset("XOffset",float) = 0
        _HeightRate("HeightRate",float) = 0
        _YOffset("YOffset",float) = 0

        [Toggle]_GrayEnabled("Gray Enabled",int) = 0
    }
    SubShader
    {
        Tags { "Queue"="Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Stencil
        {

            Ref [_Ref]
            Comp [_StencilComp]
            Pass [_StencilOp]
        }
        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma multi_compile _ _GRAYENABLED_ON
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                fixed4 color : COLOR;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Power;
            float _LargeWidth;
            float _LittleWidth;
            float _Lengthlitandlar;
            float _MoveSpeed;
            fixed4 _FlowlightColor;
            float _UVPosX;
            float _WidthRate;
            float _XOffset;
            float _HeightRate;
            float _YOffset;


            v2f vert (appdata v)    
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.color = v.color;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 c;
                fixed4 col = tex2D(_MainTex, i.uv);
                c = col;
                c *= i.color;

                #if _GRAYENABLED_ON
                    c.rgb = Luminance(c);
                #endif

                /* Flowlight */
                //计算流动的标准uvX从-0.5到1.5范围
                _UVPosX = _XOffset +(fmod(_Time.x*_MoveSpeed, 1) * 2 -0.5)* _WidthRate;
                //标准uvX倾斜
                _UVPosX += (i.uv.y- _HeightRate*0.5- _YOffset)*0.2;
                //以下是计算流光在区域内的强度，根据到标准点的距离的来确定强度，为了使变化更柔和非线性，使用距离平方或者sin函数也可以
                float lar = pow(1 - _LargeWidth*_WidthRate, 2);
                float lit = pow(1 - _LittleWidth*_WidthRate, 2);
                //第一道流光，可以累加任意条，如下
                fixed4 cadd = _FlowlightColor* saturate((1 - saturate(pow(_UVPosX - i.uv.x,2))) - lar)*_Power /(1-lar);
                cadd += _FlowlightColor* saturate((1 - saturate(pow(_UVPosX - _Lengthlitandlar*_WidthRate - i.uv.x, 2))) - lit)*_Power/ (1-lit);

                c.rgb += cadd.rgb;
                c.rgb *= c.a;

                return c;
            }
            ENDCG
        }
    }
}