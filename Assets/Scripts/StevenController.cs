using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.ParticleSystemJobs;
using System.Runtime.CompilerServices;

public class StevenController : MonoBehaviour
{
    CharacterController playerController;
    public Animator playeranimator;

    public float moveSpeed;

    public float sprintSpeedMultiplier = 2f;

    public float jumpHeight = 3f;

    public float _gravity = -10f;

    private float _yAxisVelocity;


    public GameObject shield;
    public GameObject platform;
    private float sheildleft = 3f;
    public GameObject[] sheildtext;



    public float hp = 6;

    private float timefalling;
    private int inttimefalling;
    private Vector3 oldvelocity;
    public ParticleSystem dust;
    public ParticleSystem runingdust;
    public Transform dustspawn;
    public Transform respawn;
    private Vector3 oldpos;
    public bool inabubble = true;
    private bool issheilding;

    public int jumpsleft = 2;
    public bool isjumping = false;

    private static float slopeforce = 20;
    private static float slopeforceraylength = 2;
    private static float extraspeed = 0.1f;
    private Vector2 Direction;
    private void Start()
    {
        playerController = gameObject.GetComponent(typeof(CharacterController)) as CharacterController;
    }
    private void Update()
    {
        var camera = Camera.main;
        Direction = new Vector2(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
        var forward = camera.transform.forward;
        var right = camera.transform.right;
        forward.y = 0f;
        right.y = 0f;
        forward.Normalize();
        right.Normalize();

        playeranimator.SetFloat("Movespeed", (Mathf.Abs(Direction.x) + Mathf.Abs(Direction.y)));
        playeranimator.SetBool("Jumping?", isjumping);
        playeranimator.SetBool("Sheilding?", issheilding);
        playeranimator.SetBool("Stabby", Input.GetMouseButtonDown(0));




        //check for inputs
        if (Input.GetKey(KeyCode.LeftShift))
        {
            Direction *= sprintSpeedMultiplier;
        }

        if (Input.GetKeyDown(KeyCode.Space) && jumpsleft == 1)
        {
            StartCoroutine(platformjump());
        }

        if (Input.GetMouseButtonDown(1))
        {
            shield.SetActive(true);
            issheilding = true;
        }

        if (Input.GetMouseButtonUp(1) || sheildleft <= 0)
        {
            shield.SetActive(false);
            issheilding = false;
        }

        Sheildstuff();

        //figure out movement
        Vector3 movement = Direction.x * moveSpeed * Time.deltaTime * right + Direction.y * moveSpeed * Time.deltaTime * forward;

        if (timefalling < .001 || (Input.GetKeyDown(KeyCode.Space) && jumpsleft > 0))
            oldvelocity = movement; 
        else if (timefalling >= 3)
            movement = new Vector3((3 * movement.x + oldvelocity.x) / 4, (3 * movement.y + oldvelocity.y) / 4, (3 * movement.z + oldvelocity.z) / 4);
        else
            movement = new Vector3((2 * movement.x + oldvelocity.x) / 3, (2 * movement.y + oldvelocity.y) / 3, (2 * movement.z + oldvelocity.z) / 3);

        if (playerController.isGrounded)
        {
            _yAxisVelocity = -0.5f;
            jumpsleft = 2;
            isjumping = false;
        }

        //set the number of jumps left
        if (Input.GetKeyDown(KeyCode.Space) && jumpsleft > 0)
        {
           _yAxisVelocity = Mathf.Sqrt(jumpHeight * -2f * _gravity);
            jumpsleft -= 1;
            isjumping = true;
        }

        _yAxisVelocity += _gravity * Time.deltaTime * (timefalling/3 + 2);

        if (dust.particleCount == 0)
        {
            dust.gameObject.SetActive(false);
        }


        //Bonk Back if you hit your head
        RaycastHit hit2;
        if (Physics.Raycast(transform.position, Vector3.up, out hit2, playerController.height / 2 * slopeforceraylength))
        {
            _yAxisVelocity -= (Mathf.Sqrt(jumpHeight * -1f * _gravity));
            Debug.Log(jumpHeight * -2f * _gravity + ", square root is" + (Mathf.Sqrt(jumpHeight * -2f * _gravity)));
        }

        movement.y = _yAxisVelocity * Time.deltaTime;


        //particles if you hit the ground
        Particles();

        if ((Direction.x != 0 || Direction.y != 0) && Onslope())
            movement += (Vector3.down * playerController.height / 2 * slopeforce * Time.deltaTime);

        //move the character
        oldpos = this.transform.position;
        playerController.Move(movement);
        oldpos = new Vector3(oldpos.x, this.transform.position.y, oldpos.z);
        transform.LookAt(oldpos);

       

        if (this.transform.position.y <= -100 || hp <= 0)
        {
            gameObject.transform.position = respawn.position;
            timefalling = 0;
            oldpos = this.transform.position;
            hp = 6;
        }


    }

    void Particles()
    {
        if (playerController.isGrounded || Input.GetKeyDown(KeyCode.Space))
        {
            if (timefalling > 1 && !Input.GetKeyDown(KeyCode.Space))
            {
                inttimefalling = (int)timefalling;
                dust.gameObject.SetActive(true);
                if (inabubble == true)
                {
                    dust.transform.position = dustspawn.transform.position;
                    dust.maxParticles = inttimefalling * 4;
                    dust.Play(true);
                }
                else
                {
                    dust.transform.position = dustspawn.transform.position;
                    dust.maxParticles = inttimefalling * 2;

                    dust.Play(true);
                }

            }
            timefalling = 0;
        }
        else
        {
            if (dust.particleCount == 0)
            {
                dust.gameObject.SetActive(false);
            }
            timefalling += Time.deltaTime * 8;
        }

        //particles if you goin fast;
        if (((Mathf.Abs(Direction.x) > .5) || (Mathf.Abs(Direction.y) > .5)) && timefalling < .01)
        {
            runingdust.gameObject.SetActive(true);
        }
        else
        {
            runingdust.gameObject.SetActive(false);
        }
    }
    public IEnumerator platformjump()
    {
        platform.SetActive(true);
        platform.transform.position = dustspawn.transform.position;
        platform.transform.rotation = this.transform.rotation;
        yield return new WaitForSeconds(1);
        platform.SetActive(false);
    }

    private bool Onslope()
    {
        if (isjumping)
            return false;

        RaycastHit hit;

        if (Physics.Raycast(transform.position, Vector3.down, out hit, playerController.height / 2 * slopeforceraylength))
            if (hit.normal != Vector3.up)
                return false;

        return true;
    }

    public void Gethurt(float damage)
    {
        hp -= damage;
    }

    void Sheildstuff()
    {
        if (issheilding == true)
        {
            sheildleft -= Time.deltaTime;
        }
        else
        {
            sheildleft += Time.deltaTime / 2;
        }

        sheildleft = Mathf.Clamp(sheildleft, -1, 3);

        if (sheildleft >= 3)
        {
            sheildtext[0].SetActive(false);
            sheildtext[1].SetActive(false);
            sheildtext[2].SetActive(false);
            sheildtext[3].SetActive(false);
        }
        else
        {
            sheildtext[3].SetActive(true);
            int texttoshow = (int)Mathf.Round(sheildleft);
            sheildtext[0].SetActive(false);
            sheildtext[1].SetActive(false);
            sheildtext[2].SetActive(false);
            if(texttoshow >=0)
             sheildtext[texttoshow].SetActive(true);
        }

    }

}
