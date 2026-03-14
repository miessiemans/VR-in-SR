Shader "Custom/Newest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EquirectTex ("Equirect Texture", 2D) = "black" {}
        _DisplayFOV ("Display FOV", Float) = 90.0
        _CaptureFOV ("Capture FOV", Float) = 90.0
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

            TEXTURE2D(_EquirectTex);
            SAMPLER(sampler_EquirectTex);

            float _Beta;
            float _Gamma;
            float3 _VelocityDir;
            float _DisplayFOV;
            float _CaptureFOV;

            float3 UVToWorldDirection(float2 uv)
            {
                float2 ndc = uv * 2.0 - 1.0;
                float fov = radians(_DisplayFOV);
                float aspect = _ScreenParams.x / _ScreenParams.y;

                float3 viewDir;
                viewDir.x = ndc.x * tan(fov * 0.5) * aspect;
                viewDir.y = ndc.y * tan(fov * 0.5);
                viewDir.z = 1.0;
                viewDir = normalize(viewDir);

                float3 worldDir = mul((float3x3)UNITY_MATRIX_I_V, viewDir);
                return normalize(worldDir);
            }

            float2 WorldDirToEquirectUV(float3 dir)
            {
                dir = normalize(dir);
                float u = atan2(dir.x, dir.z) / (2.0 * PI) + 0.5;
                float v = asin(clamp(dir.y, -1.0, 1.0)) / PI + 0.5;
                return float2(u, v);
            }

            float3 ApplyAberration(float3 worldDir, float3 velocityWorld, float beta)
            {
                worldDir = normalize(worldDir);
                velocityWorld = normalize(velocityWorld);

                float cosTheta = dot(worldDir, velocityWorld);
                float denominator = 1.0 - beta * cosTheta;
                if (abs(denominator) < 0.001)
                    return worldDir;

                float cosThetaPrime = (cosTheta - beta) / denominator;
                cosThetaPrime = clamp(cosThetaPrime, -0.9999, 0.9999);
                float sinThetaPrime = sqrt(max(0.0, 1.0 - cosThetaPrime * cosThetaPrime));

                float3 parallel = dot(worldDir, velocityWorld) * velocityWorld;
                float3 perp = worldDir - parallel;
                float perpLen = length(perp);

                if (perpLen < 0.001)
                    return cosThetaPrime * velocityWorld;

                perp = perp / perpLen;
                return normalize(cosThetaPrime * velocityWorld + sinThetaPrime * perp);
            }

            float3 ApplyDopplerColorFromD(float3 color, float D, float cosTheta, float beta)
            {
                // Only start colour shifting above 0.3c
                float colorStrength = max(beta - 0.3, 0.0) / 0.7 * 2.5;

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

                float3 worldDir = UVToWorldDirection(uv);
                float2 equirectUV = WorldDirToEquirectUV(worldDir);
                half4 col = SAMPLE_TEXTURE2D(_EquirectTex, sampler_EquirectTex, equirectUV);

                if (_Beta < 0.001)
                    return col;

                // Aberrate in world space
                float3 sourceWorldDir = ApplyAberration(worldDir, _VelocityDir, _Beta);
                float2 aberratedUV = WorldDirToEquirectUV(sourceWorldDir);
                col = SAMPLE_TEXTURE2D(_EquirectTex, sampler_EquirectTex, aberratedUV);

                // Doppler factor from world space angle to velocity
                float cosTheta = dot(normalize(worldDir), normalize(_VelocityDir));
                float D = _Gamma * (1.0 - _Beta * cosTheta);
                D = max(D, 0.01);

                col.rgb = ApplyDopplerColorFromD(col.rgb, D, cosTheta, _Beta);


                float beaming = 1.0 / (D * D * D * D);
                beaming = min(beaming, 4.0);
                col.rgb *= beaming;

                float2 vignetteUV = uv * 2.0 - 1.0;
                float vignette = 1.0 - _Beta * 0.4 * dot(vignetteUV, vignetteUV);
                col.rgb *= max(vignette, 0.3);

                return col;
            }
            ENDHLSL
        }
    }
}