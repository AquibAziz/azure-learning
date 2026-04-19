# Azure Firewall

> The compound wall of your VNet. A managed, cloud-native, stateful firewall that protects all resources inside a VNet.

## Why it exists

NSGs are basic — they filter by IP and port. But real-world security needs more: URL filtering, FQDN rules, threat intelligence, application-layer inspection. Azure Firewall fills that gap.

Think of it as the **main gate and security checkpoint** at the entrance to a gated community, while NSGs are the individual building-level guards.

## Core capabilities

- **Network rules** — allow/deny by IP, port, protocol (like NSG, but centralized)
- **Application rules** — allow/deny by FQDN (e.g., `*.microsoft.com`, `*.github.com`)
- **NAT rules** — translate public IPs to private IPs for inbound traffic
- **Threat intelligence** — Microsoft-maintained feed that blocks known bad IPs/domains
- **Stateful** — tracks connections, auto-allows return traffic
- **Fully managed** — no VMs to patch; Azure handles HA and scaling

## Azure Firewall vs NSG

| | **Azure Firewall** | **NSG** |
|---|---|---|
| Scope | Whole VNet (central) | Per subnet or NIC |
| Layer | L3–L7 | L3–L4 |
| FQDN filtering | ✅ Yes | ❌ No (only IPs) |
| Threat intel | ✅ Built-in | ❌ No |
| Logging | Rich, centralized | Basic flow logs |
| Cost | ~$900+/month base | Free |
| When to use | Production, regulated workloads | Always (baseline) |

**They complement each other.** A typical setup uses **Azure Firewall at the edge** for internet-bound traffic, plus **NSGs per subnet** for internal segmentation.

## Common patterns

### Force-tunneling through firewall
Use a **User-Defined Route (UDR)** on every subnet with next-hop = Azure Firewall's IP. Now all outbound traffic is inspected before leaving Azure.

### Hub-and-spoke networking
Put Azure Firewall in a central "hub" VNet. Spoke VNets peer to the hub. All cross-spoke and internet traffic flows through the firewall — centralized control.

## Gotchas

- **Expensive** — base cost plus per-GB processing fee. For learning, stick to NSGs.
- **Needs its own subnet** named `AzureFirewallSubnet` (exact name required)
- **Minimum subnet size** `/26`
- **Azure Firewall Premium** adds TLS inspection, IDPS, URL filtering — costs more

## Related topics

- [NSG & ASG](./02-nsg-asg.md)
- [Route tables & UDRs](./04-route-tables-udr.md)
- [VNet peering](./05-vnet-peering.md)

## Sources

- YouTube — Abhishek Veeramalla, *Azure Zero to Hero Day 6*
- Microsoft Learn — [Azure Firewall overview](https://learn.microsoft.com/en-us/azure/firewall/overview)
