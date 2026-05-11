using Sandbox;

public sealed class StylizationVolume : Component
{
    [Property]
    [Category("Light")]
    [Description("Primary Light source for the area")]
    private PrimaryLight _primaryLight = null;

    public PrimaryLight GetPrimaryLight()
    {
        return _primaryLight;
    }
}