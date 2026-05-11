# Infrastructure — Vercel, Supabase, CI/CD

## Contenu

```
infra/
├── github/
│   ├── labels.yml           # Source de vérité des labels
│   ├── projects.md          # Configuration GitHub Projects
│   └── branch-protection.md # Règles protection branches
├── vercel/                  # Config Vercel (à venir Sprint 0)
├── supabase/                # Migrations + policies (à venir Sprint 0)
└── README.md
```

## Conventions
- IaC déclarative quand possible.
- Aucune ressource manuelle non documentée ici.
- Toute modif d'infra → ADR dans `docs/decision-log.md`.

## Environnements
| Env | Frontend | Backend | DB |
|---|---|---|---|
| dev (local) | Next.js dev | uvicorn local | Supabase project dev |
| preview | Vercel preview (PR) | Render branch deploy | Supabase project dev |
| prod | Vercel prod | Render prod | Supabase project prod |
