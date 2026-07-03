resource "kubernetes_secret" "github_runner_token" {
  metadata {
    name      = "github-runner-secret"
    namespace = "arc-runners"
  }
  data = {
    github_token = var.github_pat
  }
  type = "Opaque"

  depends_on = [
    helm_release.arc_runner_set # waits for the namespace to be created
  ]
}
