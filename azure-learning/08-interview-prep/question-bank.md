# 📚 Master Azure Interview Question Bank

All Q&A from all topics, compiled as I progress through the series. Grows with each video.

**Last updated:** 2026-04-19 (after Day 6)
**Total questions:** 20

Jump to topic: [Networking](#networking) | _Compute (pending)_ | _Storage (pending)_ | _Identity (pending)_

---

## Networking

### Q1: Why do cloud providers use Virtual Networks (VNet / VPC)?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** Day 5

<details><summary>Answer</summary>

To provide **logical network isolation** in a multi-tenant cloud. Millions of customers share the same physical infrastructure — without VNets, one customer's compromised VM could sit on the same network as another customer's. VNets fence off each customer's traffic, IP space, and security rules into a private logical network on shared hardware.

**Follow-up point:** Mention that AWS calls it VPC and the concept is identical across cloud providers.

</details>

---

### Q2: How many usable IP addresses does a `/24` subnet give you in Azure?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** Day 5

<details><summary>Answer</summary>

**251.** A `/24` has 256 total IPs, but Azure reserves 5 per subnet: the first 4 (network address, default gateway, and two for DNS mapping) and the last one (broadcast).

**Follow-up point:** This is different from traditional networking where only 2 IPs are reserved. Catches people out on sizing small subnets.

</details>

---

### Q3: Where should you attach an NSG — to a VM's NIC or to a subnet?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** Day 5

<details><summary>Answer</summary>

**Subnet level** as the default. More scalable, consistent, and manageable — one NSG covers every resource in the subnet. Use NIC-level NSGs only for exceptions (e.g., one specific jump box with unique rules).

**Follow-up point:** If NSGs exist at both levels, traffic must pass *both* to get through. This double-filtering is a common source of connectivity bugs.

</details>

---

### Q4: What's the difference between an NSG and an ASG?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** Day 5

<details><summary>Answer</summary>

- **NSG** is the set of allow/deny rules (the firewall itself)
- **ASG** is a logical grouping of VMs by role, used *as a reference* inside NSG rules

ASGs let you write rules in terms of VM roles (`asg-business-logic`) instead of IP ranges, which makes rules cleaner and independent of IP changes.

**Follow-up point:** ASGs only work within a single VNet — can't be used across peered VNets.

</details>

---

### Q5: You have 15 VMs in one subnet. Only 5 should reach the DB. What's the cleanest solution?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** Day 5

<details><summary>Answer</summary>

Create an **ASG** (e.g., `asg-business-logic`), tag the 5 specific VMs with it, then write an NSG rule: **Source = asg-business-logic, Destination = DB subnet, Allow**. A CIDR-based NSG rule would grant access to all 15 VMs since they share the subnet's IP range.

**Follow-up point:** Splitting into two subnets would also work but requires re-architecting. ASGs solve this without network redesign.

</details>

---

### Q6: What does an NSG rule's priority number do, and which number wins?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** Day 5

<details><summary>Answer</summary>

Priorities range **100–4096** for custom rules. **Lower number = higher priority.** Once a rule matches, evaluation stops. Default built-in rules live in 65000–65500 and can be overridden by lower-priority custom rules.

</details>

---

### Q7: What problem does a User-Defined Route (UDR) solve that system routes don't?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** Day 5

<details><summary>Answer</summary>

System routes handle basic connectivity (VNet ↔ VNet, VNet ↔ Internet). UDRs let you **override that default routing** to force traffic through a specific path — typically an Azure Firewall or NVA for inspection, logging, or compliance. Also useful for blackholing traffic or custom routing between subnets.

</details>

---

### Q8: Using Abhishek's housing society analogy, what does the "compound wall + main gate" map to in Azure?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** Day 6

<details><summary>Answer</summary>

**Azure Firewall.** It's the entry-level security checkpoint for the entire VNet — inspects and filters traffic before it reaches any subnet. The guard at each block entrance is the per-subnet NSG.

</details>

---

### Q9: What's the difference between Application Gateway and Azure Load Balancer?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** Day 6

<details><summary>Answer</summary>

- **Application Gateway** — Layer 7 (HTTP/HTTPS). Inspects URL path, hostname, headers. Makes routing decisions like `/login → login-pool, /api/* → api-pool`. Has built-in WAF and SSL termination. Use in front of web applications.
- **Azure Load Balancer** — Layer 4 (TCP/UDP). Forwards based on IP and port only. Faster, simpler, cheaper. Use between internal tiers (web→app, app→db) where no URL routing is needed.

**Simple rule:** If routing depends on the URL, use App Gateway; otherwise use Load Balancer.

</details>

---

### Q10: Why does Application Gateway need its own dedicated subnet?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** Day 6

<details><summary>Answer</summary>

App Gateway provisions multiple instances for HA and scaling, and Azure manages those instances' IPs inside the subnet. Sharing the subnet with other resources would conflict with that management. The subnet is typically sized `/27` or larger and is usually named `AppGatewaySubnet` by convention.

**Follow-up point:** Same applies to `GatewaySubnet` for VPN/ExpressRoute gateways and `AzureFirewallSubnet` — all must be dedicated.

</details>

---

### Q11: Walk through what happens when a user in India types `abhishek.com` and hits an app running in Azure.

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** Day 6

<details><summary>Answer</summary>

1. Browser asks OS for the IP of `abhishek.com`
2. OS asks home router → ISP DNS server
3. ISP DNS (if not cached) walks the DNS hierarchy — root → TLD → Azure DNS (authoritative)
4. Azure DNS returns the A record's IP (usually the App Gateway or Load Balancer's public IP)
5. Browser opens a TCP/HTTPS connection to that IP
6. Traffic hits **Azure Firewall** → accepted → forwarded to **App Gateway**
7. App Gateway inspects the URL (e.g., `/login`) and routes to the correct backend pool
8. NSG on the web subnet allows the traffic → web VM processes
9. Web VM calls the app tier via an internal **Load Balancer (L4)**
10. App tier queries the DB

