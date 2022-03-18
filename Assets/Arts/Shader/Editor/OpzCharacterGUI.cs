using System.Collections;

using System.Collections.Generic;

using UnityEngine;

using UnityEditor;



public class OpzCharacterGUI : ShaderGUI

{

    public static string CHARACTER = "Toon/TA/Opz_Sha_BattleCharacter_StencilOutline";

    public static string SCENE = "Toon/TA/Opz_Sha_BattleScene";

    public enum Specular

    {

        Off = 0,

        Isotropic = 1,

        Anisotropic = 2

    };



    public enum SmoothedNormalChannel

    {

        Origin = 0,

        Tangent = 1,

        UV2 = 2,

        VertexColor = 3

    }



    public enum ZTest

    {

        Always = 0,

        Equal = 1,

        GEqual = 2,

        Greater = 3,

        LEqual = 4,

        Less = 5,

        NotEqual = 6



    }



    MaterialEditor m_MaterialEditor;



    public GUILayoutOption[] shortButtonStyle = new GUILayoutOption[] { GUILayout.Width(130) };

    public GUILayoutOption[] middleButtonStyle = new GUILayoutOption[] { GUILayout.Width(130) };





    static bool _BasicShaderSettings_Foldout = true;

    static bool _ReceiveShadows = false;

    static bool _PBR_Foldout = true;

    static bool _CellShading_Foldout = false;

    static bool _RimLighting_Foldout = false;

    static bool _OutlineSettings_Foldout = true;







    static string[] SpecularMode = new string[] { "关闭", "各项同性", "各项异性" };

    static string[] SmoothNormalInChannel = new string[] { "原法线", "切线空间", "UV2", "顶点颜色" };



    //bool enableNormalMap = false;

    bool isCharacterShader = true;



    MaterialProperty receiveShadow = null;

    MaterialProperty mainTex = null;

    MaterialProperty mainColor = null;

    MaterialProperty enableNormalMap = null;

    MaterialProperty normalMap = null;

    MaterialProperty normalScale = null;

    MaterialProperty specularIntensity = null;

    MaterialProperty specularMode = null;

    MaterialProperty anisotropy = null;

    MaterialProperty enableMetallicMap = null;

    MaterialProperty metallicMap = null;

    MaterialProperty metallic = null;

    MaterialProperty smoothness = null;

    MaterialProperty aoStrength = null;

    MaterialProperty occlusionStrength = null;

    MaterialProperty enableEmissionMap = null;

    MaterialProperty emissionMap = null;

    MaterialProperty emssion = null;

    MaterialProperty diffuseSmoothness = null;

    MaterialProperty specularSmoothness = null;

    MaterialProperty lightBands = null;

    MaterialProperty lightBandScale = null;

    MaterialProperty lightThreshold = null;

    MaterialProperty enableCelSpec = null;

    MaterialProperty specularLightThreshold = null;

    MaterialProperty goochBrightColor = null;

    MaterialProperty goochDarkColor = null;

    MaterialProperty rim = null;

    MaterialProperty rimColor = null;

    MaterialProperty rimPower = null;

    MaterialProperty stencilRef = null;

    MaterialProperty normalChannel = null;

    MaterialProperty outlineWidth = null;

    MaterialProperty outlineColor = null;

    MaterialProperty offsetZ = null;

    MaterialProperty enablePBRShading = null;











    private static class Styles

    {

        public static readonly GUIContent albedo = new GUIContent("漫反射贴图", "漫反射贴图 : 这里存放漫反射贴图");

        public static readonly GUIContent normalMap = new GUIContent("法线贴图", "法线贴图 : 这里存放法线贴图");

        public static readonly GUIContent metallicMap = new GUIContent("金属度贴图", "a通道存金属度，g通道存occlusion，b通道存粗糙度，a通道存自发光遮罩");

        public static readonly GUIContent emissionMap = new GUIContent("自发光贴图", "当开启自发光贴图后，自发光颜色等于自发光的颜色乘自发光贴图的颜色");

        public static readonly GUIContent bandsSlider = new GUIContent("数量",

                "控制色阶数量.");

