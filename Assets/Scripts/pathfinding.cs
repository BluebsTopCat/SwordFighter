using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class pathfinding : MonoBehaviour
{
    public Transform[] points;
    public float safedist = 10f;
    private float currentdist;
    private NavMeshAgent nav;
    private int destPoint = 0;
    public GameObject player;
    private Vector3 positioning;
    public Quaternion lookat;
    public GameObject head;
    public bool inthetrigger = false;

    public float giveupdistance;
    // Start is called before the first frame update
    void Start()
    {
        nav = GetComponent<NavMeshAgent>();
        player = GameObject.FindGameObjectWithTag("Player");
    }

    // Update is called once per frame
    void FixedUpdate()
    {

        positioning = new Vector3(this.transform.position.x + 1, this.transform.position.y, this.transform.position.z);
        nav.destination = points[destPoint].position;
        if (!nav.pathPending && nav.remainingDistance < 0.5f)
        {
            GoToNextPoint();
        }
        if (nav.destination == player.transform.position && (Vector3.Distance(this.transform.position, player.transform.position) > giveupdistance) && inthetrigger == false)
        {
            GoToNextPoint();
        }
    }
    void GoToNextPoint()
    {
        if (points.Length == 0)
        {
            return;
        }

        nav.destination = points[destPoint].position;
        destPoint += 1;
        if (destPoint > points.Length - 1)
        {
            destPoint = 0;
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject == player)
        {
            inthetrigger = false;
        }

    }
    private void OnTriggerEnter(Collider other)
    {
        if(other.gameObject == player)
        {
            inthetrigger = true;
            nav.destination = player.transform.position;
        }
    }
}


