using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NewBehaviourScript : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        Debug.Log("123");
        Object obj2=new Object();
        LightProbes obj = obj2 as LightProbes;
        LightProbeGroup lightProbeGroup = new LightProbeGroup();


    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
