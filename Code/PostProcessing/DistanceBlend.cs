using System;
using System.ComponentModel;
using Sandbox;

[Title("Distance Blend")]
[Category("Post Processing")]
[Description("Blends pixels at a distance")]
[Icon("grain")]
public sealed class DistanceBlend : BasePostProcess<DistanceBlend>
{
    // Effect Range
    [Property]
    [Category("Range")]
    [Description("The range of nearby pixels that get blended in.")]
    private float _blendRange = 0.25f;

    [Property]
    [Category("Range")]
    [Description("The maximum difference of pixel depth before we ignore the color.")]
    private float _maxDepthDelta = 5f;

    [Property]
    [Category("Range")]
    [Description("At this distance the effect will be in full use.")]
    private float _maxEffectDepth= 1000f;

    [Property, Range(0f, 1f)]
    [Category("Range")]
    [Description("The starting point of the effects smoothing.")]
    private float _blendStart = 0.1f;

    [Property, Range(0f, 1f)]
    [Category("Range")]
    [Description("The end point of the effects smoothing.")]
    private float _blendEnd = 1f;

    // Effect Strength
    [Property, Range(0f, 1f)]
    [Category("Strength")]
    [Description("How much edges are maintained.")]
    private float _edgeStrength = 0.08f;


    private Material _material;

    protected override void OnEnabled()
    {
        _material = Material.FromShader("Shaders/PostProcessing/DepthBlend.shader");
    }
    
	public override void Render()
	{
        // Effect Range
		Attributes.Set("DistanceBlend_BlendRange", _blendRange);
        Attributes.Set("DistanceBlend_MaxDistanceDelta", _maxDepthDelta);
        Attributes.Set("DistanceBlend_MaxEffectDepth", _maxEffectDepth);

        Attributes.Set("DistanceBlend_BlendStart", _blendStart);
        Attributes.Set("DistanceBlend_BlendEnd", _blendEnd);

        // Effect Strength
        Attributes.Set("DistanceBlend_EdgeStrength", _edgeStrength);

        // Push to .shader
        if (_material == null)
        {
            _material = Material.FromShader("Shaders/PostProcessing/DepthBlend.shader");
        }

        BlitMode blitMode = BlitMode.WithBackbuffer(_material, Sandbox.Rendering.Stage.AfterPostProcess, 200, false);
        Blit(blitMode, "Depth Blend");
	}
}