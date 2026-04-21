using UnityEngine;

public class WaterFlow : MonoBehaviour
{
    public float speedX = 0.05f;
    public float speedY = 0.02f;

    private Renderer rend;

    void Start()
    {
        rend = GetComponent<Renderer>();
    }

    void Update()
    {
        float offsetX = Time.time * speedX;
        float offsetY = Time.time * speedY;

        rend.material.mainTextureOffset = new Vector2(offsetX, offsetY);
    }
}