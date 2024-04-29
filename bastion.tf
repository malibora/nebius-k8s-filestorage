resource "nebius_iam_service_account" "bastion-sa" {
  folder_id = var.folder_id
  name      = "bastion-sa-${random_string.kf_unique_id.result}"
}

// Grant permissions
resource "nebius_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${nebius_iam_service_account.bastion-sa.id}"
}


resource "null_resource" "generate-api-key" {
  depends_on = [nebius_resourcemanager_folder_iam_member.sa-editor]
  provisioner "local-exec" {
    command = <<EOT
      sa_editor_id="${nebius_iam_service_account.bastion-sa.name}"
      ncp iam key create --service-account-name $sa_editor_id --output key.json
EOT
  }
}
