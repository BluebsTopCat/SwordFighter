using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SwordAttacking : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag != ("Hurtable"))
            return;

            Debug.Log("Hit Enemy!");
        Turrettscript Attackee = other.GetComponent(typeof(Turrettscript)) as Turrettscript;

            Attackee.Stabbed();
        
    }
}
