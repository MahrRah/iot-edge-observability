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
DEVICE_CONNECTION_STRING =  "<connection-string>"
IOTHUB_CONNECTION_STRING =  "<connection-string>"
IOT_HUB_RESOURCE_ID = "subscriptions/<subspcription-id>/resourceGroups/<resouce-group>/providers/Microsoft.Devices/IotHubs/<prefix>-iot-hub"
LOG_ANALYTICS_WORKSPACE_ID = "<workspace-id>"
LOG_ANALYTICS_WORKSPACE_KEY =  "<key>"
edge_device_name = "<prefix>-edge-device"
iot_edge_vm_public_ssh = "ssh -i ../../.ssh/id_rsa <vm-username>@<prefix>-iot-edge.westeurope.cloudapp.azure.com"
iot_hub_name = "<prefix>-iot-hub"
```

The ssh private key key should also be stored under the generated `.ssh` directory in root.
### 2. Generate .env` file

Use terraform output to generate the `.env` file

```bash
python generate_config.py
```

All `generate_config.py` options:

```bash
generate_config.py
    usage: generate_config.py [-h] [-e {local-development,development}] [-mg] [-g]

    optional arguments:
    -h, --help            show this help message and exit
    -e, --environment {local-development,development} Terraform environment to get output from. Must have provisioned infrastructure before running this. (default: local-development)
    -mg, --mock-grpc      Set gRPC to send mock inferencing (default: real inferencing)
    -g, --gpu             Set when running GPU enabled containers with GPU VMs (default: no GPU)
```

### 3. Create deployment

Change directory:

```bash
cd deployments/edge
```

Use `iotedgedev` to generate `deployment.json` from deployment template using the `.env` file it

```bash
`iotedgedev build -f config/deployment.json
```

### 4. Deploy

Deploy to egde device using `iotedgedev`

```bash
iotedgedev deploy -f config/deployment.json
```

