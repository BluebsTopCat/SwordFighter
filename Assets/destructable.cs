using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class destructable : MonoBehaviour
{
    public GameObject shatterprefab;
    // Start is called before the first frame update
    void OnTriggerEnter(Collider other)
    {
        Debug.Log("colliding");
        bool isbubbled = other.gameObject.GetComponent<StevenController>().inabubble;
        if (other.gameObject.tag == ("Player") && isbubbled == true)
        {
            Instantiate(shatterprefab, this.gameObject.transform);
            Destroy(gameObject);
            
        }

    }

}
