# Backend — FastAPI (placeholder)

> ⚠️ Aucun code applicatif n'est encore présent. À implémenter à partir du Sprint 1, conformément à [docs/product-roadmap.md](../docs/product-roadmap.md).

## Stack
- Python 3.11+, FastAPI, Pydantic v2
- SQLAlchemy / SQLModel + Supabase Postgres
- Tests : pytest + httpx
- Lint/format : Ruff
- Sécu : bandit + pip-audit

## Structure cible
Voir [docs/technical-spec.md](../docs/technical-spec.md) §2.

```
backend/
├── app/
│   ├── api/
│   ├── agents/
│   ├── brokers/
│   ├── data/
│   ├── domain/
│   ├── infra/
│   ├── jobs/
│   └── main.py
└── tests/
```
