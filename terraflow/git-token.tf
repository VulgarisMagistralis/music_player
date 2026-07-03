# This uses the GitHub API to fetch a short‑lived runner registration token.
# You must set a GitHub personal‑access token (with admin:repo_hook scope) as TF_VAR_github_pat
variable "github_pat" {
  description = "GitHub personal access token for the repo (admin:repo_hook scope)."
  type        = string
  sensitive   = true
}
