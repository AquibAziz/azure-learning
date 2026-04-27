# 🛠️ Hands-on labs

Real things I built, broke, and fixed in Azure. Each lab folder has commands, screenshots, and lessons learned.

**Why this matters:** Reading about VNets is different from creating one and having traffic fail to route. Labs make the concepts stick and give me artifacts to reference later.

## Labs

| # | Lab | Topics | Status |
|---|---|---|---|
| 01 | [First VM](./lab-01-first-vm/) | VM, NSG, SSH | ⬜ |
| 02 | [3-tier VNet with NSG + ASG](./lab-02-3tier-vnet/) | VNet, subnets, NSG, ASG | ⬜ |
| 03 | [Host web server on VM (AZ-500)](./lab-03-host-web-server/) | VM, nginx, NSG default-deny | 🔄 |

Legend: ⬜ Not started • 🔄 In progress • ✅ Completed

## Lab conventions

- Every lab has a cleanup step at the end (`az group delete`) — free tier credits are precious
- Resources use a consistent naming pattern: `<proj>-<env>-<resource>-<region>` → e.g., `learn-dev-vnet-centralindia`
- Screenshots go in `screenshots/` inside each lab folder
- Commands in `commands.sh` or `commands.md` — reproducible

## Lab template

Every lab folder follows this structure:

```
lab-NN-short-name/
├── README.md              ← goal, architecture, steps, lessons
├── commands.sh            ← azure CLI commands used
├── architecture.md        ← diagram or description
└── screenshots/           ← portal screenshots of key moments
```

See [`/CONTRIBUTING.md`](../CONTRIBUTING.md) for the full lab write-up template.

## Safety reminders

- **Never commit credentials, keys, or `.pem` files** — `.gitignore` covers the common cases but double-check
- **Always delete the resource group** at the end of a lab session
- **Set a budget alert** on your Azure subscription so you don't get surprised
- Use free-tier-eligible SKUs wherever possible (B1s VMs, standard LRS storage, etc.)
