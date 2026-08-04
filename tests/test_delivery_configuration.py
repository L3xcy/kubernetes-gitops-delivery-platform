from pathlib import Path

import yaml

ROOT = Path(__file__).resolve().parents[1]
REPOSITORY = "https://github.com/L3xcy/kubernetes-gitops-delivery-platform.git"


def load_yaml(path: str) -> dict:
    with (ROOT / path).open(encoding="utf-8") as handle:
        return yaml.safe_load(handle)


def test_kind_cluster_is_loopback_only() -> None:
    cluster = load_yaml("cluster/kind.yaml")
    assert cluster["kind"] == "Cluster"
    assert cluster["networking"]["apiServerAddress"] == "127.0.0.1"


def test_argocd_project_restricts_repository_and_namespaces() -> None:
    project = load_yaml("gitops/project.yaml")
    assert project["spec"]["sourceRepos"] == [REPOSITORY]
    assert {item["namespace"] for item in project["spec"]["destinations"]} == {
        "delivery-dev",
        "delivery-prod",
    }
    assert {item["kind"] for item in project["spec"]["namespaceResourceBlacklist"]} == {
        "Secret"
    }


def test_dev_auto_syncs_while_production_requires_approval() -> None:
    development = load_yaml("gitops/dev-application.yaml")
    production = load_yaml("gitops/prod-application.yaml")
    assert development["spec"]["source"]["repoURL"] == REPOSITORY
    assert development["spec"]["syncPolicy"]["automated"]["selfHeal"] is True
    assert "automated" not in production["spec"]["syncPolicy"]


def test_container_declares_non_root_runtime_user() -> None:
    dockerfile = (ROOT / "Dockerfile").read_text(encoding="utf-8")
    assert "USER 10001:10001" in dockerfile
    assert "HEALTHCHECK" in dockerfile
