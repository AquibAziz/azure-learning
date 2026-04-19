# 🎭 Scenario-based interview questions

Real-world design and troubleshooting scenarios. These are the questions interviewers ask senior engineers. Each scenario requires you to combine multiple Azure services.

---

### Scenario 1: Design a secure 3-tier web app for a retail startup

**Setup:** The startup is building an e-commerce site. Expected traffic: ~10K daily users in India initially, growing to global scale. Security and cost matter.

<details><summary>Expected answer</summary>

**Networking:**
- One **VNet** (`10.0.0.0/16`) in Central India region
- Three subnets: `web` (`10.0.1.0/24`), `app` (`10.0.2.0/24`), `db` (`10.0.3.0/24`)
- **NSGs per subnet** — web allows 443 from internet; app allows only from web subnet; db allows only from app ASG
- **ASGs** for business-logic VMs so rules are role-based

**Entry point:**
- **Application Gateway with WAF** in its own subnet (`AppGatewaySubnet`)
- SSL termination at App Gateway
- Public IP + Azure DNS for the custom domain

**High availability:**
- VMs deployed across 2 availability zones
- VM Scale Sets with autoscaling rules

**Internal:**
- Internal Load Balancer (L4) between web and app tier

**Database:**
- Azure SQL with geo-redundancy (not a VM-based DB) — managed, HA built-in

**Cost control:**
- Skip Azure Firewall (expensive); rely on NSGs + App Gateway WAF for now
- Set Azure Monitor budget alerts

**Future scaling:**
- Add Front Door when going global
- Add Redis Cache for session state

</details>

---

### Scenario 2: A web app's response time has spiked. Walk through how you'd debug it.

<details><summary>Expected answer</summary>

1. **Narrow where the slowness is** — client, network, App Gateway, app tier, or DB?
   - Check **Application Insights** for request timings by component
   - Check **App Gateway metrics** (backend response time vs total)
   - Check **Log Analytics** for errors or throttling

2. **Check health:**
   - App Gateway backend health — are all backends reporting healthy?
   - VM CPU/memory in Azure Monitor
   - DB DTU/vCore usage

3. **Check recent changes:**
   - Was there a deployment? Roll back or check activity logs
   - Did traffic spike? Check Application Insights request count

4. **Network path:**
   - NSG flow logs — any unexpected denies?
   - DNS resolution — is it slow?

5. **Mitigate:**
   - Scale out the bottleneck tier
   - Enable caching at App Gateway or Front Door
   - Add Redis if DB is the bottleneck

</details>

---

### Scenario 3: Two teams in your org need to share a service across VNets

**Setup:** Team A has a reporting service in VNet-A. Team B in VNet-B needs to consume it. How do you connect them?

<details><summary>Expected answer</summary>

Options, in order of preference:

1. **VNet peering** — ideal if both VNets are in Azure and address spaces don't overlap. Fast, cheap, uses Azure backbone.

2. **Private Endpoint + Private Link** — if the service is a PaaS service (e.g., Azure SQL, Storage), this is cleaner than full VNet peering.

3. **VPN Gateway (VNet-to-VNet)** — older pattern, only if peering isn't feasible.

**Considerations:**
- Check address space overlap first
- Need owner access on both VNets for peering
- Peering is non-transitive — plan accordingly for hub-and-spoke

</details>

---

### Scenario 4: A VM's NSG allows port 443 from Internet, but the request still fails. Why?

<details><summary>Expected answer</summary>

Several possibilities:

1. **NSG at NIC level** also blocking — both subnet + NIC must allow
2. **Azure Firewall or NVA in the path** blocking — check UDRs forcing traffic through one
3. **Application Gateway / LB** in front — its WAF or rules may block
4. **VM's OS firewall** (iptables, Windows firewall) blocking the port
5. **App not actually listening** on 443 — check `ss -tlnp` on Linux or `netstat -an` on Windows
6. **NSG default rule priority** — a custom "deny" rule with lower priority may override the allow
7. **Public IP not associated** — VM has no public entry point

**Debug tool:** Azure Network Watcher → **IP Flow Verify** and **Effective Security Rules** tell you which rule is blocking.

</details>

---

### Scenario 5: Your hybrid cloud setup connects Azure to on-prem over VPN Gateway. Users report the connection is slow. What do you check?

<details><summary>Expected answer</summary>

1. **VPN Gateway SKU** — Basic SKU is capped at ~100 Mbps. Upgrade to VpnGw1/2/3 for more throughput.
2. **Internet path quality** — VPN goes over the public internet; unstable ISP routes hurt performance
3. **Concurrent connections** — each SKU has a max tunnel count
4. **Encryption overhead** — IPsec adds CPU load on both sides
5. **Gateway metrics** in Azure Monitor — bandwidth, tunnel ingress/egress
6. **On-prem VPN device** — check if it's CPU-bound or hitting its own limits

**Long-term fix:** If bandwidth consistently matters, move to **ExpressRoute** — dedicated private circuit, bypasses public internet.

</details>

---

*More scenarios will be added as I learn more services. A good target is 20+ scenario questions before AZ-104.*
