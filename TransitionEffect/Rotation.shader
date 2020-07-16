Shader "Lapu/Rotation"
{
	Properties {
        _MainColor("Mian Color", COLOR) = (1,1,1,1)
		_MaskTex ("Main Texture", 2D) = "black" {}
        _RotationSpeed("RoatationSpeed", Range(0.1,200)) = 1
        _PivotX("Pivot", float) = 5
        _PivotY("Pivot", float) = 5
	}


	SubShader
	{
		Tags { "RenderType" = "Opaque"  "Queue" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
		LOD 100
	
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag	
			#include "UnityCG.cginc"

			sampler2D _MaskTex;
            float _RotationSpeed, _PivotX, _PivotY;
            float4 _MaskTex_ST;
            float4 _MainColor;

			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD3;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata_img v) {
			    v2f o;
			    o.vertex = UnityObjectToClipPos(v.vertex);
                float sinX = sin ( _RotationSpeed * _Time );
                float cosX = cos ( _RotationSpeed * _Time );
                float2x2 rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
               
                o.uv = TRANSFORM_TEX(v.texcoord, _MaskTex);
                float2 pivot = float2(_PivotX, _PivotY); 
                o.uv = mul (o.uv.xy - pivot, rotationMatrix);
                return o;
		    }

			fixed4 frag(v2f i) : SV_Target
			{
				half4 col = tex2D(_MaskTex, i.uv);
				return col * _MainColor;
			}
			ENDCG
		}

	}

}