using UnityEngine;
using UnityEngine.XR;

public class OculusController : MonoBehaviour
{
    [Header("Movement Settings")]
    [SerializeField] private float acceleration = 0.05f; 
    [SerializeField] private float deceleration = 0.1f; 


    private readonly float[] velocity_presets = new float[]
    {
        0.1f, 0.2f, 0.3f, 0.4f, 0.5f, 0.6f, 0.7f, 0.8f, 0.9f
    };

    private float current_speed = 0f;
    private float? target_speed = null;

    private InputDevice leftController;
    private InputDevice rightController;


    private bool leftFound = false;
    private bool rightFound = false;

    private bool leftStickUsed = false;

}