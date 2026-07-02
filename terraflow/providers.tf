provider "kubernetes" {
  config_path = "/home/cnek/kubeconfig/kubeconfig.yaml"
}

provider "helm" {
  kubernetes = {
    config_path = "/home/cnek/kubeconfig/kubeconfig.yaml"
  }
}
