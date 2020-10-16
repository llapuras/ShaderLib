Shader "Lapu/HoloMonitor"
{
	Properties
	{
		_Emission("Emission", 2D) = "white" {}
		_Texture0("Texture 0", 2D) = "black" {}
		_Specular("Specular", Range(0 , 1)) = 0.5
		_Smoothness("Smoothness", Range(0 , 1)) = 0.5
		_Color1("Color 1", Color) = (1,1,1,0)
		_Background("Background", Color) = (0,0,0,0)
		_AlbedoPower("Albedo Power", Range(0 , 1)) = 0
		_EmissionPower("Emission Power", Range(0 , 1)) = 0
		_Distort("Distort", Range(0 , 1)) = 0.35
		[HideInInspector] _texcoord("", 2D) = "white" {}
		[HideInInspector] __dirty("", Int) = 1
	}

		SubShader
		{
			Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
			Cull Back
			ZTest LEqual
			CGPROGRAM
			#include "UnityShaderVariables.cginc"
			#pragma target 3.0
			#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows 
			struct Input
			{
				float2 uv_texcoord;
			};

			uniform float4 _Background;
			uniform float4 _Color1;
			uniform sampler2D _Texture0;
			uniform sampler2D _Emission;
			uniform float _Distort;
			uniform float _AlbedoPower;
			uniform float _EmissionPower;
			uniform float _Specular;
			uniform float _Smoothness;

			void surf(Input i , inout SurfaceOutputStandardSpecular o)
			{
				float2 panner337 = (_Time.y * float2(0,0.5) + i.uv_texcoord);
				float2 panner360 = (1.0 * _Time.y * float2(7,9) + i.uv_texcoord);
				float temp_output_362_0 = (_Time.w * 20.0);
				float clampResult372 = clamp((sin((temp_output_362_0 * 0.7)) + sin(temp_output_362_0) + sin((temp_output_362_0 * 1.3)) + sin((temp_output_362_0 * 2.5))) , 0.0 , 1.0);
				float2 temp_output_361_0 = (i.uv_texcoord + ((tex2D(_Texture0, panner360).b * clampResult372) * _Distort));
				float4 tex2DNode308 = tex2D(_Emission, temp_output_361_0);
				float2 panner312 = (_Time.y * float2(0,0.2) + temp_output_361_0);
				float2 panner331 = (_Time.y * float2(-0.2,0) + temp_output_361_0);
				float temp_output_343_0 = (_Time.y * 20.0);
				float clampResult349 = clamp((sin((temp_output_343_0 * 0.7)) + sin(temp_output_343_0) + sin((temp_output_343_0 * 1.3)) + sin((temp_output_343_0 * 2.5))) , 0.7 , 1.0);
				float4 lerpResult335 = lerp(_Background , _Color1 , ((tex2D(_Texture0, panner337).r + (((tex2DNode308.g * tex2D(_Emission, panner312).a) + (tex2DNode308.b * tex2D(_Emission, panner331).a)) + tex2DNode308.r)) + (0.0 + ((clampResult349 * tex2D(_Texture0, i.uv_texcoord).g) - 0.0) * (0.5 - 0.0) / (1.0 - 0.0))));
				o.Albedo = (lerpResult335 * _AlbedoPower).rgb;
				o.Emission = (lerpResult335 * _EmissionPower).rgb;
				float3 temp_cast_2 = (_Specular).xxx;
				o.Specular = temp_cast_2;
				o.Smoothness = _Smoothness;
				o.Alpha = 1;
			}

			ENDCG
		}
			Fallback "Diffuse"
}