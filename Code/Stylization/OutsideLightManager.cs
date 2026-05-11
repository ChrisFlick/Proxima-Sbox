using System;
using System.ComponentModel;
using Sandbox;

[Title("Primary Light Manager")]
[Category("Stylization")]
[Description("Keeps track of all Outside Primary Light used for styilization effects.")]
[Icon("assignment")]
public sealed class OutsideLightManager : Sandbox.Component
{
	public static OutsideLightManager Instance { get; private set; }

	[Property]
	[Category("Defaults")]
	[Description("Back Glow color when outside")]
	private Color _outsideHaloColor = new Color(1.00f, 0.94f, 0.37f, 1.00f);

	protected override void OnStart()
	{
		base.OnStart();

		if (Instance != null)
		{
			return;
		}

		Instance = this;

	}

	// Outside Light
	public Color GetHaloColor()
	{
		return _outsideHaloColor;
	}

	public Vector3 GetOutsideLightDirection()
	{
		return -WorldRotation.Forward;
	}
}