using System;
using System.ComponentModel;
using Sandbox;

[Title("Depth Blend")]
[Category("Post Processing")]
[Description("Blends pixels at a distance")]
[Icon("grain")]
public sealed class DepthBlend : BasePostProcess
{
    // Effect Range
    [Property]
    [Category("Range")]
    [Description("The range of nearby pixels that get blended in.")]
    private float _blendRange = 1;

    [Property]
    [Category("Range")]
    [Description("The maximum difference of pixel depth before we ignore the color.")]
    private float _maxDepthDelta = 20f;

    [Property]
    [Category("Range")]
    [Description("At this distance the effect will be in full use.")]
    private float _maxEffectDepth= 100f;

    [Property, Range(0f, 1f)]
    [Category("Range")]
    [Description("The starting point of the effects smoothing.")]
    private float _blendStart = 0f;

    [Property, Range(0f, 1f)]
    [Category("Range")]
    [Description("The end point of the effects smoothing.")]
    private float _blendEnd = 1f;

    // Effect Strength
    [Property, Range(0f, 1f)]
    [Category("Strength")]
    [Description("How much edges are maintained.")]
    private float _edgeStrength = 0.08f;

    [Property, Range(0f, 1f)]
    [Category("Strength")]
    [Description("How much of the original image is added back in.")]
    private float _smoothStrength = 0.5f;

    [Property]
    [Category("Strength")]
    [Description("How far between the original pixel color the blended color is.")]
    private float _lerpInterpolation = 0.5f;

    private Material _material;

    protected override void OnEnabled()
    {
        _material = Material.FromShader("Shaders/PostProcessing/DepthBlend.shader");
    }
    
	public override void Render()
	{
        // Effect Range
		Attributes.Set("DepthBlend_BlendRange", _blendRange);
        Attributes.Set("DepthBlend_MaxDepthDelta", _maxDepthDelta);
        Attributes.Set("DepthBlend_MaxEffectDepth", _maxEffectDepth);

        Attributes.Set("DepthBlend_BlendStart", _blendStart);
        Attributes.Set("DepthBlend_BlendEnd", _blendEnd);

        // Effect Strength
        Attributes.Set("DepthBlend_EdgeStrength", _edgeStrength);
        Attributes.Set("DepthBlend_SmoothStrength", _smoothStrength);
        Attributes.Set("DepthBlend_LerpInterpolation", _lerpInterpolation);

        // Push to .shader
        if (_material == null)
        {
            _material = Material.FromShader("Shaders/PostProcessing/DepthBlend.shader");
        }

        BlitMode blitMode = BlitMode.WithBackbuffer(_material, Sandbox.Rendering.Stage.AfterPostProcess, 200, false);
        Blit(blitMode, "Depth Blend");
	}
}