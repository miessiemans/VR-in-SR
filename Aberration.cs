using UnityEngine;
using UnityEngine.InputSystem;
public class Aberration : MonoBehaviour
{
    //Source and Observation points
    private Vector3 observerPos = new Vector3(0,0.25f,0);
    [SerializeField] private Vector3 vertexDir; //Direction of ray between observer and a point
    private float nxPrime;
    private float nyPrime;
    private float nzPrime;
    
    //Lorentz factor values
    [SerializeField] private float velocity = 0f;
    private float c = 10f;
    [SerializeField] private float beta;
    
    //Spherical Coordinates
    private float r;
    private float cosThetaPrime;
    private float sinThetaPrime;
    private float phi;

    //S Frame values
    private Vector3 positionInSFrame;

    //Input controller
    public InputActionAsset InputActions;
    private InputAction accelerate_Action;
    private float acceleration;

    private void OnEnable()
    {
        InputActions.FindActionMap("Observer").Enable();
    }
    private void Awake()
    {
        accelerate_Action = InputSystem.actions.FindAction("accelerate");
    }
    
    void Start()
    {
        positionInSFrame = transform.position;
    }

   void Update()
    {
        Accelerate();
        Update_SFrame();
        CalcBeta();
        CalcThetaPrimeIdentities();
        ConvertToSphericalCoords();
        Aberrate();
        transform.Translate(velocity*Time.deltaTime, 0, 0);
    }
    private void CalcBeta()
    {
        beta = velocity/c;
    }
    private void Accelerate()
    {
        if (accelerate_Action.triggered)
            velocity = velocity + accelerate_Action.ReadValue<float>();
    }
    private void CalcThetaPrimeIdentities()
    {
       cosThetaPrime = (vertexDir.x - beta)/(1 - (beta*vertexDir.x));
       sinThetaPrime = Mathf.Sqrt(1 - cosThetaPrime*cosThetaPrime);
    }
    private void ConvertToSphericalCoords()
    {
        nxPrime = cosThetaPrime;
        nyPrime = sinThetaPrime*Mathf.Cos(phi);
        nzPrime = sinThetaPrime*Mathf.Sin(phi);
    }
    private void Aberrate()
    {
        transform.position = observerPos + new Vector3(nxPrime, nyPrime, nzPrime)*r;
    }    
    private void Update_SFrame() //Tracks positions seen in the S frame so aberration can be applied correctly
    {
        positionInSFrame = positionInSFrame + new Vector3(velocity*Time.deltaTime, 0, 0);
        
        r = Mathf.Sqrt(Vector3.Dot(positionInSFrame, positionInSFrame));
        
        vertexDir = (positionInSFrame - observerPos).normalized;
        
        phi = Mathf.Atan2(vertexDir.z, vertexDir.y); //In radians
    }
    
}
