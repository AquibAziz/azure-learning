# AZ-500 Lab — Host a web server on a VM

**Course:** Alan Rodrigues, AZ-500 Security (Udemy)
**Date watched:** 2026-04-20
**Type:** Hands-on lab (demonstration video)
**Duration:** ~10 min

## Lab goal

Deploy an Ubuntu VM, install nginx, try to access it from the internet, and observe that **NSG blocks the request by default**. This failure sets up the next lesson on NSG configuration.

## What was done

1. Deployed an Ubuntu Linux VM via Azure portal wizard
2. Noted: wizard auto-created VNet (`10.0.0.0/16`), subnet (`10.0.0.0/24`), Public IP, NIC, NSG
3. SSH'd to the VM from local machine: `ssh azureuser@<public-ip>`
4. Installed nginx:
   ```bash
   sudo apt update
   sudo apt install nginx
   ```
5. Verified nginx works *from inside the VM*:
   ```bash
   curl http://10.0.0.4   # returns nginx welcome HTML
   ```
6. Tried accessing from laptop browser: `http://<public-ip>` → **request times out**

## Why the browser failed

- nginx is listening on port 80 ✅
- The VM has a public IP ✅
- The path from internet → Azure edge → VM is intact ✅
- **BUT** the NSG on the subnet/NIC has a default-deny rule for all inbound traffic except the auto-added SSH rule (port 22)
- Port 80 wasn't explicitly allowed → dropped silently

## Concepts demonstrated

### Two IPs per VM
| | Private IP | Public IP |
|---|---|---|
| Purpose | Internal (VNet-scoped) | Internet-accessible |
| From | Subnet's CIDR | Azure's public IP pool |
| Example | 10.0.0.4 | 20.x.x.x |

### Why first usable IP is `.4` not `.1`
Azure reserves 5 IPs per subnet:
- `.0` — network address
- `.1` — default gateway
- `.2`, `.3` — Azure DNS mapping
- `.255` (last) — broadcast

So in a `/24`, usable range is `.4` to `.254` = 251 IPs.

### Default NSG behavior
- `AllowVnetInBound` (65000) — allow within VNet
- `AllowAzureLoadBalancerInBound` (65001) — health probes
- `DenyAllInBound` (65500) — block everything else
- Custom rules (100–4096) override these by priority (lower wins)

## What's next
The following video shows how to **fix this** by adding an inbound NSG rule to allow port 80.

## Questions this raised

- Static vs dynamic public IP — when does the IP change?
- Cost of an unattached public IP sitting around
- How does SSH work by default? (Answer: Azure auto-adds an allow rule for port 22 when you create a Linux VM)

## Links to canonical notes

- [NSG & ASG](../../01-fundamentals/networking/02-nsg-asg.md) — NSG rule mechanics
- [VNet & Subnets](../../01-fundamentals/networking/01-vnet-subnets.md) — reserved IPs

## Added to interview question bank

- Why does a VM get 2 IPs (private + public)?
- Why is the first usable IP `.4` in a subnet?
- "curl works inside but browser fails from outside" — what's wrong?
- What NSG rule would fix it?

See [interview question bank](../../08-interview-prep/question-bank.md).
