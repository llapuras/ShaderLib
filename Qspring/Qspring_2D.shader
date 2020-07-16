Shader "Lapu/Qspring_2D"
{
    Properties
    {
        _MainTex("Texture", 2D) = "white" {}
        _Position("xyz:position,w:range",vector) = (0,0,0,1)
        _PointTime("point time",float) = 0
        _Duration("duration",float) = 2
        _Frequency("frequency",float) = 5
    }
        SubShader
        {
            Tags { "QUEUE" = "Transparent" "IGNOREPROJECTOR" = "true" "RenderType" = "Transparent" } 
            LOD 100
            Blend SrcAlpha OneMinusSrcAlpha
           
            Pass
            {
                CGPROGRAM
                #pragma vertex vert
                #pragma fragment frag
                #include "UnityCG.cginc"

                struct appdata
                {
                    float4 vertex : POSITION;
                    float2 uv : TEXCOORD0;
                };

                struct v2f
                {
                    float2 uv : TEXCOORD0;
                    float4 vertex : SV_POSITION;
                };

                sampler2D _MainTex;
                float4 _MainTex_ST;
                float4 _Position; 
                float _PointTime;
                float _Duration;
                float _Frequency;

                v2f vert(appdata v)
                {
                    v2f o;
                    float t = _Time.y - _PointTime;

                    // 在点击和指定变化时间内弹性变化
                    if (t > 0 && t < _Duration)
                    {
                        // 归一化点击范围内点的数值，并且因为点击点应该变化最大，周边次子到最小，故 1-
                        float r = 1 - saturate(length(v.vertex.y - 0.9) / _Position.w);
                        // 时间上的变化，随时间逐渐复原，故要 1-
                        float l = 1 - t / _Duration;
                        //竖直方向弹动，当然也可以改改改成其他形式的弹动
                        v.vertex.y += r * l * sin(t * _Frequency)*0.4;
                    }

                    o.vertex = UnityObjectToClipPos(v.vertex);
                    o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                    return o;
                }

                fixed4 frag(v2f i) : SV_Target
                {
                    fixed4 col = tex2D(_MainTex, i.uv);
                    return col;
                }

            ENDCG
        }
        }
}