# Azure DNS

> Turns human-friendly names (`abhishek.com`) into machine-friendly IP addresses. Like Google Maps resolving a property name to GPS coordinates.

## Why DNS exists

Users don't type IP addresses — they type names. Every time you visit a website, DNS translates the name you typed into the IP address the browser actually connects to.

This translation happens in layers:
1. Your home router → your ISP's DNS server
2. ISP's DNS → authoritative DNS for that domain (e.g., Azure DNS if the domain is hosted there)
3. Authoritative DNS returns the IP → cached back down the chain
4. Browser finally connects to the IP

Azure DNS hosts the **authoritative** records for a domain — the source of truth for "what IP does `abhishek.com` point to?"

## What Azure DNS offers

### Public DNS zones
- Host your public domain (e.g., `mycompany.com`)
- Records you manage: A, AAAA, CNAME, MX, TXT, NS, SRV, SOA, CAA, PTR
- Globally distributed — fast lookups from anywhere

### Private DNS zones
- Used **inside** a VNet for resolving private resources
- Example: `api.internal.mycompany.com` → private IP of an internal service
- Auto-registration for VMs in linked VNets

## Typical DNS record types

| Record | Purpose | Example |
|---|---|---|
| A | Name → IPv4 | `abhishek.com` → `3.4.5.6` |
| AAAA | Name → IPv6 | `abhishek.com` → `2001:db8::1` |
| CNAME | Alias to another name | `www.abhishek.com` → `abhishek.com` |
| MX | Mail servers | `abhishek.com` → `mail.abhishek.com` |
| TXT | Arbitrary text (verification, SPF) | Domain ownership proof |
| NS | Which DNS servers are authoritative | — |

## How a request flows (full picture)

1. User types `abhishek.com` in browser
2. Browser asks OS → OS asks home router → router asks ISP DNS
3. ISP DNS checks cache; if missed, asks root servers, then TLD servers, then Azure DNS
4. Azure DNS returns the A record's IP (e.g., load balancer's public IP)
5. Browser opens a TCP connection to that IP
6. Request hits Azure Firewall → App Gateway → backend

## Custom domain flow in Azure

To put your own domain in front of an Azure service:

1. **Buy the domain** from a registrar (GoDaddy, Namecheap, Azure App Service domains, etc.)
2. **Create a public DNS zone** in Azure DNS for that domain
3. **Update name servers** at the registrar to point to Azure's name servers (4 of them)
4. **Add records** pointing to your Azure resources:
   - A record → public IP of App Gateway / Load Balancer
   - CNAME → App Service default hostname
5. **Validate propagation** with `nslookup` or `dig`

## Gotchas

- **DNS propagation takes time** — new records may take minutes to hours to be visible worldwide due to caching
- **TTL matters** — low TTL = fast changes but more DNS queries (costs more); high TTL = cheaper but slower to roll out changes
- **Private DNS zones** don't resolve for clients outside the linked VNet — by design
- **CNAME at apex** (e.g., `abhishek.com` directly) isn't allowed by DNS standards — use A records or alias records

## Related topics

- [Load balancing](./09-load-balancing.md)
- [VNet & Subnets](./01-vnet-subnets.md)

## Sources

- YouTube — Abhishek Veeramalla, *Azure Zero to Hero Day 6*
- Microsoft Learn — [Azure DNS overview](https://learn.microsoft.com/en-us/azure/dns/dns-overview)
