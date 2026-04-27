# Flashcards — Networking

10 cards covering VNet, Subnet, NSG, ASG, CIDR, and routing.

---

### Q: Why do cloud providers use VNets / VPCs?

<details><summary>Answer</summary>

To provide **logical network isolation** on shared physical infrastructure. Without them, one customer's compromised VM could sit on the same network as another customer's — a critical security issue in a multi-tenant cloud.

</details>

---

### Q: How many usable IPs does an Azure `/24` subnet give you?

<details><summary>Answer</summary>

**251.** Azure reserves 5 IPs per subnet — the first 4 (network + gateway + 2 DNS) and the last 1 (broadcast).

</details>

---

### Q: Where should you attach an NSG — subnet or NIC?

<details><summary>Answer</summary>

**Subnet**, as the default. NIC-level is for exceptions (e.g., one specific VM with unique rules). Subnet-level is more scalable, consistent, and easier to manage.

</details>

---

### Q: What happens if NSGs exist at BOTH subnet and NIC level?

<details><summary>Answer</summary>

Traffic must be allowed by **both** to get through. Inbound is evaluated subnet → NIC; outbound is NIC → subnet. This double-filtering is a common cause of "why is my traffic blocked?" debugging.

</details>

---

### Q: What's the difference between an NSG and an ASG?

<details><summary>Answer</summary>

- **NSG** = the firewall rules themselves (allow/deny based on source, destination, port, protocol)
- **ASG** = a way to *group VMs by role* so NSG rules can reference "business-logic VMs" instead of specific IPs

They work together — you use an ASG as the source or destination in an NSG rule.

</details>

---

### Q: You have 15 VMs in one subnet. Only 5 should reach the DB. What do you do?

<details><summary>Answer</summary>

Create an **ASG** (e.g., `asg-business-logic`), tag only those 5 VMs with it, then write an NSG rule: **Source = asg-business-logic, Destination = DB subnet, Allow**. CIDR-based rules would allow all 15 since they share the subnet's range.

</details>

---

### Q: What's the priority range for NSG custom rules, and which number wins?

<details><summary>Answer</summary>

Custom rules: **100–4096**. **Lower number wins.** (Default rules live in 65000–65500 and can be overridden by lower-priority custom rules.)

</details>

---

### Q: What problem does a User-Defined Route (UDR) solve?

<details><summary>Answer</summary>

It overrides Azure's default system routes to force traffic through a specific path — typically for **security inspection** (routing outbound traffic through a firewall/NVA) or custom routing requirements that system routes don't handle.

</details>

---

### Q: Can you use an ASG from VNet A in an NSG rule for a VM in VNet B (even if peered)?

<details><summary>Answer</summary>

**No.** ASGs are scoped to a single VNet. For cross-VNet rules, use IP ranges or service tags.

</details>

---

### Q: You create a VM without specifying networking. What does Azure do?

<details><summary>Answer</summary>

Azure **auto-creates** a default VNet, subnet, public IP, and NSG. Fine for quick experiments — never for production. In real workloads, you design networking explicitly.

</details>

---

*Add more cards as you study. Keep questions specific and answers concise.*
