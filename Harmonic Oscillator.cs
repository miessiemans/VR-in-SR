using UnityEngine;

public class HarmonicO : MonoBehaviour
{
    public enum Axis { X, Y, Z, Custom}

    [Header("Motion")]
    public Axis axis = Axis.X;

    // axis = Custom, oscillation direction uses this vector
    public Vector3 customDirection = Vector3.right;

    public float amplitude = 1f;

    //Anuglar frequency omega (rad/s). 2pi means 1 Hz
    public float omega = 2f * Mathf.PI;

    //Phase phi (rad)
    public float phase = 0f;

    [Header("Time")]
    public float timeScale = 1f;

    public bool useUnscaleTime = false;

    [Header("PlayBack")]
    public bool playOnAwake = true;
    public bool loop = true;

    private Vector3 _startPos;
    private float _t;
    private bool _isPlaying;

    private void Start()
    {
        _startPos = transform.position;
        _t = 0f;
        _isPlaying = playOnAwake;

    }

    void Update()
    {
        if (!_isPlaying) return;

        float dt = useUnscaleTime ? Time.unscaledDeltaTime : Time.deltaTime;
        _t += dt * timeScale;

        //if not looping, stop after one period
        if (! loop)
        {
            float period = (omega <= 0f) ? 0f : (2f * Mathf.PI / omega);
            if (period > 0f && _t > period)
            {
                _t = period;
                _isPlaying = false;
            }
        }

        Vector3 dir = GetDirection();
        float displacement = amplitude * Mathf.Cos(omega * _t + phase);
        transform.position = _startPos + dir * displacement;
    }

    Vector3 GetDirection()
    {
        Vector3 dir = axis switch
        {
            Axis.X => Vector3.right,
            Axis.Y => Vector3.up,
            Axis.Z => Vector3. forward,
            _ => customDirection
        };

        if (dir.sqrMagnitude < 1e-6f) dir = Vector3.right;
        return dir.normalized;
    }



}
