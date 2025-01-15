provider "google" {
  project = var.project_id
  region  = var.region
}

module "gce_instance" {
  source = "../../../modules/compute/gce"

  project_id    = var.project_id
  instance_name = "example-instance"
  machine_type  = "e2-medium"
  zone         = "${var.region}-a"

  network    = "default"
  subnetwork = "default"

  enable_public_ip = true

  boot_disk_image    = "debian-cloud/debian-11"
  boot_disk_size_gb  = 50
  boot_disk_type     = "pd-standard"

  network_tags = ["web", "ssh"]

  metadata = {
    startup-script = "echo 'Hello, World!' > /tmp/hello.txt"
  }

  labels = {
    environment = "dev"
    managed_by  = "terraform"
  }
}
