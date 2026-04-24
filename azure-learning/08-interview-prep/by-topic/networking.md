# 🌐 Interview Questions — Networking

All networking interview questions, isolated for focused study. Same entries as in the master bank but filtered.

**Total networking questions:** 31
**Breakdown:** 🟢 15 beginner · 🟡 14 intermediate · 🔴 2 advanced

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

### Q: Why does every Azure VM get two IP addresses?

<details><summary>Answer</summary>

**Private IP** for communication inside the VNet (other VMs, databases, internal LBs). **Public IP** for internet-facing access (SSH/RDP, public services). Not every VM needs a public IP — production workloads often have private IPs only.

</details>

---

### Q: In a subnet `10.0.0.0/24`, why is the first usable IP `10.0.0.4`?

<details><summary>Answer</summary>

Azure reserves 5 IPs per subnet: `.0` (network), `.1` (gateway), `.2`/`.3` (DNS), and `.255` (broadcast). First usable = `.4`. This is different from traditional networking, which only reserves 2.

</details>

---

### Q: You installed nginx, `curl localhost` works on the VM, but the browser can't reach the public IP. Why?

<details><summary>Answer</summary>

NSG is blocking inbound port 80. Default NSG has `DenyAllInBound` at priority 65500 and only an auto-allow for SSH (22). Add an inbound rule: Allow TCP 80 from Internet, priority 100.

</details>

---

### Q: Why does SSH work on a new Linux VM but HTTP doesn't, out of the box?

<details><summary>Answer</summary>

Azure's VM wizard automatically adds an inbound NSG rule for port 22 so you can manage the VM. HTTP isn't auto-allowed because not every VM is a web server.

</details>

---

### Q: Your app tier VM needs to call the web tier VM in a different subnet. Should it use the public or private IP?

<details><summary>Answer</summary>

**Private IP, always.** Stays on Azure's backbone (faster, no egress charges), no internet exposure, no NSG default-deny issues. Public IPs are only for traffic entering Azure from outside.

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

### Q: When you delete a VM in Azure, what else should you delete?

<details><summary>Answer</summary>

VM deletion does NOT clean up: **Public IP** (still billed), **OS/data disks**, **NIC**, **NSG**. Best practice: put each lab in its own resource group and delete the whole group with `az group delete`.

</details>

---

### Q: Static vs dynamic public IP — when to use each?

<details><summary>Answer</summary>

**Dynamic** — can change on stop/start; cheap; fine for lab VMs. **Static** — reserved, stable; use when DNS points to it, firewall allowlists it, or certs are bound to it. Even better: front the VM with a DNS name so IP changes don't matter.

</details>

---

### Q: Two VMs in different subnets of the same VNet talk by private IP without any NSG rule. Why?

<details><summary>Answer</summary>

The default rule **`AllowVnetInBound`** at priority 65000 allows any source with the `VirtualNetwork` service tag. This covers the whole VNet (plus peered VNets and VPN on-prem). To restrict internal traffic, add explicit Deny rules with priority < 65000.

</details>

---

### Q: A VM's public IP is 20.x.x.x, private is 10.0.0.4. When writing an NSG rule for HTTP from my laptop, what IP do I put as destination?

<details><summary>Answer</summary>

**The private IP (10.0.0.4).** Azure performs NAT at the edge — rewrites destination from public to private IP *before* the NSG evaluates the packet. NSGs only see post-NAT packets, so destination must match the private IP.

</details>

---

### Q: What does "My IP Address" in the NSG source wizard do, and what's the catch?

<details><summary>Answer</summary>

Auto-detects your current home/office public IP. Catch: most home ISPs give **dynamic IPs** — your IP can change, and the rule stops working. For persistent access, use **Azure Bastion**, **VPN**, or a static business IP.

</details>

---

### Q: Difference between one NSG per VM vs one NSG per subnet?

<details><summary>Answer</summary>

**Per VM** (wizard default): easy to start, messy to scale (20 VMs = 20 NSGs). **Per subnet** (best practice): one NSG governs all resources, consistent, scales naturally. Use NIC-level only for exceptions. If both exist, traffic must pass both.

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
