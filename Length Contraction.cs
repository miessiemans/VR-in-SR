using UnityEngine;

public class LengthContraction : MonoBehaviour
{
    [SerializeField] private float lorentzFactor = 1f;
    [SerializeField] private float velocity = 5f;
    private float beta;
    private int c = 30;
    private float initialScale;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        initialScale = transform.localScale.x;
    }

    // Update is called once per frame
    void Update()
    {
        CalcLorentzFactor();
        ChangeLength();
        transform.Translate(velocity*Time.deltaTime, 0, 0);
    }
    private void CalcLorentzFactor()
    {
        beta = velocity/c;
        lorentzFactor = 1/(Mathf.Sqrt(1 - (beta*beta)));
    }
    private void ChangeLength()
    {
        transform.localScale = new Vector3(initialScale/lorentzFactor, 1, 1);
    }
}
