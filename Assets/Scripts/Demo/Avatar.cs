using UnityEngine;
using System.Collections;
using MeshAnimation;


public class Avatar: MonoBehaviour
{
   public MeshAnimator animator;
    void Start()
    {
        animator.Play("NightmareWizard_Idle");
    }

    private void Update()
    {
        
    }

    private void OnGUI()
    {
        
    }
}
