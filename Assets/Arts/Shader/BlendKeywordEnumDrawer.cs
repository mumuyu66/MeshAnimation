using UnityEngine;
using UnityEngine.Rendering;
using UnityEditor;
using System;

#if UNITY_EDITOR
public class BlendKeywordEnumDrawer : MaterialPropertyDrawer
{
    private readonly GUIContent[] keywords;
    public enum BlendMode
    {
        ParticleAdd,
        Additive,
        Alpha,   // Old school alpha-blending mode, fresnel does not affect amount of transparency
        Premultiply, // Physically plausible transparency mode, implemented as alpha pre-multiply
        Multiply
    }

    public BlendKeywordEnumDrawer(params string[] keywords)
    {
        this.keywords = new GUIContent[keywords.Length];
        for (int i = 0; i < keywords.Length; ++i)
            this.keywords[i] = new GUIContent(keywords[i]);
    }

    static bool IsPropertyTypeSuitable(MaterialProperty prop)
    {
        return prop.type == MaterialProperty.PropType.Float || prop.type == MaterialProperty.PropType.Range;
    }

    void SetKeyword(MaterialProperty prop, int index)
    {

        for (int i = 0; i < keywords.Length; ++i)
        {
            string keyword = GetKeywordName(prop.name, keywords[i].text);
            foreach (Material material in prop.targets)
            {
                if (index == i)
                    material.EnableKeyword(keyword);
                else
                    material.DisableKeyword(keyword);
            }

        }

    }



    public override void OnGUI(Rect position, MaterialProperty prop, GUIContent label, MaterialEditor editor)
    {

        var mat = prop.targets[0] as Material;
        EditorGUI.BeginChangeCheck();

        EditorGUI.showMixedValue = prop.hasMixedValue;
        var value = (int)prop.floatValue;
        value = EditorGUI.Popup(position, label, value, keywords);
        EditorGUI.showMixedValue = false;
        if (EditorGUI.EndChangeCheck())
        {
            prop.floatValue = value;
            SetKeyword(prop, value);
        }
        SetupMaterialBlendMode(mat);
    }

    public override void Apply(MaterialProperty prop)
    {
        base.Apply(prop);
        if (!IsPropertyTypeSuitable(prop))
            return;

        if (prop.hasMixedValue)
            return;

        SetKeyword(prop, (int)prop.floatValue);
    }

    // Final keyword name: property name + "_" + display name. Uppercased,
    // and spaces replaced with underscores.
    private static string GetKeywordName(string propName, string name)
    {
        string n = propName + "_" + name;
        return n.Replace(' ', '_').ToUpperInvariant();
    }

    public static void SetupMaterialBlendMode(Material material)
    {
        if (material == null)
            throw new ArgumentNullException("material");

        BlendMode blendMode = (BlendMode)material.GetFloat("_Blend");
        var queue = (int)UnityEngine.Rendering.RenderQueue.Transparent;
        // Specific Transparent Mode Settings

        switch (blendMode)
        {
            case BlendMode.ParticleAdd:
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                //material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                break;
            case BlendMode.Alpha:
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.SrcAlpha);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                //material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                break;
            case BlendMode.Premultiply:
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.OneMinusSrcAlpha);
                //material.EnableKeyword("_ALPHAPREMULTIPLY_ON");
                break;
            case BlendMode.Additive:
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.One);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.One);
                //material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                break;
            case BlendMode.Multiply:
                material.SetInt("_SrcBlend", (int)UnityEngine.Rendering.BlendMode.DstColor);
                material.SetInt("_DstBlend", (int)UnityEngine.Rendering.BlendMode.Zero);
                //material.DisableKeyword("_ALPHAPREMULTIPLY_ON");
                //material.EnableKeyword("_ALPHAMODULATE_ON");
                break;
        }

    }


}
#endif