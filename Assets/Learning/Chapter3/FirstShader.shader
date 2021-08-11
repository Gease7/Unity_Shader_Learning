Shader "Shader-Learning/Chapter3/FirstShader"
{
    // 声明属性
    Properties
    {
        // 展示一个下拉列表
        [Enum(Normal,0,Tangent,1,Binomial,2)]_BasicSelection("Basic selection",float) = 0
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
            #pragma vertex vert
            #pragma fragment frag

            // 包含的文件
            #include "UnityCG.cginc"

            // 声明传递给顶点函数的结构体数据
            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
            };

            // 声明用于顶点函数和片元函数数据传递的结构体数据
            struct v2f
            {
                float4 pos : SV_POSITION;
                fixed3 color : COLOR0;
            };

            // 声明属性变量
            float _BasicSelection;
            fixed4 _BaseColor;

            // 顶点函数
            v2f vert (appdata v)
            {
                v2f o;
                // 将顶点坐标从模型空间变换到世界空间下
                o.pos = UnityObjectToClipPos(v.vertex);
                // 计算颜色
                // 在实际项目中，最好不用条件判断
                if (_BasicSelection == 0)
                    o.color = (v.normal * 0.5 + fixed3(0.5, 0.5, 0.5)) * _BaseColor;
                else if (_BasicSelection == 1)
                    o.color = (v.tangent.xyz * 0.5 + fixed3(0.5, 0.5, 0.5)) * _BaseColor;
                else{
                    fixed3 binormal = cross(v.normal, v.tangent.xyz) * v.tangent.w;
                    o.color = (binormal * 0.5 + fixed3(0.5, 0.5, 0.5)) * _BaseColor;
                }
                return o;
            }

            // 片元函数
            fixed4 frag (v2f i) : SV_Target
            {
                return fixed4(i.color, 1.0);    // 将颜色返回
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
}
