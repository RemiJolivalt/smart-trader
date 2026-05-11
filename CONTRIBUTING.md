# Contribuer à Smart Trader

Merci de respecter strictement ce guide. Toute PR non conforme sera refusée.

---

## 1. Règles d'or (humains & IA)

1. **Aucun développement sans spécification préalable.**
2. **Chaque feature est liée à une User Story** GitHub.
3. **Chaque code respecte l'architecture et les conventions** ([ARCHITECTURE.md](ARCHITECTURE.md), [docs/technical-spec.md](docs/technical-spec.md)).
4. **Aucune implémentation sans critères d'acceptation** validés.
5. **Priorité absolue : MVP, coût faible, sécurité forte.**
6. **Toute décision structurante est tracée** dans [docs/decision-log.md](docs/decision-log.md).

---

## 2. Workflow Git

### Branches
- `main` — production, protégée.
- `develop` — intégration continue.
- `feature/<id>-slug` — nouvelle fonctionnalité (basé sur `develop`).
- `fix/<id>-slug` — correctif (basé sur `develop`).
- `hotfix/<id>-slug` — correctif critique prod (basé sur `main`, back-merge dans `develop`).

### Commits — Conventional Commits
Format : `<type>(<scope>): <résumé impératif>`

Types : `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `build`, `perf`, `security`.

Exemples :
- `feat(agents): ajout strategy selector momentum`
- `fix(broker): gestion timeout IBKR`
- `security(auth): rotation policy api keys`

### Pull Requests
- 1 PR = 1 issue (User Story / Bug / Tech Task).
- Template `.github/PULL_REQUEST_TEMPLATE.md` rempli intégralement.
- CI verte obligatoire (lint + tests + build + sécu).
- ≥ 1 reviewer (CODEOWNERS si zone critique).
- Merge **squash** sur `develop`, **merge commit** sur `main`.
- Pas de `--no-verify`, pas de `--force` sur branches partagées.

### Hooks locaux (pre-commit)

Installation une seule fois :

```bash
pip install pre-commit
pre-commit install
```

Les hooks s'exécutent automatiquement à chaque `git commit` :
- **gitleaks** — détection de secrets
- **pre-commit-hooks** — fin de fichier, whitespace, fichiers lourds, détection de clés privées
- **ruff** — lint + format Python (backend)
- **prettier** — format TypeScript/JSON/CSS (frontend)

> Ne jamais bypasser avec `--no-verify` sauf cas exceptionnel documenté dans la PR.

---

## 3. Standards de code

### Principes
- **Nommage clair** : variables, fonctions, fichiers explicites.
- **Commentaires utiles** : pourquoi, pas quoi.
- **Modularité** : fonctions courtes (< 50 lignes idéalement).
- **Séparation des responsabilités** : domaine ≠ infra ≠ API.
- **Sécurité par défaut** : valider les entrées, jamais de secret en clair.

### Backend (Python)
- Python 3.11+, typage strict (`mypy --strict` recommandé).
- Format : **Ruff format** (line length 100).
- Lint : **Ruff** + **Bandit** (sécu).
- Tests : **pytest** + `pytest-asyncio`.
- Imports triés (`ruff isort`).

### Frontend (TypeScript)
- TypeScript strict (`strict: true`).
- Format : **Prettier**.
- Lint : **ESLint** (config Next.js + `@typescript-eslint/strict`).
- Tests : **Vitest** + **Playwright** (E2E).
- Composants accessibles (ARIA basiques).

---

## 4. Checklist qualité (avant de pousser)

- [ ] Code formaté (`pnpm format`, `uv run ruff format`)
- [ ] Lint propre (`pnpm lint`, `uv run ruff check`)
- [ ] Tests unitaires écrits + verts
- [ ] Couverture non régressée
- [ ] Aucun secret commité (vérifier `.env` ignorés)
- [ ] Logs / observabilité ajoutés si pertinent
- [ ] Documentation mise à jour
- [ ] ADR si décision structurante
- [ ] Issue liée à la PR

---

## 5. Conventions documentation

- Markdown propre, titres hiérarchisés, exemples de code.
- Liens relatifs uniquement.
- Tout changement de structure projet → mise à jour `README.md` + `ARCHITECTURE.md`.

---

## 6. Gestion des secrets

- **Jamais** de secret dans le repo.
- `.env.example` versionnés, `.env` ignorés.
- Voir [SECURITY.md](SECURITY.md) pour la matrice complète.

---

## 7. Code de conduite

Respect, bienveillance, focus produit. Critique du code, pas de la personne.
