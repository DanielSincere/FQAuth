resource "digitalocean_database_cluster" "fqauth-sample-db-cluster" {
  name       = "fqauth-sample-db-cluster"
  engine     = "pg"
  version    = "13"
  size       = "db-s-1vcpu-1gb"
  region     = "nyc1"
  node_count = 1
  tags       = ["fqauth-sample"]
}

resource "digitalocean_database_firewall" "underway-db-cluster-firewall" {
  cluster_id = digitalocean_database_cluster.fqauth-sample-db-cluster.id

  rule {
    type  = "tag"
    value = "fqauth-sample"
  }
}

resource "digitalocean_database_db" "customers-db" {
  cluster_id = digitalocean_database_cluster.fqauth-sample-db-cluster.id
  name       = "fqauth-sample"
}


resource "digitalocean_database_user" "customers-app" {
  cluster_id = digitalocean_database_cluster.fqauth-sample-db-cluster.id
  name       = "fqauth-sample-server"
}

output "fqauth-sample-server-password" {
  value = digitalocean_database_user.fqauth-sample-server.password
  sensitive = true
}

