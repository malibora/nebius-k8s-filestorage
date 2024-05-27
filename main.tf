resource "nebius_compute_filesystem" "k8s-shared-storage" {
  name      = "k8s-shared-storage"
  folder_id = var.folder_id
  type      = "network-ssd"
  zone      = "eu-north1-c"
  size      = 40
}

resource "null_resource" "attach-filestore" {
  depends_on = [nebius_compute_filesystem.k8s-shared-storage, module.kube-cluster]
  provisioner "local-exec" {
    command = <<EOT
      # Define the subnet_id to filter the instances
      subnet_id="${nebius_vpc_subnet.k8s-subnet.id}"

      # Define the filesystem details to attach
      filesystem_id="${nebius_compute_filesystem.k8s-shared-storage.id}"

      # Fetch the list of instance IDs that are connected to the specified subnet
      instance_ids=$(ncp compute instance list --format json | jq -r ".[] | select(.network_interfaces[].subnet_id == \"$subnet_id\") | .id")

      # Loop through each instance ID and attach the filesystem
      for id in $instance_ids; do
          echo "Attaching filesystem to instance ID: $id"
          ncp compute instance attach-filesystem $id \
              --filesystem-id $filesystem_id
          echo "Filesystem attached to instance ID: $id"
      done

      echo "All operations have been initiated."
EOT
  }
}

module "kube-cluster" {
  source = "github.com/nebius/terraform-nb-kubernetes.git?ref=1.0.4"

  network_id = nebius_vpc_network.k8s-network.id
  folder_id  = var.folder_id

  master_locations = [
    {
      zone      = "eu-north1-c"
      subnet_id = "${nebius_vpc_subnet.k8s-subnet.id}"
    },

  ]

  master_maintenance_windows = [
    {
      day        = "monday"
      start_time = "20:00"
      duration   = "3h"
    }
  ]
  node_groups = {
    k8s-ng-1g-system = {
      description = "Kubernetes nodes group 01 with fixed 1 size scaling"
      fixed_scale = {
        size = 2
      }
      node_labels = {
        "group" = "system"
      }
      # node_taints = ["CriticalAddonsOnly=true:NoSchedule"]
    }
    k8s-ng-a100-8gpu3 = {
      description = "Kubernetes nodes h100-1-gpu nodes with autoscaling"
      fixed_scale = {
        size = 3
      }
      platform_id     = var.platform_id
      gpu_environment = "runc"
      node_cores      = 224 // change according to VM size
      node_memory     = 952 // change according to VM size
      node_gpus       = 8
      disk_type       = "network-ssd-nonreplicated"
      disk_size       = 372
      node_labels = {
        "group"               = "a100-1gpu"
        "nebius.com/gpu"      = "A100"
        "nebius.com/gpu-a100" = "A100"
      }
    }
  }
}
