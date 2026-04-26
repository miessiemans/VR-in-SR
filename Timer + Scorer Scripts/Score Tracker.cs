using UnityEngine;
using TMPro;

public class ScoreTracker : MonoBehaviour
{
    [SerializeField] TextMeshProUGUI scoreTracker;
    public int score = 0;
    private string string1 = "Secrets Found:";

    private void Start()
    {
        scoreTracker.text = string1 + score.ToString();
    }
    private void Update()
    {
        scoreTracker.text = string1 + score.ToString();
    }
}
