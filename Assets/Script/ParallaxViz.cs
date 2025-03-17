using R3;
using UnityEngine;
using System;

public class ParallaxViz : MonoBehaviour
{
    public float heightScale = 1;
    public ReactiveLine reactiveLine;
    public HA_Text ha_text;
    public GameObject sphereGO;
    public GameObject arrowGO;

    public Material surfaceHitMaterial;
    public Material endHitMaterial;
    public Material pMaterial;

    private CompositeDisposable disposables = new CompositeDisposable();
    private GameObject hitSphere;
    private GameObject heightMapSphere;
    private GameObject endSphere;
    private GameObject pSphere;
    private GameObject pArrow;

    private LineRenderer pvectorLineRenderer;

    private float heightmap_value = 0f;
    private Vector3 surfaceHitPoint = Vector3.zero;

    private void Start()
    {
        if (reactiveLine == null || sphereGO == null)
        {
            Debug.LogError("Missing references in ParallaxViz!");
            return;
        }

        reactiveLine.SurfaceHitPoint.Subscribe(hitPoint =>
        {
            UpdateSphere(ref hitSphere, surfaceHitMaterial, hitPoint);
            surfaceHitPoint = hitPoint;
        }).AddTo(disposables);

        reactiveLine.HeightMapHitPoint.Subscribe(hitPoint => { UpdateSphere(ref heightMapSphere, surfaceHitMaterial, hitPoint); }).AddTo(disposables);
        reactiveLine.EndHitPoint.Subscribe(endHitPoint => { UpdateSphere(ref endSphere, endHitMaterial, endHitPoint); }).AddTo(disposables);
        ha_text.HeightText.Subscribe(height => heightmap_value = height);
        reactiveLine.ViewDir.Subscribe(viewDir => VisualizeP(viewDir)).AddTo(disposables);

        pvectorLineRenderer = GetComponent<LineRenderer>();
        pvectorLineRenderer.startWidth = pvectorLineRenderer.endWidth = 0.05f;
        pvectorLineRenderer.positionCount = 2;
    }

    private void VisualizeP(Vector3 viewDir)
    {
        // Handle invalid values (Infinity, NaN)
        if (!viewDir.IsFinite()) return;

        // Calculate p
        Vector2 view2D = new Vector2(viewDir.x, viewDir.y);
        Vector2 p = view2D / Mathf.Max(0.01f, viewDir.z) * (heightmap_value * heightScale);

        // Define start and end points with offset in the negative x-axis to prevent the line from occlusion.
        Vector3 startPos = new Vector3(-0.1f, surfaceHitPoint.y, surfaceHitPoint.z);
        Vector3 endPos = startPos - new Vector3(0, p.x, p.y);

        if (!surfaceHitPoint.IsFinite() || !endPos.IsFinite())
        {
            // Handles invalid start and end positions
            pvectorLineRenderer.enabled = false;
            SafeDestroy(ref pSphere);
            SafeDestroy(ref pArrow);
        }
        else
        {
            // Draw the parallax vector
            pvectorLineRenderer.enabled = true;
            pvectorLineRenderer.SetPosition(0, startPos);
            pvectorLineRenderer.SetPosition(1, endPos);
            UpdateSphere(ref pSphere, pMaterial, endPos);
            UpdateArrow(ref pArrow, pMaterial, (startPos + endPos) * 0.5f);
        }
    }

    // Draw arrows on the lines
    private void UpdateArrow(ref GameObject arrow, Material material, Vector3 position)
    {
        if (!position.IsFinite())
        {
            SafeDestroy(ref arrow);
            return;
        }

        if (arrow == null)
        {
            arrow = Instantiate(arrowGO, position, Quaternion.identity);
        }
        else
        {
            arrow.transform.position = position;
        }

        arrow.GetComponent<Renderer>().material = material;
    }

    // Draw spheres at hitpoints
    private void UpdateSphere(ref GameObject sphere, Material material, Vector3 position)
    {
        if (!position.IsFinite())
        {
            SafeDestroy(ref sphere);
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

    private void SafeDestroy(ref GameObject gameObject)
    {
        if (gameObject != null)
        {
            Destroy(gameObject);
            gameObject = null;
        }
    }

    private void OnDestroy()
    {
        disposables.Dispose(); // Clean up all subscriptions
    }
}