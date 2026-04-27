# 🚀 Projects

End-to-end builds — bigger than labs, structured like real work. These are portfolio pieces. Each project has:
- A clear problem statement
- An architecture diagram
- IaC (Bicep or Terraform if I go that route)
- Deployment steps
- A "what I'd do differently" retrospective

## Projects

| # | Project | Key services | Status |
|---|---|---|---|
| 01 | 3-tier web app (manual) | VNet, VM, App Service, SQL | ⬜ |
| 02 | Static site on Azure Storage + CDN | Storage, CDN, Custom domain | ⬜ |
| 03 | Serverless API with Functions | Functions, Cosmos DB, API Mgmt | ⬜ |
| 04 | Containerized app on AKS | AKS, ACR, Ingress, Monitor | ⬜ |

Legend: ⬜ Not started • 🔄 In progress • ✅ Completed

## Project conventions

Each project folder has:

```
project-NN-name/
├── README.md              ← problem, architecture, demo link
├── architecture/          ← diagrams
├── infra/                 ← bicep/terraform/arm
├── src/                   ← app code (or submodule)
├── deploy.md              ← deployment guide
└── retrospective.md       ← what went well, what I'd change
```

## Ideas I'm considering

- **Personal portfolio site** — Storage static site + Front Door + custom domain
- **URL shortener** — Functions + Cosmos DB
- **Image processing pipeline** — Blob trigger → Function → resized outputs
- **IoT-lite telemetry** — Event Hubs → Stream Analytics → dashboard
- **Multi-region DR demo** — active/passive failover with Traffic Manager
