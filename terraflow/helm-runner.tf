resource "helm_release" "github_runner" {
  name             = "github-runner"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart            = "actions-runner-controller"
  version          = "0.23.7"
  namespace        = "github-runners"
  create_namespace = true
  set = [{
    name  = "githubConfigUrl"
    value = "https://github.com/${var.github_repo}"
    }
    , {
      name  = "githubConfigSecret"
      value = kubernetes_secret.github_runner_token.metadata[0].name
    }
    ,
    {
      name  = "runnerLabels"
      value = var.runner_label
    }

    , {
      name  = "replicas"
      value = "1"
    }

    # Give the runner enough resources for Android builds
    , {
      name  = "resources.limits.cpu"
      value = "2"
    }

    , {
      name  = "resources.limits.memory"
      value = "4Gi"
    }

    # Persist /home/runner/_work so that caches survive pod restarts
    , {
      name  = "persistence.enabled"
      value = "true"
    }

    , {
      name  = "persistence.size"
      value = "10Gi"
  }]
}
