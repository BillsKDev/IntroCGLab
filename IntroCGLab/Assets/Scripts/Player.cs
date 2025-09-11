using UnityEngine;

public class PlayerMovement : MonoBehaviour
{
    [Header("Movement")]
    [SerializeField] float speed = 5f;
    Vector2 moveInput;
    
    Controls controls;
    CharacterController characterController;

    void Awake()
    {
        controls = new Controls();
        characterController = GetComponent<CharacterController>();
    }

    void OnEnable() => controls.Enable();
    void OnDisable() => controls.Disable();

    void Update()
    {
        Move();
    }
    
    void Move()
    {
        moveInput = controls.Player.Move.ReadValue<Vector2>();
        Vector3 movement = (transform.right * moveInput.x + transform.forward * moveInput.y).normalized;
        characterController.Move(movement * (speed * Time.deltaTime));
    }
}