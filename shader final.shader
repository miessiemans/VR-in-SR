Shader "Custom/Relativistic Shader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EquirectTex ("Equirect Texture", 2D) = "black" {}
        _DisplayFOV ("Display FOV", Float) = 90.0
    }

    SubShader
    {
        // set render types and states
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
            float _DisplayFOV;
            float _CaptureFOV;

            float3 UV_projector(float2 uv)
            {   // each UV point correlates to a ray of light
                // use trig to project each UV pixel as an outward looking vector "world_direction"
                float2 ndc = uv * 2.0 - 1.0;
                float fov = radians(_DisplayFOV);
                float aspect = _ScreenParams.x / _ScreenParams.y;

                float3 view_direction; // define new 3D vector

                // rescale NDC coordinates by FOV
                view_direction.x = ndc.x * tan(fov * 0.5) * aspect;
                view_direction.y = ndc.y * tan(fov * 0.5);
                view_direction.z = 1.0;
                // normalise vector
                view_direction = normalize(view_direction);

                // enforce world direction so that aberration is independent of camera orientation
                float3 world_direction = mul((float3x3)UNITY_MATRIX_I_V, view_direction);
                return normalize(world_direction);
            }

            float2 direction_to_equiUV(float3 dir)
            {   // map aberrated direction vector to equirect UV
                dir = normalize(dir);
                float u = atan2(dir.x, dir.z) / (2.0 * PI) + 0.5; // x, z transformed to UV range
                float v = asin(clamp(dir.y, -1.0, 1.0)) / PI + 0.5; // y transformed to UV range 
                return float2(u, v);
            }

            float3 aberrate(float3 world_direction, float beta)

            {   


                world_direction = normalize(world_direction);
                //velocity)dir leftover from free movement, set to 1 -> +Z
                float3 velocity_direction = float3(0,0,1);

                // dot between the two unit vectors gives us theta 
                float cosTheta = dot(world_direction, velocity_direction);

                float denominator = 1.0 - beta * cosTheta;
                if (abs(denominator) < 0.001)
                    return world_direction;

                // cos(theta_prime) = (costheta - beta) / 1 - (beta*cos(theta_prime))
                float cosTheta_prime = (cosTheta - beta) / denominator;

                // clamp to cos range
                cosTheta_prime = clamp(cosTheta_prime, -0.9999, 0.9999);
                float sinTheta_prime = sqrt(max(0.0, 1.0 - cosTheta_prime * cosTheta_prime));

                // decompose vector into parallel and perpendicular parts to project vector with theta_prime 
                float3 parallel = dot(world_direction, velocity_direction) * velocity_direction;
                float3 perp = world_direction - parallel;
                float perp_length = length(perp);

                if (perp_length < 0.001) // prevent zero division  
                    return cosTheta_prime * velocity_direction;
                perp = perp / perp_length;
                // return new direction unit vector
                return normalize(cosTheta_prime * velocity_direction + sinTheta_prime * perp);
            }

float3 doppler_colour(float3 colour, float D, float cosTheta, float beta)
{
if (D < 1.0)
{
    float colour_multiplier = lerp(0.1, 4, (1.0 - D));
    float shift = clamp((1.0 - D) * colour_multiplier, 0.0, 1.0);
    colour.b = lerp(colour.b, 1.0, shift);
    colour.r *= lerp(1.0, 0.0, shift);        // red fully suppressed
    colour.g *= lerp(1.0, 0.5, shift);         // green stays higher than red
    
    // boost brightness ahead at high beta
    float brightness_boost = clamp((beta - 0.7) / 0.3, 0.0, 1.0) 
                           * clamp((cosTheta - 0.5) / 0.5, 0.0, 1.0);
    brightness_boost = brightness_boost * brightness_boost;
    colour.rgb += float3(0.0, 0.2, 0.8) * brightness_boost;
}
    else
    {
        float colour_multiplier = lerp(0.1, 4, (D - 1));
        float shift = clamp((D - 1.0) * colour_multiplier, 0.0, 1.0);
        colour.r = lerp(colour.r, 1.0, shift);
        colour.b *= lerp(1.0, 0.2, shift);
        colour.g *= lerp(1.0, 0.6, shift * 0.8);
    }

    if (beta > 0.5)
    {
        float spectrum_position = (cosTheta + 1.0) * 0.5;
        float3 spectrumcolour;

        if (spectrum_position > 0.66)
        {
            float t = (spectrum_position - 0.66) / 0.34;
            spectrumcolour = lerp(float3(0, 1, 1), float3(0.2, 0.2, 1), t);
        }
        else if (spectrum_position > 0.33)
        {
            float t = (spectrum_position - 0.33) / 0.33;
            spectrumcolour = lerp(float3(0, 1, 0), float3(0, 1, 1), t);
        }
        else
        {
            float t = spectrum_position / 0.33;
            spectrumcolour = lerp(float3(1, 0, 0), float3(1, 1, 0), t);
        }

        float spectrum_strength = ((beta - 0.5) / 0.45);
        spectrum_strength = spectrum_strength * spectrum_strength;
        colour.rgb = lerp(colour.rgb, spectrumcolour, spectrum_strength);
    }

    return saturate(colour);
}

            half4 Frag(Varyings input) : SV_Target
            {
                float2 uv = input.texcoord;

                float3 world_direction = UV_projector(uv);
                float2 equirectUV = direction_to_equiUV(world_direction);
                half4 col = SAMPLE_TEXTURE2D(_EquirectTex, sampler_EquirectTex, equirectUV);

                if (_Beta < 0.001)
                    return col;

                // Aberrate in world space
                float3 source_world_direction = aberrate(world_direction, _Beta);
                float2 aberratedUV = direction_to_equiUV(source_world_direction);
                col = SAMPLE_TEXTURE2D(_EquirectTex, sampler_EquirectTex, aberratedUV);

                // Doppler factor from world space angle to velocity
                float cosTheta = dot(normalize(world_direction), float3(0, 0, 1));
                float D = _Gamma * (1.0 - _Beta * cosTheta); 
                D = max(D, 0.01);

                col.rgb = doppler_colour(col.rgb, D, cosTheta, _Beta);


                float beaming = 1.0 / (D * D);
                beaming = min(beaming, 4.0);
                col.rgb *= beaming;

                /*float2 snapUV = uv * 2.0 - 1.0;
                float snap = 1.0 - _Beta * 0.4 * dot(snapUV, snapUV);
                col.rgb *= max(snap, 0.3);*/

                return col;
            }
            ENDHLSL
        }
    }
}