        public static readonly GUIContent stencilSlider = new GUIContent("模板测试值", "如果不为0，则会开启描边");

    }





    public void FindProperties(MaterialProperty[] properties)

    {

        receiveShadow = FindProperty("_ReceiveShadows", properties);

        mainTex = FindProperty("_BaseMap", properties);

        mainColor = FindProperty("_BaseColor", properties);

        enableNormalMap = FindProperty("_EnableNormalMap", properties);

        normalMap = FindProperty("_BumpMap", properties);

        normalScale = FindProperty("_BumpScale", properties);

        specularMode = FindProperty("_SpecularMode", properties);

        specularIntensity = FindProperty("_SpecularIntensity", properties);

        anisotropy = FindProperty("_Anisotropy", properties);

        enableMetallicMap = FindProperty("_EnableMetallicMap", properties);

        metallicMap = FindProperty("_MetallicMap", properties);

        metallic = FindProperty("_Metallic", properties);

        smoothness = FindProperty("_Smoothness", properties);

        aoStrength = FindProperty("_AOStrength", properties);

        occlusionStrength = FindProperty("_OcclusionStrength", properties);

        enableEmissionMap = FindProperty("_EnableEmission", properties);

        emissionMap = FindProperty("_Emissionmap", properties);

        emssion = FindProperty("_EmissionColor", properties, false);

        diffuseSmoothness = FindProperty("_DiffuseSmoothness", properties);

        specularSmoothness = FindProperty("_SpecularSmoothness", properties);

        lightBands = FindProperty("_LightBands", properties);

        lightBandScale = FindProperty("_LightBandsScale", properties);

        lightThreshold = FindProperty("_LightThreshold", properties);

        enableCelSpec = FindProperty("_EnableCellSpec", properties);

        specularLightThreshold = FindProperty("_SpecularLightThreshold", properties);

        goochDarkColor = FindProperty("_GoochDarkColor", properties);

        goochBrightColor = FindProperty("_GoochBrightColor", properties);

        rim = FindProperty("_Rim", properties);

        rimColor = FindProperty("_RimColor", properties);

        rimPower = FindProperty("_RimPower", properties);



        if (isCharacterShader)

        {

            stencilRef = FindProperty("_Stencil", properties);

            normalChannel = FindProperty("_SmoothNormalInChannel", properties);

            outlineWidth = FindProperty("_OutlineWidth", properties);

            outlineColor = FindProperty("_OutlineColor", properties);

            offsetZ = FindProperty("_OffsetZ", properties);

        }

        else

        {

            enablePBRShading = FindProperty("_EnablePBRShading", properties);

        }

















    }



    public override void AssignNewShaderToMaterial(Material material, Shader oldShader, Shader newShader)

