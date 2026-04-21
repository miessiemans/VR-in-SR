using UnityEngine;

public class contract : MonoBehaviour
{
    // set up treadmill
    public Transform observer;
    public int n_tiles = 6;
    private Transform[] tiles;
    private float tile_length = 30f;

    // set up contraction
    private void calculate_lorentz()
    {
        beta = v/c;
        lf = 1/(Mathf.Sqrt(1 - (beta*beta)));
    }

    [SerializeField] private float lf = 1f;
    [Range(1f,29.99f)]
    [SerializeField] public float v = 25f;
    private float beta;
    private int c = 30;
    private float initialScale;
    

    void Start()
    {
        tiles = new Transform[n_tiles];
        for (int x = 0; x < n_tiles; x++)
        {
            tiles[x] = transform.GetChild(x);
        }

        initialScale = transform.localScale.x;
    }


    void Update()
    {
        transform.Translate(-v*Time.deltaTime, 0,0);
        calculate_lorentz();
        transform.localScale = new Vector3(initialScale/lf, 1, 1);

        for (int i = 0; i < tiles.Length; i++)
        {
            if (tiles[i].position.x < (observer.position.x - (tile_length/lf)))
            {
                tiles[i].position += Vector3.right * (tile_length/lf) *n_tiles;
            }
        }
    }
}
