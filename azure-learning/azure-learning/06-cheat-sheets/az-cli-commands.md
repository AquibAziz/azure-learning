# Azure CLI — most-used commands

Ordered by how often I reach for them.

## Auth & context

```bash
az login                                  # browser login
az login --use-device-code                # for headless/remote
az account list --output table            # list subscriptions
az account set --subscription "<name>"    # switch sub
az account show                           # current sub/tenant
```

## Resource groups

```bash
az group create --name <rg> --location <region>
az group list --output table
az group show --name <rg>
az group delete --name <rg> --yes --no-wait
az group exists --name <rg>
```

## VMs

```bash
# Create (auto-creates VNet, subnet, NSG, Public IP)
az vm create \
  --resource-group <rg> \
  --name <vm> \
  --image Ubuntu2204 \
  --size Standard_B1s \
  --admin-username azureuser \
  --generate-ssh-keys

az vm list --output table
az vm show --resource-group <rg> --name <vm> --show-details
az vm start  --resource-group <rg> --name <vm>
az vm stop   --resource-group <rg> --name <vm>   # still billed
az vm deallocate --resource-group <rg> --name <vm>   # NOT billed for compute
az vm delete --resource-group <rg> --name <vm> --yes

az vm open-port --resource-group <rg> --name <vm> --port 80 --priority 1001
```

## Networking

```bash
# VNet
az network vnet create \
  --resource-group <rg> \
  --name <vnet> \
  --address-prefix 10.0.0.0/16 \
  --subnet-name default \
  --subnet-prefix 10.0.1.0/24

# Subnet
az network vnet subnet create \
  --resource-group <rg> \
  --vnet-name <vnet> \
  --name <subnet> \
  --address-prefix 10.0.2.0/24

# NSG
az network nsg create --resource-group <rg> --name <nsg>
az network nsg rule create \
  --resource-group <rg> \
  --nsg-name <nsg> \
  --name allow-http \
  --priority 100 \
  --source-address-prefixes Internet \
  --destination-port-ranges 80 \
  --access Allow --protocol Tcp

# ASG
az network asg create --resource-group <rg> --name <asg>
```

## Storage

```bash
az storage account create \
  --resource-group <rg> \
  --name <unique-name> \
  --sku Standard_LRS \
  --kind StorageV2

az storage account list --output table
az storage container create --account-name <sa> --name <container>
```

## Common flags

| Flag | What it does |
|---|---|
| `--output table` or `-o table` | Human-readable table |
| `--output json` (default) | JSON — pipe to `jq` |
| `--query "[].name"` | JMESPath filter |
| `--verbose` | Show HTTP calls |
| `--debug` | Full trace including auth |
| `--no-wait` | Don't block on long operations |

## Query examples

```bash
# List all VM names
az vm list --query "[].name" -o tsv

# List VMs with size & region
az vm list --query "[].{name:name, size:hardwareProfile.vmSize, region:location}" -o table

# Get public IP of a VM
az vm show -g <rg> -n <vm> --show-details --query publicIps -o tsv
```

## Cost / billing

```bash
az consumption usage list --top 5
az consumption budget list
```

## Cleanup sweep (when you're done with a lab)

```bash
# List all RGs so you know what's there
az group list --output table

# Nuke one
az group delete --name <rg> --yes --no-wait
```
