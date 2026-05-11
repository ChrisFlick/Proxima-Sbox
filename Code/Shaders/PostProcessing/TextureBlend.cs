using System;
using System.ComponentModel;
using Sandbox;
using Sandbox.Rendering;

[Title("Texture Blend")]
[Category("Post Processing")]
[Description("Blend a texture with the current screen image state")]
[Icon("texture")]
public sealed class TextureBlend : BasePostProcess<TextureBlend>
{   
    // Texture
    [Property]
    [Category("Texture")]
    [Description("The texture that will be blended with the screens image.")]
    private Texture _blendTexture = null;


    [Property]
    [Category("Texture")]
    [Description("Intensity of the blended texture.")]
    private float _textureStrength = 0.5f;


    // Tiling
    [Property]
    [Category("Tiling")]
    private float _tiling = 2.0f;

    [Property]
    [Category("Tiling")]
    private float _xOffset = 1.0f;

    [Property]
    [Category("Tiling")]
    private float _yOffset = 1.0f;

    private Material _material;


	protected override void OnStart()
	{
		base.OnStart();

        if (_blendTexture == null)
        {
            throw new InvalidOperationException("TextureBlend: Blend texture is not assigned.");
        }

        _material = Material.FromShader("shaders/postprocessing/TextureBlend.shader");
	}

    public override void Render()
        {   
            if (_blendTexture == null)
            {
                return;
            }

            if (_material == null)
            {
                _material = Material.FromShader("shaders/postprocessing/TextureBlend.shader");
            }
            
            // Texture
            Attributes.Set("TextureBlend_BlendTexture", _blendTexture);

            // Strength
            Attributes.Set("TextureBlend_TextureStrength", _textureStrength);

            // Tiling
            Attributes.Set("TextureBlend_Tiling", _tiling);
            Attributes.Set("TextureBlend_XOffset", _xOffset);
            Attributes.Set("TextureBlend_YOffset", _yOffset);

            // Push to .shader
            BlitMode blitMode = BlitMode.Simple(
                _material, 
                Stage.AfterPostProcess, 
                500
            );

            Blit(blitMode, "Texture Blend");
        }
}
