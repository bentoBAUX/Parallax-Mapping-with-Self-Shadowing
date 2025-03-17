using System;
using UnityEngine;
using R3;

[RequireComponent(typeof(LineRenderer))]
public class ReactiveLine : MonoBehaviour
{
    public LayerMask collisionLayer;
    public float maxDistance = 1000f;
    public string surfaceTag = "Surface";
    public string heightMapTag = "HeightMap"; // No spaces!

    private LineRenderer mainLineRenderer;
    public LineRenderer heightMapLineRenderer;
    private Material lineMaterial;
    bool foundHeightMap = false;

    // Create BehaviorSubjects that remembers last emitted value so that new subscribers immediately receive the latest data.
    private readonly BehaviorSubject<Vector3> surfaceHitPointSubject = new(Vector3.positiveInfinity);
    private readonly BehaviorSubject<Vector3> heightMapHitPointSubject = new(Vector3.zero);
    private readonly BehaviorSubject<Vector3> endHitPointSubject = new(Vector3.zero);
    private readonly BehaviorSubject<Vector3> viewDirSubject = new(Vector3.zero);

    // Expose the BehaviourSubjects
    public Observable<Vector3> SurfaceHitPoint => surfaceHitPointSubject;
    public Observable<Vector3> HeightMapHitPoint => heightMapHitPointSubject;
    public Observable<Vector3> EndHitPoint => endHitPointSubject;
    public Observable<Vector3> ViewDir => viewDirSubject;

    void Start()
    {
        this.transform.rotation = Quaternion.Euler(60, 0, 0);
        mainLineRenderer = GetComponent<LineRenderer>();

        heightMapLineRenderer.positionCount = mainLineRenderer.positionCount = 2;
        mainLineRenderer.startWidth = 0.05f;
        mainLineRenderer.endWidth = 0.05f;

        heightMapLineRenderer.startWidth = heightMapLineRenderer.endWidth = 0.02f;

        lineMaterial = mainLineRenderer.material;
    }

    void Update()
    {
        foundHeightMap = false;
        Vector3 start = transform.position;
        Vector3 direction = transform.forward;
        Vector3 end = start + direction * maxDistance;
        Vector3 surfaceHitPoint = Vector3.positiveInfinity;
        Vector3 heightMapHitPoint = surfaceHitPoint;

        RaycastHit[] hits = Physics.RaycastAll(start, direction, maxDistance, collisionLayer);
        Array.Sort(hits, (a, b) => a.distance.CompareTo(b.distance)); // Hits are not guaranteed to be stored by ascending distances.

        // Check hits for surface, heightmap and endpoint
        foreach (RaycastHit hit in hits)
        {
            if (hit.collider.CompareTag(surfaceTag))
            {
                surfaceHitPoint = end = hit.point;

                // Find height map value of surface hit point and draw a line
                RaycastHit hit2;
                if (Physics.Raycast(surfaceHitPoint, Vector3.down, out hit2, 10f))
                {
                    if (hit2.collider.CompareTag(heightMapTag))
                    {
                        heightMapHitPoint = hit2.point;
                        foundHeightMap = true;
                    }
                }
            }
        }

        // Emit values on change
        if (surfaceHitPoint != surfaceHitPointSubject.Value)
        {
            surfaceHitPointSubject.OnNext(surfaceHitPoint);
        }

        if (heightMapHitPoint != heightMapHitPointSubject.Value)
        {
            heightMapHitPointSubject.OnNext(heightMapHitPoint);
        }

        if (end != endHitPointSubject.Value)
        {
            endHitPointSubject.OnNext(end);
        }

        // Update the LineRenderer positions
        mainLineRenderer.SetPosition(0, start);
        mainLineRenderer.SetPosition(1, end);

        if (foundHeightMap)
        {
            heightMapLineRenderer.enabled = true;
            heightMapLineRenderer.SetPosition(0, surfaceHitPoint);
            heightMapLineRenderer.SetPosition(1, heightMapHitPoint);
        }
        else
        {
            heightMapLineRenderer.enabled = false;
        }

        float surfaceHitUV = surfaceHitPoint == Vector3.positiveInfinity ? 1.0f : Mathf.Clamp01(Vector3.Distance(start, surfaceHitPoint) / Vector3.Distance(start, end));
        lineMaterial.SetFloat("_SurfaceHitUV", surfaceHitUV);

        // Broadcast line vector
        Vector3 viewDirVector = transform.up;
        viewDirSubject.OnNext(viewDirVector);
    }

    public string GetHeightMapTag()
    {
        return heightMapTag;
    }

    private void OnDestroy()
    {
        surfaceHitPointSubject.Dispose();
        heightMapHitPointSubject.Dispose();
        endHitPointSubject.Dispose();
    }
}