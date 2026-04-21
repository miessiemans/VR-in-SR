using UnityEngine;

public class LoopTeleport : MonoBehaviour
{
    public Transform player;
    public Transform loopStart;

    private void OnTriggerEnter(Collider other)
    {
        if (other.transform == player)
        {
            Vector3 offset = player.position - transform.position;
            player.position = loopStart.position + offset;
        }
    }
}