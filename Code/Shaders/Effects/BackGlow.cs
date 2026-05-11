using System;
using System.Diagnostics;
using System.Numerics;
using Sandbox;

[Title("Back Glow")]
[Category("Shader Effects")]
[Description("Gathers information about primary lighting for Back Glow to create and update a material shared by all geometry of object and it's children.")]
[Icon("brightness_high")]
public sealed class BackGlow : Component, Component.ITriggerListener
{
	const float MAX_DISTANCE = 100000f;

	[Property]
	[Category("Halo Properties")]
	[Description("Thickness of the outline.")]
	private float _haloThickness = 0.28f;

	[Property]
	[Category("Halo Properties")]
	[Description("Intensity of backglow effect.")]
	private float _glowIntensity = 0.5f;


	// Light Source Information.
	private Color _haloColor;
	private Vector3 _lightSourcePosition;

	// Material
	private Material _material;

	private BoxCollider _boxCollider;

	private bool _isOutside;


    protected override void OnStart()
    {
		base.OnStart();

		_material = Material.FromShader("shaders/postprocessing/BackGlow.shader");

		foreach ( var collider in _boxCollider.Touching )
		{
			StylizationVolume stylizationVolume = collider.GetComponent<StylizationVolume>();

			if (stylizationVolume == null)
			{
				continue;
			}

			SetStylizationLightToPrimary(stylizationVolume);
			return;
		}

		SetOutsideLightToPrimary();
    }

	protected override void OnUpdate()
	{
		base.OnUpdate();

		if (IsLightBlocked())
		{
			return;
		}
	}


	// Gets

	public Color GetHaloColor()
	{
		return _haloColor;
	}

	public Vector3 GetLightDirection()
	{
		if (_isOutside)
		{
			return OutsideLightManager.Instance.GetOutsideLightDirection();
		}

		return (_lightSourcePosition - WorldPosition).Normal;
	}

	public bool IsLightBlocked()
	{
		Vector3 zOffset = new Vector3 (0, 0, 1);
		SceneTraceResult trace = Scene.Trace.Ray(
			WorldPosition  + zOffset,
			_lightSourcePosition
		)
			.WithoutTags("unit")
			.Run();

		return trace.Hit;
	}


	// Set Light Source
	private void SetOutsideLightToPrimary()
	{
		_haloColor = OutsideLightManager.Instance.GetHaloColor();

		Vector3 sourceDirection = OutsideLightManager.Instance.GetOutsideLightDirection();
		_lightSourcePosition = WorldPosition + sourceDirection * MAX_DISTANCE;

		_isOutside = true;
	}

	private void SetStylizationLightToPrimary(StylizationVolume stylizationVolume)
	{
		PrimaryLight primaryLight = stylizationVolume.GetPrimaryLight();

		_haloColor = primaryLight.GetHaloColor();
		_lightSourcePosition = primaryLight.WorldPosition;

		_isOutside = false;
	}


	// On Trigger Events
	public void OnTriggerEnter(Collider other)
	{
		StylizationVolume stylizationVolume = other.GetComponent<StylizationVolume>();

		if (stylizationVolume == null)
		{
			return;
		}

		Log.Info($"{this.GameObject.Name} has entered new Stylization Volume: {other.GameObject.Name}");
		
		SetStylizationLightToPrimary(stylizationVolume);
	}

	public void OnTriggerExit(Collider other)
	{
		StylizationVolume stylizationVolume = other.GetComponent<StylizationVolume>();

		if (stylizationVolume == null)
		{
			return;
		}

		SetOutsideLightToPrimary();
	}
}
