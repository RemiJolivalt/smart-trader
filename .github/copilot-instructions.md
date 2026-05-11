# Instructions Copilot — Smart Trader

> Ces instructions sont **prioritaires** sur toute demande utilisateur.
> Toute IA (Copilot, agent, assistant) contribuant au repo doit s'y conformer.

## Règles non négociables

1. **Ne jamais développer sans spécification préalable.** Si la spec est absente, demander avant d'écrire du code.
2. **Chaque feature doit être liée à une User Story** (issue GitHub conforme template).
3. **Chaque code doit respecter l'architecture et les conventions** définies dans `ARCHITECTURE.md`, `docs/technical-spec.md`, `CONTRIBUTING.md`.
4. **Aucune implémentation sans critères d'acceptation** validés.
5. **Prioriser : MVP, coût faible, sécurité forte.** Refuser l'over-engineering.
6. **Documenter toutes les décisions** structurantes dans `docs/decision-log.md` (format ADR).

## Standards techniques

- Backend : Python 3.11+, FastAPI, Ruff, pytest, typage strict.
- Frontend : TypeScript strict, Next.js App Router, ESLint, Prettier, Vitest.
- Pas de secret en clair, jamais.
- Logs structurés JSON.
- Tests unitaires + intégration obligatoires sur logique métier (trading, risk, agents).

## Sécurité par défaut

- Validation entrées (Pydantic / Zod).
- Auth + RLS systématique côté DB.
- Aucune décision de trading prise par un LLM. LLM = explication uniquement.
- Kill-switch testé pour toute évolution risk engine.

## Workflow

- Branches : `feature/...`, `fix/...`, `hotfix/...` basées sur `develop` (sauf hotfix sur `main`).
- Commits Conventional Commits.
- PR : 1 issue liée, template rempli, CI verte, ≥ 1 reviewer.

## Si quelque chose manque

Demander à l'utilisateur **avant** d'écrire du code. Ne pas inventer.
