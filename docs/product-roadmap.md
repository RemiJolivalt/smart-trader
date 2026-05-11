# Product Roadmap — Smart Trader

> Roadmap incrémentale orientée **MVP rapide → enrichissement progressif**.
> Chaque sprint = 2 semaines. Chaque issue = User Story conforme template.

---

## Sprint 0 — Fondations (Setup) — 1 semaine

**Sprint Goal :** repo industrialisé, environnements prêts, CI/CD verte sans code applicatif.

| Issue | Type | Estim |
|---|---|---|
| Setup monorepo + conventions | tech | S |
| CI/CD (lint, test, build, preview) | tech | M |
| Setup Supabase project (DB vide + auth) | tech | S |
| Setup Vercel + Render | tech | S |
| Setup secrets management (Vercel/Render/GitHub) | security | S |
| Setup observabilité (Sentry, BetterStack) | tech | S |
| Documenter setup local (`docs/setup.md`) | docs | S |

**Livrables :** repo green, déploiements vides accessibles, secrets configurés.
**KPI :** CI < 5 min, 0 secret en clair, 100 % conventions respectées.
**Risques :** dérive de scope → strict respect du périmètre fondations.
**Validation :** PR review + checklist Sprint 0.

---

## Sprint 1 — Capital & lecture portefeuille (US Epic A) — MVP V1.0

**Sprint Goal :** afficher dashboard portefeuille connecté à IBKR paper en lecture seule.

| Issue | Epic | Estim |
|---|---|---|
| US-A1 Valeur portefeuille temps quasi-réel | A | M |
| US-A3 Liste positions ouvertes | A | M |
| US-A4 Cash disponible + cash idle | A | S |
| Adapter IBKR (lecture seule, paper) | tech | L |
| Modèle DB positions + sync | tech | M |
| Dashboard UI v1 (Next.js) | front | L |

**Livrables :** dashboard read-only fonctionnel sur compte paper.
**KPI :** 100 % positions IBKR affichées, latence < 5 s.
**Risques :** rate-limit IBKR — mitigation : cache + polling raisonné.

---

## Sprint 2 — Scanner + Décisions IA simples (Epic B) — MVP V1.1

**Sprint Goal :** scanner horaire + décision momentum simple + explication.

| Issue | Epic | Estim |
|---|---|---|
| US-B1 Scanner horaire | B | M |
| US-B2 Strategy Selector (momentum + defensive seulement) | B | L |
| US-B3 Explainability (LLM léger) | B | M |
| US-B4 UI historique décisions | B | M |
| Data feed Yahoo + Finnhub | tech | M |
| Job cron GitHub Actions | tech | S |

**Livrables :** décisions simulées, dashboard logs IA.
**KPI :** scan réussi > 95 %, 100 % décisions expliquées.
**Risques :** qualité data gratuite — fallback multi-source.

---

## Sprint 3 — Risk Manager + Exécution paper (Epics C + D) — MVP V1.2

**Sprint Goal :** boucle complète scan → décision → ordre paper avec garde-fous.

| Issue | Epic | Estim |
|---|---|---|
| US-D1 Stop-loss adaptatif | D | M |
| US-D2 Trailing stop | D | M |
| US-D3 Kill-switch automatique | D | L |
| US-D4 Limites exposition | D | M |
| US-C1 Exécution ordres IBKR paper | C | L |
| US-C3 Limit vs market selon spread | C | M |

**Livrables :** boucle complète opérationnelle en paper trading.
**KPI :** 0 violation garde-fous, kill-switch testé.
**Risques :** bugs exécution → tests intégration broker prioritaires.

---

## Sprint 4 — Notifications + Sécurité durcie (Epics E + F) — MVP V1.3 = MVP livré

**Sprint Goal :** MVP complet livrable avec notifications et sécurité validée.

| Issue | Epic | Estim |
|---|---|---|
| US-E1 Notifications email + Telegram | E | M |
| US-F1 Chiffrement API keys | F | M |
| US-F2 Double validation paper→live | F | M |
| US-F3 Audit log complet | F | M |
| Pen-test interne checklist OWASP | security | M |
| Documentation utilisateur finale | docs | M |

**Livrables :** **MVP V1 complet en paper trading**.
**KPI :** 0 vulnérabilité critique, 100 % notifications délivrées.
**Validation finale :** revue sécurité + revue produit + go/no-go bascule réel.

---

## Sprint 5 — Backtest minimal + bascule réel (Epic G)

| Issue | Epic | Estim |
|---|---|---|
| US-G1 Backtest stratégie momentum | G | L |
| Bascule live (capital réel 1000 €) | tech | M |
| Monitoring renforcé J+1 à J+30 | ops | M |

**Livrables :** **passage en live contrôlé**.

---

## V2 — Enrichissement (post-MVP)

- Sentiment news avancé
- Backtesting multi-stratégies + walk-forward
- Mean reversion + volatility exploit complets
- Module fiscalité (PEA, CTO)
- Optimisation frais (regroupement ordres)

## V3 — Industrialisation avancée

- Self-learning / RL
- Multi-broker (Trade Republic, Saxo)
- App mobile (React Native)
- Marketplace de stratégies

---

## Format de chaque sprint

Chaque sprint doit produire :

- **Sprint Goal** — phrase unique, mesurable.
- **Issues liées** — toutes labellisées et estimées.
- **Livrables** — démontrables.
- **KPI sprint** — quantifiables.
- **Risques identifiés** — + mitigations.
- **Validation finale** — Sprint Review + Retro documentées.
