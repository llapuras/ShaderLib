Shader "Lapu/ToonSnow"{
    Properties{
        _ModelColor("Model Color", Color) = (0.5,0.5,0.5,1)
        _ModelTex("Model Tex", 2D) = "white" {}
	    _SnowRamp("Snow Ramp", 2D) = "white" {}
        _SnowColor("Snow Color", Color) = (0.5,0.5,0.5,1)
		_SnowRimColor("Snow Rim Color", Color) = (0.5,0.5,0.5,1)
		_SnowRimIntensity("Snow Rim Intensity", Range(0,10)) = 3
        _SnowDir("Snow Direction", Vector) = (0,1,0)
        _SnowSize("Snow Size", Range(0,2)) = 1
        _SnowHeight("Snow Height",Range(0,10)) = 0 
		_Atten("Atten",Range(0,10)) = 1.5 
		_Phong ("Phong Strengh", Range(0,1)) = 0.5
		_EdgeLength ("Edge length", Range(2,50)) = 5
    }


SubShader{
    Tags{"RenderType" = "Opaque"}
    LOD 100
    Cull off
    
    CGPROGRAM

    #pragma surface surf Lambert vertex:vert 
    #include "Tessellation.cginc"


 	struct Input {
		float2 uv_ModelTex : TEXCOORD0; 
		float3 worldPos;
		float3 viewDir;
		float3 lightDir;
	};

	struct appdata {                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                           
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};

    float4 _ModelColor;
    sampler2D _ModelTex;  
    sampler2D _SnowRamp;  
    float4 _SnowColor;
	float4 _SnowRimColor;
	float _SnowRimIntensity;
	float4 _SnowDir;
	float  _SnowSize;
	float  _SnowHeight;
	float  _Atten;
	float _Phong;
	float _EdgeLength;
	
    float4 tessEdge (appdata_full v0, appdata_full v1, appdata_full v2)
    {
        return UnityEdgeLengthBasedTess (v0.vertex, v1.vertex, v2.vertex, _EdgeLength);
	}

	void vert(inout appdata_full v)
	{
		float3 up = float3(0,1,0);
		if (dot(v.normal, normalize(_SnowDir.xyz)) > -(_SnowSize-1) )
		{
			v.vertex.xyz += up.xyz * _SnowHeight * 0.0001;
		}
	}


	void surf(Input IN, inout SurfaceOutput o) {
		float3 localPos = (IN.worldPos - mul(unity_ObjectToWorld, float4(0, 0, 0, 1)).xyz); 
		half d = dot(o.Normal, IN.lightDir)*0.5 + 0.5; 
		half4 c = tex2D(_ModelTex, IN.uv_ModelTex) * _ModelColor; 
		half3 snowRamp = tex2D(_SnowRamp, float2(d, d)).rgb;
		o.Albedo = _Atten * c.rgb * _ModelColor;
		half rim = 1.0 - saturate(dot(normalize(IN.viewDir), o.Normal)); 
		if (dot( o.Normal, normalize(_SnowDir.xyz)) >= -(_SnowSize-1)) { 
			o.Albedo = _Atten * _SnowColor * snowRamp; 
			o.Emission = _SnowRimColor.rgb *pow(rim, _SnowRimIntensity);
		}
	}

    ENDCG
    }

    Fallback "Diffuse"
}