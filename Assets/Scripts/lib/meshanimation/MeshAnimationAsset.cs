namespace MeshAnimation
{
    using System;
    using System.Collections.Generic;
    using UnityEngine;

    [CreateAssetMenu(menuName = "Mesh Animation")]
    public class MeshAnimationAsset : ScriptableObject
    {
        [SerializeField]
        internal GameObject skin = default;

        [SerializeField]
        internal Shader shader = default;

        [SerializeField]
        internal Material materialPreset = default;

        [SerializeField]
        internal bool npotBakedTexture = false;

        [SerializeField]
        internal AnimationClip[] animationClips = new AnimationClip[0];

        [SerializeField]
        internal List<ExtraMaterial> extraMaterials = new List<ExtraMaterial>();

        [SerializeField]
        internal Texture2D bakedTexture = default;

        [SerializeField]
        internal Material bakedMaterial = default;

        [SerializeField]
        internal List<ExtraMaterialData> extraMaterialData = new List<ExtraMaterialData>();

        [SerializeField]
        internal List<AnimationData> animationData = new List<AnimationData>();

        [Serializable]
        internal class ExtraMaterial
        {
            public string name;

            public Material preset;
        }

        [Serializable]
        internal class ExtraMaterialData
        {
            public string name;
            public Material material;
        }

        [Serializable]
        internal class AnimationData
        {
            public string name;
            public float startFrame;
            public float lengthFrames;
            public float lengthSeconds;
            public bool looping;
        }

        public bool IsInvalid => GetValidationMessage() != null;

        public string GetValidationMessage()
        {
            if (animationClips.Length == 0) return "No animation clips";

            foreach (var clip in animationClips)
            {
                if (clip == null) return "Animation clip is null";
                if (clip.legacy) return "Legacy Animation clips not supported";
            }

            if (shader == null) return "shader is null";
            if (skin == null) return "skin is null";

            var skinnedMeshRenderer = skin.GetComponentInChildren<SkinnedMeshRenderer>();
            if (skinnedMeshRenderer == null) return "skin.GetComponentInChildren<SkinnedMeshRenderer>() == null";

            var skinAnimator = skin.GetComponent<Animator>();
            if (skinAnimator == null) return "skin.GetComponent<Animator>() == null";
            if (skinAnimator.runtimeAnimatorController == null)
                return "skin.GetComponent<Animator>().runtimeAnimatorController == null";

            return null;
        }

#if UNITY_EDITOR

        private void Bake()
        {
            MeshAnimationBaker.Bake(this);
        }

        private void Clear()
        {
            MeshAnimationBaker.Clear(this);
        }
#endif
    }
}