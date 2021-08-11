Shader "Shader-Learning/Chapter5/NormalMapTangentSpace"
{
    Properties
    {
        _MainTex ("Main Texture", 2D) = "white" {}
        // 声明法线纹理
        _BumpMap ("Normal Texture", 2D) = "bump" {}
        // 声明凹凸系数
        _BumpScale ("Bump Scale", Float) = 1.0
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular", Color) = (1, 1, 1, 1)
        _Gloss ("Gloss", Range(8, 256)) = 20
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags {"LightMode" = "ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Lighting.cginc"
            #include "UnityCG.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 tangent : TANGENT;
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 uv : TEXCOORD0;
                float3 lightDir : TEXCOORD1;
                float3 viewDir : TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _BaseColor;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // 为减少插值寄存器的使用数目，使用一个纹理坐标的不同通道
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                // // 计算副切线，v.tangent.w存储的是副切线的方向
                // float3 binormal = cross(normalize(v.normal), normalize(v.tangent.xyz)) * v.tangent.w;
                // // 构建从模型空间到切线空间的变换矩阵
                // float3x3 rotation = float3x3(v.tangent.xyz, binormal, v.normal);

                // 使用内置宏完成上面的计算
                TANGENT_SPACE_ROTATION;

                // 计算切线空间下的光线向量和视角向量
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);

                // 通过对法线贴图进行采样
                fixed4 packedNormal = tex2D(_BumpMap, i.uv.zw);
                fixed3 tangentNormal;

                // 如果贴图没有设置为"Normal Map"类型，需要进行手动反映射
                // tangentNormal = (packedNormal.xyz*2-1);

                // 如果贴图已经设置为"Normal Map"类型，使用内置函数
                tangentNormal = UnpackNormal(packedNormal);
                // 乘以凹凸度系数，控制凹凸的效果
                tangentNormal.xy *= _BumpScale;
                // 计算tangentNormal.z分量，因为Unity对法线纹理进行了压缩，z分量的信息丢掉了，无法提取，需要单独计算
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _BaseColor.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
