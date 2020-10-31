using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class spikething : MonoBehaviour
{
    public float speed = 1;
    public float deathtime = 5;
    public GameObject player;
    private GameObject sheild;
    public bool hitsomething;
    private GameObject[] host;
    // Update is called once per frame
    void Update()
    {
        if (hitsomething == false)
        {
            this.transform.position += this.transform.up * -speed * Time.deltaTime;
        }

        if (sheild != null)
        {  
                Destroy(this.gameObject);
        }
    }

    private void Start()
    {
        host = GameObject.FindGameObjectsWithTag("parent"); 
        this.transform.parent = host[0].transform;
        StartCoroutine(Kill());
    }
    IEnumerator Kill()
    {
        yield return new WaitForSeconds(deathtime);
        Destroy(this.gameObject);
    }
    IEnumerator Killfaster()
    {
        yield return new WaitForSeconds(1);
        Destroy(this.gameObject);
    }

    private void OnTriggerEnter(Collider collision)
    {

        if (collision.gameObject.tag == "Sheild")
        {
            hitsomething = true;
            Debug.Log("hitshield");
            sheild = collision.gameObject;
            this.transform.parent = collision.transform.parent.gameObject.transform;
            StartCoroutine(Killfaster());
        }
        if (collision.gameObject.tag == "Player")
        {
            Debug.Log("hitplayer");
            collision.gameObject.GetComponent<StevenController>().Gethurt(1);
            Destroy(gameObject);
        }
        if (collision.gameObject.tag == "Bubble")
        {
            collision.gameObject.SetActive(false);
            Destroy(gameObject);
        }



    }
}
