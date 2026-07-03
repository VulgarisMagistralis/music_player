variable "github_repo" {
  description = "GitHub repository in the form org/repo"
  type        = string
  default     = "VulgarisMagistralis/music_player"
}

variable "runner_label" {
  description = "Custom label for the self‑hosted runner"
  type        = string
  default     = "local-k8-runner"
}
