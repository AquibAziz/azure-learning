# Day 6 — Azure Networking with the Housing Society analogy

**Date watched:** 2026-04-19
**Video:** Day 6, Azure Zero to Hero series
**Duration:** ~40 min
**Level:** Beginner → intermediate

## Key concepts covered

- Full housing society analogy (John builds a secure gated community)
- Azure Firewall
- Application Gateway (L7) vs Azure Load Balancer (L4)
- Azure DNS + request flow from browser to VM
- High availability with availability zones
- VNet peering
- VPN Gateway
- Billing concept (brief mention)

## My notes

### The analogy that makes everything click

John builds a gated community:
- Private land → VNet
- Blocks → Subnets
- Houses → Instances (VMs, DBs)
- Compound wall + main gate → Azure Firewall
- Guard per block → NSG
- Paths & signboards → Route tables + system routes
- Reception directing guests → Load Balancer / App Gateway
- "John Properties" on Google Maps → Azure DNS

### Request flow (full picture)

User types `abhishek.com` →
→ Home router → ISP DNS
→ ISP DNS talks to Azure DNS → gets IP
→ Request hits Azure Firewall (compound wall)
→ Firewall allows → forwards to App Gateway (L7)
→ App Gateway routes by URL (`/login`, `/payment`, etc.)
→ Web subnet NSG checks → forwards to healthy VM
→ VM processes → forwards to internal Load Balancer (L4)
→ App tier VM → DB

### App Gateway vs Load Balancer

This is the one to remember:
- **App Gateway (L7)** — inspects HTTP content, routes by URL — use for web apps facing internet
- **Load Balancer (L4)** — just TCP/UDP, faster, simpler — use between internal tiers

Example: `abhishek.com/login` and `abhishek.com/payment` both enter through App Gateway; App Gateway sends login traffic to login-pool and payment traffic to payment-pool. Inside, login-frontend VMs call login-backend VMs via an internal Load Balancer (no URL routing needed since it's 1:1).

### Availability zones — always deploy 2+ copies

VNets auto-span all AZs in a region. That's free HA infrastructure, but only helpful if you actually deploy multiple copies across zones. Load Balancer handles routing around a failed copy.

### VNet peering

- Connects 2 Azure VNets (same or different region)
- Must be owner of both
- Update route tables
- Non-transitive (A↔B, B↔C ≠ A can reach C)

### VPN Gateway

- Connects Azure VNet to on-premises network
- Encrypted tunnel over internet
- Used in hybrid cloud (some resources stay on-prem)

## Questions that came up

- How exactly does WAF work on App Gateway? What attacks does it block?
- When is Front Door better than App Gateway?
- Is there a cost difference that makes NSG preferred over Azure Firewall for small workloads?
  - **Answer I dug up:** Yes. Azure Firewall has a ~$900/month base cost. For learning and small workloads, stick with NSGs.
- How does DNS propagation actually work after updating a record?
- What's the actual throughput difference between VPN Gateway and ExpressRoute?

## Links to canonical notes

Synthesized from this session:
- [Azure Firewall](../../01-fundamentals/networking/10-azure-firewall.md) *(new)*
- [Load balancing — App Gateway vs LB](../../01-fundamentals/networking/09-load-balancing.md) *(new)*
- [Azure DNS](../../01-fundamentals/networking/11-azure-dns.md) *(new)*
- [VNet peering & VPN Gateway](../../01-fundamentals/networking/05-vnet-peering-and-vpn.md) *(new)*

And updated/related:
- [VNet & Subnets](../../01-fundamentals/networking/01-vnet-subnets.md)
- [NSG & ASG](../../01-fundamentals/networking/02-nsg-asg.md)

## Added to interview question bank

- Housing society analogy question
- App Gateway vs Load Balancer
- DNS flow
- VNet peering limitations
- VPN Gateway vs ExpressRoute

See [interview question bank](../../08-interview-prep/question-bank.md).
