# Networking — quick reference

## CIDR → IP count

| CIDR | Total IPs | Azure usable | Typical use |
|---|---|---|---|
| `/16` | 65,536 | 65,531 | Whole VNet |
| `/20` | 4,096 | 4,091 | Large subnet |
| `/22` | 1,024 | 1,019 | Medium subnet |
| `/24` | 256 | 251 | Standard subnet |
| `/26` | 64 | 59 | Small subnet |
| `/28` | 16 | 11 | Minimum for most things |
| `/29` | 8 | 3 | Minimum allowed in Azure |

**Azure reserves 5 IPs per subnet:**
- `.0` — network address
- `.1` — reserved for default gateway
- `.2`, `.3` — Azure DNS mapping
- `.255` (last) — broadcast

## Service tags (useful ones)

| Tag | Meaning |
|---|---|
| `Internet` | Public IP space outside Azure |
| `VirtualNetwork` | All VNet address space + peered VNets + on-prem |
| `AzureLoadBalancer` | Azure infrastructure load balancer |
| `AzureCloud` | All Azure public IPs |
| `Storage` | Azure Storage service IPs |
| `Sql` | Azure SQL service IPs |

## NSG priority ranges

- **100–4096** — custom rules (you pick)
- **65000–65500** — default rules (can't delete, can override)
- **Lower number = higher priority** (100 wins over 200)

## Common ports

| Port | Protocol | Service |
|---|---|---|
| 22 | TCP | SSH |
| 80 | TCP | HTTP |
| 443 | TCP | HTTPS |
| 3389 | TCP | RDP |
| 1433 | TCP | SQL Server |
| 3306 | TCP | MySQL |
| 5432 | TCP | PostgreSQL |
| 6379 | TCP | Redis |
| 27017 | TCP | MongoDB |
| 53 | UDP/TCP | DNS |

## Connectivity options (VNet ↔ X)

| Want to connect | Use |
|---|---|
| VNet to VNet (same/different region) | VNet peering |
| VNet to on-prem (over internet) | VPN Gateway |
| VNet to on-prem (private circuit) | ExpressRoute |
| VNet to Azure PaaS privately | Private Endpoint (preferred) or Service Endpoint |
| VNet outbound through a firewall | UDR + Azure Firewall / NVA |

## Load balancing — which one?

| Service | Layer | When |
|---|---|---|
| Azure Load Balancer | L4 | TCP/UDP inside a region, high throughput |
| Application Gateway | L7 | HTTP(S) inside a region, WAF, path routing |
| Traffic Manager | DNS | Multi-region, DNS-based routing |
| Front Door | L7 global | Global HTTP(S), CDN, WAF, failover |
