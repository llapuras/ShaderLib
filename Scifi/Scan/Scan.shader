//autor:Alfx
//date:2020-9-9
//desc:扫描效果。

Shader "Lapu/Scan"
{
	Properties
	{

		//animated
		[Toggle(ScanMode)] _enableScanMode("Add Cloud", Float) = 0

		[Header(Texture Setting)]
		_Diffuse("Diffuse Texture", 2D) = "white" {}
		_HighLitTexture("High Lit Texture", 2D) = "white" {}
		_Color("Main Color", Color) = (1,1,1,0)
		[HDR]_Highcolor("Highcolor", Color) = (1,1,1,0)
		_Opacity("Opacity", Range(0 , 1)) = 1

		[Header(Scane Setting)]
		_Width("Width", Range(0 , 10)) = 5
		_Speed("Speed", Range(-10 , 10)) = 0
		_Direction("Direction", Range(0 , 5)) = 1

		[Header(Cut Off Setting)]
		_Cutoff("Cutoff Value",Range(0,1.1)) = 0.5

		[HideInInspector] _texcoord2("", 2D) = "white" {}
		[HideInInspector] _texcoord("", 2D) = "white" {}
	}

		SubShader
		{
			Tags{ "RenderType" = "Opaque" "Queue" = "Transparent" }
			
			CGPROGRAM

			#pragma target 4.6
			#pragma surface surf Lambert alpha 

			#pragma shader_feature ScanMode


			struct Input
			{
				float2 uv_texcoord;
				float2 uv2_texcoord2;
			};

			float4 _Color, _Highcolor;
			sampler2D _Diffuse, _HighLitTexture;
			float4 _Diffuse_ST, _HighLitTexture_ST;
			float _Direction, _Speed, _Width;
			float _Opacity, _Cutoff;
		
			void surf(Input i, inout SurfaceOutput  o)
			{
				//texture 
				float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
				float2 uv_HighLitTexture = i.uv2_texcoord2 * _HighLitTexture_ST.xy + _HighLitTexture_ST.zw;

				float4 maincolor = tex2D(_Diffuse, uv_Diffuse);
				float4 highlitcolor = tex2D(_HighLitTexture, uv_HighLitTexture);

				//float texcut = step(_Cutoff, highlitcolor);
				//direction
#if ScanMode
				float lerpvalue = lerp(i.uv2_texcoord2.x, i.uv2_texcoord2.y, _Direction);
#else
				float lerpvalue = 1;
#endif
				 
				float4 final = clamp(_Highcolor * pow(sin(highlitcolor.r * lerpvalue * 3.14 + _Speed * _Time.y) , exp(10.0 - _Width)), float4(0, 0, 0, 0), float4(1, 1, 1, 1));
				
				o.Albedo = (maincolor * _Color).rgb * _Opacity;
				o.Emission = final.rgb;
				o.Alpha = _Opacity ? maincolor :final.a;
			}

			ENDCG
		}
			Fallback "Diffuse"
}