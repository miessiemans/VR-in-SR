using UnityEngine;
using TMPro;

public class EggScoreCheck : MonoBehaviour
{
    [SerializeField] TextMeshProUGUI scoreTracker;
    public ScoreTracker script;
    private void OnEnable()
    {
        script.score +=1;
    }

}
