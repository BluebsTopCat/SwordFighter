using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class visualisewheretobe : MonoBehaviour
{
    public GameObject llegpos;
    public GameObject rlegpos;

    public GameObject wherefootisl;
    public GameObject wherefootshouldbel;

    public GameObject wherefootisr;
    public GameObject wherefootshouldber;

    public float steplength;

    public Vector3 cachel;
    private Vector3 storedcachel;
    private Vector3 currentl;

    public Vector3 cacher;
    private Vector3 storedcacher;
    private Vector3 currentr;

    private bool isstepping = false;
    public float stepspeed;


    // Update is called once per frame

    private void Start()
    {
        //initialise where the legs start
        RaycastHit cachl;
        Physics.Raycast(llegpos.transform.position, Vector3.down, out cachl);
        cachel = new Vector3(llegpos.transform.position.x, llegpos.transform.position.y - cachl.distance, llegpos.transform.position.z);

        RaycastHit cachr;
        Physics.Raycast(rlegpos.transform.position, Vector3.down, out cachr);
        cacher = new Vector3(rlegpos.transform.position.x, rlegpos.transform.position.y - cachr.distance, rlegpos.transform.position.z);
    }
    void Update()
    {
        RaycastHit hitl;
        Physics.Raycast(llegpos.transform.position, Vector3.down, out hitl);
        currentl = new Vector3(llegpos.transform.position.x, llegpos.transform.position.y - hitl.distance, llegpos.transform.position.z);

        RaycastHit hitr;
        Physics.Raycast(rlegpos.transform.position, Vector3.down, out hitr);
        currentr = new Vector3(rlegpos.transform.position.x, rlegpos.transform.position.y - hitr.distance, rlegpos.transform.position.z);

        if ((Vector3.Distance(wherefootshouldbel.transform.position, wherefootisl.transform.position) > steplength) && isstepping == false)
        {
            StartCoroutine(stepl());
        }
        else if ((Vector3.Distance(wherefootshouldber.transform.position, wherefootisr.transform.position) > steplength) && isstepping == false)
        {
            StartCoroutine(stepr());
        }


        wherefootshouldber.transform.position = currentr;
        wherefootshouldbel.transform.position = currentl;

        wherefootisr.transform.position = cacher;
        wherefootisl.transform.position = cachel;

        Debug.DrawLine(cacher, currentr);
        Debug.DrawLine(cachel, currentl);

    }

    IEnumerator stepl()
    {
        isstepping = true;
        RaycastHit hitll;
        Physics.Raycast(llegpos.transform.position, Vector3.down, out hitll);
        storedcachel = cachel;
        float t = 0f;
        while (t < 1f)
        {
            t += Time.deltaTime * stepspeed;
            cachel = Vector3.Lerp(storedcachel, new Vector3(llegpos.transform.position.x, llegpos.transform.position.y - hitll.distance, llegpos.transform.position.z), Mathf.SmoothStep(0f, 1f, t));
            yield return null;
        }
        isstepping = false;
    }

    IEnumerator stepr()
    {
        isstepping = true;
        RaycastHit hitrr;
        Physics.Raycast(rlegpos.transform.position, Vector3.down, out hitrr);
        storedcacher = cacher;
        float t = 0f;
        while (t < 1f)
        {
            t += Time.deltaTime * stepspeed;
            cacher = Vector3.Lerp(storedcacher, new Vector3(rlegpos.transform.position.x, rlegpos.transform.position.y - hitrr.distance, rlegpos.transform.position.z), Mathf.SmoothStep(0f, 1f, t));
            yield return null;
        }
        isstepping = false;
    }


}
