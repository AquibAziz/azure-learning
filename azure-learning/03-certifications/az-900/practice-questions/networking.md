# AZ-900 / AZ-104 Practice Questions — Networking

Self-test questions from my study. Answers are collapsed — click to reveal.

---

### Q1. What is the primary purpose of an Azure Virtual Network?

<details>
<summary>Answer</summary>

To provide **logical network isolation** in Azure's multi-tenant cloud. A VNet gives each customer a private network space even though the underlying physical infrastructure is shared with other customers.
</details>

---

### Q2. How many usable IP addresses does a `/24` subnet give you in Azure?

<details>
<summary>Answer</summary>

**251 usable IPs** (not 254, not 256). Azure reserves **5 IPs per subnet**: the first 4 (network address + gateway + 2 for DNS/internal use) and the last 1 (broadcast address).
</details>

---

### Q3. You want only 5 specific VMs in an app subnet to reach the database subnet. The other 10 VMs in the same subnet must not. What's the cleanest solution?

<details>
<summary>Answer</summary>

Use an **Application Security Group (ASG)**. Create an ASG called `asg-business-logic`, tag the 5 VMs with it, and reference that ASG as the source in your NSG rule. CIDR-based NSG rules would apply to the whole subnet.
</details>

---

### Q4. A colleague says "NSGs should always be applied to individual VM NICs for maximum control." Do you agree?

<details>
<summary>Answer</summary>

**No.** Best practice is to apply NSGs at the **subnet level** for most rules. NIC-level NSGs should be exceptions. Subnet-level is more scalable, consistent, and manageable. If rules exist at both levels, traffic must pass both, which can cause unexpected blocks.
</details>

---

### Q5. What Azure feature would you use to force all outbound traffic from a VNet to pass through a firewall appliance for inspection?

<details>
<summary>Answer</summary>

A **User-Defined Route (UDR)** in a route table. Create a route that sends `0.0.0.0/0` (all traffic) to the firewall VM's IP as the next hop. System routes alone would send traffic directly to the internet.
</details>

---

### Q6. Can you use an ASG defined in VNet A within an NSG rule for a VM in VNet B (the VNets are peered)?

<details>
<summary>Answer</summary>

**No.** ASGs only work within a single VNet. Across peered VNets, you'd need to use IP ranges, service tags, or design the ASGs per VNet.
</details>

---

### Q7. If a VNet has address space `10.0.0.0/16`, how many IP addresses is that?

<details>
<summary>Answer</summary>

**65,536 IP addresses.** `/16` means 16 bits are fixed for the network, leaving 16 bits (2^16 = 65,536) for hosts.
</details>

---

### Q8. What happens when you create a VM in the portal without specifying a VNet?

<details>
<summary>Answer</summary>

Azure **auto-creates a default VNet, subnet, and NSG** for you. Convenient for learning and testing, but in production you should always design these explicitly rather than relying on defaults.
</details>

---

*Add more questions as you study. Use the `<details>` HTML pattern to keep them testable.*
