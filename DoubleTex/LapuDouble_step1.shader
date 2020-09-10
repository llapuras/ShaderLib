Shader "Lapu/LapuDoubleTex_step1" {
    Properties{
        _Color("Primary Color", Color) = (1,1,1,1)
        _MainTex("Primary (RGB)", 2D) = "white" {}
        _Radius("Radius", Range(0, 10)) = 0
        _SphereIntensity("Sphere Intensity", Range(0, 10)) = 1
        _EmissionIntensity("Emission Intensity", Range(0, 10)) = 0.5
    }

        SubShader{
            Tags { "RenderType" = "Transparent" }
            LOD 200

        CGPROGRAM

        #pragma surface surf Lambert 

        float3 _Position; // from script

        sampler2D _MainTex;
        float4 _Color;
        float _Radius, _EmissionIntensity, _SphereIntensity;

        struct Input {
            float2 uv_MainTex : TEXCOORD0;
            float3 worldPos;// built in value to use the world space position
            float3 worldNormal; // built in value for world normal
        };

        void surf(Input IN, inout SurfaceOutput o) {
            half4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

            //画圆
            float3 dis = distance(_Position, IN.worldPos);
            float3 sphere = 1 - saturate(dis / _Radius);
            sphere = saturate(sphere * _SphereIntensity);

            float3 primaryTex = c.rgb;
            float3 resultTex = primaryTex + sphere;
            o.Albedo = resultTex;

            o.Emission = sphere * _EmissionIntensity;
            o.Alpha = c.a;

        }
        ENDCG

        }

            Fallback "Diffuse"
}