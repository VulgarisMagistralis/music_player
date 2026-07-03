resource "helm_release" "arc_controller" {
  name             = "arc"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set-controller"
  namespace        = "arc-systems"
  create_namespace = true
}

resource "helm_release" "arc_runner_set" {
  name             = "arc-runner-set"
  repository       = "oci://ghcr.io/actions/actions-runner-controller-charts"
  chart            = "gha-runner-scale-set"
  namespace        = "arc-runners"
  create_namespace = true
  set = [
    { name = "githubConfigUrl", value = "https://github.com/${var.github_repo}" },
    { name = "githubConfigSecret", value = "github-runner-secret" },
    { name = "runnerScaleSetName", value = "local-k8-runner" }
  ]
  depends_on = [helm_release.arc_controller]
}
