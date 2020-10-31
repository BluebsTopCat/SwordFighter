using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
public interface EventReader : IEventSystemHandler
{
    //Functions that can be called.
    void SwordSlash();
    void Holster();
}

