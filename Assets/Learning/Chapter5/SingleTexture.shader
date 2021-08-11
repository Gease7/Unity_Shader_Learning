Shader "Shader-Learning/Chapter5/SingleTexture"
{
    Properties
    {
        // 声明2D贴图属性
        _MainTex ("Texture", 2D) = "white" {}
        _BaseColor ("Base Color", Color) = (1, 1, 1, 1)
        _Specular ("Specular Color", Color) = (1, 1, 1, 1)
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

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                //使用texcoord变量存储模型的第一组纹理坐标
                float4 texcoord : TEXCOORD0;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
                float3 worldPos : TEXCOORD1;
                //uv坐标，在顶点函数中计算，后使用该坐标去片元函数中对纹理进行采样
                float2 uv : TEXCOORD2;
            };

            sampler2D _MainTex;
            // 这个是纹理的属性，控制纹理的缩放(scale)和平移(translation)
            float4 _MainTex_ST;
            fixed4 _BaseColor;
            fixed4 _Specular;
            float _Gloss;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_WorldToObject, v.vertex).xyz;
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                // 使用纹理属性对纹理坐标进行变换，对应材质面板的Tiling和Offset调节项
                // o.uv = v.texcoord.xy * _MainTex_ST.zw + _MainTex_ST.xy;
                // 使用内置宏计算上述过程
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 worldNormal = normalize(i.worldNormal);
                fixed3 worldLightDir = normalize(UnityWorldSpaceLightDir(i.worldPos));
                fixed3 worldViewDir = normalize(UnityWorldSpaceViewDir(i.worldPos));
                fixed3 halfDir = normalize(worldLightDir + worldViewDir);

                // 使用tex2D对纹理进行采样
                // 漫反射的颜色是基础颜色与纹理颜色的正片叠底
                fixed3 albedo = tex2D(_MainTex, i.uv).rgb * _BaseColor.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(worldNormal, worldLightDir));
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(worldNormal, halfDir)), _Gloss);
                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
