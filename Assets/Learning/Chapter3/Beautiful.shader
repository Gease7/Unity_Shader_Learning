Shader "Shader-Learning/Chapter3/Beautiful"
{
    SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
                float3 normal :NORMAL;
			};

			struct v2f
			{
				float3 normal : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.normal = UnityObjectToWorldNormal(v.normal);
				return o;
			}

			fixed4 frag (v2f i) : SV_Target
			{
				float3 col = 0.5 + 0.5 * cos(_Time.y + i.normal + float3(0, 2, 4));
                return float4(col, 1.0);
			}
			ENDCG
		}
	}
}
