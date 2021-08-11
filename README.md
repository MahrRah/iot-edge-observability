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

APP_INSIGHTS_CONNECTION_STRING = "<connection-string>"
CONTAINER_NAME = "<prefix>-device-logs"
CONTAINER_REGISTRY_PASSWORD = "<password>"                 
CONTAINER_REGISTRY_SERVER = "<prefix>-acr.azurecr.io"
CONTAINER_REGISTRY_USERNAME = "<prefix>-acr"
DEVICE_CONNECTION_STRING =  "<connection-string>"
FUNCTION_HOST = "https://<prefix>-azure-functions.azurewebsites.net"
FUNCTION_KEY = "<key>" 
IOTHUB_CONNECTION_STRING =  "<connection-string>"
IOT_HUB_RESOURCE_ID = "subscriptions/<subspcription-id>/resourceGroups/<resouce-group>/providers/Microsoft.Devices/IotHubs/<prefix>-iot-hub"
LOG_ANALYTICS_WORKSPACE_ID = "<workspace-id>"
LOG_ANALYTICS_WORKSPACE_KEY =  "<key>"
QUEUE_NAME = "<queue-name>"
STORAGE_CONNECTION_STRING = "<connection-string>"
edge_device_name = "<prefix>-edge-device"
iot_edge_vm_public_ssh = "ssh -i ../../.ssh/id_rsa <vm-username>@<prefix>-iot-edge.westeurope.cloudapp.azure.com"
iot_hub_name = "<prefix>-iot-hub"
```

The ssh private key key should also be stored under the generated `.ssh` directory in root.
### 2. Generate .env` file

Use terraform output to generate the `.env` file

```bash
python scripts/generate_config.py
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
iotedgedev build -f config/deployment.json
```

### 4. Deploy

Deploy to egde device using `iotedgedev`

```bash
iotedgedev deploy -f config/deployment.json
```

## Logging
This sample uses the Azure Functions from [ELMS](https://github.com/Azure-Samples/iotedge-logging-and-monitoring-solution) to export the logs into Application Insights. 

### 1. Create `local.settings.json` 
Run the command bellow to create a new `local.settings.json` with the information in the `.env` file.

```bash
python scripts/generate_local_json.py
```

## Metrics
This sample usees the Azure monitoring module to collect the metrics from all the egde modules and push them to Application Insights (see [docs](https://docs.microsoft.com/en-us/azure/iot-edge/how-to-collect-and-transport-metrics?view=iotedge-2020-11))

All metrics are expost at port `9600`.
## Tracing

> Context tracing for messaging systmes is currently not possible out of the box. 