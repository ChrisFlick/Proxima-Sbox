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

    // Textures
    Texture2D g_tColorBuffer < Attribute("ColorBuffer"); SrgbRead(true); > ;
    Texture2D blendTexture < Attribute("TextureBlend_BlendTexture"); SrgbRead(false); > ;

    // Tiling
    float tiling < Attribute("TextureBlend_Tiling"); > ;
    float xOffset < Attribute("TextureBlend_XOffset"); > ;
    float yOffset < Attribute("TextureBlend_YOffset"); > ;

    float4 MainPs(PixelInput input ) : SV_Target0
    {
        float4 sceneColor = g_tColorBuffer.Sample(g_sDefault, input.uv);

        // Blend Texture
        float2 textureUV = input.uv * tiling;
        textureUV += float2(xOffset, yOffset);
        float4 blendColor = blendTexture.Sample(g_sBilinearWrap, textureUV);

        return sceneColor * blendColor;
    }
}