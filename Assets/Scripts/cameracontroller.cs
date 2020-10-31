using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class cameracontroller : MonoBehaviour
{
    public float turnSpeed = 4.0f;
    public float minTurnAngle = -90.0f;
    public float maxTurnAngle = 90.0f;
    public float movespeed;

    public GameObject rotatepoint;
    public Transform whereitshouldbe;
    public bool iscolliding;
    
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        float y = Input.GetAxis("Mouse X") * turnSpeed;
         float X = Input.GetAxis("Mouse Y") * turnSpeed;

        // clamp the vertical rotation

       

        rotatepoint.transform.eulerAngles = new Vector3(0f, rotatepoint.transform.eulerAngles.y + y, Mathf.Clamp(rotatepoint.transform.eulerAngles.z + X, 0, 85));
        transform.LookAt(rotatepoint.transform.position);

        if (Input.GetMouseButton(0))
            Cursor.lockState = CursorLockMode.Locked;

        if (Input.GetKeyDown(KeyCode.Escape))
            Cursor.lockState = CursorLockMode.Confined;

        if ((this.gameObject.transform.position != whereitshouldbe.transform.position) && iscolliding == false)
        {
            this.transform.position = new Vector3(Mathf.Lerp(this.transform.position.x, whereitshouldbe.transform.position.x, Time.deltaTime * movespeed), Mathf.Lerp(this.transform.position.y, whereitshouldbe.transform.position.y, Time.deltaTime * movespeed), Mathf.Lerp(this.transform.position.z, whereitshouldbe.transform.position.z, Time.deltaTime * movespeed));
        }

    }
    void OnCollisionEnter()
    {
        iscolliding = true;
    }
     void OnCollisionStay()
    {
        iscolliding = true;

    }
    void OnCollisionExit()
    {
        StartCoroutine(waitasec());
    }
    IEnumerator waitasec()
    {
        yield return new WaitForSeconds(0.01F);
        iscolliding = false; 
    }
}
