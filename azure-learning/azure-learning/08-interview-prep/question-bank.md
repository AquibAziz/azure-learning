# 📚 Master Azure Interview Question Bank

All Q&A from all topics, compiled as I progress through the series. Grows with each video.

**Last updated:** 2026-04-24 (after AZ-500 dual NSG evaluation)
**Total questions:** 41

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

### Q21: Why does every Azure VM get two IP addresses?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** AZ-500 Lab

<details><summary>Answer</summary>

A VM needs to communicate in two directions:

- **Private IP** — from the subnet's CIDR range, used for communication *within* the VNet (to other VMs, databases, internal load balancers). Never reachable from the internet.
- **Public IP** — allocated from Azure's public IP pool, reachable from the internet. Used for admin access (SSH/RDP) and public-facing services.

Not every VM needs a public IP — production workloads often have private IPs only, with access through load balancers, bastion hosts, or VPN/ExpressRoute.

**Follow-up point:** Public IPs are billed as a separate resource. Deleting a VM without deleting its public IP leaves you paying for nothing.

</details>

---

### Q22: In a subnet with CIDR `10.0.0.0/24`, why is the first usable IP `10.0.0.4` and not `10.0.0.1`?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** AZ-500 Lab

<details><summary>Answer</summary>

Azure reserves 5 IPs per subnet:
- `.0` — network address
- `.1` — default gateway
- `.2` and `.3` — Azure DNS mapping
- `.255` (last) — broadcast

This leaves `.4` through `.254` for your resources — 251 usable IPs. Traditional networking only reserves 2 (network + broadcast), so this trips people up.

</details>

---

### Q23: You installed nginx on an Azure VM. `curl localhost` works on the VM, but `http://<public-ip>` from your laptop browser times out. What's wrong?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** AZ-500 Lab

<details><summary>Answer</summary>

Almost certainly the **NSG is blocking inbound port 80**. By default, Azure's NSG allows SSH (port 22) but denies all other inbound traffic from the internet (via the `DenyAllInBound` rule at priority 65500). nginx is running fine, but traffic never reaches it.

**Fix:** Add an inbound NSG rule — Allow TCP 80 from Internet, priority 100 (or any value below 65500).

**Other things to rule out:**
- OS-level firewall (ufw, iptables) — unlikely on default Ubuntu image but possible
- nginx not actually listening on 0.0.0.0 (bound to localhost only)

**Follow-up point:** Use Network Watcher's "IP Flow Verify" to confirm which rule is blocking.

</details>

---

### Q24: Why does SSH work out-of-the-box on a new Azure Linux VM but HTTP doesn't?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** AZ-500 Lab

<details><summary>Answer</summary>

When you create a Linux VM, the deployment wizard **automatically adds an inbound NSG rule** allowing port 22 (SSH) from the internet. It does this so you can actually manage the VM after deployment.

HTTP (port 80) isn't auto-allowed because not every VM is a web server. You can check a box during VM creation to pre-allow HTTP/HTTPS, or add the rule manually afterward.

**Follow-up point:** For production, SSH shouldn't be open to the internet at all. Use Azure Bastion or a jump box in a restricted subnet.

</details>

---

### Q25: When you delete a VM in Azure, what else should you delete?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** AZ-500 Lab

<details><summary>Answer</summary>

Deleting the VM alone does NOT delete its associated resources. You'll keep paying for:

- **Public IP address** — still allocated, still billed
- **OS disk and data disks** — managed disks persist
- **Network Interface (NIC)** — cheap but adds clutter
- **NSG** — if dedicated, may be abandoned

**Best practice:** put each lab's resources in its own **Resource Group** and delete the whole group with `az group delete --name <rg> --yes --no-wait`. One command, everything gone, no orphans.

**Follow-up point:** Newer Azure portal deployments offer "Delete VM with associated resources" — but don't rely on it; always verify with `az resource list -g <rg>`.

</details>

---

### Q26: What's the difference between a static and a dynamic public IP, and when would you use each?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** AZ-500 Lab

<details><summary>Answer</summary>

- **Dynamic** — IP is assigned when the VM starts; *can change* if the VM is stopped (deallocated) and restarted. Cheaper. Default for new VMs.
- **Static** — IP is reserved for you and stays the same forever (until you delete it). Slightly more expensive.

