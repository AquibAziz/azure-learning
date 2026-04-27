# AZ-500 — Deploying a second web VM (ASG setup)

**Course:** Alan Rodrigues, AZ-500 Security (Udemy)
**Date watched:** 2026-04-24
**Type:** Hands-on lab (setup for ASG demo)
**Duration:** ~8 min

## Chapter purpose

This is a **stage-setting chapter** — Alan doesn't teach ASGs yet. He's creating a third VM and cleaning up NSGs so the ASG demo in the next chapter is clean.

## What was done

1. **Created web-vm-02** (Ubuntu, B1s) in web-subnet-01
   - **Critical step:** selected **"None"** for NSG during VM creation
   - This tells the wizard to NOT create a per-VM NSG on the NIC
   - VM will rely on the subnet-level NSG only
2. **Disassociated the leftover NIC NSG from web-vm-01**
   - Clean-up from the dual-NSG experiment in the previous chapter
3. **SSH broke initially** because the subnet NSG's SSH rule had destination `10.0.0.4` only
4. **Fix:** edited the SSH rule to include `10.0.0.5` in the destination list
5. SSH'd in and installed nginx — same as the first lab

## The real lesson (Alan doesn't state this explicitly)

This chapter demonstrates the **production-grade deployment pattern**:

> Create the subnet NSG once with all your rules. Future VMs deploy with "None" at NIC level and inherit the subnet's rules automatically.

### The three patterns compared

| Pattern | VM deployment default | Rule management |
|---|---|---|
| **Wizard default** | Each VM gets its own NIC NSG | Scattered, N rules per deployment |
| **Dual NSG** | VM has both NIC + subnet NSG | Traffic must pass BOTH gates |
| **Subnet-only** (this chapter) | "None" at NIC, relies on subnet | Centralized, scales naturally |

Subnet-only is the goal for most real-world setups.

## Why SSH broke for the new VM

The existing SSH rule had destination = `10.0.0.4` (just web-vm-01). When web-vm-02 came up as `10.0.0.5`, no rule matched it → default deny won → SSH blocked.

**Alan's quick fix:** add `10.0.0.5` to the destination list → `10.0.0.4,10.0.0.5`.

**The gotcha Alan left visible on purpose:** every new VM requires editing this rule. Forget once → that VM is inaccessible. This fragility is exactly what ASGs solve in the next chapter.

## The seed for the ASG demo

Alan now has TWO web VMs in the same subnet:
- web-vm-01 @ 10.0.0.4
- web-vm-02 @ 10.0.0.5

Next chapter: instead of listing IPs in NSG rules, he'll create an ASG called something like `asg-web-servers`, tag both VMs with it, and reference the ASG as destination. Add a third VM → tag with ASG → automatically covered.

## Key concepts reinforced

- **VM deployment → subnet inheritance** — deploy into a subnet and you inherit its NSG. No separate config needed.
- **"None" option during VM creation** — opt-out of the wizard's auto-NSG. Easy to miss; critical for clean architecture.
- **IP-based rules are brittle** — any change to VM inventory requires rule edits. ASGs fix this.

## Gotchas

- **Easy to miss the "None" option** — most tutorials blindly accept wizard defaults. Always check the networking step during VM creation.
- **Default wizard behavior creates NSG sprawl** — 10 VMs via wizard = 10 orphan NSGs after cleanup.
- **Be careful with "disassociate"** — detaching a NIC NSG is instant. If the subnet NSG doesn't cover the traffic, connectivity breaks immediately.
- **IP list in rules doesn't scale** — this is the setup for ASGs. Don't commit to IP-based rules in anything beyond a 2-3 VM lab.

## Questions this raised

- What if I want a new VM deployed with "None" via Azure CLI? (Use `--nsg ""` flag or Bicep/ARM with empty networkSecurityGroup)
- Can I remove the NSG from an existing VM's NIC after it's been created? (Yes — Azure portal → NIC → Network Security Group → Edit → None)
- Does "None" mean no security? (No — the subnet NSG still applies. "None" only refers to the NIC level.)

## Links to canonical notes

- [NSG & ASG](../../01-fundamentals/networking/02-nsg-asg.md) — the "Dual NSG evaluation" section is exactly why we're consolidating
- [Subnet-level NSG pattern](./lab-subnet-level-nsg.md)

## Added to interview question bank

- Why select "None" for NSG during VM creation?
- How does IP-based destination in NSG rules become a maintenance problem?
- When a VM is deployed into a subnet with existing NSG, what security applies automatically?

See [interview question bank](../../08-interview-prep/question-bank.md).
