// Sample the colors of nearby pixels and blend them together increasing the intesity the further the depthis.

FEATURES
{
    #include "system.fxc"
    #include "common.fxc"
}

MODES
{
    Forward();
    Depth();
}

COMMON
{
    struct VertexInput
    {
        float3 position : POSITION < Semantic(PosXyz); > ;
        float2 uv : TEXCOORD0 < Semantic(LowPrecisionUv); > ;
    };

    struct PixelInput
    {
        float4 position : SV_Position;
        float2 uv : TEXCOORD0;
    };

    struct EffectRange
    {
        float BlendRange < Attribute("DepthBlend_BlendRange"); > ;
        float MaxDepthDelta < Attribute("DepthBlend_MaxDepthDelta"); > ;
        float MaxEffectDepth < Attribute("DepthBlend_MaxEffectDepth"); > ;

        float BlendStart < Attribute("DepthBlend_BlendStart"); > ;
        float BlendEnd < Attribute("DepthBlend_BlendEnd"); > ;
    }

    struct EffectStrength
    {
        float EdgeStrength < Attribute("DepthBlend_EdgeStrength"); > ;
        float SmoothStrength < Attribute("DepthBlend_SmoothStrength"); > ;
        float LerpInterpolation < Attribute("DepthBlend_LerpInterpolation"); > ;
    }
}

VS // Vertex Shader
{
    PixelInput MainVs(VertexInput input)
    {
        PixelInput PSInput;

        PSInput.position = float4(input.position.xy, 0.0f, 1.0f);
        PSInput.uv = input.uv;
        
        return PSInput;
    }
}

PS // Pixel Shader.
{
    // Screen State.
    SamplerState SampleState < Filter(Point); > ;
    Texture2D ColorBuffer < Attribute("ColorBuffer"); SrgbRead(true); > ;

    EffectRange g_EffectRange;
    EffectStrength g_EffectStrength;

    float4 MainPS(PixelInput input) : SV_Target
    {   
        // Center Pixel
        int blendCount = 1;
        float4 centerColor = ColorBuffer.Sample(SampleState, input.uv);
        float centerDepth = Depth::Get(input.uv);

        // Sample nearby pixels.

        // Top Left Pixel
        float2 topLeftUV = input.uv + float2(-1 * g_EffectRange.BlendRange, -1 * g_EffectRange.BlendRange);
        float4 topLeftColor = FindColorAtNearbyUV(topLeftUV, centerDepth, blendCount);

        // Bottom Right Pixel
        float2 bottomRightUV = input.uv + float2(g_EffectRange.BlendRange, g_EffectRange.BlendRange);
        float4 bottomRightColor = FindColorAtNearbyUV(bottomRightUV, centerDepth, blendCount);

        // Top Right Pixel
        float2 topRightUV = input.uv + float2(g_EffectRange.BlendRange, -1 * g_EffectRange.BlendRange);
        float4 topRightColor = FindColorAtNearbyUV(topRightUV, centerDepth, blendCount);

        // Bottem Left Pixel
        float2 bottomLeftUV = input.uv + float2(-1 * g_EffectRange.BlendRange, g_EffectRange.BlendRange);
        float4 bottomLeftColor = FindColorAtNearbyUV(bottomLeftUV, centerDepth, blendCount);

        // Take the average of all nearby pixels at similar similar depth (defined by MaxDepthDelta)
        float4 nearbyPixelBlendedColor = 
            (centerColor + topLeftColor + bottomRightColor + topRightColor + bottomLeftColor) / blendCount;

        // To correct for edges we take the delta of the color and multiply it by EdgeStrength.
        // We do that so edges are kept where there is a large change in color.
        float4 colorDelta = abs(centerColor - nearbyPixelBlendedColor);
        float4 edgeCorrectedColor = colorDelta * g_EffectStrength.EdgeStrength;

        // We create a smooth transition of color using the depth of the uv.
        float normalizedDepth = smoothstep(centerDepth / g_EffectRange.MaxEffectDepth, g_EffectRange.BlendStart, g_EffectRange.BlendEnd);
        float4 depthBlendColor = nearbyPixelBlendedColor * normalizedDepth;

        // How much of the original color is put back in.
        float4 smoothingColor = centerColor * g_EffectStrength.SmoothStrength;

        // Finally we combine everything and use lerp to smooth everything out a final time.
        float4 combinedColor = edgeCorrectedColor + depthBlendColor + smoothingColor;
        float4 blendedColor = lerp(centerColor, combinedColor, g_EffectStrength.LerpInterpolation);
        return blendedColor;
    }

    float4 FindColorAtNearbyUV(float2 uv, float centerDepth, inout int blendCount)
    {
        float depth = Depth.Get(uv);

        float depthDelta = abs(centerDepth - depth);
        if (depthDelta < g_EffectRange.MaxDepthDelta)
        {
            blendCount++;

            return ColorBuffer.Sample(SampleState, uv);
        }

        return float4(0, 0, 0, 0);
    }
}