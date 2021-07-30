# IoT Egde Observability sample 

| Directory        | Info           |
| -------------    |:-------------:|
| terraform        | Contains root terraform skrip and terraform modules to create resources  |
| scripts          | Contains shell script to register VM as an edge device.       |  
| src              | Contains source code.       |  
| .ssh (generated) | Generated dircetory when creating ressources. Contains the private key to access the VM over ssh  |
| .devcontainer    | Contains devcontainer setup (tbd), requirments.text files etc. |

## Run sample

### 1. Infrastructure

The following instruction are all done in the directory `terraform`

Run `terraform init` to initialize terraform and `terraform apply` to create resources.

This should result in an terraform output  containing the following values.

```bash
Outputs:

edge_device_name = "<prefix>-edge-device"
iot_edge_device_connction_string = "<connection-string>"
iot_edge_vm_public_ssh = "ssh -i ../../.ssh/id_rsa <vm-username>@<prefix>-iot-edge.westeurope.cloudapp.azure.com"
iot_hub_name = "<prefix>-iot-hub"
```

The ssh private key key should also be stored under the generated `.ssh` directory in root.

### 2. Edge Deployment

