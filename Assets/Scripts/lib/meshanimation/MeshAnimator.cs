namespace MeshAnimation
{
    using JetBrains.Annotations;
    using UnityEngine;

    public class MeshAnimator : MonoBehaviour
    {
        [SerializeField]
        private MeshRenderer meshRenderer = default;

        [SerializeField]
        private MeshAnimationAsset meshAnimation = default;

        private MaterialPropertyBlock _propertyBlock;

        private void Awake()
        {
            _propertyBlock = new MaterialPropertyBlock();
            
            MeshCache.GenerateSecondaryUv(this.meshRenderer.GetComponent<MeshFilter>().sharedMesh);
        }

        [PublicAPI]
        public void Play(string animationName, float speed = 1f, float? normalizedTime = 0f)
        {
            meshRenderer.GetPropertyBlock(_propertyBlock);
            meshAnimation.Play(_propertyBlock, animationName, speed, normalizedTime);
            meshRenderer.SetPropertyBlock(_propertyBlock);
        }
    }
}