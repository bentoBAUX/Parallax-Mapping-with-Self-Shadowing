using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class PointLight : MonoBehaviour
{
    public float radius = 5f; // Radius of the circle
    public float speed = 1f; // Speed of rotation
    public Vector3 center = Vector3.zero;
    private float angle = 0f; // Current angle in radians

    void Update()
    {
        angle += Time.deltaTime * speed; // update angle
        Vector3 direction = Quaternion.AngleAxis(angle, Vector3.up) * Vector3.forward; // calculate direction from center - rotate the up vector Angle degrees clockwise
        transform.position = center + direction * radius;
    }
}
