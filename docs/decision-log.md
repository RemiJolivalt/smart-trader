# Decision Log

> Toute décision stratégique, technique ou produit **doit** être tracée ici.
> Format ADR léger. Une décision = un bloc.

---

## Template

```
### ADR-XXXX — <titre court>
- **Date :** YYYY-MM-DD
- **Statut :** Proposed | Accepted | Deprecated | Superseded by ADR-YYYY
- **Contexte :** ...
- **Décision :** ...
- **Conséquences :** (positives / négatives / neutres)
- **Alternatives considérées :** ...
- **Liens :** issues, PR, docs
```

---

## Décisions initiales (cadrage)

### ADR-0001 — Monorepo unique
- **Date :** 2026-05-11
- **Statut :** Accepted
- **Contexte :** Centraliser front, back, docs, infra pour pilotage unique et compatibilité agents IA.
- **Décision :** Monorepo `smart-trader` avec dossiers `/frontend`, `/backend`, `/docs`, `/scripts`, `/tests`, `/infra`.
- **Conséquences :**
  - (+) Cohérence, refactor cross-stack facilité, CI unique.
  - (-) Build matrix plus complexe, frontière des responsabilités à discipliner.
- **Alternatives :** multi-repo (rejeté : surcoût coordination).

### ADR-0002 — Stack Next.js + FastAPI + Supabase
- **Date :** 2026-05-11
- **Statut :** Accepted
- **Contexte :** MVP low-cost, time-to-market rapide, écosystème mature.
- **Décision :** Front Next.js (Vercel), back FastAPI (Render/Fly.io), DB+Auth Supabase.
- **Conséquences :**
  - (+) Free tiers cumulés < 20 €/mois, DX excellente.
  - (-) Vendor lock-in modéré (Supabase) à surveiller.
- **Alternatives :** Django full-stack, Node/NestJS, Firebase.

### ADR-0003 — Broker IBKR pour MVP
- **Date :** 2026-05-11
- **Statut :** Accepted
- **Contexte :** Besoin API robuste + frais bas + paper trading + Europe.
- **Décision :** IBKR via `ib_insync` (ou Web API), paper d'abord.
- **Alternatives :** Trade Republic (API limitée), DEGIRO (API non idéale), Saxo (coûteux).

### ADR-0004 — IA multi-agents, LLM uniquement pour explication
- **Date :** 2026-05-11
- **Statut :** Accepted
- **Contexte :** Éviter dépendance LLM pour décisions trading (coût, latence, déterminisme).
- **Décision :** Décisions = règles + signaux quantitatifs. LLM = couche d'explainability.
- **Conséquences :** déterminisme, coût LLM marginal, audit facilité.

### ADR-0005 — Scan horaire, exécution opportuniste
- **Date :** 2026-05-11
- **Statut :** Accepted
- **Contexte :** Capital 1000 € → surtrading = perte garantie via frais.
- **Décision :** Cadence scan horaire pendant heures Euronext, exécution déclenchée uniquement si seuils atteints.
- **Conséquences :** moins de signaux mais meilleur ratio rendement/frais.

### ADR-0006 — Capital initial limité à 500 € en bascule live
- **Date :** 2026-05-11
- **Statut :** Accepted
- **Contexte :** Réduire le risque opérationnel lors du passage paper → live.
- **Décision :** 500 € pendant 7 jours, puis 1000 € après revue.
- **Conséquences :** ramp-up sécurisé, validation comportement réel.

### ADR-0007 — GitHub Projects pour pilotage Agile
- **Date :** 2026-05-11
- **Statut :** Accepted
- **Décision :** Colonnes : Backlog / Sprint courant / In Progress / Review / Done / Blocked.
- **Conséquences :** zero-cost, intégration native issues + PR.
