using Sandbox;

[Title("Primary Light")]
[Category("Stylization")]
[Description("Contains all information about a Primary Light for stylization.")]
[Icon("brightness_high")]
public sealed class PrimaryLight : Component
{
	[Property]
	[Category("Effect")]
	[Description("Color of Back Glow derived from this light source")]
	private Color _haloColor = new Color(1.00f, 0.94f, 0.37f, 1.00f);


	public Color GetHaloColor()
	{
		return _haloColor;
	}
}