HEADER
{
    DevShader = true;
}

MODES
{
    Default();
    Forward();
}

COMMON
{
    #include "postprocess/shared.hlsl"
}

struct VertexInput
{
    float3 vPositionOs : POSITION < Semantic( PosXyz ); >;
    float2 vTexCoord : TEXCOORD0 < Semantic( LowPrecisionUv ); >;
};

struct PixelInput
{
    float2 uv : TEXCOORD0;

	// VS only
	#if ( PROGRAM == VFX_PROGRAM_VS )
		float4 vPositionPs: SV_Position;
	#endif

	// PS only
	#if ( ( PROGRAM == VFX_PROGRAM_PS ) )
		float4 vPositionSs: SV_Position;
	#endif
};

VS
{
    PixelInput MainVs( VertexInput input )
    {
        PixelInput output;

        output.vPositionPs = float4(input.vPositionOs.xy, 0.0f, 1.0f);
        output.uv = input.vTexCoord;
        return output;
    }
}

PS
{
    #include "postprocess/common.hlsl"
    #include "postprocess/functions.hlsl"

    #include "common/classes/Depth.hlsl"

    // Textures
    Texture2D g_tColorBuffer < Attribute("ColorBuffer"); SrgbRead(true); > ;

    // Range
    float blendRange < Attribute("DistanceBlend_BlendRange"); > ;
    float maxDepthDelta < Attribute("DistanceBlend_MaxDistanceDelta"); > ;
    float maxEffectDistance < Attribute("DistanceBlend_MaxEffectDepth"); > ;

    float blendStart < Attribute("DistanceBlend_BlendStart"); > ;
    float blendEnd < Attribute("DistanceBlend_BlendEnd"); > ;

    // Strength
    float edgeStrength < Attribute("DistanceBlend_EdgeStrength"); > ;
    //float smoothStrength < Attribute("DistanceBlend_SmoothStrength"); > ;
    //float lerpInterpolation < Attribute("DistanceBlend_LerpInterpolation"); > ;

    float4 FindColorAtNearbyUV(float2 uv, float centerDistance, inout int blendCount)
    {
        float3 worldPosition = Depth::GetWorldPosition(uv);
        float distance = length(worldPosition - g_vCameraPositionWs);

        float depthDelta = abs(centerDistance - distance);
        if (depthDelta < maxDepthDelta)
        {
            blendCount++;

            return g_tColorBuffer.Sample(g_sDefault, uv);
        }

        return float4(0, 0, 0, 0);
    }

    float4 MainPs(PixelInput input ) : SV_Target0
    {
        // Center Pixel
        float4 centerColor = g_tColorBuffer.Sample(g_sDefault, input.uv);
        float3 centerWorldPosition = Depth::GetWorldPosition(input.uv);
        float centerDistance = length(centerWorldPosition - g_vCameraPositionWs);

        // Sample nearby pixels.
        int blendCount = 0;

        // Top Left Pixel
        float2 topLeftUV = input.uv + float2(-1 * blendRange, -1 * blendRange);
        float4 topLeftColor = FindColorAtNearbyUV(topLeftUV, centerDistance, blendCount);

        // Bottom Right Pixel
        float2 bottomRightUV = input.uv + float2(blendRange, blendRange);
        float4 bottomRightColor = FindColorAtNearbyUV(bottomRightUV, centerDistance, blendCount);

        // Top Right Pixel
        float2 topRightUV = input.uv + float2(blendRange, -1 * blendRange);
        float4 topRightColor = FindColorAtNearbyUV(topRightUV, centerDistance, blendCount);

        // Bottem Left Pixel
        float2 bottomLeftUV = input.uv + float2(-1 * blendRange, blendRange);
        float4 bottomLeftColor = FindColorAtNearbyUV(bottomLeftUV, centerDistance, blendCount);

        // Take the average of all nearby pixels at similar similar depth (defined by MaxDepthDelta)
        float4 nearbyPixelBlendedColor =
            (topLeftColor + bottomRightColor + topRightColor + bottomLeftColor) / blendCount;

        // To correct for edges we take the delta of the color and multiply it by EdgeStrength.
        // We do that so edges are kept where there is a large change in color.
        float4 colorDelta = abs(centerColor - nearbyPixelBlendedColor);
        float4 edgeCorrectedColor = colorDelta * edgeStrength;
        

        // Finally we combine everything and use lerp to smooth everything out based on distance from Camera.
        float normalizedDistance = smoothstep(centerDistance / maxEffectDistance, blendStart, blendEnd);
        float4 combinedColor = edgeCorrectedColor + nearbyPixelBlendedColor;
        float4 blendedColor = lerp(centerColor, combinedColor, normalizedDistance);

        return blendedColor;
    }
}