**Follow-up point:** Caching happens at multiple layers (browser, OS, router, ISP) — DNS changes may take time to propagate.

</details>

---

### Q12: What is VNet peering, and what's a key limitation?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** Day 6

<details><summary>Answer</summary>

VNet peering connects two Azure VNets so their resources can communicate directly over Microsoft's backbone network — low latency, high bandwidth, no public internet.

**Key limitation: it's non-transitive.** If VNet A is peered with B, and B is peered with C, A *cannot* reach C through B automatically. You'd need either explicit A↔C peering, or a hub-and-spoke with UDRs forcing traffic through a firewall/NVA in the hub.

**Follow-up point:** Address spaces must not overlap. Peering requires owner-level access on both VNets.

</details>

---

### Q13: When would you choose VPN Gateway over ExpressRoute?

**Topic:** networking | **Difficulty:** 🔴 Advanced | **Source:** Day 6

<details><summary>Answer</summary>

Choose **VPN Gateway** when:
- Budget is constrained (VPN ~$100s/month vs ExpressRoute thousands)
- Moderate bandwidth needs (<= 1 Gbps typically sufficient)
- Acceptable to go over the public internet (encrypted)
- Fast provisioning (hours vs weeks)

Choose **ExpressRoute** when:
- High throughput needed (up to 100 Gbps)
- Consistent low latency required (financial trading, real-time systems)
- Regulatory requirements disallow public internet
- Mission-critical hybrid workloads with SLA expectations

**Follow-up point:** Common pattern is **ExpressRoute with VPN failover** — ExpressRoute as primary, VPN Gateway as backup for resilience.

</details>

---

### Q14: Your organization uses a hub-and-spoke network. Web app in spoke-1 needs to talk to a database in spoke-2. Does VNet peering alone solve this?

**Topic:** networking | **Difficulty:** 🔴 Advanced | **Source:** Day 6

<details><summary>Answer</summary>

**No.** VNet peering is non-transitive. If spoke-1 peers with hub, and spoke-2 peers with hub, spoke-1 still cannot reach spoke-2 through the hub by default.

