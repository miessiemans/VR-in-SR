using UnityEngine;

public class MoveForward : MonoBehaviour
{
    public float speed = 5f;

    void Update()
    {
        Debug.Log("MoveForward running");
        transform.position += Vector3.right * speed * Time.deltaTime;
    }
}