# Udemy — AZ-500 Microsoft Azure Security Exam Certification (Alan Rodrigues)

**Instructor:** Alan Rodrigues
**Platform:** Udemy
**Cert target:** AZ-500 (Azure Security Engineer Associate)
**Format:** Lecture + heavy hands-on labs
**Level:** Intermediate → advanced (assumes AZ-104 level knowledge)

## Why this course

Alan's course is hands-on lab-heavy, which is exactly how security should be learned. Every concept is shown working (or failing) in a real Azure environment.

## Heads-up on prerequisites

AZ-500 sits above AZ-104 in Microsoft's cert path. Starting it this early is ambitious but not impossible — the networking and security fundamentals overlap heavily with what I'm learning in Abhishek's Zero-to-Hero series, so concepts reinforce each other.

**Strategy:** Use Alan's labs to *apply* the theory I'm learning elsewhere. Don't stress about taking the AZ-500 exam until AZ-104 is done.

## Progress

| Section / Lab | Topic | Status | Notes |
|---|---|---|---|
| Networking fundamentals | Host a web server on a VM | ✅ | [lab-host-web-server.md](./lab-host-web-server.md) |
| Networking fundamentals | Communication across VMs in a VNet | ✅ | [lab-vm-communication.md](./lab-vm-communication.md) |
| _TBD_ | _TBD_ | ⬜ | |

## Key takeaways so far

- Every VM gets both a private and public IP — understand the role of each
- NSGs default-deny inbound traffic; SSH works because Azure adds the rule automatically
- The "web server works from inside but not outside" problem is the classic lead-in to understanding NSGs

## Questions that came up

- How do I make my public IP static so I can bookmark it?
- What's the exact cost of an unused public IP?
- Does nginx start automatically on reboot?

## Links to canonical notes

- [VNet & Subnets](../../01-fundamentals/networking/01-vnet-subnets.md)
- [NSG & ASG](../../01-fundamentals/networking/02-nsg-asg.md)

## Links to labs

- [Lab 03 — Host web server on VM (hands-on)](../../04-hands-on-labs/lab-03-host-web-server/README.md)
