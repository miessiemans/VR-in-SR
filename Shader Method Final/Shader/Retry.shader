Shader "Custom/RelativisticFresh"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FOV ("Field of View", Float) = 90.0
    }
    
    SubShader
    {
        Tags { "RenderType"="Opaque" "RenderPipeline"="UniversalPipeline" }
        
        Cull Off ZWrite Off ZTest Always
        
        Pass
        {
            Name "RelativisticFresh"
            
            HLSLPROGRAM
            #pragma vertex Vert
            #pragma fragment Frag
            
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
            
            float _Beta;
            float _Gamma;
            float3 _VelocityDir;
            float _FOV;
            
            float3 UVToViewDirection(float2 uv)
{
                float2 ndc = uv * 2.0 - 1.0;
                float fov = radians(_FOV);
                float aspect = _ScreenParams.x / _ScreenParams.y;
    
    // Gentler scale — grows slowly and never overshoots
    // At 0.5c: ~1.2x, at 0.9c: ~1.6x, approaches but never hits 2x
                float fovScale = 1.0 + _Beta * _Beta * 0.8;
    
                float3 viewDir;
                viewDir.x = ndc.x * tan(fov * 0.5 * fovScale) * aspect;
                viewDir.y = ndc.y * tan(fov * 0.5 * fovScale);
                viewDir.z = 1.0;
    
                return normalize(viewDir);
            }
            
            float2 ViewDirectionToUV(float3 viewDir)
            {
                float fov = radians(_FOV);
                float aspect = _ScreenParams.x / _ScreenParams.y;
                
                if (viewDir.z <= 0.0)
                    return float2(-1.0, -1.0);
                
                float2 ndc;
                ndc.x = viewDir.x / (viewDir.z * tan(fov * 0.5) * aspect);
                ndc.y = viewDir.y / (viewDir.z * tan(fov * 0.5));
                
                return ndc * 0.5 + 0.5;
            }
            
            float3 WorldToViewDirection(float3 worldDir)
            {
                float3 viewDir = mul((float3x3)UNITY_MATRIX_V, worldDir);
                return normalize(viewDir);
            }
            
            float3 ApplyAberration(float3 viewDir, float3 velocityViewSpace, float beta)
            {
                viewDir = normalize(viewDir);
                velocityViewSpace = normalize(velocityViewSpace);
                
                float cosTheta = dot(viewDir, velocityViewSpace);
                float denominator = 1.0 + beta * cosTheta;
                if (abs(denominator) < 0.001)
                    return viewDir;
                
                float cosThetaPrime = (cosTheta + beta) / denominator;
                cosThetaPrime = clamp(cosThetaPrime, -0.9999, 0.9999);
                float sinThetaPrime = sqrt(max(0.0, 1.0 - cosThetaPrime * cosThetaPrime));
                
                float3 perp = viewDir - dot(viewDir, velocityViewSpace) * velocityViewSpace;
                float perpLen = length(perp);
                
                if (perpLen < 0.001)
                    return cosThetaPrime * velocityViewSpace;
                
                perp = perp / perpLen;
                return normalize(cosThetaPrime * velocityViewSpace + sinThetaPrime * perp);
            }
            
            float3 ApplyDopplerColorFromD(float3 color, float D, float cosTheta, float beta)
            {
                float colorStrength = beta * 2.5;
                
                if (D < 1.0)
                {
                    float shift = clamp((1.0 - D) * colorStrength, 0.0, 1.0);
                    color.b = lerp(color.b, 1.0, shift);
                    color.r *= lerp(1.0, 0.2, shift);
                    color.g *= lerp(1.0, 0.6, shift * 0.8);
                }
                else
                {
                    float shift = clamp((D - 1.0) * colorStrength, 0.0, 1.0);
                    color.r = lerp(color.r, 1.0, shift);
                    color.b *= lerp(1.0, 0.2, shift);
                    color.g *= lerp(1.0, 0.6, shift * 0.8);
                }
                
                if (beta > 0.5)
                {
                    float spectrumPos = (cosTheta + 1.0) * 0.5;
                    float3 spectrumColor;
                    
                    if (spectrumPos > 0.66)
                    {
                        float t = (spectrumPos - 0.66) / 0.34;
                        spectrumColor = lerp(float3(0, 1, 1), float3(0.2, 0.2, 1), t);
                    }
                    else if (spectrumPos > 0.33)
                    {
                        float t = (spectrumPos - 0.33) / 0.33;
                        spectrumColor = lerp(float3(0, 1, 0), float3(0, 1, 1), t);
                    }
                    else
                    {
                        float t = spectrumPos / 0.33;
                        spectrumColor = lerp(float3(1, 0, 0), float3(1, 1, 0), t);
                    }
                    
                    float spectrumStrength = ((beta - 0.5) / 0.5);
                    spectrumStrength = spectrumStrength * spectrumStrength * 0.5;
                    color.rgb = lerp(color.rgb, spectrumColor, spectrumStrength);
                }
                
                return saturate(color);
            }
            
            half4 Frag(Varyings input) : SV_Target
            {
                float2 uv = input.texcoord;
    
                if (_Beta < 0.001)
                    return SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, uv);
    
                float3 viewDir = UVToViewDirection(uv);
                float3 velocityViewSpace = WorldToViewDirection(_VelocityDir);
    
                float3 sourceDir = ApplyAberration(viewDir, velocityViewSpace, _Beta);
                float2 sampleUV = ViewDirectionToUV(sourceDir);
    

                sampleUV = clamp(sampleUV, 0.001, 0.999);
    
                half4 col = SAMPLE_TEXTURE2D(_BlitTexture, sampler_LinearClamp, sampleUV);
    
                float cosTheta = dot(normalize(viewDir), normalize(velocityViewSpace));
                float D = _Gamma * (1.0 - _Beta * cosTheta);
                D = max(D, 0.01);
    
                col.rgb = ApplyDopplerColorFromD(col.rgb, D, cosTheta, _Beta);
    
                /*float beaming = 1.0 / (D * D * D * D);
                beaming = clamp(beaming, 0.05, 12.0);
                col.rgb *= beaming; */
    
                float2 vignetteUV = uv * 2.0 - 1.0;
                float vignette = 1.0 - _Beta * 0.4 * dot(vignetteUV, vignetteUV);
                col.rgb *= max(vignette, 0.3);
    
                return col;
            }
            ENDHLSL
        }
    }
}