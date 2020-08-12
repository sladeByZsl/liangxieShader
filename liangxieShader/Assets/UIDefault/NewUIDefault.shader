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
        _MoveSpeed("MoveSpeed", float) = 5
        _Power("Power", float) = 1

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
            float _MoveSpeed;
            fixed4 _FlowlightColor;


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

                
                
                c.rgb *= c.a;
                c.rgb +=_FlowlightColor;

                return c;
            }
            ENDCG
        }
    }
}