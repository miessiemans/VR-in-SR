using UnityEngine;
using TMPro;

public class Timer : MonoBehaviour
{
    public RelativisticCameraURP rc; //public field requiring main camera gameobject 
    
    [SerializeField] TextMeshProUGUI properTimer; //public field requiring textbox gameobject for Viewer time (moving observer)
    [SerializeField] TextMeshProUGUI dilatedTimer; //public field requiring textbox gameobject for Thames time (stationary observer)
    float elapsedProperTime;
    float elapsedDilatedTime;
    float gamma;

    void Update()
    {
       HandleProperTime();
       HandleDilatedTime();
    }
    private void HandleProperTime()
    {
        elapsedProperTime += Time.deltaTime; //track time
        
        //Split time into minutes and seconds
        int minutes = Mathf.FloorToInt(elapsedProperTime / 60);
        int seconds = Mathf.FloorToInt(elapsedProperTime % 60);
        properTimer.text = string.Format("{0:00}:{1:00}", minutes, seconds); //formats timer into minutes:seconds
    }
    private void HandleDilatedTime()
    {
        gamma = 1 / Mathf.Sqrt(1 - (rc.spd * rc.spd));
        elapsedDilatedTime += (Time.deltaTime * gamma);
        int minutes = Mathf.FloorToInt(elapsedDilatedTime / 60);
        int seconds = Mathf.FloorToInt(elapsedDilatedTime % 60);
        dilatedTimer.text = string.Format("{0:00}:{1:00}", minutes, seconds);
    }
}
