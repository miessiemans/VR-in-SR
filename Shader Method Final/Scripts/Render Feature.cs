using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Rendering.Universal;
using UnityEngine.Rendering.RenderGraphModule;

public class RelativisticRenderFeatureFinal : ScriptableRendererFeature
{
    [System.Serializable]
    public class Settings
    {
        public Material material = null;
        public RenderPassEvent renderPassEvent = RenderPassEvent.AfterRenderingPostProcessing;
    }

    public Settings settings = new Settings();
    private RelativisticPass pass;

    public override void Create()
    {
        if (settings.material == null)
        {
            Debug.LogError("RelativisticRenderFeature: Material is not assigned!");
            return;
        }

        pass = new RelativisticPass(settings);
        pass.renderPassEvent = settings.renderPassEvent;
    }

    public override void AddRenderPasses(ScriptableRenderer renderer, ref RenderingData renderingData)
    {
        if (settings.material == null || pass == null)
            return;

        renderer.EnqueuePass(pass);
    }

    protected override void Dispose(bool disposing)
    {
        pass?.Dispose();
    }

    class RelativisticPass : ScriptableRenderPass
    {
        private Settings settings;

        private class PassData
        {
            internal Material material;
            internal TextureHandle source;
        }

        public RelativisticPass(Settings settings)
        {
            this.settings = settings;
            profilingSampler = new ProfilingSampler("Relativistic Effect");
        }

        public override void RecordRenderGraph(RenderGraph renderGraph, ContextContainer frameData)
        {
            if (settings.material == null)
                return;

            UniversalResourceData resourceData = frameData.Get<UniversalResourceData>();
            UniversalCameraData cameraData = frameData.Get<UniversalCameraData>();

            if (resourceData == null || cameraData == null)
                return;

            var controller = cameraData.camera.GetComponent<RelativisticCameraURP>();
            if (controller == null || !controller.enabled)
                return;

            float beta = controller.SpeedFraction;
            float gamma = beta < 0.001f ? 1f : 1f / Mathf.Sqrt(1f - beta * beta);
            Vector3 velocityDir = controller.VelocityDirection;

            float displayFOV = controller.DisplayFOV;
            float captureFOV = cameraData.camera.fieldOfView;

            settings.material.SetFloat("_Beta", beta);
            settings.material.SetFloat("_Gamma", gamma);
            settings.material.SetVector("_VelocityDir", velocityDir);
            settings.material.SetFloat("_DisplayFOV", displayFOV);
            settings.material.SetFloat("_CaptureFOV", captureFOV);

            var equirect = controller.EquirectTexture;
            if (equirect == null || !equirect.IsCreated())
                return;

            settings.material.SetTexture("_EquirectTex", equirect);

            TextureHandle source = resourceData.activeColorTexture;

            RenderTextureDescriptor desc = cameraData.cameraTargetDescriptor;
            desc.depthBufferBits = 0;
            desc.msaaSamples = 1;

            TextureHandle destination = UniversalRenderer.CreateRenderGraphTexture(
                renderGraph, desc, "_RelativisticDest", false);

            using (var builder = renderGraph.AddRasterRenderPass<PassData>(
                "Relativistic Effect", out var passData, profilingSampler))
            {
                passData.material = settings.material;
                passData.source = source;

                builder.UseTexture(source, AccessFlags.Read);
                builder.SetRenderAttachment(destination, 0, AccessFlags.Write);

                builder.SetRenderFunc((PassData data, RasterGraphContext context) =>
                {
                    Blitter.BlitTexture(context.cmd, data.source,
                        new Vector4(1, 1, 0, 0), data.material, 0);
                });
            }

            using (var builder = renderGraph.AddRasterRenderPass<PassData>(
                "Relativistic Copy Back", out var passData2, profilingSampler))
            {
                passData2.source = destination;

                builder.UseTexture(destination, AccessFlags.Read);
                builder.SetRenderAttachment(source, 0, AccessFlags.Write);

                builder.SetRenderFunc((PassData data, RasterGraphContext context) =>
                {
                    Blitter.BlitTexture(context.cmd, data.source,
                        new Vector4(1, 1, 0, 0), 0.0f, false);
                });
            }
        }

        public void Dispose() { }
    }
}