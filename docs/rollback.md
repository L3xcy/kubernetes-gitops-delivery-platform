# Promotion and rollback

## Promote an image

Use an immutable release tag produced by the release workflow:

```bash
scripts/promote-image.sh dev v0.1.1
git diff -- charts/delivery-demo/values-dev.yaml
git add charts/delivery-demo/values-dev.yaml
git commit -m "chore(dev): promote delivery demo to v0.1.1"
git push
```

After development verification, repeat the change for production. Production intentionally requires a manual Argo CD sync so the promotion remains an explicit approval step.

## Roll back through Git

Git remains the source of truth. Revert the promotion commit instead of running an imperative `kubectl set image` command:

```bash
git revert <promotion-commit>
git push
```

Argo CD detects the previous declared tag and reconciles the workload. This keeps the audit trail, live state, and repository history aligned.

## Emergency distinction

An imperative Kubernetes rollback may be appropriate during an active production emergency, but Git must be updated immediately afterward. This portfolio lab demonstrates the normal Git-first workflow rather than claiming to replace an incident-specific emergency procedure.
