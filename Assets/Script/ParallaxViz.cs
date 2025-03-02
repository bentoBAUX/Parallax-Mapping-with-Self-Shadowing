using R3;
using UnityEngine;
using System;

public class ParallaxViz : MonoBehaviour
{
    public ReactiveLine reactiveLine;
    public GameObject sphereGO;

    public Material surfaceHitMaterial;
    public Material endHitMaterial;

    private CompositeDisposable disposables = new CompositeDisposable();
    private GameObject hitSphere;
    private GameObject heightMapSphere;
    private GameObject endSphere;
    private string heightMapTag; // Cached height map tag

    private Vector3 targetHeightMapPosition; // Smooth target position
    private Vector3 heightMapVelocity = Vector3.zero; // Needed for SmoothDamp

    private LineRenderer lineRenderer;

    private void Start()
    {
        if (reactiveLine == null || sphereGO == null)
        {
            Debug.LogError("Missing references in ParallaxViz!");
            return;
        }

        heightMapTag = reactiveLine.GetHeightMapTag(); // Cache the tag

        reactiveLine.SurfaceHitPoint.Subscribe(hitPoint => { UpdateSphere(ref hitSphere, surfaceHitMaterial, hitPoint); }).AddTo(disposables);
        reactiveLine.HeightMapHitPoint.Subscribe(hitPoint => { UpdateSphere(ref heightMapSphere, surfaceHitMaterial, hitPoint); }).AddTo(disposables);
        reactiveLine.EndHitPoint.Subscribe(endHitPoint => { UpdateSphere(ref endSphere, endHitMaterial, endHitPoint); }).AddTo(disposables);
    }

    private void UpdateSphere(ref GameObject sphere, Material material, Vector3 position)
    {
        if (position == Vector3.positiveInfinity || float.IsInfinity(position.x) || float.IsNaN(position.x))
        {
            DestroySphere(ref sphere);
            return;
        }

        if (sphere == null)
        {
            sphere = Instantiate(sphereGO, position, Quaternion.identity);
        }
        else
        {
            sphere.transform.position = position;
        }

        sphere.GetComponent<Renderer>().material = material;
    }

    private void DestroySphere(ref GameObject sphere)
    {
        if (sphere != null)
        {
            Destroy(sphere);
            sphere = null;
        }
    }

    private void OnDestroy()
    {
        disposables.Dispose(); // Clean up all subscriptions
    }
}