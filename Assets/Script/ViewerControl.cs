using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ViewerControl : MonoBehaviour
{
    public float sensitivity = 1f;
    private float _xRotation = 10f;
    private Viewer _viewer;

    private Camera _mainCamera;

    private void Start()
    {
        _mainCamera = Camera.main;
        Cursor.visible = false;
        Cursor.lockState = CursorLockMode.Locked;
    }

    private void Awake()
    {
        _viewer = new Viewer();
    }

    private void OnEnable()
    {
        _viewer.Look.Mouse.performed += ctx => RotateMouse(ctx.ReadValue<Vector2>());
        _viewer.Look.Enable();
    }

    private void OnDisable()
    {
        _viewer.Look.Mouse.performed -= ctx => RotateMouse(ctx.ReadValue<Vector2>());
        _viewer.Look.Disable();
    }

    private void RotateMouse(Vector2 mouseDelta)
    {
        float mouseY = mouseDelta.y * sensitivity * Time.deltaTime;
        _xRotation -= mouseY;

        transform.localRotation = Quaternion.Euler(_xRotation, 0f, 0f);
    }
}