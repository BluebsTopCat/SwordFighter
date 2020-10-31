using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Turrettscript : MonoBehaviour
{
    public bool onoff = true;
    public bool isshooting = false;
    public int timetowait;
    public bool invulnerability;
    public float maxhp = 3;
    public float hp = 3;
    public Image Healthbar;
    public Text HealthQuanity;
    public GameObject spike;
    public Transform shootplace;
    // Update is called once per frame
    void Update()
    {
        if (this.hp <= 0)
            Destroy(this.transform.parent.gameObject);
        HealthQuanity.text = hp + "";
        Healthbar.fillAmount = (hp/maxhp);
        if (isshooting == false && onoff == true)
        {
            isshooting = true;
            StartCoroutine(Fire());
            Instantiate(spike, shootplace);
        }
    }
    IEnumerator Fire()
    {
        yield return new WaitForSeconds(0.5f);
        isshooting = false;

    }
    public void Stabbed()
    {
        hp--;
    }
}
