using UnityEngine;

public class RelativityManager : MonoBehaviour
{
    public Transform boat;
    public float c = 30f;
    public float betaClamp = 0.99f;

    Vector3 _lastPos;
    Vector3 _velWS;

    private void Start()
    {
        if (boat) _lastPos = boat.position;

    }

    public void Update()
    {
        if (!boat) return;

        float dt = Mathf.Max(Time.deltaTime, 1e-6f);
        _velWS = (boat.position - _lastPos) / dt;
        _lastPos = boat.position;

        Vector3 betaVec = _velWS / Mathf.Max(c, 1e-6f);
        float beta = Mathf.Clamp(betaVec.magnitude, 0f, betaClamp);
        Vector3 vhat = beta > 1e-6f ? betaVec / betaVec.magnitude : Vector3.forward;

        float gamma = 1f / Mathf.Sqrt(1f - beta * beta);

        Shader.SetGlobalVector("_BetaVecWS", new Vector3(betaVec.x, betaVec.y, betaVec.z));
        Shader.SetGlobalFloat("_Beta", beta);
        Shader.SetGlobalFloat("_Gamma", gamma);
        Shader.SetGlobalVector("¡ª¡ªVHatWS", new Vector3(vhat.x, vhat.y, vhat.z));


    }
}
