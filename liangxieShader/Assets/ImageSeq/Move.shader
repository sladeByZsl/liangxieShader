Shader "Custom/ImageSeq"
{
    Properties
    {
        [PerRendererData] _MainTex ("Sprite Texture", 2D) = "white" {}
        _Color ("Tint", Color) = (1,1,1,1)

        _StencilComp ("Stencil Comparison", Float) = 8
        _Stencil ("Stencil ID", Float) = 0
        _StencilOp ("Stencil Operation", Float) = 0
        _StencilWriteMask ("Stencil Write Mask", Float) = 255
        _StencilReadMask ("Stencil Read Mask", Float) = 255

        _ColorMask ("Color Mask", Float) = 15

        [Toggle(UNITY_UI_ALPHACLIP)] _UseUIAlphaClip ("Use Alpha Clip", Float) = 0

        [Toggle]_FlowLightEnabled("FlowLight Enabled",int)= 0
        _FlowLightColor("FlowLightColor",color) = (1,1,1,1)
        // _FlowLightTex("FlowLightTex",2D) = "white"{}
        _FlowLight("Speed(X) Width(Y) Alpha(Z) Angle(W)",vector) = (0.3,8,0.5,0.45)
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

        Stencil
        {
            Ref [_Stencil]
            Comp [_StencilComp]
            Pass [_StencilOp]
            ReadMask [_StencilReadMask]
            WriteMask [_StencilWriteMask]
        }

        Cull Off
        Lighting Off
        ZWrite Off
        ZTest [unity_GUIZTestMode]
        Blend SrcAlpha OneMinusSrcAlpha
        ColorMask [_ColorMask]

        Pass
        {
            Name "Default"
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 2.0

            #include "UnityCG.cginc"
            #include "UnityUI.cginc"

            #pragma multi_compile __ UNITY_UI_CLIP_RECT
            #pragma multi_compile __ UNITY_UI_ALPHACLIP
            #pragma shader_feature _ _FLOWLIGHTENABLED_ON

            struct appdata_t
            {
                float4 vertex   : POSITION;
                float4 color    : COLOR;
                float2 uv : TEXCOORD0;
                UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                fixed4 color    : COLOR;
                float4 uv  : TEXCOORD0;
                float4 worldPosition : TEXCOORD1;
            };

            sampler2D _MainTex;
            fixed4 _Color;
            fixed4 _TextureSampleAdd;
            float4 _ClipRect;
            float4 _MainTex_ST;
            fixed4 _FlowLightColor;
            float4 _FlowLight;

            v2f vert(appdata_t v)
            {
                v2f o;
                UNITY_SETUP_INSTANCE_ID(v);
                UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);
                o.worldPosition = v.vertex;
                o.vertex = UnityObjectToClipPos(o.worldPosition);

                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);
                //利用UV来做刷光，这里把UV独立开来，以免受主纹理的Tiling和Offset影响
                o.uv.zw = v.uv;

                o.color = v.color * _Color;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                half4 color = (tex2D(_MainTex, i.uv.xy) + _TextureSampleAdd) * i.color;

                #ifdef UNITY_UI_CLIP_RECT
                    color.a *= UnityGet2DClipping(i.worldPosition.xy, _ClipRect);
                #endif

                #ifdef UNITY_UI_ALPHACLIP
                    clip (color.a - 0.001);
                #endif

                #if _FLOWLIGHTENABLED_ON
                    float angle = lerp(1-i.uv.x,i.uv.y,_FlowLight.w);
                    //不断重复向一个方向刷光
                    float offset = sin(frac(angle+_Time.y*_FlowLight.x)*3-1.5)*2;
                    //斜线刷光形状
                    fixed4 light = pow(1-saturate(abs(i.uv.z-i.uv.w-offset)),_FlowLight.y);
                    light *= _FlowLightColor;
                    color +=light * color.a * _FlowLight.z;
                #endif

                return color;
            }
            ENDCG
        }
    }
}
