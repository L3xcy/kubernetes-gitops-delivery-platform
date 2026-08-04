import os
import time
from contextlib import asynccontextmanager

from fastapi import FastAPI, Request, Response
from prometheus_client import CONTENT_TYPE_LATEST, Counter, Gauge, Histogram, generate_latest

REQUESTS = Counter(
    "delivery_demo_http_requests_total",
    "Total HTTP requests handled by the demo service.",
    ["method", "path", "status"],
)
LATENCY = Histogram(
    "delivery_demo_http_request_duration_seconds",
    "HTTP request latency in seconds.",
    ["method", "path"],
)
READINESS = Gauge(
    "delivery_demo_ready",
    "Whether the service is ready to receive traffic.",
)


def runtime_metadata() -> dict[str, str]:
    return {
        "service": "delivery-demo",
        "version": os.getenv("APP_VERSION", "dev"),
        "environment": os.getenv("APP_ENVIRONMENT", "local"),
        "release_color": os.getenv("RELEASE_COLOR", "blue"),
        "commit_sha": os.getenv("COMMIT_SHA", "unknown"),
    }


@asynccontextmanager
async def lifespan(_: FastAPI):
    READINESS.set(1)
    yield
    READINESS.set(0)


app = FastAPI(
    title="GitOps Delivery Demo",
    version="0.1.0",
    description="A small observable service used to demonstrate Kubernetes GitOps delivery.",
    lifespan=lifespan,
)


@app.middleware("http")
async def observe_request(request: Request, call_next):
    started = time.perf_counter()
    response = await call_next(request)
    route = request.scope.get("route")
    path = getattr(route, "path", request.url.path)
    REQUESTS.labels(request.method, path, str(response.status_code)).inc()
    LATENCY.labels(request.method, path).observe(time.perf_counter() - started)
    response.headers["X-Content-Type-Options"] = "nosniff"
    return response


@app.get("/", tags=["service"])
async def service_info() -> dict[str, str]:
    return runtime_metadata()


@app.get("/version", tags=["service"])
async def version() -> dict[str, str]:
    return runtime_metadata()


@app.get("/health/live", tags=["health"])
async def liveness() -> dict[str, str]:
    return {"status": "alive"}


@app.get("/health/ready", tags=["health"])
async def readiness() -> dict[str, str]:
    return {"status": "ready"}


@app.get("/metrics", include_in_schema=False)
async def metrics() -> Response:
    return Response(generate_latest(), media_type=CONTENT_TYPE_LATEST)
