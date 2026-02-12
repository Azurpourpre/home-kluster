terraform {
    required_providers {
        vault = {
            source = "hashicorp/vault"
            version = "5.0.0"
        }
    }
}

variable root_token {
    type = string
}

provider "vault" {
    token_name = "root"
    token = var.root_token
}