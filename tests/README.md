# Tests globaux — stratégie qualité

> Les tests **unitaires** vivent dans `frontend/tests` et `backend/tests`.
> Ce dossier accueille les tests **transverses** : E2E, contrats API, qualité, charge.

## Structure cible
```
tests/
├── e2e/            # Playwright — parcours utilisateur
├── contracts/      # schemathesis vs OpenAPI backend
├── load/           # k6 / Locust (post-MVP)
└── README.md
```

## Stratégie qualité

| Niveau | Outil | Bloquant CI | Couverture |
|---|---|---|---|
| Unit backend | pytest | ✅ | ≥ 80 % |
| Unit frontend | vitest | ✅ | ≥ 70 % |
| Intégration backend | pytest + httpx | ✅ | scénarios critiques |
| Contract | schemathesis | ⚠️ warning MVP | toutes routes |
| E2E | Playwright | ✅ scénarios MVP | dashboard + kill-switch |
| Sécu | gitleaks, bandit, audit | ✅ | dépendances + secrets |
| Charge | k6 | non bloquant | post-MVP |

## Règles
- Aucun test commenté ou skipé sans issue traçant la dette.
- Données de test isolées (pas de prod).
- Pas d'appels broker réels en CI (mock IBKR).
