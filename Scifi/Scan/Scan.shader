//author:Alfx
//date:2020-9-9
//desc:扫描效果
//TODO:
//- 可选闪烁和扫描模式
//- 支持世界坐标和本地坐标 √
//- 支持方向更改 √
//- 线条宽度优化 

Shader "Lapu/Scan"
{
	Properties
	{
		
		//默认闪烁模式
		[Toggle(ScanMode)] _enableScanMode("Scan Mode", Float) = 0	//开启扫描模式
		[Toggle(WorldPosMode)] _enableWorldPos("World Pos", Float) = 0	//开启扫描模式

		[Header(Texture Setting)]
		_Diffuse("Diffuse Texture", 2D) = "white" {}
		_HighLitTexture("High Lit Texture", 2D) = "white" {}
		_Color("Main Color", Color) = (1,1,1,0)
		[HDR]_Highcolor("Highcolor", Color) = (1.018156,2.249626,3.924528,1)
		_Opacity("Opacity", Range(0 , 1)) = 1

		[Header(Scane Setting)]
		_Width("Width", Range(0 , 10)) = 8.15
		_Speed("Speed", Range(-10 , 10)) = 4.5
		_Rotation("Rotation", Range(0 , 15)) = 0.85	//todo

		[Header(Cut Off Setting)]
		_Cutoff("Cutoff Value",Range(-10,10)) = 1.1

		_HorizonIntensity("Horizon Intensity",  Range(0, 100)) = 3.3
		_HorizonHeight("Horizon Height", Range(-10,10)) = 10
		
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
			float _Rotation, _Speed, _Width;
			float _Opacity, _Cutoff, _HorizonHeight, _HorizonIntensity;
		
			void surf(Input i, inout SurfaceOutput  o)
			{
				float Rot = _Rotation * (3.1415926f / 180.0f);
				float s = sin(Rot);
				float c = cos(Rot);

				//texture 
				float2 uv_Diffuse = i.uv_texcoord * _Diffuse_ST.xy + _Diffuse_ST.zw;
				float2 uv_HighLitTexture = i.uv2_texcoord2 * _HighLitTexture_ST.xy + _HighLitTexture_ST.zw + fixed2(s,c);

				float4 maincolor = tex2D(_Diffuse, uv_Diffuse);
				float4 highlitcolor = tex2D(_HighLitTexture, uv_HighLitTexture);
#if ScanMode
				float lerpvalue = lerp(uv_HighLitTexture.x, uv_HighLitTexture.y, _Rotation);
#else
				float lerpvalue = 1;
#endif
				float4 final = clamp(_Highcolor * pow(sin(highlitcolor.r * lerpvalue + _Speed * _Time.y), exp(10.0 - _Width)), float4(0, 0, 0, 0), float4(1, 1, 1, 1));

				o.Albedo = (maincolor * _Color).rgb;
				o.Emission = final.rgb;
				o.Alpha = final.a;
			}

			ENDCG
		}
			Fallback "Diffuse"
}