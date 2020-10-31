using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Heartmaster : MonoBehaviour
{
    public SpriteRenderer[] hearts;
    public Sprite full;
    public Sprite half;
    public Sprite empty;


    // Update is called once per frame
    void Update()
    {
        int heartArray = 0;
        float hpleft = GameObject.FindGameObjectWithTag("Player").GetComponent<StevenController>().hp;
        int tinkerablehp = Mathf.RoundToInt(hpleft);
        while (tinkerablehp >= 0 & heartArray < hearts.Length)
        {
            if (tinkerablehp - 2 >= 0)
            {
                hearts[heartArray].sprite = full;
                tinkerablehp -= 2;
            }
            else if (tinkerablehp - 1 >= 0)
            {
                hearts[heartArray].sprite = half;
                tinkerablehp -= 1;
            }
            else
            {
                hearts[heartArray].sprite = empty;
            }
            heartArray++;
        }
    }
}
