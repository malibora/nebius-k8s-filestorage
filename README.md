# Kubernetes and Filestore playbook

## Features

- Create Kubernetes cluster with CPU and GPU nodes
- Install neccessary [Nvidia tools](https://github.com/NVIDIA/gpu-operator) to run GPU workloads
- Create a [FileStorage](https://nebius.ai/docs/compute/concepts/filesystem) virtual filessytem and attach it to all the nodes
- [Example workload](./test-deployment.yaml) with shared storage is included on the example



## Configure Terraform for Nebius Cloud

- Install [NCP CLI](https://nebius.ai/docs/cli/quickstart)
- Add environment variables for terraform authentication in Nebuis Cloud

```
export NCP_TOKEN=$(ncp iam create-token)
export NCP_CLOUD_ID=$(ncp config get cloud-id)
export NCP_FOLDER_ID=$(ncp config get folder-id)
```


## Install instructions

- Set folder_id, region in [terraform.tfvars](./terraform/terraform.tfvars) configuration file



- Run Terraform :

```
cd kubeflow/terraform
terraform init
terraform apply
```

- Run example deployment with mounted shared storage: 

```
kubectl apply -f test-example.yaml
```