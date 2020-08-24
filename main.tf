provider "google" {
 credentials = "${file("${var.credentials}")}"
 project     = "${var.gcp_project}"
 region      = "${var.region}"
}

// Create VPC
resource "google_compute_network" "prodvpc" {
 name                    = "${var.name}-vpc"
 auto_create_subnetworks = "false"
}

// Create Subnet
resource "google_compute_subnetwork" "prodsubnet" {
 name          = "${var.name}-subnet"
 ip_cidr_range = "${var.subnet_cidr}"
 network       = "${var.name}-vpc"
 depends_on    = ["google_compute_network.prodvpc"]
 region      = "${var.region}"
}

// VPC firewall configuration
resource "google_compute_firewall" "prodfirewall" {
  name    = "${var.name}-firewall"
  network = "${google_compute_network.prodvpc.name}"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

// Launch MySQL Instance

resource "google_sql_database" "database" {
  name     = "my-database"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_database_instance" "instance" {
  name   = "my-database-instance"
  database_version = "MYSQL_5_7"
  region = "asia-southeast1"
  project = "mysqldb-project-400200"

  settings {
    tier = "db-f1-micro"
    availability_type = "REGIONAL"
    disk_size         = 10  # 10 GB is the smallest disk size
  }
}

