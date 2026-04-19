# Load balancing — App Gateway vs Load Balancer

> If the routing decision needs to look at the URL, use Application Gateway. If not, use Azure Load Balancer.

## Why load balancing exists

Critical applications are deployed as **multiple copies across availability zones** for high availability. But something has to decide which copy handles each request. That's the load balancer's job:

- Distribute load evenly across healthy copies
- Detect unhealthy copies and route around them
- Scale by adding more copies behind the same entry point

Without a load balancer, deploying 100 copies is pointless — clients wouldn't know which to hit.

## Azure's main load balancing options

| Service | Layer | Scope | Best for |
|---|---|---|---|
| **Application Gateway** | L7 (HTTP/HTTPS) | Regional | Web apps with URL-based routing |
| **Azure Load Balancer** | L4 (TCP/UDP) | Regional | Internal tier-to-tier traffic, non-HTTP |
| **Front Door** | L7 | Global | Global web apps, CDN, WAF |
| **Traffic Manager** | DNS | Global | Multi-region failover, geo-routing |

## Application Gateway (L7)

- Inspects HTTP content: URL path, hostname, headers, cookies
- Makes routing decisions like: `/login` → login pool, `/api/*` → API pool, `/` → homepage pool
- **Requires its own dedicated subnet** (usually named `AppGatewaySubnet`)
- Built-in **WAF** (Web Application Firewall) — protects against OWASP top 10 (SQLi, XSS, etc.)
- Supports **SSL termination** (decrypts HTTPS once, forwards HTTP internally — saves CPU on backends)
- Slower than L4 because of HTTP inspection

**Use it when:** incoming traffic is web traffic and the routing depends on the URL.

## Azure Load Balancer (L4)

- Operates on IP + port only — doesn't care about HTTP content
- Forwards packets fast — minimal overhead
- Two flavors:
  - **Public Load Balancer** — internet-facing entry point
  - **Internal Load Balancer** — private, used between internal tiers
- No WAF, no SSL termination, no URL routing

**Use it when:** routing decision doesn't need URL context — typically internal traffic (web → app, app → db) or non-HTTP protocols.

## The typical 3-tier pattern

```
Internet → App Gateway (L7, routes by URL)
            │
            ▼
     Web tier (multiple VMs in multiple AZs)
            │
            ▼
   Internal Load Balancer (L4)
            │
            ▼
     App tier (multiple VMs in multiple AZs)
            │
            ▼
   Internal Load Balancer (L4, optional)
            │
            ▼
     DB tier (usually managed DB handles its own HA)
```

**Why the mix?**
- L7 at the front: users hit URLs, need URL-based routing
- L4 between tiers: internal calls are one-to-one (login-frontend VMs always call login-backend VMs) — no URL inspection needed, and L4 is faster

## Front Door vs App Gateway

Both are L7 load balancers with WAF. Key differences:

| | **Front Door** | **App Gateway** |
|---|---|---|
| Scope | Global (multi-region) | Regional |
| Layer | L7 | L7 |
| CDN | ✅ Built in | ❌ No |
| Use when | Users worldwide, multi-region | Single region |

**Rule of thumb:** Front Door sits in front of multiple regional App Gateways in big deployments.

## Gotchas

- App Gateway **requires its own subnet** and can't share it with other resources
- Load Balancer is **free-ish** (small per-rule fee); App Gateway is significantly more expensive
- Changing the App Gateway subnet later is painful — size it right the first time
- **Health probes** — both LB and App Gateway need probes to detect unhealthy backends. Misconfigured probes = traffic going to dead VMs.

## Related topics

- [VNet & Subnets](./01-vnet-subnets.md)
- [Azure DNS](./11-azure-dns.md)
- [Azure Firewall](./10-azure-firewall.md)

## Sources

- YouTube — Abhishek Veeramalla, *Azure Zero to Hero Day 6*
- Microsoft Learn — [Load balancing options](https://learn.microsoft.com/en-us/azure/architecture/guide/technology-choices/load-balancing-overview)
