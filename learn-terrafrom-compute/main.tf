terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.5.0"
    }
  }
}

provider "google" {
  credentials = file("../secure/gcp-terrafrom-user.json")

  project = "symmetric-core-242320"
  region  = "us-central1"
  zone    = "us-central1-c"
}


# https://amazicworld.com/overriding-variables-in-terraform/ 
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_instance


resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  # machine_type = "e2-medium"
  machine_type = "e2-micro"
  tags = ["http-server","https-server"]
  boot_disk {
    initialize_params {
      image = "debian-10-buster-v20210609"
    }
  }

  network_interface {
    # A default network is created for all GCP projects
    network = "default"
    access_config {
    }
  }
  
  metadata_startup_script = "echo hi > /tmp/test.txt"

  scheduling {
    automatic_restart   = false
    preemptible         = true
  }
}

