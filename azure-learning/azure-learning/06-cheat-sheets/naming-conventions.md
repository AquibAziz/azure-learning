# Azure naming conventions

## My convention

```
<project>-<env>-<resource-type>-<region-short>[-<instance>]
```

Examples:
- `learn-dev-vnet-cin` (VNet in Central India, dev environment, learning project)
- `shop-prod-vm-eus-01` (first VM in East US prod)
- `blog-dev-sa-cin` (storage account — but see constraints below)

## Resource type abbreviations

| Resource | Abbrev |
|---|---|
| Resource group | `rg` |
| Virtual network | `vnet` |
| Subnet | `snet` |
| Network security group | `nsg` |
| Application security group | `asg` |
| Virtual machine | `vm` |
| Public IP | `pip` |
| Network interface | `nic` |
| Storage account | `sa` or `st` |
| Key vault | `kv` |
| App service | `app` |
| App service plan | `plan` |
| Function app | `func` |
| SQL server | `sql` |
| SQL database | `sqldb` |
| Cosmos DB | `cosmos` |
| AKS cluster | `aks` |
| Container registry | `acr` |
| Log Analytics workspace | `log` |

## Region short codes

| Region | Short |
|---|---|
| Central India | `cin` |
| South India | `sin` |
| East US | `eus` |
| East US 2 | `eus2` |
| West US | `wus` |
| West Europe | `weu` |
| North Europe | `neu` |
| Southeast Asia | `sea` |

## Azure naming constraints (watch out!)

Some resources have strict rules — they override my convention.

| Resource | Rules |
|---|---|
| Storage account | 3–24 chars, lowercase letters + numbers only, **globally unique** |
| Key Vault | 3–24 chars, alphanumeric + hyphens, globally unique |
| Container registry | 5–50 chars, alphanumeric only, globally unique |
| CosmosDB account | 3–44 chars, lowercase + numbers + hyphens, globally unique |
| App Service / Function name | 2–60 chars, must form valid hostname `<name>.azurewebsites.net` |
| VM name (Linux) | 1–64 chars |
| VM name (Windows) | 1–15 chars |
| Resource group | 1–90 chars |
| VNet | 2–64 chars |

**Key principle:** If it becomes part of a URL or DNS name, it's **globally unique** across all Azure customers — plan for collisions.

## Example: storage account for my learn project

My convention would say `learn-dev-sa-cin`, but storage accounts don't allow hyphens. So:

- **Canonical:** `learndevsacin`
- **If taken:** append digits → `learndevsacin01`, `learndevsacin02`

## References

- [Microsoft's Cloud Adoption Framework naming guide](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
