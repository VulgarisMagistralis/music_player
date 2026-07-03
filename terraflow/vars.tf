variable "github_repo" {
  description = "GitHub repository in the form org/repo"
  type        = string
  default     = "VulgarisMagistralis/music_player"
}

variable "kubeconfig_path" {
  description = "Path to the kubeconfig file"
  type        = string
}
