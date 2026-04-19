# Day 5 — Azure Virtual Network (VNet)

**Date watched:** 2026-04-19
**Video:** Day 5, Azure Zero to Hero series
**Duration:** ~19 min
**Level:** Beginner

## Key concepts covered

- Why VNets exist (multi-tenant security problem)
- VNet basics and sizing via CIDR
- Subnets — splitting a VNet by tier (web/app/db)
- Network Security Groups (NSG)
- Application Security Groups (ASG)
- Route tables & User-Defined Routes (briefly — demo to come)

## My notes

### The "why" — Nike vs Puma analogy

Two DevOps engineers (Nike, Puma) both request a VM in East US Zone 1. Without VNets, Azure could place both on the same physical server. If Puma's VM gets hacked, Nike's is one hop away on the same network. VNet = logical isolation that fixes this. Same concept in AWS is called VPC.

### VNet

- Created per region, can span AZs in that region
- Unlimited per subscription
- One org usually has many VNets — one per project/env
- Size defined by CIDR. `/16` = 65,536 IPs (common default)

### Subnets

- Divide VNet by workload tier
- Example: `subnet-web`, `subnet-app`, `subnet-db`
- Each gets its own CIDR
- Apply different security rules per subnet

### NSG

- Firewall rules (allow/deny)
- Attach to subnet OR NIC (subnet better for most cases)
- Example rule: deny all internet → DB subnet; allow app subnet → DB subnet

### ASG

- Groups VMs by role
- Lets NSG rules reference "business-logic VMs" instead of IP ranges
- Abhishek's example: even within a subnet, only 5 out of 15 VMs should reach DB → use ASG
- Best used WITH NSG — not instead of

### Route tables / UDRs

- Just explains how traffic flows
- Deeper dive coming in the demo

## Questions that came up

- What does CIDR `/16` actually mean mathematically? → watch his dedicated CIDR video
- How are default NSG rules evaluated vs custom rules?
- When would I use UDRs vs system routes?

## Links to canonical notes

I synthesized this into:
- [VNet & Subnets](../../01-fundamentals/networking/01-vnet-subnets.md)
- [NSG & ASG](../../01-fundamentals/networking/02-nsg-asg.md)

## Self-check answers

I also answered practice questions — see [VNet self-check answers](../../01-fundamentals/networking/self-check-vnet.md) *(TODO: move here)*
