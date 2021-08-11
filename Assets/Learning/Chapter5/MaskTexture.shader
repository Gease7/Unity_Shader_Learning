Shader "Unlit/MaskTexture"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpTex ("Bump Texture", 2D) = "bump" {}
        _BumpScale ("Bump Scale", Float) = 1.0
        // 声明遮罩纹理
        _MaskTex ("Mask Texture", 2D) = "white" {}
        // 遮罩系数对遮罩进行控制
        _MaskScale ("Mask Scale", Float) = 1.0
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
                float3 lightDir : TEXCOORD0;
                float3 viewDir : TEXCOORD1;
                // 声明多个uv坐标是为了可以控制每个纹理
                float4 uv1 : TEXCOORD2;
                float2 uv2 : TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpTex;
            float4 _BumpTex_ST;
            float _BumpScale;
            sampler2D _MaskTex;
            float4 _MaskTex_ST;
            float _MaskScale;
            fixed4 _BaseColor;
            fixed4 _Specular;
            float _Gloss;


            v2f vert (a2v v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                o.uv1.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv1.zw = TRANSFORM_TEX(v.texcoord, _BumpTex);
                o.uv2 = TRANSFORM_TEX(v.texcoord, _MaskTex);

                TANGENT_SPACE_ROTATION;
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed3 tangentLightDir = normalize(i.lightDir);
                fixed3 tangentViewDir = normalize(i.viewDir);
                fixed3 halfDir = normalize(tangentLightDir + tangentViewDir);

                fixed3 tangentNormal = UnpackNormal(tex2D(_BumpTex, i.uv1.zw));
                tangentNormal.xy *= _BumpScale;
                tangentNormal.z = sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

                fixed3 albedo = tex2D(_MainTex, i.uv1.xy).rgb * _BaseColor.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * saturate(dot(tangentNormal, tangentLightDir));

                // 用纹理坐标采样获取遮罩纹理中对应的数值
                fixed specularMask = tex2D(_MaskTex, i.uv2).r * _MaskScale;
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss) * specularMask;

                return fixed4(ambient + diffuse + specular, 1.0);
            }
            ENDCG
        }
    }
    FallBack "Specular"
}
