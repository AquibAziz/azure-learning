# AZ-500 — Effect of having multiple NSGs (subnet + NIC)

**Course:** Alan Rodrigues, AZ-500 Security (Udemy)
**Date watched:** 2026-04-24
**Type:** Hands-on lab (demonstration)
**Duration:** ~5 min

## Lab goal

Demonstrate what happens when a VM has an NSG at **both** the subnet level AND the NIC level — which is a common real-world configuration and a classic interview question.

## What was done

1. Starting state: shared NSG attached to subnets (has HTTP + SSH allow rules). No NIC-level NSGs.
2. **Re-attached** the old per-VM NSG to web-vm-01's NIC
3. **Deleted** the HTTP allow rule from that NIC-level NSG (leaving only SSH)
4. Tried to access nginx from browser → **FAILED**
5. Added HTTP rule back to the NIC NSG → **SUCCESS**

## The key takeaway

> **When a VM has NSGs at BOTH subnet and NIC levels, inbound traffic must be explicitly allowed by BOTH NSGs. An allow at only one level = traffic is blocked.**

Why? NSGs default-deny. No rule = denied. So both gates must have an explicit allow to let the packet through.

## Alan's actual configuration when it failed

| Rule | Subnet NSG | NIC NSG |
|---|---|---|
| SSH (22) | ✅ Allow | ✅ Allow |
| HTTP (80) | ✅ Allow | ❌ No rule |

HTTP traffic flow:
- Subnet NSG → "HTTP allowed ✓" → passes
- NIC NSG → "No HTTP rule → default deny ✗" → **blocked**

Result: browser can't reach nginx, even though the subnet NSG "should allow it."

## Evaluation order (important for AZ-500)

**Inbound traffic:**
1. Subnet NSG evaluated first
2. NIC NSG evaluated second

**Outbound traffic:**
1. NIC NSG evaluated first
2. Subnet NSG evaluated second

Same principle either direction — both must allow for traffic to pass.

## Why would you use both levels in production?

If both have to match, why ever use two? Because it's **defense in depth**:

**Subnet NSG = baseline (security team policy)**
- Broad denies (no admin ports from internet)
- Baseline allows (HTTPS for public web tier)
- Acts as a safety net

**NIC NSG = exceptions (app team)**
- VM-specific open ports (a custom agent's port)
- Special admin access (jump box with RDP from corporate IP)
- Tighter restrictions on one VM in a shared subnet

This split lets multiple teams manage different layers without stepping on each other. Even if the app team misconfigures the NIC NSG, the subnet NSG still enforces the baseline.

## The mental model that matters

Think of it as **two separate firewalls in series, not a merged rule set:**

- Azure does NOT combine the rule sets
- Azure does NOT pick the more permissive NSG
- Azure does NOT use "OR" logic between them
- Both NSGs are evaluated independently, each must say "yes"

Missing rule at either level → absence of "yes" → default deny wins → traffic dropped.

## Gotchas

- **Most common bug:** adding an allow rule to one NSG, assuming it'll work, forgetting the other NSG. Always check "Effective Security Rules" in Network Watcher to see what's actually applied.
- **SSH can stop working unexpectedly** if you manipulate NSGs — both NSGs need an SSH allow rule, or you're locked out.
- **Default rules differ between the two NSGs** — each NSG has its own 65000-65500 default rule set. They don't share or merge.
- **"Effective Security Rules"** view in Azure shows the combined effect — always your first debug tool when things don't work.

## How to debug "traffic is blocked but I have a rule!"

1. Azure portal → the VM → **Networking** → **Effective Security Rules** button
2. You'll see rules from BOTH NSGs evaluated together
3. Look for which rule is actually blocking (usually a default deny because nothing explicitly allowed)
4. Add matching allow rules to BOTH NSGs, or remove one NSG entirely

## Questions this raised

- What's the evaluation order for intra-VNet traffic? (Same order: subnet → NIC for inbound)
- Does this dual-NSG pattern cost more? (No — NSGs are free. Only the complexity cost matters.)
- Can I see which NSG is blocking? (Yes — Effective Security Rules + NSG Flow Logs)

## Links to canonical notes

- [NSG & ASG](../../01-fundamentals/networking/02-nsg-asg.md) *(updated with dual-NSG section)*
- [Subnet-level NSG pattern](./lab-subnet-level-nsg.md)

## Added to interview question bank

- What happens when NSGs exist at both subnet and NIC level?
- Evaluation order for inbound vs outbound
- Why dual-NSG pattern is useful (defense in depth)
- How to debug blocked traffic

See [interview question bank](../../08-interview-prep/question-bank.md).
