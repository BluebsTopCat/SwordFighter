using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class flytowards : MonoBehaviour
{
    public GameObject location;
    public float speed;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        if (Vector3.Distance(location.transform.position, this.transform.position) > .1)
        {
            transform.LookAt(location.transform.position);
            transform.position += this.transform.forward * speed * Time.deltaTime;
        }
    }
}
