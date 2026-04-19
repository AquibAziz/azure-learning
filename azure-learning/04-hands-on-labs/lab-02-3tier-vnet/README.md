# Lab 02 — 3-tier VNet with NSG + ASG

## Goal

Build the classic 3-tier architecture (web, app, db) using what I learned in the Day-5 VNet notes. Enforce the rule that only business-logic VMs can reach the DB, even when they share a subnet with web VMs. This is the lab where NSG + ASG actually click.

## Architecture

```
                  Internet
                     │
                     ▼ (only port 80/443)
┌────────────────────────────────────────────────┐
│ VNet: 10.0.0.0/16                              │
│                                                │
│  ┌───────────────┐  ┌───────────────┐          │
│  │ subnet-web    │  │ subnet-app    │          │
│  │ 10.0.1.0/24   │  │ 10.0.2.0/24   │          │
│  │               │  │               │          │
│  │ [web VM x1]   │  │ [web VM x1]   │          │
│  │               │  │   (asg-web)   │          │
│  │               │  │ [bizlogic VM] │          │
│  │               │  │   (asg-biz)   │          │
│  └───────────────┘  └───────┬───────┘          │
│                             │                   │
│                             ▼ (only asg-biz)    │
│                    ┌───────────────┐            │
│                    │ subnet-db     │            │
│                    │ 10.0.3.0/24   │            │
│                    │ [db VM]       │            │
│                    └───────────────┘            │
└────────────────────────────────────────────────┘
```

## What this proves

- **NSG basics** — how allow/deny rules work at subnet level
- **ASG power** — role-based rules beat CIDR-based ones when subnets are mixed
- **Defense in depth** — even if web is compromised, attacker can't jump straight to DB
- **Traffic flow testing** — `nc`/`curl` from each VM to confirm rules work as expected

## Steps (to be filled in)

1. Create resource group and VNet with address space `10.0.0.0/16`
2. Create 3 subnets: web, app, db (each `/24`)
3. Create 3 NSGs, one per subnet
4. Create 2 ASGs: `asg-web`, `asg-biz`
5. Deploy VMs and associate with ASGs
6. Add NSG rules using ASGs as source/destination
7. Test from each VM to verify traffic rules
8. Clean up

## Gotchas (to fill in as I go)

- [ ] TBD

## Related notes

- [VNet & Subnets](../../01-fundamentals/networking/01-vnet-subnets.md)
- [NSG & ASG](../../01-fundamentals/networking/02-nsg-asg.md)
