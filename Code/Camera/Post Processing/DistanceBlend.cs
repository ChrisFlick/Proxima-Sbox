using Sandbox;

public sealed class DistanceBlend : BasePostProcess
{
    // Effect Range
    [Property]
    [Category("Range")]
    [Description("At this distance the effect will be in full use.")]
    private float _maxEffectDistance = 100f;

    [Property, Range(0f, 1f)]
    [Category("Range")]
    [Description("The starting point of the effects smoothing")]
    private float _blendStart = 0f;

    [Property, Range(0f, 1f)]
    [Category("Range")]
    [Description("The end point of the effects smoothing")]
    private float _blendEnd = 1f;

    // Effect Strength
    [Property, Range(0f, 1f)]
    [Category("Strength")]
    [Description("How much edges are maintained")]
    private float _edgeStrength = 0.08f;

    [Property, Range(0f, 1f)]
    [Category("Strength")]
    [Description("How much of the original image is added back in")]
    private float _smoothStrength = 0.5f;

    
	public override void Render()
	{
		throw new System.NotImplementedException();
	}
}