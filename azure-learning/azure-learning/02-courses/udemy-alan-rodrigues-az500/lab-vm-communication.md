# AZ-500 — Communication across VMs within a VNet

**Course:** Alan Rodrigues, AZ-500 Security (Udemy)
**Date watched:** 2026-04-20
**Type:** Hands-on lab (demonstration)
**Duration:** ~10 min

## Lab goal

Demonstrate:
1. Two VMs in different subnets of the same VNet can talk to each other via **private IP** by default
2. The same VM is still unreachable from the internet via public IP unless NSG rules allow it
3. Why NSG rules use the **private IP** of the destination VM, even when clients connect using the public IP

## What was done

1. Created second subnet `app-subnet-01` (`10.0.1.0/24`) in the existing VNet
2. Deployed `app-vm-01` (Ubuntu) in that subnet with its own auto-created NSG
3. SSH'd into `app-vm-01`
4. `curl http://10.0.0.4` → **works** (private IP of `web-vm-01`) ✅
5. `curl http://<public-ip-of-web-vm-01>` → **fails** ❌
6. Added an NSG rule on `web-vm-01`: Source = my IP, Destination = 10.0.0.4 (private IP), port 80 → browser now works ✅

## The three key learnings

### 1. Default rule `AllowVnetInBound` enables VM-to-VM private traffic

Every NSG has a built-in rule at priority 65000:
- Name: `AllowVnetInBound`
- Source: `VirtualNetwork` service tag
- Destination: `VirtualNetwork`
- Ports: Any
- Action: Allow

This is why `app-vm-01` could `curl` `web-vm-01`'s private IP without any custom rules — it's the default-open within the VNet.

**Service tag `VirtualNetwork`** includes: address space of this VNet + all connected peered VNets + on-prem connected via VPN/ExpressRoute.

### 2. Public IP traffic is still blocked

Even though both VMs are in the same VNet, hitting `web-vm-01`'s **public IP** from `app-vm-01` fails. Why? Because the traffic leaves Azure (goes to the public IP), Azure routes it back in through the edge, NSG default-deny for internet sources applies.

**Takeaway:** Always use private IPs for VM-to-VM communication inside Azure. Never route internal traffic through public IPs.

### 3. NSG rules use the PRIVATE IP of the destination VM

This was the confusing part. Alan's rule:
- Source: "My IP Address" (auto-fills laptop's public IP)
- Destination: `10.0.0.4` (web-vm-01's PRIVATE IP)
- Port: 80

When the user hits the public IP from their browser, Azure's edge does NAT — rewrites the destination from public IP to `10.0.0.4`. The NSG sees the translated packet, the rule matches, traffic is allowed.

**Rule of thumb:**
- Source IP in NSG rule = where the request is coming FROM (usually a public IP of the client)
- Destination IP in NSG rule = PRIVATE IP of the Azure resource (post-NAT)

## Concepts demonstrated

- **Multi-subnet VNet pattern** — web and app subnets separate
- **NSG per VM (wizard default)** vs NSG per subnet (better in practice)
- **Default NSG rules** — `AllowVnetInBound`, `AllowAzureLoadBalancerInBound`, `DenyAllInBound`
- **NAT (Network Address Translation)** — how public IPs actually work
- **"My IP Address" source option** — convenient for locking admin access to your home IP

## Gotchas

- **Wizard creates one NSG per VM** — gets messy fast. In real deployments, attach ONE NSG per subnet.
- **"My IP Address" shifts with your ISP** — your home public IP isn't permanent; rule may break the next day.
- **Don't mix public and private IPs in your rules** — always use private as destination.
- **Deleting a VM leaves the public IP orphaned** — still billed.

## Questions this raised

- Can I force traffic between VMs to go through Azure Firewall even within the same VNet? (Yes — with UDRs)
- What happens if I peer two VNets with overlapping IP ranges? (Peering fails; plan CIDRs carefully)
- How do I restrict admin access without exposing SSH to the internet? (Azure Bastion)

## Links to canonical notes

- [Public IPs and NAT](../../01-fundamentals/networking/12-public-ip-and-nat.md) *(new — explains the NAT confusion)*
- [NSG & ASG](../../01-fundamentals/networking/02-nsg-asg.md) *(updated)*
- [VNet & Subnets](../../01-fundamentals/networking/01-vnet-subnets.md)

## Added to interview question bank

- Why can two VMs in different subnets communicate by private IP without any rule?
- Why does the NSG rule use the private IP as destination when the client connects using the public IP?
- What's the difference between source "Any" and source "My IP Address"?
- Why does deleting a VM not delete its public IP?

See [interview question bank](../../08-interview-prep/question-bank.md).