    {

        base.AssignNewShaderToMaterial(material, oldShader, newShader);

        //TODO

    }



    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)

    {

       



        EditorGUIUtility.fieldWidth = 0;

        m_MaterialEditor = materialEditor;

        Material material = materialEditor.target as Material;

        isCharacterShader = material.shader.name.Equals(CHARACTER) ? true : false;



        FindProperties(properties);



        EditorGUILayout.BeginHorizontal();

        OpenManualLink();

        EditorGUILayout.EndHorizontal();



        EditorGUI.BeginChangeCheck();

        EditorGUILayout.Space();

        _BasicShaderSettings_Foldout = Foldout(_BasicShaderSettings_Foldout, "基本设置");

        if (_BasicShaderSettings_Foldout)

        {

            EditorGUI.indentLevel++;

            EnablePBRForScene(material);

            SetBasicSettings(material);

            SetSpcularParam(material);

            EditorGUI.indentLevel--;

        }

        EditorGUILayout.Space();



        _PBR_Foldout = Foldout(_PBR_Foldout, "物理材质设置");

        if (_PBR_Foldout)

        {

            EditorGUI.indentLevel++;

            SetDiffuseColor(material);

            SetSpecular(material);

            EditorGUI.indentLevel--;

        }

        EditorGUILayout.Space();



        _CellShading_Foldout = Foldout(_CellShading_Foldout, "色阶设置");

        if (_CellShading_Foldout)

        {

            EditorGUI.indentLevel++;

            SetCelShading(material);

            EditorGUI.indentLevel--;

        }

        EditorGUILayout.Space();



        _RimLighting_Foldout = Foldout(_RimLighting_Foldout, "边缘光设置");

        if (_RimLighting_Foldout)

        {

            EditorGUI.indentLevel++;

            SetRimLighting(material);

            EditorGUI.indentLevel--;

        }

        EditorGUILayout.Space();



        if(isCharacterShader)

            CharacterShaderGUI(material);



        if (EditorGUI.EndChangeCheck())

        {

            m_MaterialEditor.PropertiesChanged();

        }





    }



    void OpenManualLink()

    {

        if (GUILayout.Button("ShaderGUI文档", middleButtonStyle))

        {

            Application.OpenURL("https://confluence.xindong.com/pages/viewpage.action?pageId=264973656");

        }

        if (GUILayout.Button("Shader文档", middleButtonStyle))

        {

            Application.OpenURL("https://confluence.xindong.com/pages/viewpage.action?pageId=260837887");

        }

    }



    static bool Foldout(bool display, string title)

    {

        var style = new GUIStyle("ShurikenModuleTitle");

        style.font = new GUIStyle(EditorStyles.boldLabel).font;

        style.border = new RectOffset(15, 7, 4, 4);

        style.fixedHeight = 22;

        style.contentOffset = new Vector2(20f, -2f);



        var rect = GUILayoutUtility.GetRect(16f, 22f, style);

        GUI.Box(rect, title, style);



        var e = Event.current;



        var toggleRect = new Rect(rect.x + 4f, rect.y + 2f, 13f, 13f);

        if (e.type == EventType.Repaint)

        {

            EditorStyles.foldout.Draw(toggleRect, false, false, display, false);

        }



        if (e.type == EventType.MouseDown && rect.Contains(e.mousePosition))

        {

            display = !display;

            e.Use();

        }



        return display;

    }



    static bool FoldoutSubMenu(bool display, string title)

    {

        var style = new GUIStyle("ShurikenModuleTitle");

        style.font = new GUIStyle(EditorStyles.boldLabel).font;

        style.border = new RectOffset(15, 7, 4, 4);

        style.padding = new RectOffset(5, 7, 4, 4);

        style.fixedHeight = 22;

        style.contentOffset = new Vector2(32f, -2f);

        var rect = GUILayoutUtility.GetRect(16f, 22f, style);

        GUI.Box(rect, title, style);



        var e = Event.current;



        var toggleRect = new Rect(rect.x + 16f, rect.y + 2f, 13f, 13f);

        if (e.type == EventType.Repaint)

        {

            EditorStyles.foldout.Draw(toggleRect, false, false, display, false);

        }



        if (e.type == EventType.MouseDown && rect.Contains(e.mousePosition))

        {

            display = !display;

            e.Use();

        }



        return display;

    }







    void SetBasicSettings(Material material)

    {

        EditorGUI.BeginChangeCheck();

        EditorGUILayout.BeginHorizontal();

        EditorGUILayout.PrefixLabel("接受阴影");

        bool enableReceiveShadow = (receiveShadow.floatValue > 0.5f);

        enableReceiveShadow = EditorGUILayout.Toggle(enableReceiveShadow);

        if (enableReceiveShadow)

        {

            material.DisableKeyword("_RECEIVE_SHADOWS_OFF");

        }

        else

        {

            material.EnableKeyword("_RECEIVE_SHADOWS_OFF");

        }

        EditorGUILayout.Space();

        EditorGUILayout.EndHorizontal();

        
        
        //if (isCharacterShader || material.HasFloat("_ZTest"))
        if (isCharacterShader) 
        {

            EditorGUILayout.BeginHorizontal();

            EditorGUILayout.PrefixLabel("取消遮挡高亮");

            bool disableCullShow = (material.GetFloat("_ZTest") == (int)ZTest.LEqual);

            if (EditorGUILayout.Toggle(disableCullShow))

            {

                material.SetFloat("_ZTest", (int)ZTest.LEqual);

                

            }

            else

            {

                material.SetFloat("_ZTest", (int)ZTest.Always);

            }

            EditorGUILayout.EndHorizontal();

            EditorGUILayout.Space();

        }

        

        

        

        if (EditorGUI.EndChangeCheck())

        {

            receiveShadow.floatValue = enableReceiveShadow ? 1.0f : 0;

        }



    }



    void SetSpcularParam(Material material)

    {

        EditorGUI.BeginChangeCheck();

        //      set specular mode

        EditorGUILayout.BeginHorizontal();

        EditorGUILayout.PrefixLabel("高光");

        int index_specularMode = (int)material.GetFloat("_SpecularMode");

        index_specularMode = EditorGUILayout.Popup(index_specularMode, SpecularMode);

        SetKeyword(index_specularMode == (int)Specular.Isotropic, "_SPECULARMODE_ISOTROPIC", material);

        SetKeyword(index_specularMode == (int)Specular.Anisotropic, "_SPECULARMODE_ANISOTROPIC", material);

        EditorGUILayout.Space();

        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();

        EditorGUILayout.PrefixLabel("开启高光分层");

        bool enableCelSpecular = EditorGUILayout.Toggle(enableCelSpec.floatValue > 0.5);

        SetKeyword(enableCelSpecular, "CELLSHADING_SPECULAR", material);

        EditorGUILayout.EndHorizontal();







        if (index_specularMode == (int)Specular.Off)

        {

            if (EditorGUI.EndChangeCheck())

            {

                specularMode.floatValue = index_specularMode;

            }

            return;

        }

           

        float specularIntensity = this.specularIntensity.floatValue;

        EditorGUILayout.BeginHorizontal();

        EditorGUI.indentLevel++;

        float value = EditorGUILayout.FloatField("高光强度", specularIntensity);



        EditorGUI.indentLevel--;

        EditorGUILayout.Space();

        EditorGUILayout.EndHorizontal();



        if (index_specularMode == (int)Specular.Anisotropic)

        {

            EditorGUILayout.BeginHorizontal();

            EditorGUI.indentLevel++;

            m_MaterialEditor.RangeProperty(anisotropy, "高光拉伸方向");

            EditorGUI.indentLevel--;

            EditorGUILayout.Space();

            EditorGUILayout.EndHorizontal();

        }



        if (EditorGUI.EndChangeCheck())

        {

            enableCelSpec.floatValue = enableCelSpecular ? 1 : 0;

            this.specularIntensity.floatValue = value < 0 ? 0 : value;

            specularMode.floatValue = index_specularMode;

        }

    }



    void EnablePBRForScene(Material  material)

    {

        if (isCharacterShader || !material.HasProperty("_EnablePBRShading"))

            return;

        EditorGUI.BeginChangeCheck();

        EditorGUILayout.BeginHorizontal();

        EditorGUILayout.PrefixLabel("开启PBR");

        bool enablePBR = EditorGUILayout.Toggle(enablePBRShading.floatValue > 0.5);

        SetKeyword(enablePBR, "_PBR_SHADING_ON", material);

        EditorGUILayout.EndHorizontal();

        if (EditorGUI.EndChangeCheck())

        {

            enablePBRShading .floatValue= enablePBR ? 1 : 0;

        }

    }



    void SetDiffuseColor(Material material)

    {

        EditorGUI.BeginChangeCheck();

        GUILayout.Label("漫反射设置", EditorStyles.boldLabel);

        EditorGUILayout.BeginHorizontal();

        m_MaterialEditor.TexturePropertySingleLine(Styles.albedo, mainTex, mainColor);

        EditorGUILayout.Space();

        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginVertical();

        EditorGUILayout.BeginHorizontal();

        EditorGUILayout.PrefixLabel("开启法线贴图");

        bool isEnabledNormalMap = EditorGUILayout.Toggle(enableNormalMap.floatValue == 1);

        SetKeyword(isEnabledNormalMap, "_NORMALMAP", material);

        EditorGUILayout.EndHorizontal();

        if (DisableNormalMap(material))

        {

            EditorGUILayout.HelpBox("不支持法线贴图，如果法线存入切线空间！", MessageType.Error);

        }



        m_MaterialEditor.TexturePropertySingleLine(Styles.normalMap, normalMap, normalMap.textureValue == null ? null : normalScale);

        EditorGUILayout.Space();

        EditorGUILayout.EndVertical();

        EditorGUILayout.Space();

        if (EditorGUI.EndChangeCheck())

        {

            enableNormalMap.floatValue = isEnabledNormalMap ? 1 : 0;

        }

    }



    void SetSpecular(Material material)

    {

        EditorGUI.BeginChangeCheck();

        GUILayout.Label("镜面反射设置", EditorStyles.boldLabel);

        EditorGUILayout.BeginHorizontal();

        EditorGUILayout.PrefixLabel("开启金属度贴图");

        bool enableMetallic = EditorGUILayout.Toggle(enableMetallicMap.floatValue > 0.5f);

        SetKeyword(enableMetallic, "_METALLICMAP", material);

        EditorGUILayout.Space();

        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginHorizontal();

        m_MaterialEditor.TexturePropertySingleLine(Styles.metallicMap, metallicMap, metallic);

        EditorGUILayout.Space();

        EditorGUILayout.EndHorizontal();

        EditorGUILayout.BeginVertical();

        m_MaterialEditor.RangeProperty(smoothness, "光滑");

        m_MaterialEditor.RangeProperty(occlusionStrength, "间接光强度");

        EditorGUILayout.Space();

        EditorGUILayout.BeginHorizontal();

        if (!enableMetallic)

        {

            EditorGUILayout.HelpBox("AO存入G通道,如果不启用金属贴图,AO遮罩强度无效", MessageType.Warning);

        }

        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();

        m_MaterialEditor.RangeProperty(aoStrength, "AO遮罩强度");

        EditorGUILayout.BeginHorizontal();

        EditorGUILayout.PrefixLabel("开启自发光贴图");

        // bool enableEmission = EditorGUILayout.Toggle(enableEmissionMap.floatValue > 0.5f);

        // SetKeyword(enableEmission, "_ENABLEEMISSION", material);

        EditorGUILayout.EndHorizontal();

        m_MaterialEditor.TexturePropertySingleLine(Styles.emissionMap, emissionMap, emssion);

        EditorGUILayout.EndVertical();

        EditorGUILayout.Space();

        if (EditorGUI.EndChangeCheck())

        {

            //enableEmissionMap.floatValue = enableEmission ? 1.0f : 0;

            enableMetallicMap.floatValue = enableMetallic ? 1.0f : 0;



        }





    }



    void SetCelShading(Material material)

    {

        if (material.HasProperty("_EnablePBRShading") && material.GetFloat("_EnablePBRShading" )>0.5)

        {

            EditorGUILayout.HelpBox("开启了PBR模式，不支持Cel Shading", MessageType.Warning);

            return;

        }



        

        GUILayout.Label("平滑程度", EditorStyles.boldLabel);

        EditorGUILayout.BeginVertical();

        m_MaterialEditor.RangeProperty(diffuseSmoothness, "漫反射平滑程度");

        m_MaterialEditor.RangeProperty(specularSmoothness, "镜面反射平滑程度");

        EditorGUILayout.EndVertical();

        EditorGUILayout.Space();

        GUILayout.Label("色块设置", EditorStyles.boldLabel);

        EditorGUILayout.BeginVertical();

        //m_MaterialEditor.RangeProperty(lightBands, "数量");

        EditorGUI.BeginChangeCheck();

        var bandsNum = EditorGUILayout.IntSlider(Styles.bandsSlider, (int)lightBands.floatValue, 2, 6);

        if (EditorGUI.EndChangeCheck())

            lightBands.floatValue = bandsNum;

        m_MaterialEditor.RangeProperty(lightBandScale, "收拢度");

        m_MaterialEditor.RangeProperty(lightThreshold, "漫反射阈值");

        m_MaterialEditor.RangeProperty(specularLightThreshold, "镜面反射阈值");

        EditorGUILayout.EndVertical();

        EditorGUILayout.Space();



        GUILayout.Label("Gooch", EditorStyles.boldLabel);

        EditorGUILayout.BeginVertical();

        m_MaterialEditor.ColorProperty(goochBrightColor, "明部颜色");

        m_MaterialEditor.ColorProperty(goochDarkColor, "暗部颜色");

        EditorGUILayout.EndVertical();

        EditorGUILayout.Space();





    }



    void SetRimLighting(Material material)

    {

        EditorGUILayout.BeginHorizontal();

        EditorGUILayout.PrefixLabel("开启边缘光");

        //if(EditorGUILayout.Toggle(rim.floatValue == 1.0f))

        //{



        //}

        bool enableRimLighting = EditorGUILayout.Toggle(rim.floatValue == 1.0f);

        SetKeyword(enableRimLighting, "_RIMLIGHTING", material);

        rim.floatValue = enableRimLighting ? 1 : 0;

        EditorGUILayout.EndHorizontal();

        EditorGUILayout.Space();



        EditorGUILayout.BeginVertical();

        m_MaterialEditor.ColorProperty(rimColor, "边缘光颜色");

        m_MaterialEditor.FloatProperty(rimPower, "边缘光强度(Power)");

        EditorGUILayout.EndVertical();

        EditorGUILayout.Space();

    }



    void SetOutline(Material material)

    {

        EditorGUI.BeginChangeCheck();

        EditorGUILayout.BeginHorizontal();

        EditorGUILayout.PrefixLabel("平滑法线存储通道");

        int index_smoothNormalInChannel = (int)normalChannel.floatValue;

        index_smoothNormalInChannel = EditorGUILayout.Popup(index_smoothNormalInChannel, SmoothNormalInChannel);

        SetKeyword(index_smoothNormalInChannel == (int)SmoothedNormalChannel.Tangent, "_SMOOTHNORMALINCHANNEL_TANGENT", material);

        SetKeyword(index_smoothNormalInChannel == (int)SmoothedNormalChannel.UV2, "_SMOOTHNORMALINCHANNEL_UV2", material);

        SetKeyword(index_smoothNormalInChannel == (int)SmoothedNormalChannel.VertexColor, "_SMOOTHNORMALINCHANNEL_VERTEXCOLOR", material);

        EditorGUILayout.EndHorizontal();



        EditorGUILayout.BeginVertical();

        //m_MaterialEditor.RangeProperty(stencilRef, "模板测试值");

        var stencilValue = EditorGUILayout.IntSlider(Styles.stencilSlider, (int)stencilRef.floatValue, 1, 255);

        m_MaterialEditor.RangeProperty(outlineWidth, "描边粗细");

        m_MaterialEditor.ColorProperty(outlineColor, "描边颜色");

        m_MaterialEditor.FloatProperty(offsetZ, "沿z轴调整描边");

        EditorGUILayout.EndVertical();

        EditorGUILayout.Space();

        if (EditorGUI.EndChangeCheck())

        {

            stencilRef.floatValue = stencilValue;

            normalChannel.floatValue = index_smoothNormalInChannel;

        }

    }



    bool DisableNormalMap(Material material)

    {

        if (!material.HasProperty("_SmoothNormalInChannel"))

            return false;

            

        float normalChannel = material.GetFloat("_SmoothNormalInChannel");

        //Debug.Log(normalChannel);

        if (normalChannel == (float)SmoothedNormalChannel.Tangent)

        {

            return true;

        }

        return false;

    }



    void CharacterShaderGUI(Material material)

    {

        _OutlineSettings_Foldout = Foldout(_OutlineSettings_Foldout, "描边设置");

        if (_OutlineSettings_Foldout)

        {

            EditorGUI.indentLevel++;

            SetOutline(material);

            EditorGUI.indentLevel--;

        }

        EditorGUILayout.Space();

    }



    internal static void SetKeyword(bool enable, string keyword, Material mat)

    {

        if (enable)

        {

            mat.EnableKeyword(keyword);

        }

        else

        {

            mat.DisableKeyword(keyword);

        }

    }





}

