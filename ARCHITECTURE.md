# Architecture — Smart Trader

> Vue technique de référence. Toute évolution structurante doit faire l'objet d'un ADR dans [docs/decision-log.md](docs/decision-log.md).

---

## 1. Schéma système

```
┌─────────────────────────────────────────────────────────────────┐
│                         UTILISATEUR                              │
│                       (navigateur web)                           │
└─────────────────────┬───────────────────────────────────────────┘
                      │ HTTPS
                      ▼
┌─────────────────────────────────────────────────────────────────┐
│                  FRONTEND  (Next.js / Vercel)                    │
│  Dashboard · Positions · Logs IA · Settings · Backtest          │
└─────────┬─────────────────────────────────────┬─────────────────┘
          │ Supabase JS (auth + RLS reads)      │ REST/JWT
          ▼                                     ▼
┌─────────────────────────┐    ┌──────────────────────────────────┐
│   SUPABASE              │    │   BACKEND  (FastAPI / Render)    │
│   - Postgres            │◄──►│   - REST API                     │
│   - Auth (JWT)          │    │   - Multi-agents IA              │
│   - Storage             │    │   - Risk engine                  │
│   - RLS policies        │    │   - Broker adapter               │
└─────────────────────────┘    └─┬──────────────────┬─────────────┘
                                 │                  │
                                 ▼                  ▼
                    ┌─────────────────┐   ┌────────────────────┐
                    │ Data feeds      │   │ Broker IBKR        │
                    │ Yahoo / AV /    │   │ ib_insync /        │
                    │ Finnhub         │   │ Web API            │
                    └─────────────────┘   └────────────────────┘

           Cron horaire (GitHub Actions / Vercel Cron) ──► Backend /jobs
```

---

## 2. Flux de données

### 2.1 Boucle de trading (chaque heure)

```
[Cron] ──► /jobs/scan
            │
            ▼
   Agent Scanner ──► snapshot prix/vol/momentum/volat
            │
            ▼
   Agent Strategy Selector ──► stratégie active + candidats
            │
            ▼
   Agent Risk Manager ──► ordres validés + sizing + stop
            │
            ▼
   Agent Execution Engine ──► IBKR API (paper/live)
            │
            ├──► persist `decisions`, `orders`, `positions` (Supabase)
            ▼
   Agent Explainability ──► texte LLM ──► persist + notification
```

### 2.2 Lecture utilisateur

```
Browser ──► Next.js (RSC) ──► Backend /api/v1/portfolio
                          ──► Supabase (RLS) directement pour lectures simples
```

### 2.3 Kill-switch

```
[Conditions] ──► RiskManager.trigger_kill_switch()
                  ├──► annulation ordres pendants (broker)
                  ├──► stop scanner
                  ├──► audit_log + notifications P0
                  └──► dashboard banner
```

---

## 3. Logique IA

### 3.1 Architecture multi-agents

| Agent | Responsabilité | Stateless | LLM ? |
|---|---|---|---|
| Scanner | collecte données marché | oui | non |
| Strategy Selector | choix stratégie | oui | non |
| Risk Manager | sizing + garde-fous | oui | non |
| Execution Engine | ordres broker | oui (idempotent) | non |
| Explainability | génère explication | oui | **oui** |

### 3.2 Stratégies (registre pluggable)

- **Momentum breakout** (70 % du temps cible)
- **Mean reversion** (20 %)
- **Defensive cash mode** (selon volatilité)
- **Volatility exploit** (10 %)

### 3.3 Décision = signaux quantitatifs déterministes

> **Aucune décision d'achat/vente n'est prise par un LLM.**
> Le LLM justifie *a posteriori*. Cela garantit déterminisme, audit, et coût marginal.

---

## 4. Broker

### Interface abstraite

```
BrokerPort
 ├── get_account()
 ├── get_positions()
 ├── place_order(order)
 ├── cancel_order(id)
 └── get_order_status(id)

IBKRBrokerAdapter implements BrokerPort
```

- Multi-broker en V3 = nouvelle implémentation de `BrokerPort` sans changer la logique métier.
- **Idempotence** : chaque ordre porte un `client_order_id` unique pour éviter les doubles envois.
- **Réconciliation** : job EOD compare DB vs broker et alerte sur divergence.

---

## 5. Sécurité (vue archi)

```
┌─ Vercel ──┐    ┌─ Render/Fly ──┐    ┌─ Supabase ──┐
│ Env vars  │    │ Env vars       │   │ Vault chiffré│
│ HTTPS/HSTS│    │ HTTPS only     │   │ at-rest enc. │
│ CSP strict│    │ CORS whitelist │   │ RLS partout  │
└───────────┘    └────────────────┘   └──────────────┘
       │                 │                    │
       └────── JWT Supabase + audit_log ──────┘

Secrets sortants : IBKR API keys → AES-GCM en DB, déchiffrement côté backend uniquement.
```

Détails : [SECURITY.md](SECURITY.md) et `docs/technical-spec.md` §6.

---

## 6. Observabilité

```
Backend ──► structured logs (JSON) ──► BetterStack
        ──► Sentry (errors + traces)
        ──► metrics push (decisions/sec, orders/sec, kill_switch_count)
Frontend ──► Sentry browser
Cron    ──► GitHub Actions logs
Health  ──► UptimeRobot ping /health 5 min
```

---

## 7. Décisions d'architecture (résumé)

Voir tous les ADR dans [docs/decision-log.md](docs/decision-log.md). Décisions clés :

- ADR-0001 Monorepo unique
- ADR-0002 Stack Next.js + FastAPI + Supabase
- ADR-0003 Broker IBKR
- ADR-0004 LLM pour explication uniquement
- ADR-0005 Scan horaire opportuniste
