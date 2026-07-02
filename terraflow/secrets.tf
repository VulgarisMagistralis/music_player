resource "kubernetes_secret" "github_runner_token" {
  metadata {
    name      = "github-runner-token-${random_pet.token_name.id}"
    namespace = "github-runners"
  }

  data = {
    token = jsondecode(data.http.runner_token.response_body).token
  }

  type = "Opaque"
}

resource "kubernetes_secret" "controller_manager" {
  metadata {
    name      = "controller-manager"
    namespace = "github-runners"
  }

  data = {
    github_token = jsondecode(data.http.runner_token.response_body).token
  }

  type = "Opaque"
}
