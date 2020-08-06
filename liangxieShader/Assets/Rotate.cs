using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Rotate : MonoBehaviour
{
    public bool x = false;
    public bool y = true;
    public bool z = false;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        float xVal = x ? 1 : 0;
        float yVal = y ? 1 : 0;
        float zVal = z ? 1 : 0;

        transform.Rotate(new Vector3(xVal, yVal, zVal));
    }
}
