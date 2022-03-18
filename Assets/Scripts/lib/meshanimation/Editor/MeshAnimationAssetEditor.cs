using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using MeshAnimation;

[CustomEditor(typeof(MeshAnimationAsset))]
public class MeshAnimationAssetEditor : Editor
{
    public override void OnInspectorGUI()
    {
        serializedObject.Update();
        DrawDefaultInspector();
        GUILayout.Space(EditorGUIUtility.singleLineHeight);

        if (GUILayout.Button("Bake", GUILayout.Height(40)))
        {
            MeshAnimationBaker.Bake((MeshAnimationAsset)serializedObject.targetObject);
        }
        if (GUILayout.Button("Clear", GUILayout.Height(40)))
        {
            MeshAnimationBaker.Clear((MeshAnimationAsset)serializedObject.targetObject);
        }

        serializedObject.ApplyModifiedProperties();
    }
    
}
