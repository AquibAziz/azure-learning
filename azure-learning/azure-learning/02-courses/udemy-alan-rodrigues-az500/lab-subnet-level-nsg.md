# AZ-500 — NSGs at the subnet layer

**Course:** Alan Rodrigues, AZ-500 Security (Udemy)
**Date watched:** 2026-04-24
**Type:** Hands-on lab (demonstration)
**Duration:** ~10 min

## Lab goal

Replace the messy per-VM NSG pattern (default from the wizard) with **one shared NSG attached at the subnet level** — the real-world best practice.

## What was done

1. Created a brand-new standalone NSG via "Create resource" → search "Network Security Group" → same region as VMs (North Europe)
2. **Disassociated** the wizard-created NSGs from each VM's NIC (one for web-vm-01, one for app-vm-01)
3. **Associated** the new NSG with both subnets (web-subnet-01 and app-subnet-01)
4. Added inbound rules on the new NSG:
   - **Rule 1** — Allow HTTP (port 80) from "My IP Address" → destination = private IP of web-vm-01 (priority 300)
   - **Rule 2** — Allow SSH (port 22) from "My IP Address" → destination = VNet address space OR specific private IPs comma-separated

## Why this matters

**Per-VM NSG (wizard default) = maintenance nightmare:**
- 2 VMs → 2 NSGs
- 20 VMs → 20 NSGs
- Same rule must be duplicated across each NSG
- Add a new VM → forget to set up its NSG → security gap

**Per-subnet NSG = scales naturally:**
- One NSG governs all resources in the tier
- New VMs inherit security automatically
- One place to audit, update, and reason about
- Consistent rules across identical workloads

## Three key concepts from this chapter

### 1. NSG attachment scope
Attach NSG to:
- ✅ Subnet (recommended)
- ✅ NIC (for exceptions per VM)
- ❌ Whole VNet (impossible — use Azure Firewall for VNet-level control)

### 2. Manually created NSGs have no SSH rule
The VM wizard silently adds an SSH allow rule. When you create an NSG from scratch, it has only the default built-in rules (which deny everything inbound from the internet). **You must add an SSH rule yourself** before detaching the old NSG, or you lose VM access.

### 3. Writing destination for multi-VM rules
For the SSH rule covering multiple VMs, Alan showed two options:
- **Broad:** `10.0.0.0/16` (entire VNet address space)
- **Specific:** `10.0.0.4,10.0.1.4` (individual private IPs, comma-separated)

Specific IPs are more secure (least privilege) but break when VMs are added. VNet address space is easier to maintain but more permissive.

## Gotchas

- **Order matters when swapping NSGs:** Create new NSG → add SSH rule → attach to subnet → detach old NSG from NIC. Doing these in the wrong order can lock you out.
- **One NSG CAN be attached to multiple subnets** — but usually you want different rules per subnet, so use separate NSGs.
- **Detaching an NSG is live** — no VM restart, no downtime. Rules just stop applying.
- **NSG and resource must be in the same region** (Alan mentioned this — North Europe in his case).

## A pattern worth reinforcing

This chapter shows the shift from **VM-centric security** to **zone-centric security**:

> Think about security at the **tier level** (web, app, db), not the VM level. VMs come and go; tiers are stable.

This aligns perfectly with cloud-native practices: VMs are cattle, not pets. Security belongs to the zone they live in.

## Questions this raised

- Can I apply NSG rules at the resource group level too? (No — only subnet or NIC)
- What if I want traffic inspection, not just allow/deny? (That's Azure Firewall territory)
- How do I track which NSGs have been modified recently? (Activity log + NSG diagnostic logs)

## Links to canonical notes

- [NSG & ASG](../../01-fundamentals/networking/02-nsg-asg.md) *(updated with subnet-level pattern)*
- [Public IPs and NAT](../../01-fundamentals/networking/12-public-ip-and-nat.md)
- [VNet & Subnets](../../01-fundamentals/networking/01-vnet-subnets.md)

## Added to interview question bank

- NSG attachment scopes (subnet vs NIC vs VNet)
- Why manually created NSGs lack SSH rules
- Order of operations when migrating NSGs
- Broad vs specific destination IPs
- One NSG on multiple subnets — when and when not

See [interview question bank](../../08-interview-prep/question-bank.md).
