from fastapi.testclient import TestClient

from app.main import app


def test_service_metadata(monkeypatch) -> None:
    monkeypatch.setenv("APP_VERSION", "1.2.3")
    monkeypatch.setenv("APP_ENVIRONMENT", "test")
    monkeypatch.setenv("RELEASE_COLOR", "green")
    monkeypatch.setenv("COMMIT_SHA", "abc1234")

    with TestClient(app) as client:
        response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {
        "service": "delivery-demo",
        "version": "1.2.3",
        "environment": "test",
        "release_color": "green",
        "commit_sha": "abc1234",
    }
    assert response.headers["x-content-type-options"] == "nosniff"


def test_health_endpoints() -> None:
    with TestClient(app) as client:
        assert client.get("/health/live").json() == {"status": "alive"}
        assert client.get("/health/ready").json() == {"status": "ready"}


def test_prometheus_metrics_are_exposed() -> None:
    with TestClient(app) as client:
        client.get("/version")
        response = client.get("/metrics")

    assert response.status_code == 200
    assert "delivery_demo_http_requests_total" in response.text
    assert "delivery_demo_http_request_duration_seconds" in response.text
