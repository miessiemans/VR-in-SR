using UnityEngine;

public class DopplerDemo : MonoBehaviour
{
    [Header("Target Material")]
    public Material dopplerMat;

    private float c = 30;
    private float v = 10;
    private float betaClamp = 0.99f;

    [Header("Velocity Dir")]
    public Transform velocityReference;
    public Vector3 fallbackDirection = Vector3.forward;

    public string betaProp = "_Beta";
    public string gammaProp = "_Gamma";
    public string vHatProp = "_vHat";

    [Header("Debug")]
    [SerializeField] private float beta;
    [SerializeField] private float gamma;
    [SerializeField] private Vector3 vHat;

    private void Update()
    {
        if (!dopplerMat) return;

        Vector3 dir = velocityReference ? velocityReference.forward : fallbackDirection;
        if (dir.sqrMagnitude < 1e-8f) dir = Vector3.forward;
        vHat = dir.normalized;

        float cSafe = Mathf.Max(1e-6f, c);
        float vSafe = Mathf.Max(0f, v);

        beta = Mathf.Clamp(vSafe / cSafe, 0f, betaClamp);

        float oneMinus = 1f - beta * beta;
        oneMinus = Mathf.Max(oneMinus, 1e-8f);
        gamma = 1f / Mathf.Sqrt(oneMinus);

        dopplerMat.SetFloat(betaProp, beta);
        dopplerMat.SetFloat(gammaProp, gamma);
        dopplerMat.SetVector(vHatProp, new Vector3(vHat.x, vHat.y, vHat.z));

    }


}
