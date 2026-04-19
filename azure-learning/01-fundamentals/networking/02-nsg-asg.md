# NSG & ASG — Securing subnets

> NSGs are Azure's firewall rules. ASGs let you group VMs by role so NSG rules can reference *what* a VM does instead of *where* it lives.

## Network Security Group (NSG)

An NSG is a set of allow/deny rules for inbound and outbound traffic.

### Where to attach an NSG

- **Subnet (preferred)** — rules apply to every resource inside
- **NIC / individual VM** — for rules specific to one machine

**Best practice:** Attach at subnet level for most rules. Use NIC-level only for genuine exceptions (e.g., one jump box with special SSH access).

**Gotcha:** If both subnet-level and NIC-level NSGs exist, traffic must pass *both*. Inbound: subnet → NIC. Outbound: NIC → subnet. This double-filtering is a common source of "why is my traffic blocked?" mysteries.

### Rule components

| Field | What it is |
|---|---|
| Source | IP range, service tag (e.g., `Internet`, `VirtualNetwork`), or ASG |
| Source port | Usually `*` (any) — clients pick random source ports |
| Destination | IP range, service tag, or ASG |
| Destination port | The service port (80, 443, 22, 3306, etc.) |
| Protocol | TCP / UDP / ICMP / Any |
| Action | Allow or Deny |
| Priority | 100–4096, **lower number = higher priority** |

### Default rules (can't delete)

Every NSG comes with built-in rules:

**Inbound:**
- `AllowVNetInBound` — allow traffic from anywhere in the VNet
- `AllowAzureLoadBalancerInBound` — allow health probes
- `DenyAllInBound` — block everything else

**Outbound:**
- `AllowVnetOutBound`
- `AllowInternetOutBound`
- `DenyAllOutBound`

Your custom rules override these by priority.

## Application Security Group (ASG)

NSG rules based on CIDR are coarse — they apply to entire IP ranges. ASGs let you write rules based on VM **roles** instead.

### The problem ASG solves

Scenario: Your app subnet has 15 VMs — 10 web servers and 5 business-logic servers. Only the business-logic servers should reach the DB.

Without ASG, your options are all bad:
- Split into two subnets → re-architecting, new CIDR blocks
- List each VM's IP individually → breaks when you add/remove VMs

### The ASG solution

1. Create an ASG: `asg-business-logic`
2. Tag the 5 business-logic VMs with it (just a label — no IP changes)
3. Write an NSG rule: **Source = `asg-business-logic`**, **Destination = DB subnet**, **Allow**

Now only those 5 VMs reach the DB, regardless of their IP. Add a new business-logic VM tomorrow? Tag it with the ASG — done.

### Benefits

- **Role-based** — rules describe *what*, not *where*
- **Dynamic** — VMs can be added/removed without touching rules
- **Readable** — "allow business-logic to DB" beats "allow 10.0.2.45, 10.0.2.67, ..."
- **Less rule sprawl** — one rule handles any number of VMs

## Common patterns

### NSG + ASG together (the real-world pattern)

```
VNet: 10.0.0.0/16
├── subnet-web (10.0.1.0/24)
│   └── NSG rule: Allow 80/443 from Internet
├── subnet-app (10.0.2.0/24)
│   ├── asg-web-servers       (10 VMs)
│   ├── asg-business-logic    (5 VMs)
│   └── NSG rule: Allow asg-business-logic → subnet-db on 3306
└── subnet-db (10.0.3.0/24)
    └── NSG rule: Deny Internet, allow asg-business-logic only
```

## Gotchas & exam tips

- **Priority is evaluated low to high.** Rule 100 wins over rule 200. Once a match is found, processing stops.
- **ASGs only work inside a single VNet.** You can't reference an ASG across peered VNets.
- **Service tags** like `Internet`, `VirtualNetwork`, `AzureLoadBalancer` are maintained by Microsoft — cleaner than hardcoding IP ranges.
- **Effective security rules** — use this feature in the portal to debug why traffic is blocked. It shows which rule won.
- **Stateful** — if inbound traffic is allowed, the return traffic is automatically allowed. You don't need mirror outbound rules.

## Related topics

- [VNet & subnets](./01-vnet-subnets.md)
- [Azure Firewall vs NSG](./07-azure-firewall.md)
- [Route tables & UDRs](./04-route-tables-udr.md)

## Sources

- YouTube — Abhishek Veeramalla, *Azure Zero to Hero Day 5*
- Microsoft Learn — [Network security groups overview](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- Microsoft Learn — [Application security groups](https://learn.microsoft.com/en-us/azure/virtual-network/application-security-groups)
