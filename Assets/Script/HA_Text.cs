using System;
using System.Collections;
using System.Collections.Generic;
using R3;
using TMPro;
using UnityEngine;
using System.Globalization;

public class HA_Text : MonoBehaviour
{
    public ReactiveLine reactiveLine;

    private readonly BehaviorSubject<float> HeightTextSubject = new BehaviorSubject<float>(0.0f);
    public Observable<float> HeightText => HeightTextSubject;

    private TMP_Text heightText;
    private LineRenderer _lineRenderer;
    private float offset = 0.5f;

    private CompositeDisposable disposables = new CompositeDisposable();

    private Vector3 offset_vector;

    // Start is called before the first frame update
    void Start()
    {
        reactiveLine.HeightMapHitPoint.Subscribe(height => UpdatePositionAndText(height)).AddTo(disposables);
        heightText = GetComponentInChildren<TMP_Text>();

        _lineRenderer = GetComponent<LineRenderer>();
    }

    private void Update()
    {
        offset_vector = transform.forward * offset;
    }

    private void UpdatePositionAndText(Vector3 HA_pos)
    {
        offset_vector = new Vector3(0, 0, offset);

        if (HA_pos.IsFinite())
        {
            gameObject.SetActive(true);

            Vector3 newPosition = transform.position;
            newPosition.y = HA_pos.y;
            transform.position = newPosition;

            float normalizedHeight = Mathf.Clamp01((0 - HA_pos.y) / 4.0f);

            HeightTextSubject.OnNext(normalizedHeight);
            heightText.text = $"{normalizedHeight.ToString("F2", CultureInfo.InvariantCulture)}";

            _lineRenderer.SetPosition(0, transform.position + offset_vector);
            _lineRenderer.SetPosition(1, HA_pos);
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