using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwordProcesser : MonoBehaviour, EventReader
{
    public GameObject SwordHand;
    public GameObject SwordBack;
    public GameObject SwordHitBox;
    public void SwordSlash()
    {
        SwordBack.SetActive(false);
        SwordHand.SetActive(true);
        SwordHitBox.SetActive(true);
    }
    public void Holster()
    {
        SwordBack.SetActive(true);
        SwordHand.SetActive(false);
        SwordHitBox.SetActive(false);
    }
}
