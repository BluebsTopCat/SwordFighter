using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class StabbyScript : MonoBehaviour
{
    public GameObject SwordBack;
    public GameObject SwordHand;
    // Start is called before the first frame update
    void Holster()
    {
        SwordBack.SetActive(true);
        SwordHand.SetActive(false);
    }
    void Draw()
    {
        SwordBack.SetActive(false);
        SwordHand.SetActive(true);
    }
}
