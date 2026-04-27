# Virtual Network (VNet) & Subnets

> A VNet is a logically isolated network inside Azure. It's what lets millions of customers share the same physical infrastructure safely.

## Why VNets exist

The public cloud is multi-tenant — millions of customers share the same physical servers and network hardware. Without isolation, two different customers could end up with their VMs on the same physical host sharing the same network segment. If one gets compromised, the attacker is already inside the network of everyone else on that hardware.

**VNet (Azure) / VPC (AWS)** solves this by providing logical network isolation on top of shared physical infrastructure. Each customer gets their own private, fenced-off network — own IP range, own routing, own security rules — even though the underlying hardware is shared.

## Core concepts

### VNet basics

- **Regionally scoped** — a VNet lives in one region, but can span availability zones within that region
- **Unlimited per subscription** — create as many VNets as you need
- **One org, many VNets** — typical pattern is one VNet per project or environment (dev/test/prod)
- **Defined by an address space** — using CIDR notation (e.g., `10.0.0.0/16`)

### Subnets

A VNet alone isn't enough. Different workloads have different security needs:

| Tier | Example | Internet-facing? |
|---|---|---|
| Web | Frontend websites | ✅ Yes |
| App | APIs, business logic | ❌ No |
| DB | Databases | ❌ Absolutely not |

**Solution:** Divide the VNet into **subnets** — one per tier. Each subnet gets its own CIDR slice and can have its own security rules.

## Sizing — CIDR

The number of IPs in a VNet or subnet is defined using CIDR notation:

| CIDR | Total IPs | Usable in Azure* |
|---|---|---|
| `/16` | 65,536 | 65,531 |
| `/24` | 256 | 251 |
| `/28` | 16 | 11 |

*Azure reserves **5 IPs per subnet** — first 4 (network, gateway, DNS×2) and last 1 (broadcast). This catches people out when planning small subnets.

**Typical usage:** `/16` for a whole VNet, `/24` for each subnet inside it.

## Common patterns

### Classic 3-tier architecture

```
VNet: 10.0.0.0/16
├── Web subnet:  10.0.1.0/24  ← internet-facing
├── App subnet:  10.0.2.0/24  ← private, talks to DB
└── DB subnet:   10.0.3.0/24  ← private, only app tier can reach
```

Traffic flow: `Internet → Web → App → DB` (one-way funnel enforced by NSGs)

This pattern implements **defense in depth**. Even if the web tier is compromised, the attacker has to pivot through the app tier to reach the data.

## Gotchas & exam tips

- **Azure reserves 5 IPs per subnet**, not 2 like traditional networking. A `/24` gives 251 usable IPs, not 254.
- **VNets are regional.** To connect VNets in different regions, use **VNet peering** (global peering).
- **Default VNet/subnet when creating a VM:** Azure creates these automatically if you don't specify. Fine for playing around, never for production.
- **Address spaces must not overlap** if you want to peer VNets or connect them via VPN. Plan your CIDR blocks across the whole org up front.
- **You can't shrink a subnet once resources are in it.** Plan sizing carefully.

## Related topics

- [NSG & ASG — securing subnets](./02-nsg-asg.md)
- [CIDR deep dive](./03-cidr-explained.md)
- [Route tables & UDRs](./04-route-tables-udr.md)
- [VNet peering](./05-vnet-peering.md)

## Sources

- YouTube — Abhishek Veeramalla, *Azure Zero to Hero Day 5*
- Microsoft Learn — [Azure Virtual Network overview](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-networks-overview)
