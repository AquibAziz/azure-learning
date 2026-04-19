# 🌐 Interview Questions — Networking

All networking interview questions, isolated for focused study. Same entries as in the master bank but filtered.

**Total networking questions:** 20
**Breakdown:** 🟢 10 beginner · 🟡 8 intermediate · 🔴 2 advanced

---

## Beginner (🟢)

### Q: Why do cloud providers use Virtual Networks (VNet / VPC)?

<details><summary>Answer</summary>

To provide **logical network isolation** in a multi-tenant cloud. Without VNets, one customer's compromised VM could sit on the same network as another customer's. VNets fence off each customer's traffic, IP space, and security rules into a private logical network on shared hardware.

</details>

---

### Q: How many usable IP addresses does a `/24` subnet give you in Azure?

<details><summary>Answer</summary>

**251.** 256 total minus 5 reserved by Azure (first 4 + last 1).

</details>

---

### Q: Where should you attach an NSG — to a VM's NIC or to a subnet?

<details><summary>Answer</summary>

**Subnet** by default. NIC-level is for exceptions. If both exist, traffic must pass both.

</details>

---

### Q: What does an NSG rule's priority number do, and which wins?

<details><summary>Answer</summary>

Priorities 100–4096 for custom rules. **Lower number = higher priority.** Evaluation stops on first match.

</details>

---

### Q: Using the housing society analogy, what does the "compound wall + main gate" map to in Azure?

<details><summary>Answer</summary>

**Azure Firewall** — the entry-level security checkpoint for the entire VNet. Per-subnet NSGs are the block-level guards.

</details>

---

### Q: How many VNets can you have per Azure subscription?

<details><summary>Answer</summary>

Practically unlimited (soft limit 1000, can be raised). Common reasons for multiple VNets: environment separation, project isolation, compliance boundaries, multi-region deployments.

</details>

---

### Q: What happens if one AZ goes down and you have VMs spread across 2 AZs behind a load balancer?

<details><summary>Answer</summary>

The LB's health probe detects the unhealthy VM in seconds and stops routing to it. Surviving AZ's VM handles all traffic. Users see minimal disruption.

</details>

---

### Q: What does Azure DNS do?

<details><summary>Answer</summary>

Hosts authoritative DNS records for domains — translates names like `abhishek.com` into IP addresses. Offers both public zones (for your domain) and private zones (for VNet-internal resolution).

</details>

---

### Q: You need to route `company.com/login` and `company.com/api/*` to different backend pools. What service?

<details><summary>Answer</summary>

**Application Gateway** with URL path-based routing. Azure Load Balancer can't do this — it's L4 and doesn't see URLs.

</details>

---

### Q: Can you create a VNet in Azure without specifying networking details when launching a VM?

<details><summary>Answer</summary>

Yes — Azure auto-creates a default VNet, subnet, NSG, and public IP. Convenient for learning, never do this in production.

</details>

---

## Intermediate (🟡)

### Q: What's the difference between an NSG and an ASG?

<details><summary>Answer</summary>

- **NSG** — the allow/deny firewall rules
- **ASG** — a logical grouping of VMs by role, referenced *inside* NSG rules

ASGs let rules be role-based (`asg-business-logic`) instead of IP-based. They only work within a single VNet.

</details>

---

### Q: You have 15 VMs in one subnet. Only 5 should reach the DB. What's the cleanest solution?

<details><summary>Answer</summary>

Use an **ASG**. Tag the 5 VMs with `asg-business-logic`, then write an NSG rule: Source = asg-business-logic, Destination = DB subnet, Allow. CIDR-based rules would allow all 15.

</details>

---

### Q: What problem does a User-Defined Route solve?

<details><summary>Answer</summary>

System routes handle default connectivity. UDRs override them to **force traffic through a specific path** — typically a firewall or NVA for inspection, logging, or compliance.

</details>

---

### Q: Difference between Application Gateway and Azure Load Balancer?

<details><summary>Answer</summary>

- **App Gateway (L7)** — inspects HTTP content, URL routing, WAF, SSL termination. Use in front of web apps.
- **Load Balancer (L4)** — TCP/UDP only, faster, cheaper. Use between internal tiers.

Rule of thumb: if routing depends on the URL, use App Gateway.

</details>

---

### Q: Why does App Gateway need its own dedicated subnet?

<details><summary>Answer</summary>

App Gateway provisions multiple managed instances inside that subnet. Sharing with other resources would conflict with Azure's IP management. Applies equally to GatewaySubnet (VPN) and AzureFirewallSubnet.

</details>

---

### Q: Walk through what happens when a user types `abhishek.com` and reaches an Azure-hosted app.

<details><summary>Answer</summary>

Browser → OS → home router → ISP DNS → (if uncached) walks DNS hierarchy to Azure DNS → gets IP → browser connects → Azure Firewall inspects → App Gateway routes by URL → NSG allows → web VM → internal LB → app tier → DB.

</details>

---

### Q: What is VNet peering, and what's a key limitation?

<details><summary>Answer</summary>

Connects two Azure VNets via Microsoft's backbone — low latency, high bandwidth.

**Key limitation: non-transitive.** A↔B peered and B↔C peered does NOT mean A can reach C. For that, either direct A↔C peering or force traffic through a hub with UDRs.

</details>

---

### Q: What's a WAF, and where does it live in Azure?

<details><summary>Answer</summary>

Web Application Firewall — protects HTTP apps against OWASP Top 10 (SQLi, XSS, etc.). In Azure, WAF is a feature of **Application Gateway** (regional) or **Front Door** (global). Not standalone.

</details>

---

## Advanced (🔴)

### Q: When would you choose VPN Gateway over ExpressRoute?

<details><summary>Answer</summary>

**VPN Gateway** when: budget-constrained, moderate bandwidth (<1 Gbps), internet-acceptable (encrypted), fast provisioning needed.

**ExpressRoute** when: high throughput (up to 100 Gbps), consistent low latency, regulatory demands, mission-critical with SLA. Often paired — ExpressRoute primary, VPN failover.

</details>

---

### Q: In hub-and-spoke, how do you make spoke-1 talk to spoke-2?

<details><summary>Answer</summary>

VNet peering is non-transitive, so hub peering alone won't work. Options:

1. **UDR in each spoke** forcing traffic through a firewall/NVA in the hub (standard pattern)
2. **Direct spoke-to-spoke peering** (doesn't scale)
3. **Azure Virtual WAN** — managed service with native transitive routing

</details>

---

### Q: Global app with users in India, US, Europe. What do you put at the front?

<details><summary>Answer</summary>

**Azure Front Door** — global L7 LB with built-in CDN, WAF, and intelligent routing to nearest healthy region. Typically: Front Door → regional App Gateway → regional VMs.

Traffic Manager (DNS-based) is an older alternative for simple geo-routing.

</details>

---

*Keep this file in sync with the master [`../question-bank.md`](../question-bank.md).*
