using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using System;
using System.Collections.Generic;

public class OutlineFeature : ScriptableRendererFeature
{
    [Serializable]
    public class Settings
    {
        public Color color = Color.white;
        [Range(0,1.0f)]
        public float transparency = 1.0f;
    }


    class OutlinePass : ScriptableRenderPass
    {
        const string m_ProfilerTag = "Outline Pass";
        const string m_ShaderTagString = "CullColorPass";
        FilteringSettings m_FilteringSettings;
        RenderStateBlock m_RenderStateBlock;
        ShaderTagId m_ShaderTagIdList;
        ProfilingSampler m_ProfilingSampler;
        Color color;
        float transparency;

        public OutlinePass(Settings settings)
        {
            m_ProfilingSampler = new ProfilingSampler(m_ProfilerTag);
            m_ShaderTagIdList = new ShaderTagId(m_ShaderTagString);
            renderPassEvent = RenderPassEvent.BeforeRenderingPostProcessing;
            int layerIndex = 0;
            int layerMask = 1 << layerIndex;
            m_FilteringSettings = new FilteringSettings(RenderQueueRange.all, layerMask);
            m_RenderStateBlock = new RenderStateBlock(RenderStateMask.Nothing);
            this.color = settings.color;
            this.transparency = settings.transparency;
        }
        

        // This method is called before executing the render pass.
        // It can be used to configure render targets and their clear state. Also to create temporary render target textures.
        // When empty this render pass will render to the active camera render target.
        // You should never call CommandBuffer.SetRenderTarget. Instead call <c>ConfigureTarget</c> and <c>ConfigureClear</c>.
        // The render pipeline will ensure target setup and clearing happens in a performant manner.
        public override void OnCameraSetup(CommandBuffer cmd, ref RenderingData renderingData)
        {
           

        }

        // Here you can implement the rendering logic.
        // Use <c>ScriptableRenderContext</c> to issue drawing commands or execute command buffers
        // https://docs.unity3d.com/ScriptReference/Rendering.ScriptableRenderContext.html
        // You don't have to call ScriptableRenderContext.submit, the render pipeline will call it at specific points in the pipeline.
        public override void Execute(ScriptableRenderContext context, ref RenderingData renderingData)
        {
            CommandBuffer cmd = CommandBufferPool.Get(m_ProfilerTag);
            using(new ProfilingScope(cmd,m_ProfilingSampler))
            {
                cmd.SetGlobalColor("_CullColor", color);
                cmd.SetGlobalFloat("_CullTransparency", transparency);
                Camera camera = renderingData.cameraData.camera;
                var sortFlags = renderingData.cameraData.defaultOpaqueSortFlags;
                var drawSettings = CreateDrawingSettings(m_ShaderTagIdList, ref renderingData, sortFlags);
                var filterSettings = m_FilteringSettings;
                context.DrawRenderers(renderingData.cullResults, ref drawSettings, ref filterSettings, ref m_RenderStateBlock);
            }
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        // Cleanup any allocated resources that were created during the execution of this render pass.
        public override void OnCameraCleanup(CommandBuffer cmd)
        {
        }
    }

    public Settings settings;
    OutlinePass m_OutlinePass;


    /// <inheritdoc/>
    public override void Create()
    {

        m_OutlinePass = new OutlinePass(settings);
    }

    // Here you can inject one or multiple render passes in the renderer.
    // This method is called when setting up the renderer once per-camera.
    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        renderer.EnqueuePass(m_OutlinePass);
    }
}


