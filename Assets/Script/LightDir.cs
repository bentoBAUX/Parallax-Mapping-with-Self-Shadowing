using UnityEngine;

[ExecuteAlways]
public class LightDir : MonoBehaviour
{
    public float length = 5.0f;

    void Update()
    {
        Vector3 lightDir = -RenderSettings.sun.transform.forward;
        Debug.Log($"[Light Direction] {lightDir}");
    }
}