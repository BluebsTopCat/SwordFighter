using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class cubescript : MonoBehaviour
{
    public Transform oldpos;
    public Transform correctpos;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        oldpos.transform.position = this.transform.position;
        this.transform.position = correctpos.transform.position;
    }
    

    private void OnTriggerEnter(Collider other)
    {
        this.transform.position = (this.transform.position - oldpos.transform.position) * 4;
    }
}
