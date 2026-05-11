# Smart Trader — Autonomous European Equity Trader

> Application web personnelle de trading automatique IA sur actions françaises et européennes.
> Capital initial : **1 000 €** — Infra **low-cost** — Sécurité **forte** — Pilotage **full auto**.

---

## 1. Vision produit

Construire un agent de trading autonome, explicable et discipliné, capable de :

- Gérer un capital initial fixe de **1 000 €** sur Euronext Paris + Europe.
- Acheter / vendre uniquement des **actions classiques** (pas d'ETF, options, CFD, crypto, dérivés).
- Adapter dynamiquement la stratégie aux conditions de marché (momentum, mean reversion, defensive cash, volatility exploit).
- Préserver une part de cash variable selon la confiance IA.
- Justifier chaque décision en langage naturel.
- Tolérer une volatilité forte (drawdown jusqu'à -50 %) sans intervention manuelle.

**Philosophie produit :** *Discipline > Sophistication. Coût bas > Optimisation prématurée. Sécurité > Vitesse.*

---

## 2. Objectif MVP (V1)

| Brique | Périmètre MVP |
|---|---|
| Marchés | Euronext Paris + Europe principale |
| Produits | Actions classiques uniquement |
| Broker | Interactive Brokers (IBKR) — paper trading puis réel |
| Données | Yahoo Finance, Alpha Vantage free, Finnhub free |
| Agents IA | Scanner, Strategy Selector, Risk Manager, Execution, Explainability |
| Cadence | Scan horaire, exécution opportuniste |
| UI | Dashboard portefeuille, P&L, positions, logs IA, paramètres risque |
| Notifications | Email + Telegram |
| Hébergement | Vercel + Supabase + Render/Fly.io (≤ 20 €/mois) |

**Non inclus dans le MVP :** sentiment analysis avancé, RL, multi-broker, mobile app, fiscalité.

---

## 3. Stack technique

### Frontend
- **React** + **Next.js** (App Router)
- Déploiement **Vercel**
- TailwindCSS, TanStack Query, Zod

### Backend
- **FastAPI** (Python 3.11+)
- Pydantic v2, SQLAlchemy / SQLModel
- Déploiement Render ou Fly.io

### Données & Auth
- **Supabase PostgreSQL** (DB + Auth + Storage)
- Row Level Security activée

### IA / Agents
- Orchestration multi-agents (LangGraph ou implémentation custom légère)
- LLM utilisé uniquement pour **explication**, pas pour la décision primaire

### Scheduler
- GitHub Actions / Vercel Cron pour scans horaires
- Worker dédié pour exécution ordres

### Broker
- **Interactive Brokers** via API officielle (`ib_insync` ou IBKR Web API)
- Paper trading par défaut

### Observabilité
- Logs structurés (JSON) → Supabase + Logtail/BetterStack (free tier)
- Sentry (free tier) pour erreurs front + back

---

## 4. Architecture globale

```
┌──────────────┐    ┌─────────────────┐    ┌──────────────────┐
│   Frontend   │◄──►│   Backend API   │◄──►│  Supabase (PG)   │
│ Next.js/Vercel│    │     FastAPI    │    │   Auth + DB      │
└──────────────┘    └────────┬────────┘    └──────────────────┘
                             │
                ┌────────────┼─────────────┐
                ▼            ▼             ▼
         ┌──────────┐ ┌──────────┐  ┌────────────┐
         │ Agents IA │ │ Data Feeds│  │ IBKR API   │
         │ (5 rôles) │ │ Yahoo/AV │  │ Broker     │
         └──────────┘ └──────────┘  └────────────┘
                             │
                       ┌─────▼──────┐
                       │ Scheduler  │
                       │ Cron 1h    │
                       └────────────┘
```

Voir [docs/technical-spec.md](docs/technical-spec.md) et [ARCHITECTURE.md](ARCHITECTURE.md).

---

## 5. Roadmap (synthèse)

| Version | Contenu | Statut |
|---|---|---|
| **V1 — MVP** | Scan, IA hybride simple, broker auto (paper), dashboard, logs | À démarrer |
| **V2** | Sentiment news, backtesting avancé, multi-stratégies, fiscalité | Planifié |
| **V3** | Self-learning, RL, multi-broker, app mobile | Future |

Détail sprintifié : [docs/product-roadmap.md](docs/product-roadmap.md).

---

## 6. Conventions de développement

- **Branches** : `main`, `develop`, `feature/<ticket>-slug`, `fix/<ticket>-slug`, `hotfix/<ticket>-slug`
- **Commits** : Conventional Commits (`feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`, `ci:`)
- **PR** : revue obligatoire (≥ 1 reviewer), CI verte, template respecté
- **Code** : lint + format auto (ESLint/Prettier côté front, Ruff/Black côté back)
- **Tests** : unitaires + intégration obligatoires sur logique métier (trading, risk, agents)
- **Sécurité** : aucun secret en clair, scan dépendances activé, secrets via Vercel/Render env

Voir [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 7. Guide d'installation

### Prérequis
- Node.js ≥ 20, pnpm ≥ 9
- Python ≥ 3.11, uv ou poetry
- Compte Supabase, Vercel, IBKR (paper)

### Setup local

```bash
git clone https://github.com/<owner>/smart-trader.git
cd smart-trader

# Frontend
cd frontend && pnpm install && cp .env.example .env.local

# Backend
cd ../backend && uv sync && cp .env.example .env

# Lancer
pnpm --dir frontend dev
uv run --directory backend uvicorn app.main:app --reload
```

Détail complet à venir dans `docs/setup.md` (à créer lors du Sprint 0).

---

## 8. Workflow Git

```
feature/* ──► develop ──► main (release)
fix/*     ──► develop
hotfix/*  ──► main + back-merge develop
```

- **`main`** : production, protégé, merge uniquement via PR validée.
- **`develop`** : intégration continue, base des features.
- Squash merge par défaut sur `develop`, merge commit sur `main`.

---

## 9. Structure du repo

```
smart-trader/
├── frontend/          # React / Next.js
├── backend/           # FastAPI + agents IA
├── docs/              # Specs fonctionnelles, techniques, roadmap, risques
├── scripts/           # Automation, cron, setup
├── tests/             # Tests globaux (E2E, contrats, qualité)
├── infra/             # Vercel, Supabase, CI/CD, IaC
├── .github/           # Workflows, templates issues/PR, labels
├── README.md
├── CONTRIBUTING.md
├── ARCHITECTURE.md
└── SECURITY.md
```

---

## 10. Règles strictes (LLM & contributeurs)

> Ces règles s'appliquent **à tout contributeur humain ou IA (Copilot, agents)** :

1. **Ne jamais développer sans spécification préalable.**
2. **Chaque feature doit être liée à une User Story** GitHub.
3. **Chaque code doit respecter l'architecture et les conventions.**
4. **Aucune implémentation sans critères d'acceptation validés.**
5. **Prioriser : MVP, coût faible, sécurité forte.**
6. **Documenter toutes les décisions** dans [docs/decision-log.md](docs/decision-log.md).

---

## Licence

Projet personnel — tous droits réservés. Voir `LICENSE` (à définir).
