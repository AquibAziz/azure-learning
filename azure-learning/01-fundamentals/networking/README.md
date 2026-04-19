# 🌐 Networking

Azure networking fundamentals — the concepts that trip up most learners but are essential for everything else.

## Notes in this section

| # | Topic | Status |
|---|---|---|
| 01 | [Virtual Network (VNet) & Subnets](./01-vnet-subnets.md) | ✅ |
| 02 | [NSG & ASG — securing subnets](./02-nsg-asg.md) | ✅ |
| 03 | [CIDR deep dive](./03-cidr-explained.md) | ⬜ |
| 04 | [Route tables & User-Defined Routes](./04-route-tables-udr.md) | ⬜ |
| 05 | [VNet peering & VPN Gateway](./05-vnet-peering-and-vpn.md) | ✅ |
| 06 | [ExpressRoute deep dive](./06-expressroute.md) | ⬜ |
| 07 | [Private Endpoints & Service Endpoints](./07-private-endpoints.md) | ⬜ |
| 09 | [Load Balancer, App Gateway, Front Door](./09-load-balancing.md) | ✅ |
| 10 | [Azure Firewall](./10-azure-firewall.md) | ✅ |
| 11 | [Azure DNS](./11-azure-dns.md) | ✅ |

## Mental model

```
Region
 └── VNet (logical network, has CIDR)
      └── Subnet (slice of VNet, has smaller CIDR)
           ├── Resources (VMs, databases, etc.)
           ├── NSG attached (firewall rules)
           └── Route Table attached (traffic direction)
```

Diagrams for these notes live in [`./diagrams/`](./diagrams/).
