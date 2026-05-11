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
    float3 vPositionOs : POSITION < Semantic(PosXyz); > ;
    float2 vTexCoord : TEXCOORD0 < Semantic(LowPrecisionUv); > ;
};

struct PixelInput
{
    float2 uv : TEXCOORD0;

    // VS only
    #if (PROGRAM == VFX_PROGRAM_VS)
        float4 vPositionPs : SV_Position;
    #endif

    // PS only
    #if ((PROGRAM == VFX_PROGRAM_PS))
        float4 vPositionSs : SV_Position;
    #endif
};

VS
{
    PixelInput MainVs(VertexInput input)
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

    float haloThickness < Attribute("BackGlow_HaloThickness"); > ;
    float intensity < Attribute("BackGlow_Intensity"); > ;

    float4[] haloColors < Attribute("BackGlow_HaloColors"); > ;
    //float3[] subjectPositions < Attribute("BackGlow_SubjectPositions"); > ;
    //float3[] lightDirection < Attribute("BackGlow_LightDirections"); > ;

	float4 MainPs(PixelInput input) : SV_Target0
    {
        return float4(1, 0, 1, 1);
	}
}
