using UnityEngine;

public class WaterScroll : MonoBehaviour
{
    [Header("Assign your water material here")]
    public Material waterMaterial;

    [Header("Scroll speed (UV offset per second)")]
    public Vector2 scrollSpeed = new Vector2(0.02f, 0.01f);

    // URP/Lit uses _BaseMap for the main texture tiling/offset
    private static readonly int BaseMapId = Shader.PropertyToID("_BaseMap");

    void Update()
    {
        if (waterMaterial == null) return;

        Vector2 offset = waterMaterial.GetTextureOffset(BaseMapId);
        offset += scrollSpeed * Time.deltaTime;
        waterMaterial.SetTextureOffset(BaseMapId, offset);
    }
}