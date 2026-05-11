# GitHub Projects — Configuration recommandée

> Configuration manuelle dans l'interface GitHub Projects (board v2).

## Nom
`Smart Trader — Delivery`

## Vues
- **Board** (par statut)
- **Roadmap** (vue temporelle par sprint)
- **Backlog** (table priorisée)

## Colonnes (statuts)

1. **Backlog** — Idées validées, non planifiées.
2. **Sprint courant** — Sélection du sprint actif.
3. **In Progress** — En cours, 1 par contributeur idéalement.
4. **Review** — En revue PR / validation acceptance.
5. **Done** — Mergé, déployé, accepté.
6. **Blocked** — Bloqué (dépendance, décision, externe).

## Champs personnalisés

| Champ | Type | Valeurs |
|---|---|---|
| Priority | Single select | high / medium / low |
| Sprint | Iteration | Sprint 0, 1, 2, ... |
| Estimate | Single select | XS, S, M, L, XL |
| Epic | Single select | A Capital, B IA, C Exécution, D Risk, E Notif, F Sécurité, G Backtest |
| Risk level | Single select | low / medium / high / critical |

## Règles d'automatisation

- Issue créée → ajoutée à **Backlog**.
- PR ouverte référençant issue → l'issue passe à **Review**.
- PR mergée → issue passe à **Done**.
- Label `blocked` ajouté → colonne **Blocked**.

## Définition d'une issue prête pour Sprint courant

- [ ] Critères d'acceptation rédigés
- [ ] Estimation posée
- [ ] Priorité posée
- [ ] Dépendances identifiées
- [ ] Risques évalués
