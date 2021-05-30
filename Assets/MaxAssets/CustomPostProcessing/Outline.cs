using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.HighDefinition;
using System;

[Serializable, VolumeComponentMenu("Post-processing/Custom/Outline")]
public sealed class Outline : CustomPostProcessVolumeComponent, IPostProcessComponent
{
    public ClampedFloatParameter distance = new ClampedFloatParameter(0f, 0f, 10000f);

    [Tooltip("Controls the intensity of the effect.")]
    public ClampedFloatParameter mix = new ClampedFloatParameter(0f, 0f, 1f);

    public ClampedIntParameter thickness = new ClampedIntParameter(1, 1, 5);

    public ClampedFloatParameter edge = new ClampedFloatParameter(1f, 0f, 5f);

    public ClampedFloatParameter transitionSmoothness = new ClampedFloatParameter(.2f, 0f, 1f);

    public ColorParameter edgeColor = new ColorParameter(Color.black);

    Material m_Material;

    public bool IsActive() => m_Material != null && mix.value > 0f;

    // Do not forget to add this post process in the Custom Post Process Orders list (Project Settings > HDRP Default Settings).
    public override CustomPostProcessInjectionPoint injectionPoint => CustomPostProcessInjectionPoint.AfterPostProcess;

    const string kShaderName = "Hidden/Shader/Outline";

    public override void Setup()
    {
        if (Shader.Find(kShaderName) != null)
            m_Material = new Material(Shader.Find(kShaderName));
        else
            Debug.LogError($"Unable to find shader '{kShaderName}'. Post Process Volume Outline is unable to load.");
    }

    public override void Render(CommandBuffer cmd, HDCamera camera, RTHandle source, RTHandle destination)
    {
        if (m_Material == null)
            return;

        m_Material.SetFloat("_Distance", distance.value);
        m_Material.SetFloat("_Mix", mix.value);
        m_Material.SetFloat("_Thickness", thickness.value);
        m_Material.SetFloat("_Edge", edge.value);
        m_Material.SetFloat("_TransitionSmoothness", transitionSmoothness.value);
        m_Material.SetColor("_Color", (Color) edgeColor);


        m_Material.SetTexture("_InputTexture", source);
        HDUtils.DrawFullScreen(cmd, m_Material, destination);
    }

    public override void Cleanup()
    {
        CoreUtils.Destroy(m_Material);
    }
}
