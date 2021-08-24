Shader "Shader-Learning/Chapter3/FirstShader"
{
    // 声明属性
    Properties
    {
        // 将一个Float值声明为一个下拉列表，下拉列表有3个字选项，他们的值分别为0,1,2
        [Enum(Normal,0,Tangent,1,Binomial,2)]_BasicSelection("Basic selection", Float) = 0
        // 声明一个基础颜色
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)

    }

    // 子着色器
    SubShader
    {
        // 标签，用于设定如何渲染对象
        Tags{"LightMode" = "ForwardBase"}

        // 渲染的主要实现
        Pass
        {
            // CG片段
            CGPROGRAM
            // 定义两个着色器函数的名字
            // 将顶点函数的名字命名为vert
            #pragma vertex vert
            // 将片元函数的名字命名为frag
            #pragma fragment frag

            // 包含的文件
            #include "UnityCG.cginc"

            // 声明传递给顶点函数的结构体数据
            struct a2v
            {
                // 获取模型的顶点坐标
                float4 vertex : POSITION;
                // 获取模型顶点的法线坐标
                float3 normal : NORMAL;
                // 获取模型顶点的切线坐标
                float4 tangent : TANGENT;
            };

            // 声明用于顶点函数和片元函数数据传递的结构体数据
            struct v2f
            {
                // 用来储存已经变换到裁剪空间中的顶点坐标
                float4 pos : SV_POSITION;
                // 用来存储顶点的颜色
                fixed3 color : COLOR0;
            };

            // 声明属性变量
            float _BasicSelection;
            fixed4 _BaseColor;

            // 顶点函数
            v2f vert (a2v v)
            {
                v2f o;
                // 将顶点坐标从模型空间变换到世界空间下
                o.pos = UnityObjectToClipPos(v.vertex);

                // 计算颜色
                // 在实际项目中，最好不使用条件判断，具体的原因之后的文章中会提到
                if (_BasicSelection == 0)
                    // 通过获取的模型顶点的法线坐标计算顶点的颜色
                    o.color = (v.normal * 0.5 + fixed3(0.5, 0.5, 0.5)) * _BaseColor;
                else if (_BasicSelection == 1)
                    // 通过获取的模型顶点的切线坐标计算顶点的颜色
                    o.color = (v.tangent.xyz * 0.5 + fixed3(0.5, 0.5, 0.5)) * _BaseColor;
                else{
                    // 通过模型顶点的法线坐标和切线坐标计算副切线，这个概念之后会细说
                    // 通过副切线计算模型顶点的颜色
                    fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                    o.color = (binormal * 0.5 + fixed3(0.5, 0.5, 0.5)) * _BaseColor;
                }
                return o;
            }

            // 片元函数
            fixed4 frag (v2f i) : SV_Target
            {
                // 将像素的颜色返回
                return fixed4(i.color, 1.0);
            }
            ENDCG
        }
    }
    // 如果上面的所有SubShader都不管用，将使用内置的Diffuse.Shader
    FallBack "Diffuse"
}
