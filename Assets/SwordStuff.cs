using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
public class SwordStuff : StateMachineBehaviour
{
    // OnStateEnter is called when a transition starts and the state machine starts to evaluate this state
   override public void OnStateEnter(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
    {
        ExecuteEvents.Execute<EventReader>(GameObject.FindGameObjectWithTag("Manager"), null, (x, y) => x.SwordSlash());
    }
    // OnStateExit is called when a transition ends and the state machine finishes evaluating this state
    override public void OnStateExit(Animator animator, AnimatorStateInfo stateInfo, int layerIndex)
   {
        ExecuteEvents.Execute<EventReader>(GameObject.FindGameObjectWithTag("Manager"), null, (x, y) => x.Holster());
    }

}
