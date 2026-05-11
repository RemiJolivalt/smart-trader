# Specification Technique — Smart Trader

## 1. Architecture cible

### Vue logique

```
┌──────────────────────┐
│  Frontend (Next.js)  │  Vercel — SSR + RSC
│  - Dashboard         │
│  - Logs IA           │
│  - Settings risque   │
└──────────┬───────────┘
           │ HTTPS (JWT Supabase)
           ▼
┌──────────────────────┐
│  Backend (FastAPI)   │  Render / Fly.io
│  - REST API          │
│  - Agents IA         │
│  - Risk engine       │
│  - Broker adapter    │
└──┬─────────┬─────────┘
   │         │
   ▼         ▼
┌────────┐ ┌──────────────┐ ┌───────────────┐
│Supabase│ │ Data feeds   │ │ IBKR API      │
│Postgres│ │ Yahoo / AV / │ │ ib_insync /   │
│ + Auth │ │ Finnhub      │ │ Web API       │
└────────┘ └──────────────┘ └───────────────┘
   ▲
   │
┌──┴─────────────────┐
│ Scheduler          │
│ GitHub Actions /   │
│ Vercel Cron        │
└────────────────────┘
```

### Vue déploiement

| Composant | Hébergement | Tier |
|---|---|---|
| Frontend Next.js | Vercel | Hobby (free) |
| Backend FastAPI | Render / Fly.io | Free / 5 €-mo |
| DB + Auth | Supabase | Free (jusqu'à 500 MB) |
| Logs | BetterStack / Logtail | Free |
| Erreurs | Sentry | Free dev |
| Scheduler | GitHub Actions | Free (2000 min/mois) |
| Broker | IBKR | Frais transaction |

---

## 2. Modules backend

```
backend/
├── app/
│   ├── api/                # Routes FastAPI
│   ├── agents/             # 5 agents IA
│   │   ├── scanner.py
│   │   ├── strategy_selector.py
│   │   ├── risk_manager.py
│   │   ├── execution_engine.py
│   │   └── explainability.py
│   ├── brokers/            # Adapter IBKR (interface broker)
│   ├── data/               # Feeds Yahoo/AV/Finnhub
│   ├── domain/             # Entités métier (Position, Order, Decision...)
│   ├── infra/              # DB, auth, secrets, logging
│   ├── jobs/                # Tâches cron (scan, settle, eod)
│   └── main.py
└── tests/
```

**Principes :**
- Chaque agent = service stateless, testable isolément.
- Broker derrière une **interface abstraite** (`BrokerPort`) → multi-broker en V3 sans réécriture.
- Pas de logique métier dans les routes API (couche fine).

---

## 3. Modèle de données (Supabase Postgres)

### Tables principales

| Table | Champs clés |
|---|---|
| `users` | id, email, role, created_at |
| `accounts` | id, user_id, broker, mode (paper/live), capital_initial |
| `instruments` | symbol, isin, mic, sector, currency, active |
| `positions` | id, account_id, symbol, qty, avg_price, opened_at, closed_at |
| `orders` | id, account_id, symbol, side, type (mkt/lmt), qty, price, status, broker_id, sent_at, filled_at |
| `decisions` | id, account_id, scan_id, strategy, action, symbol, confidence, explanation, created_at |
| `scans` | id, started_at, ended_at, items_count, status |
| `risk_settings` | account_id, max_pos_pct, max_sector_pct, sl_min, sl_max, kill_daily_loss_pct |
| `audit_log` | id, actor, action, payload_hash, created_at |
| `notifications` | id, channel, payload, status, sent_at |

### RLS (Row Level Security)
- Activée sur toutes les tables utilisateur.
- Policies : `auth.uid() = user_id` partout, sauf admin role.

### Migrations
- Outil : **Supabase migrations** (`supabase/migrations/*.sql`)
- Naming : `<timestamp>_<short_desc>.sql`

---

## 4. API REST (FastAPI)

### Conventions
- Préfixe `/api/v1`
- Auth : Bearer JWT Supabase
- Format : JSON, snake_case, ISO 8601 dates
- Pagination cursor-based
- Codes HTTP : 200/201/204/400/401/403/404/422/500
- Erreurs : RFC 7807 (`application/problem+json`)

### Endpoints MVP

| Méthode | Path | Description |
|---|---|---|
| GET | `/health` | Liveness/readiness |
| GET | `/api/v1/portfolio` | Vue portefeuille agrégé |
| GET | `/api/v1/positions` | Positions ouvertes |
| GET | `/api/v1/orders` | Historique ordres |
| GET | `/api/v1/decisions` | Historique décisions IA |
| GET | `/api/v1/scans/latest` | Dernier scan |
| GET/PUT | `/api/v1/risk-settings` | Lecture/maj garde-fous |
| POST | `/api/v1/kill-switch` | Activation manuelle |
| POST | `/api/v1/mode` | Bascule paper/live (double validation) |
| POST | `/api/v1/backtest` | Lancement backtest |

---

## 5. Agents IA — contrats

| Agent | Input | Output | Fréquence |
|---|---|---|---|
| Scanner | univers symbols | snapshot prix/vol/momentum/volatilité | horaire |
| Strategy Selector | snapshot + portefeuille | stratégie active + candidats | post-scan |
| Risk Manager | candidats + état compte | ordres validés + sizing | post-strategy |
| Execution Engine | ordres validés | confirmations broker | temps réel |
| Explainability | décisions | texte explicatif | par décision |

LLM utilisé **uniquement** par Explainability (pas de décision primaire LLM).

---

## 6. Sécurité

### Gestion des secrets
- **Aucun secret en clair** dans le repo (gitleaks en CI).
- Secrets stockés dans :
  - **Vercel Env Vars** (frontend, prod/preview/dev)
  - **Render/Fly secrets** (backend)
  - **GitHub Encrypted Secrets** (CI/CD)
- Rotation API IBKR tous les 90 jours minimum, traçée dans `decision-log.md`.

### Authentification & autorisation
- **Supabase Auth** (JWT) — RLS Postgres systématique.
- MFA recommandé sur compte Supabase + IBKR.
- Bascule paper → live exige **double validation** (re-saisie mot de passe + code email/Telegram).

### Communications
- HTTPS obligatoire partout (HSTS, TLS 1.2+).
- CORS strict : origines whitelistées (Vercel preview + prod).
- CSP stricte côté Next.js.

### Données
- Chiffrement at-rest natif Supabase.
- Chiffrement applicatif (AES-GCM) pour API keys broker stockées en DB.
- Backups Supabase quotidiens (free tier inclus).

### Audit & monitoring
- `audit_log` : toutes les actions sensibles (kill-switch, bascule mode, modif risk settings, ordres > seuil).
- Logs structurés JSON avec `trace_id`.
- Alertes Sentry sur erreurs P0/P1.
- Health checks toutes les 5 min (UptimeRobot free).

### Conformité OWASP Top 10
- A01 Broken Access Control → RLS + tests d'autorisation.
- A02 Crypto Failures → AES-GCM, TLS, secrets encrypted.
- A03 Injection → ORM SQLAlchemy, pas de SQL string concat.
- A04 Insecure Design → revue d'architecture documentée.
- A05 Misconfiguration → CSP, headers sécu, gitleaks.
- A06 Vulnerable Components → Dependabot + `pip-audit` + `pnpm audit` en CI.
- A07 Auth Failures → MFA, rate limit, lockout.
- A08 Data Integrity → signatures webhooks, vérification réponses broker.
- A09 Logging Failures → logs structurés, alerting.
- A10 SSRF → whitelist URLs sortantes (data feeds).

### Kill-switch
- Conditions automatiques :
  - Perte journalière > X % (config).
  - 3 erreurs broker consécutives.
  - Volatilité indice > seuil (ex: VIX/VSTOXX spike).
- Effet : annulation ordres pendants + arrêt scanner + notification.

---

## 7. Observabilité

| Signal | Outil | Free tier |
|---|---|---|
| Logs | BetterStack/Logtail | ✅ |
| Erreurs | Sentry | ✅ |
| Uptime | UptimeRobot | ✅ |
| Métriques business | Supabase + Vercel Analytics | ✅ |

Format log obligatoire : `{ts, level, trace_id, agent, event, payload}`.

---

## 8. Tests & qualité

| Type | Outil | Couverture cible |
|---|---|---|
| Unit backend | pytest | ≥ 80 % sur `domain/`, `agents/`, `brokers/` |
| Unit frontend | vitest | ≥ 70 % sur composants critiques |
| Intégration | pytest + httpx + Supabase test container | scénarios API critiques |
| E2E | Playwright | parcours dashboard + kill-switch |
| Contract | schemathesis (OpenAPI) | toutes routes |
| Lint | Ruff (py), ESLint (ts) | 0 warning bloquant |
| Format | Black/Ruff format, Prettier | auto via pre-commit |
| Sécu | gitleaks, pip-audit, pnpm audit, bandit | CI bloquante |

---

## 9. Performance

- Scan horaire ≤ 30 s pour univers de 100 titres.
- Décision → ordre ≤ 5 s en P95.
- Dashboard TTFB ≤ 500 ms (Vercel edge).

---

## 10. Évolutivité

- Multi-broker : interface `BrokerPort`.
- Multi-stratégies : registre de stratégies pluggable.
- Multi-utilisateurs : RLS déjà en place.
- Multi-devises : champ `currency` partout dès V1.