**Use static when:**
- DNS records point to this IP
- Firewall rules elsewhere whitelist this IP
- You're handing out the IP to clients/partners
- Certificates are bound to the IP

**Use dynamic when:**
- Lab/dev VMs where the IP doesn't need to persist
- The IP is always wrapped behind a load balancer or DNS name

**Follow-up point:** A better pattern than static IP is to front the VM with a **DNS name** — Azure gives you a free `*.cloudapp.azure.com` hostname, or you use Azure DNS with your own domain.

</details>

---

### Q27: Two VMs in different subnets of the same VNet can ping each other by private IP without any NSG rules. Why?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** AZ-500 VM Communication Lab

<details><summary>Answer</summary>

Every NSG has a built-in default rule called **`AllowVnetInBound`** at priority 65000. It allows any traffic whose source is the `VirtualNetwork` service tag — which includes the entire VNet address space (plus peered VNets and VPN-connected on-prem).

So by default, anything *inside* the VNet can talk to anything else *inside* the VNet. You only need custom NSG rules to **restrict** this internal traffic or to allow **external** traffic from the internet.

**Follow-up point:** To enforce segmentation between subnets (e.g., web shouldn't directly hit DB), you add an explicit Deny rule with priority < 65000.

</details>

---

### Q28: A VM's public IP is `20.197.45.172`. Its private IP is `10.0.0.4`. When writing an NSG rule to allow HTTP from your laptop, what IP should you put as the destination?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** AZ-500 VM Communication Lab

<details><summary>Answer</summary>

**The private IP (`10.0.0.4`).** The public IP is not actually on the VM — it's owned by Azure's edge. Azure performs NAT: when a packet arrives on the public IP, the destination is rewritten to the private IP *before* the NSG evaluates the packet.

NSGs only ever see post-NAT packets, so destination rules must match the private IP.

**Follow-up point:** This is why internal tools like `ip addr` on the VM only show the private IP — the OS has no awareness of the public IP.

</details>

---

### Q29: Your app tier VM needs to call the web tier VM in a different subnet. Should it use the public or private IP?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** AZ-500 VM Communication Lab

<details><summary>Answer</summary>

**Private IP, always.** Reasons:

- Traffic stays on Azure's internal backbone — faster, lower latency
- No egress bandwidth charges for leaving Azure
- Public IP traffic is subject to default-deny from internet sources (would be blocked anyway)
- More secure — never exposes internal routes to the internet

Public IPs are for traffic entering from outside Azure. Internal traffic is always private IPs.

</details>

---

### Q30: What does the "My IP Address" source option in the NSG rule wizard actually do, and what's a gotcha?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** AZ-500 VM Communication Lab

<details><summary>Answer</summary>

It auto-detects the public IP of the client device you're configuring Azure from (your laptop/home network) and hardcodes that IP as the source.

**Gotcha:** Most home ISPs give **dynamic public IPs** — they can change after modem restart or at the ISP's whim. If your IP changes, the rule stops working and you're locked out.

**Better approaches for persistent admin access:**
- **Azure Bastion** — browser-based RDP/SSH with no public IP exposure
- **VPN / ExpressRoute** — VPN into the VNet; use private IPs from there
- **Static IP from ISP** — some business plans offer this for a fee

</details>

---

### Q31: What's the difference between Azure having one NSG per VM vs one NSG per subnet?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** AZ-500 VM Communication Lab

<details><summary>Answer</summary>

**Per VM (wizard default):**
- Easy to get started
- Rules apply to one VM only
- Rapidly gets messy — 20 VMs = 20 NSGs to manage
- Inconsistent security if you forget to update one

**Per subnet (best practice):**
- One NSG covers every resource in the subnet
- Consistent security for workloads in the same tier
- Scales naturally — add more VMs and they inherit the rules
- Easier to audit and maintain

**Real-world pattern:** Attach NSG at subnet level. Use NIC-level NSGs only for exceptions (e.g., a single jump box with special access).

**Follow-up point:** If rules exist at both levels, traffic must pass both — double-filtering is a common source of bugs.

</details>

---

### Q32: Can an NSG be attached directly to a whole VNet? If not, how do you enforce VNet-wide network rules?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** AZ-500 Subnet NSG Lab

<details><summary>Answer</summary>

**No** — NSGs can only be attached to a **subnet** or a **NIC**. There's no "VNet-level NSG."

For VNet-wide control, use:
- **Azure Firewall** — centralized stateful firewall for the whole VNet; supports FQDN filtering and threat intelligence
- **UDRs + Azure Firewall** in a hub VNet — route all outbound/cross-subnet traffic through the firewall
- **Azure Policy** — enforce NSG existence across all subnets via policy (governance, not traffic filtering)

**Follow-up point:** If someone asks "how do I protect every subnet with one rule," the answer is Azure Firewall + hub-and-spoke, not a VNet-level NSG (which doesn't exist).

</details>

---

### Q33: You're creating a new NSG manually (not via the VM wizard) and attaching it to a subnet. What's the one rule you must remember to add yourself?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** AZ-500 Subnet NSG Lab

<details><summary>Answer</summary>

**An SSH allow rule (port 22 for Linux) or RDP (port 3389 for Windows).** The VM creation wizard silently adds this rule when it creates its own NSG. A manually created NSG has only the built-in default rules, which deny all inbound from the internet.

If you attach a rule-less NSG to your subnet and detach the old per-VM NSGs, **you lose admin access to all VMs in the subnet**.

**Safer migration order:**
1. Create new NSG
2. Add SSH + other required rules
3. Attach to subnet
4. Detach old NSGs

**Follow-up point:** For production, SSH shouldn't be open to the internet at all — use Azure Bastion or a jump box.

</details>

---

### Q34: An SSH NSG rule needs to allow access to 3 VMs across 2 subnets. What are the options for the destination IP field, and what's the trade-off?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** AZ-500 Subnet NSG Lab

<details><summary>Answer</summary>

Three options, with different trade-offs:

1. **VNet address space** (e.g., `10.0.0.0/16`) — broadest, easy to maintain. Allows SSH to ANY current or future VM in the VNet. Violates least privilege.

2. **Comma-separated private IPs** (e.g., `10.0.0.4,10.0.0.5,10.0.1.4`) — most restrictive. Only those exact VMs. Breaks when VMs change.

3. **Subnet CIDR** (e.g., `10.0.0.0/24,10.0.1.0/24`) — middle ground. Allows any VM in specified subnets.

**Best real-world answer:** Use an **ASG** — tag the 3 admin-accessible VMs with an ASG, use ASG as the destination. Role-based, dynamic, clean.

</details>

---

### Q35: When migrating from per-VM NSGs to one shared subnet NSG, what's the correct order of operations to avoid locking yourself out?

**Topic:** networking | **Difficulty:** 🔴 Advanced | **Source:** AZ-500 Subnet NSG Lab

<details><summary>Answer</summary>

**Safe order:**
1. Create the new NSG
2. **Add all required rules FIRST** (especially SSH/RDP and any app-specific rules)
3. Verify the rules by inspecting them
4. Attach the new NSG to the subnet
5. Test SSH access still works (both old and new NSGs are now in effect — traffic must pass both)
6. Detach the old per-VM NSGs from the NICs
7. Verify access still works with only the new NSG
8. Delete the old orphaned NSGs

**What NOT to do:**
- Detach old NSGs first → now you have no protection at all during the window before you attach the new one
- Attach rule-less new NSG and then detach old → new NSG's DenyAllInBound kills SSH

**Follow-up point:** In production, test this flow in dev first. Use Azure Network Watcher's "Effective Security Rules" to verify what's actually applied at each step.

</details>

---

### Q36: Can the same NSG be attached to multiple subnets? Should you do it?

**Topic:** networking | **Difficulty:** 🟢 Beginner | **Source:** AZ-500 Subnet NSG Lab

<details><summary>Answer</summary>

**Technically yes** — Azure lets you attach one NSG to as many subnets as you want.

**Should you? Usually no.** Different tiers (web/app/db) typically have different security needs:
- Web subnet: allow 80/443 from internet
- App subnet: allow only from web subnet
- DB subnet: allow only from app subnet

Sharing one NSG across tiers means sharing one rule set — which defeats much of the purpose of having subnets in the first place.

**When sharing is fine:**
- Two subnets with genuinely identical security requirements
- Non-production environments where simplicity > strict segmentation
- Small-scale learning setups (like Alan's demo)

**Follow-up point:** For production, prefer one NSG per subnet with distinct rule sets per tier.

</details>

---

### Q37: A VM has an NSG on its subnet (with HTTP allow) and a separate NSG on its NIC (with no HTTP rule). Can the browser reach the VM on port 80?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** AZ-500 Dual NSG Lab

<details><summary>Answer</summary>

**No.** When a VM has NSGs at BOTH subnet and NIC levels, traffic must be explicitly allowed by BOTH. The subnet NSG allows HTTP — passes gate 1. The NIC NSG has no HTTP rule, so the default `DenyAllInBound` (priority 65500) kicks in — gate 2 blocks it.

Both NSGs are evaluated independently; Azure does not merge them or pick the more permissive. Each must say "yes" for traffic to pass.

**Follow-up point:** To fix, add an HTTP allow rule to the NIC NSG too.

</details>

---

### Q38: In what order does Azure evaluate NSGs at the subnet and NIC level for inbound vs outbound traffic?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** AZ-500 Dual NSG Lab

<details><summary>Answer</summary>

**Inbound:** Subnet NSG → NIC NSG (external traffic enters the subnet first, then reaches the VM's NIC)

**Outbound:** NIC NSG → Subnet NSG (VM's packet leaves the NIC first, then traverses the subnet)

Either direction, both NSGs must allow for traffic to pass. A "deny" or missing rule at either level = blocked.

</details>

---

### Q39: Why would you deliberately use NSGs at both subnet and NIC level instead of just one?

**Topic:** networking | **Difficulty:** 🔴 Advanced | **Source:** AZ-500 Dual NSG Lab

<details><summary>Answer</summary>

**Defense in depth + organizational separation of concerns:**

- **Subnet NSG = baseline security policy** (managed by security/platform team): broad denies like "no RDP from internet," baseline allows like "HTTPS open for web tier"
- **NIC NSG = VM-specific exceptions** (managed by app team): a custom port a specific service needs, special admin access for a jump box

This split lets teams own different layers without stepping on each other. Even if the app team misconfigures a NIC NSG, the subnet NSG still enforces the security team's baseline.

**Trade-off:** Operational complexity. In most real workloads, one NSG level (usually subnet) is simpler and sufficient. Use dual only when team separation or baseline enforcement genuinely warrants it.

</details>

---

### Q40: A user says "my NSG allows port 443 but the connection is blocked." What's your debugging approach?

**Topic:** networking | **Difficulty:** 🟡 Intermediate | **Source:** AZ-500 Dual NSG Lab

<details><summary>Answer</summary>

Check in this order:

1. **Effective Security Rules** (Azure portal → VM → Networking) — shows the combined view of both subnet and NIC NSGs with the rule that actually applied. This is the #1 debugging tool.
2. **Is there a second NSG?** Dual NSG evaluation means an allow at one level isn't enough. Both must allow.
3. **Priority check** — a lower-numbered deny rule may override your allow.
4. **Direction** — inbound vs outbound rule? Wrong direction is a common mistake.
5. **Source/Destination** — does the rule actually match the traffic's source IP? (Remember Azure does NAT — destination is the private IP post-translation.)
6. **OS-level firewall** on the VM (iptables, Windows Firewall) — Azure doesn't see this.
7. **The app itself** — is nginx actually listening? `ss -tlnp` on the VM.
8. **NSG Flow Logs** — forensic view of denied traffic, needs Log Analytics enabled.

**Follow-up point:** `Network Watcher → IP Flow Verify` simulates a packet and tells you exactly which rule would allow or deny it.

</details>

---

### Q41: If I have matching allow rules in both my subnet NSG and NIC NSG, and a lower-priority deny rule in the NIC NSG only, does traffic pass?

**Topic:** networking | **Difficulty:** 🔴 Advanced | **Source:** AZ-500 Dual NSG Lab

<details><summary>Answer</summary>

**Depends on priorities within the NIC NSG.** Rules are evaluated within each NSG by priority (lower number wins). If the deny rule has a lower priority number than the allow rule in the NIC NSG, the deny wins at the NIC level → traffic blocked.

Azure never compares priorities across NSGs — each NSG is evaluated standalone. So:
- Subnet NSG: evaluates its own rules, picks the winner
- NIC NSG: evaluates its own rules, picks the winner
- If both winners are "allow" → traffic passes
- If either winner is "deny" → traffic blocked

**Follow-up point:** This is why priority management matters within each NSG — a low-priority deny can override higher-priority allows if you get the numbers wrong.

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