**Solutions:**
1. **UDR + firewall/NVA in the hub** — force spoke-to-spoke traffic through an inspection device in the hub (this is the standard hub-and-spoke pattern)
2. **Direct peering** between the two spokes (adds many peerings as spokes grow — doesn't scale)
3. **Azure Virtual WAN** — managed hybrid networking service that handles transitive routing natively

</details>

---

### Q15: What's a WAF, and where does it live in Azure?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** Day 6

<details><summary>Answer</summary>

WAF = **Web Application Firewall**. It protects HTTP/HTTPS apps against common attacks like SQL injection, XSS, and other OWASP Top 10 threats. In Azure, WAF is a feature built into:
- **Application Gateway** (regional)
- **Front Door** (global)

It's not a standalone service — you enable it as a tier upgrade on these load balancers.

**Follow-up point:** Azure Firewall has threat intelligence but is not a WAF — WAF specifically inspects HTTP application-layer traffic, while Azure Firewall handles network-layer filtering.

</details>

---

### Q16: How many VNets can you have in one Azure subscription, and why might you create multiple?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** Day 5

<details><summary>Answer</summary>

Practically unlimited (soft limit of 1000 per subscription, can be raised). Common reasons to have multiple VNets:
- **Separation by environment** — dev, test, staging, prod
- **Separation by project** — one VNet per business unit or application
- **Regulatory isolation** — PCI/HIPAA workloads isolated from others
- **Region-based** — VNets are regional; multi-region deployment needs multiple VNets

**Follow-up point:** Large orgs use **hub-and-spoke** — one or a few hub VNets for shared services (firewall, DNS), many spoke VNets for workloads.

</details>

---

### Q17: You deploy 2 web VMs across 2 availability zones. One AZ goes down — what happens?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** Day 6

<details><summary>Answer</summary>

The VM in the failed AZ becomes unreachable. **If** you have a load balancer (App Gateway or LB) with health probes in front of the VMs:
- The probe detects the unhealthy VM within seconds
- Load balancer stops routing traffic to it
- All traffic now goes to the healthy VM in the surviving AZ
- Users see no disruption (beyond maybe a few failed requests during detection)

**Without a load balancer**, the failure isn't masked — clients hitting the failed VM directly see errors.

**Follow-up point:** This is why "deploy across AZs" alone isn't HA — you need a load balancer to make it resilient.

</details>

---

### Q18: What does Azure DNS do, and what types of records does it support?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** Day 6

<details><summary>Answer</summary>

Azure DNS is Microsoft's managed DNS hosting service. It stores and answers authoritative DNS queries for domains — translating names like `abhishek.com` into IP addresses.

Supported records: A, AAAA, CNAME, MX, NS, TXT, SRV, PTR, CAA, SOA.

Two flavors:
- **Public DNS zones** — for your public domain
- **Private DNS zones** — for private name resolution inside VNets (e.g., `api.internal.company.com`)

</details>

---

### Q19: You need to route `company.com/login` to one backend pool and `company.com/api/*` to a different backend pool. What Azure service does this?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** Day 6

<details><summary>Answer</summary>

**Application Gateway** — configure **URL path-based routing rules**:
- `/login` → login-pool
- `/api/*` → api-pool
- `/` (default) → homepage-pool

This works at Layer 7 because the routing decision depends on the URL path. Azure Load Balancer can't do this — it only operates at L4.

</details>

---

### Q20: Your application is globally distributed (users in India, US, Europe). Which Azure service would you put at the front?

**Topic:** networking | **Difficulty:** 🔴 Advanced | **Source:** Day 6

<details><summary>Answer</summary>

**Azure Front Door.** It's a global L7 load balancer with built-in CDN, WAF, and intelligent routing. It directs each user to the nearest healthy regional endpoint (typically a regional App Gateway) — minimizing latency and handling regional failover.

**Typical pattern:**
```
Users worldwide → Front Door (global) → App Gateway (per region) → VMs
```

**Alternative:** Traffic Manager for DNS-based geo-routing (older, works at DNS level, less smart about HTTP).

**Follow-up point:** Front Door is region-redundant by design; App Gateway is regional. Combining them gives global + regional HA.

</details>

---

## Compute

*No questions yet. Will be added after compute videos.*

---

## Storage

*No questions yet. Will be added after storage videos.*

---

## Identity

*No questions yet. Will be added after identity/Entra ID videos.*

---

## How to contribute new questions

When I learn a new topic, I add questions here following these rules:

1. **Frame as the interviewer would ask** — not as a textbook definition
2. **Keep answers concise** — 2–5 lines is the sweet spot
3. **Add a follow-up point** — what an interviewer might probe next
4. **Tag topic, difficulty, source** — so I can filter later
5. **Also add to the topic-specific file** in [`by-topic/`](./by-topic/)
