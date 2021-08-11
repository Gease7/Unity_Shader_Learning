Shader "Shader-Learning/Chapter4/BlinnPhong"
{
    Properties
    {
        _Diffuse("Diffuse Color", Color) = (1, 1, 1, 1)     // 反射的颜色
        _Specular("Specular Color", Color) = (1, 1, 1, 1)   // 高光的颜色
        _Gloss ("Gloss", Range(8, 256)) = 20                // 高光的系数
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

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float3 worldPos : TEXCOORD0;
                float3 worldNormal : TEXCOORD1;
            };

            fixed4 _Diffuse;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (a2v v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_WorldToObject, v.vertex).xyz;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));

                // 计算环境光
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // 计算漫反射
                // fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * (dot(worldNormal. worldLightDir) * 0.5) + 0.5;    // 半兰伯特模型
                // fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * max(0, dot(worldNormal. worldLightDir));          // 使用max截取到0
                fixed3 diffuse = _LightColor0.rgb * _Diffuse.rgb * saturate(dot(worldNormal, worldLightDir));           // 使用内置函数截取0

                // 计算高光反射
                // Phong模型
                // fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));     // 计算视角方向
                // fixed3 reflectDir = normalize(reflect(-worldLightDir, worldNormal));     // 计算反射方向
                // fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(reflectDir, worldViewDir)), _Gloss);

                // Blinn模型
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));        // 计算视角方向
                fixed3 halfDir = normalize(worldViewDir + worldLightDir);                   // 计算Blinn模型中引入的新矢量
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
