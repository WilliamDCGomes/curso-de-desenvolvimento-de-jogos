using UnityEngine;

public class Man : MonoBehaviour {
    bool isInTheGround = false;
    float maxHeight = 1f;
    float timeToPeak = 0.3f;
    float groundPosition = 0;
    float jumpSpeed;
    float gravity;
    Vector2 ySpeed;

    void Start() {
        gravity = (2 * maxHeight) / Mathf.Pow(timeToPeak, 2);
        jumpSpeed = gravity * timeToPeak;
        groundPosition = transform.position.y;
    }

    // Update is called once per frame
    void Update() {
        ySpeed += gravity * Time.deltaTime * Vector2.down;

        if(transform.position.y <= groundPosition)
        {
            transform.position = new Vector3(transform.position.x, groundPosition, transform.position.z);
            ySpeed = Vector3.zero;
            isInTheGround = true;
        }

        if(Input.GetKeyDown(KeyCode.Space) && isInTheGround){
            ySpeed = jumpSpeed * Vector2.up;
        }

        transform.position += (Vector3)ySpeed * Time.deltaTime;
    }
}
