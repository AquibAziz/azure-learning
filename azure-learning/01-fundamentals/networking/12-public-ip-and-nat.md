# Public IPs and NAT in Azure

> A VM doesn't actually "have" a public IP. Azure owns the public IP and translates traffic to the VM's private IP. Understanding this is the key to understanding NSG rules.

## The mental model that matters

When you attach a public IP to a VM, Azure doesn't put that IP on the VM itself. Instead:

- **Public IP lives on Azure's edge** — it's a Microsoft-owned IP that Azure associates with your subscription
- **Private IP lives on the VM's NIC** — the actual interface inside the OS only knows about the private IP
- **NAT bridges the two** — Azure maintains a mapping table and translates traffic between them

Run `ip addr` on an Azure Linux VM — you'll only see the private IP. The OS has no idea a public IP exists.

## The packet journey (inbound)

1. Browser sends packet: source = your home IP, dest = VM's public IP
2. Packet travels internet → hits Azure's edge network
3. **Azure does NAT** — rewrites destination from public IP to private IP
4. Packet is now: source = your home IP, dest = `10.0.0.4`
5. **NSG evaluates this translated packet**
6. If allowed, packet reaches the VM's NIC, then nginx

## Why this matters for NSG rules

**When writing NSG rules with destination IP, always use the PRIVATE IP of the VM.**

Alan's rule in the video:
- Source: my public IP (laptop)
- Destination: `10.0.0.4` (VM's PRIVATE IP) ✅
- Port: 80

The browser connects using the public IP, but by the time NSG sees the packet, Azure has already rewritten the destination to the private IP. If Alan had put the public IP as the destination, the rule would never match.

## The packet journey (outbound)

Reverse process:
1. VM sends response: source = `10.0.0.4`, dest = your home IP
2. Azure NAT rewrites source: public IP, dest = your home IP
3. Packet travels internet back to your browser
4. Browser sees the response as coming from the public IP it originally connected to

This is called **SNAT** (Source NAT) for outbound.

## Static vs dynamic public IP

| | **Dynamic** | **Static** |
|---|---|---|
| Stays the same? | No — can change on VM stop/start | Yes, forever |
| Cost | Cheaper (slightly) | Slightly more |
| Default on new VM | Yes | No (must opt in) |
| Use when | Lab VMs, dev, testing | DNS points to it, certificates, allowlists |

**Pro tip:** Instead of making the IP static, front your VM with a **DNS name**. Azure gives you a free `*.cloudapp.azure.com` hostname. Even if the IP changes, DNS propagates the new one automatically.

## Gotchas

- **Public IP is billed separately** from the VM. Deleting a VM doesn't delete the public IP — you keep paying for an unused resource.
- **Stopping a VM doesn't release a dynamic public IP immediately** — it's only released on *deallocation* (`az vm deallocate`), and even then only when the association is broken.
- **Standard SKU public IPs are zone-redundant** — Basic SKU is being retired; always use Standard for new workloads.
- **The "My IP Address" source option** in NSG rules auto-detects your current home IP. If your ISP gives you a dynamic IP, this rule may stop working when your ISP re-assigns you a different address.

## A VM without a public IP is often better

In production, most VMs should NOT have a public IP. Instead:
- **Azure Bastion** — managed SSH/RDP in the portal, no public IP on the VM
- **Jump box / bastion host** — one VM with a public IP that you SSH into, then reach private VMs from there
- **Azure Load Balancer / App Gateway** — public-facing front end; VMs behind it stay private
- **VPN / ExpressRoute** — connect from on-prem without ever exposing VMs to the internet

## Related topics

- [NSG & ASG](./02-nsg-asg.md)
- [VNet & Subnets](./01-vnet-subnets.md)
- [Load balancing](./09-load-balancing.md)

## Sources

- Udemy — Alan Rodrigues, AZ-500 Security course, "Communication across VMs"
- Microsoft Learn — [Public IP addresses](https://learn.microsoft.com/en-us/azure/virtual-network/ip-services/public-ip-addresses)
