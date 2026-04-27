# Lab 03 — Host a web server on a VM (AZ-500 lead-in)

**Source:** Alan Rodrigues AZ-500 course (Udemy)
**Purpose:** Deliberately experience the "NSG blocks port 80" problem. This is the pedagogical setup for understanding why NSGs exist.

## Goal

1. Deploy an Ubuntu VM
2. Install nginx
3. Verify it works internally
4. Fail to reach it from the browser
5. (Next lab) Fix it with an NSG rule

## Architecture

```
Internet
   │
   │  (browser on your laptop)
   ▼
┌──────────────────────────────────────┐
│  Azure                               │
│  Public IP: <dynamic>                │
│     │                                │
│     ▼                                │
│  NSG (default rules — DENY port 80)  │  ← BLOCKS HERE
│     │                                │
│     ▼                                │
│  Ubuntu VM (10.0.0.4)                │
│    └── nginx listening on :80        │
└──────────────────────────────────────┘
```

## Steps

### 1. Deploy the VM

Via Azure portal:
- Image: Ubuntu 22.04 LTS
- Size: Standard_B1s (free-tier eligible)
- Authentication: SSH public key (or password for lab purposes)
- Username: `azureuser`
- Inbound ports: **SSH (22) only** — leave 80 closed intentionally
- Let the wizard auto-create VNet, subnet, NSG, public IP

### 2. SSH in

```bash
ssh azureuser@<public-ip>
```

If this fails: the NSG's auto-added SSH rule may be missing — check NSG → Inbound rules → you should see an allow rule for port 22.

### 3. Install nginx

```bash
sudo apt update
sudo apt install -y nginx
```

The `-y` flag auto-confirms the install prompt. Alan doesn't use this in the video but it saves a step.

### 4. Verify from inside the VM

```bash
curl http://localhost
# or
curl http://10.0.0.4
```

Expect an HTML response starting with `<!DOCTYPE html>` and containing "Welcome to nginx".

### 5. Try from your laptop browser

Open: `http://<public-ip>`

**Expect:** page times out / doesn't load. This is correct behavior — don't "fix" it yet.

### 6. Confirm it's the NSG (diagnostic)

In Azure portal:
- Go to your VM → **Networking** (left menu)
- Look at **Inbound port rules**
- You'll see SSH (22) allowed, but nothing for port 80

### 7. Fix it (preview of next lesson)

Add an inbound NSG rule:
- **Source:** Any (or "Service Tag" → "Internet")
- **Source port ranges:** `*`
- **Destination:** Any
- **Destination port ranges:** `80`
- **Protocol:** TCP
- **Action:** Allow
- **Priority:** 100
- **Name:** `Allow-HTTP-Inbound`

Refresh the browser → nginx welcome page loads. 🎉

## Gotchas I ran into

*(Fill in as you do the lab)*

- [ ] TBD
- [ ] TBD

## Cleanup — don't skip this

```bash
az group delete --name <your-rg-name> --yes --no-wait
```

Verify:
```bash
az group exists --name <your-rg-name>   # should return "false"
```

**Specifically watch out for:** public IPs are billed per hour even when the VM is deallocated. Always delete the whole resource group, not just the VM.

## What I learned

*(Fill in after completion)*

- [ ] Default NSG inbound behavior
- [ ] The public vs private IP split
- [ ] Why "it works locally" isn't enough in cloud

## Related notes

- [NSG & ASG](../../01-fundamentals/networking/02-nsg-asg.md)
- [VNet & Subnets](../../01-fundamentals/networking/01-vnet-subnets.md)
- [Lab 01 — First VM](../lab-01-first-vm/README.md) — similar but simpler setup
