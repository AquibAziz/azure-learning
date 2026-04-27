# VNet Peering & VPN Gateway

> Two ways to connect networks. **VNet peering** = Azure VNet ↔ Azure VNet. **VPN Gateway** = Azure VNet ↔ on-premises network.

## The problem: VNets are isolated

By design, resources in VNet A cannot talk to resources in VNet B. This is a security feature — but sometimes you genuinely need connectivity:

- Two projects/teams need to share a service
- A hub VNet hosts shared services (firewall, DNS, identity) used by spoke VNets
- Your on-premises data center needs to reach resources in Azure

Azure provides multiple connectivity options; the right one depends on what you're connecting.

## VNet Peering

### What it is
A low-latency, high-bandwidth connection between two VNets, using Microsoft's backbone network (not the public internet).

### Types
- **Regional peering** — both VNets in the same region
- **Global peering** — VNets in different regions

### How to set it up
1. You need **owner/administrator access on BOTH VNets**
2. Create the peering in VNet A pointing to VNet B
3. Create the reverse peering in VNet B pointing to VNet A (both directions required)
4. Azure updates route tables automatically

### Key properties
- **Non-transitive** — if A↔B and B↔C are peered, A still can't reach C via B
- **No gateway or VPN required** — uses Azure backbone directly
- Address spaces must **not overlap**
- Traffic stays on the Microsoft network (private, fast)

### When to use
- Connecting VNets owned by the same organization
- Hub-and-spoke architectures (with the hub providing shared services)
- Cross-region disaster recovery

## VPN Gateway

### What it is
An encrypted tunnel between an Azure VNet and an on-premises network (or another cloud) over the **public internet**.

### Types
- **Site-to-Site (S2S)** — connects an on-prem network to an Azure VNet
- **Point-to-Site (P2S)** — connects individual devices (e.g., a developer's laptop) to a VNet
- **VNet-to-VNet** — similar to peering but over VPN (older pattern; peering is now preferred)

### Requirements
- A **Gateway Subnet** in the VNet (name must be exactly `GatewaySubnet`)
- A VPN device or compatible software on-prem
- Public IPs on both ends
- Shared keys or certificates for encryption

### Key properties
- **Encrypted** (IPsec/IKE)
- **Slower** than peering or ExpressRoute — limited by internet throughput (~100 Mbps to 10 Gbps depending on SKU)
- **Cheap** compared to ExpressRoute
- Metered — billed per hour of the gateway + outbound data

### When to use
- Hybrid cloud with modest bandwidth needs
- Dev/test connectivity to on-prem
- Remote worker access to Azure resources (P2S)

## ExpressRoute (honorable mention — not in this video)

A **dedicated private circuit** from your data center to Azure — doesn't use the public internet at all. Much faster, more reliable, and more expensive than VPN Gateway. Used for production hybrid workloads and regulated industries.

## Comparison

| | **VNet Peering** | **VPN Gateway** | **ExpressRoute** |
|---|---|---|---|
| Connects | Azure VNet ↔ Azure VNet | Azure ↔ on-prem (or dev laptop) | Azure ↔ on-prem (private circuit) |
| Network path | Azure backbone | Public internet (encrypted) | Private dedicated line |
| Throughput | Very high | 100 Mbps – 10 Gbps | 50 Mbps – 100 Gbps |
| Latency | Very low | Medium-high | Very low |
| Encryption | Implicit (MS backbone) | IPsec | Optional (MACsec) |
| Cost | Cheap (per-GB only) | Medium | Expensive |
| Setup | Minutes | Hours | Weeks (involves telco) |

## Gotchas

- **VNet peering is non-transitive.** In hub-and-spoke, spoke-to-spoke traffic must be forced through the hub using UDRs — it doesn't happen automatically.
- **GatewaySubnet naming is exact** — must be `GatewaySubnet`, not `gateway-subnet` or anything else
- **You can't peer VNets with overlapping address spaces** — plan CIDR blocks across the whole org up front
- **VPN Gateway takes ~30 minutes to provision** — not instant
- **P2S VPN** requires certificates or Azure AD auth — set up takes some doing

## Related topics

- [VNet & Subnets](./01-vnet-subnets.md)
- [Route tables & UDRs](./04-route-tables-udr.md)
- [Azure Firewall](./10-azure-firewall.md)

## Sources

- YouTube — Abhishek Veeramalla, *Azure Zero to Hero Day 6*
- Microsoft Learn — [VNet peering](https://learn.microsoft.com/en-us/azure/virtual-network/virtual-network-peering-overview)
- Microsoft Learn — [VPN Gateway](https://learn.microsoft.com/en-us/azure/vpn-gateway/vpn-gateway-about-vpngateways)
