using UnityEngine;
using System.Collections;
using MeshAnimation;

public class MeshAnimationDemo : MonoBehaviour
{
    public MeshAnimator animator;
    void Start()
    {
        animator.Play("NightmareWizard_Attack");
    }
}
