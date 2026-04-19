# Lab 01 — First VM

## Goal

Spin up my first Azure VM, SSH into it, install nginx, and expose it over the internet. Then clean up everything to keep costs at zero.

## Architecture

```
Internet
   │
   ▼
┌──────────────────────────────┐
│  Resource Group: lab-01-rg   │
│  ┌────────────────────────┐  │
│  │ VNet: 10.0.0.0/16      │  │
│  │  ┌──────────────────┐  │  │
│  │  │ Subnet: 10.0.1.0 │  │  │
│  │  │  /24             │  │  │
│  │  │  ┌────────────┐  │  │  │
│  │  │  │ VM (B1s)   │  │  │  │
│  │  │  │ + Pub IP   │  │  │  │
│  │  │  │ NSG: 22,80 │  │  │  │
│  │  │  └────────────┘  │  │  │
│  │  └──────────────────┘  │  │
│  └────────────────────────┘  │
└──────────────────────────────┘
```

## Prerequisites

- Azure account with free trial or pay-as-you-go
- Azure CLI installed (`az --version` to verify)
- SSH key pair ready (`~/.ssh/id_rsa.pub`)

## Steps

See [`commands.sh`](./commands.sh) for runnable commands.

1. **Login & set subscription**
2. **Create resource group**
3. **Create VM** (auto-creates VNet, subnet, NSG, public IP)
4. **Open port 80** in the NSG
5. **SSH in** and install nginx
6. **Verify** by hitting the public IP in the browser
7. **Clean up** — delete the resource group

## Gotchas

*(Fill this in as you do the lab — what broke, what you had to fix)*

- [ ] TBD — ran into:
- [ ] TBD — fixed by:

## Cleanup

```bash
az group delete --name lab-01-rg --yes --no-wait
```

Verify it's gone:

```bash
az group exists --name lab-01-rg  # should return "false"
```

## What I learned

*(Fill in after completion)*

## Related notes

- [VNet & Subnets](../../01-fundamentals/networking/01-vnet-subnets.md)
- [NSG & ASG](../../01-fundamentals/networking/02-nsg-asg.md)
