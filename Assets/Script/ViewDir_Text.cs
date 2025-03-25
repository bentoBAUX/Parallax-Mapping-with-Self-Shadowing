using System.Globalization;
using R3;
using TMPro;
using UnityEngine;

public class ViewDir_Text : MonoBehaviour
{
    public ReactiveLine reactiveLine;

    public TMP_Text viewDirText;
    private LineRenderer _lineRenderer;
    private float offset = 0.5f;
    private CompositeDisposable disposables = new CompositeDisposable();

    // Start is called before the first frame update
    void Start()
    {
        reactiveLine.ViewDir.Subscribe(viewDir => UpdateViewDir(viewDir)).AddTo(disposables);
        _lineRenderer = GetComponent<LineRenderer>();
    }

    private void UpdateViewDir(Vector3 ViewDir)
    {
        if (ViewDir.IsFinite())
        {
            gameObject.SetActive(true);

            viewDirText.text = $"{ViewDir.ToString("F2", CultureInfo.InvariantCulture)}";
        }
        else
        {
            gameObject.SetActive(false);
        }
    }

    private void OnDestroy()
    {
        disposables.Dispose(); // Clean up all subscriptions
    }
}