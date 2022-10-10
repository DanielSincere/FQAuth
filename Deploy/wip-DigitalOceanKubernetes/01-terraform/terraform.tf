variable "do_token" {
  description = "Your DigitalOcean API Token"
}

terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "~> 2.9.0"
    }
  }
  required_version = ">= 1.0.0"
}

provider "digitalocean" {
  token   = var.do_token
}
