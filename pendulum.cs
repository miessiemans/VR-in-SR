using UnityEngine;

public class pendulum : MonoBehaviour
{
    public float length = 15.0f;
    public float gravity = 9.81f;

    public float initialAngle = 35f;

    public float theta;
    private float omega;

    
    void Start()
    {
        theta = initialAngle * Mathf.Deg2Rad;
        omega = 0f;

    }

    void Update()
    {
        float dt = Time.deltaTime;

        float alpha = -(gravity / length) * theta;


        omega += alpha * dt;
        theta += omega * dt;


        transform.localRotation = Quaternion.Euler(0f , 0f ,theta * Mathf.Rad2Deg);

    }
}
