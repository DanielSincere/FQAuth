resource "digitalocean_kubernetes_cluster" "underway_cluster" {
  name    = "${var.workspace_name}-cluster-${var.color}"
  version = var.do_k8s_version
  region  = "nyc1"
  tags    = ["cluster:${var.color}", "underway"]

  node_pool {
    name       = "${var.workspace_name}-${var.color}-edge"
    size       = var.edge_size
    tags       = concat(["uw-node-role:edge", "droplet:${var.color}", "underway"], var.additional_edge_tags)
    node_count = 1
  }
}
