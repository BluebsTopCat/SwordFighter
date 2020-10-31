using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Scrolllock : MonoBehaviour
{
    public GameObject center;
    public int speed;
    // Update is called once per frame
    void Update()
    {
        if(((Vector3.Distance(this.transform.position, center.transform.position) < 2) && Input.mouseScrollDelta.y > 0) || (Input.mouseScrollDelta.y == 0))
            {
            return;
            };
        if ((Vector3.Distance(this.transform.position, center.transform.position) > 20) && Input.mouseScrollDelta.y < 0)
        {
            return;
        };

        this.transform.position = Vector3.MoveTowards(this.transform.position, center.transform.position, Input.mouseScrollDelta.y * speed);
        
    }
}
