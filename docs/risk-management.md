# Risk Management — Garde-fous trading

> Document **non négociable**. Toute évolution des seuils doit passer par une décision tracée dans `decision-log.md`.

---

## 1. Garde-fous capital

| Règle | Valeur MVP | Justification |
|---|---|---|
| Capital initial fixe | 1 000 € | Cadre du projet personnel |
| Drawdown toléré max | -50 % | Tolérance utilisateur explicite |
| Cash floor minimum | 0 € (aucun) | Allocation 20–100 % autorisée |
| Cash autorisé | 0–80 % | Defensive cash mode possible |

---

## 2. Garde-fous position

| Règle | Valeur MVP |
|---|---|
| Exposition max **par titre** | **25 %** du capital |
| Exposition max **par secteur** | **40 %** du capital |
| Nombre max positions ouvertes | 8 |
| Position size minimum | 50 € (éviter dilution frais) |

---

## 3. Garde-fous ordre

| Règle | Valeur MVP |
|---|---|
| Stop-loss initial | **5 % à 12 % adaptatif** (volatilité-dépendant) |
| Trailing stop | activable, pas de seuil (X % du plus haut) |
| Take-profit | optionnel, défini par stratégie |
| Type d'ordre | Market si spread < 0.3 %, sinon Limit |
| Slippage max accepté | 0.5 % vs prix décision |

---

## 4. Kill-switch (arrêt automatique)

Conditions déclenchant arrêt total + notification immédiate :

| Condition | Seuil MVP |
|---|---|
| Perte journalière | > **5 %** du capital |
| 3 erreurs broker consécutives | oui |
| Volatilité indice extrême (VSTOXX) | > seuil configurable |
| Anomalie data feed (>3 sources KO) | oui |
| Latence broker > 30 s | oui |
| Désynchronisation positions DB ↔ broker | oui |

**Effet kill-switch :**
1. Annulation tous les ordres pendants.
2. Arrêt scanner et strategy selector.
3. Notification email + Telegram **P0**.
4. Audit log entrée + dashboard banner rouge.
5. Réactivation = manuelle uniquement (double validation).

---

## 5. Garde-fous opérationnels

- **Surtrading :** alerte si > 20 ordres/jour ou > 100/mois.
- **Frais cumulés :** alerte si frais > 2 % du capital sur le mois en cours.
- **Cash idle :** alerte si > 80 % cash sur 5 jours consécutifs.
- **Cohérence prix :** rejet ordre si prix scan vs prix exécution diverge > 1 %.

---

## 6. Bascule paper → live

Procédure obligatoire :

1. Tous les sprints MVP livrés et verts.
2. Minimum **30 jours** en paper sans incident bloquant.
3. Revue checklist sécurité OWASP complète.
4. Double validation utilisateur (mot de passe + code OTP).
5. Capital initial limité à **500 €** la première semaine en réel.
6. Revue J+7, J+30 obligatoire avec décision tracée.

---

## 7. Revue mensuelle des risques

À J+30, J+60, J+90, puis trimestriel :

- Drawdown réalisé
- Frais cumulés
- Hit rate et profit factor
- Incidents kill-switch
- Décisions IA contestables (échantillon)
- Ajustement seuils si justifié → décision tracée

---

## 8. Risques résiduels acceptés

- **Risque marché** : pertes structurelles non couvertes.
- **Risque modèle** : sous-performance IA vs benchmark.
- **Risque broker** : indisponibilité IBKR.
- **Risque data** : qualité feeds gratuits inférieure au payant.
- **Risque fiscal** : non géré en MVP, traitement manuel.
