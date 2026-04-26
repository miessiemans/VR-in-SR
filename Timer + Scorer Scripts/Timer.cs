using UnityEngine;
using TMPro;

public class Timer : MonoBehaviour
{
    public RelativisticCameraURP rc; //public field requiring main camera gameobject 
    
    [SerializeField] TextMeshProUGUI userTimer; //public field requiring textbox gameobject for Viewer time (moving observer)
    [SerializeField] TextMeshProUGUI quayTimer; //public field requiring textbox gameobject for Thames time (stationary observer)
    float elapsedUserTime;
    float elapsedQuayTime;
    float gamma;

    void Update()
    {
       HandleUserTime();
       HandleQuayTime();
    }
    private void HandleUserTime()
    {
        elapsedUserTime += Time.deltaTime; //track time
        
        //Split time into minutes and seconds
        int minutes = Mathf.FloorToInt(elapsedUserTime / 60);
        int seconds = Mathf.FloorToInt(elapsedUserTime % 60);
        userTimer.text = string.Format("{0:00}:{1:00}", minutes, seconds); //formats timer into minutes:seconds
    }
    private void HandleQuayTime()
    {
        gamma = 1 / Mathf.Sqrt(1 - (rc.spd * rc.spd));
        elapsedQuayTime += (Time.deltaTime/gamma);
        int minutes = Mathf.FloorToInt(elapsedQuayTime / 60);
        int seconds = Mathf.FloorToInt(elapsedQuayTime % 60);
        quayTimer.text = string.Format("{0:00}:{1:00}", minutes, seconds);
    }
}
