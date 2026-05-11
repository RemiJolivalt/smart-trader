# Specification Fonctionnelle — Smart Trader

## 1. Besoin métier

Disposer d'un agent autonome capable de gérer un capital personnel de **1 000 €** sur les marchés actions européens, avec une stratégie agressive mais disciplinée, sans intervention manuelle quotidienne.

### Contexte
- Utilisateur : investisseur particulier unique (mode mono-utilisateur).
- Capital : 1 000 € fixe (réinvestissement possible mais pas d'apport régulier).
- Tolérance au risque : forte (drawdown jusqu'à -50 % accepté).
- Objectif : maximiser le rendement ajusté au risque, minimiser les frais.

---

## 2. Personas

### P1 — L'opérateur (utilisateur unique)
- **Besoin :** déléguer toutes les décisions, garder le contrôle via dashboard et kill-switch.
- **Comportement :** consulte le dashboard 1 à 3 fois/jour, reçoit des notifications critiques.
- **Frustrations :** pertes inexpliquées, frais excessifs, surtrading.

---

## 3. User Stories MVP

> Toutes les US suivent le format défini dans `.github/ISSUE_TEMPLATE/user-story.md`.

### Epic A — Capital & Portefeuille
- **US-A1** : En tant qu'opérateur, je veux voir la valeur totale de mon portefeuille en temps quasi-réel.
- **US-A2** : Je veux visualiser le P&L journalier, hebdo, total.
- **US-A3** : Je veux voir les positions ouvertes (titre, quantité, PRU, valorisation, P&L latent).
- **US-A4** : Je veux voir le cash disponible et le % cash idle.

### Epic B — Décisions IA
- **US-B1** : Je veux que le système scanne le marché toutes les heures pendant les heures d'ouverture Euronext.
- **US-B2** : Je veux qu'une stratégie soit sélectionnée dynamiquement (momentum / mean reversion / defensive / volatility).
- **US-B3** : Je veux une explication en langage naturel pour chaque décision (achat, vente, hold).
- **US-B4** : Je veux consulter l'historique complet des décisions IA.

### Epic C — Exécution Broker
- **US-C1** : Je veux que les ordres soient passés automatiquement via IBKR.
- **US-C2** : Je veux pouvoir basculer entre paper trading et compte réel.
- **US-C3** : Je veux qu'un ordre limite soit utilisé si le spread dépasse un seuil configurable.

### Epic D — Risk Management
- **US-D1** : Je veux un stop-loss adaptatif (5–12 %) sur chaque position.
- **US-D2** : Je veux un trailing stop activable.
- **US-D3** : Je veux un kill-switch automatique : perte journalière > X %, anomalie API, volatilité extrême.
- **US-D4** : Je veux respecter les limites d'exposition : max 25 % par titre, 40 % par secteur.

### Epic E — Notifications
- **US-E1** : Je veux recevoir une notification (email + Telegram) pour : achat, vente, stop-loss, kill-switch, erreur broker.

### Epic F — Sécurité & Configuration
- **US-F1** : Je veux que mes API keys soient chiffrées et jamais exposées au front.
- **US-F2** : Je veux une double validation pour la configuration initiale (passage paper → réel).
- **US-F3** : Je veux un journal d'audit complet de toutes les actions sensibles.

### Epic G — Backtest (V1 minimal)
- **US-G1** : Je veux pouvoir backtester une stratégie sur l'historique gratuit disponible.

---

## 4. Parcours utilisateur clé (Happy path)

1. Connexion via Supabase Auth.
2. Dashboard : portefeuille, P&L, positions, dernière décision IA.
3. Notification reçue : "ACHAT TotalEnergies — momentum breakout confirmé."
4. Consultation logs IA → justification détaillée.
5. Vérification garde-fous risque (paramètres).
6. (Optionnel) activation kill-switch manuel si décision contestée.

---

## 5. KPI

### Business
- **Rendement net mensuel / annuel** (après frais)
- **Sharpe ratio**
- **Max drawdown** réalisé vs toléré
- **Profit factor** (gains bruts / pertes brutes)
- **Win rate**

### Opérationnels
- **Frais cumulés** (€ et % du capital)
- **Taux de cash idle** moyen
- **Nombre d'ordres / mois** (surveillance surtrading)
- **Latence décision → exécution**
- **Uptime scanner** (% scans réussis sur scans planifiés)
- **MTBF / MTTR** des kill-switches

### Qualité IA
- **Hit rate** des décisions IA (achat suivi de gain à H+24h, H+5j)
- **Taux d'explication générée** (= 100 % requis)

---

## 6. Hors scope MVP

- ETF, options, CFD, crypto, dérivés
- Multi-utilisateurs
- Mobile native
- Sentiment news avancé (V2)
- Reinforcement learning (V3)
- Fiscalité automatisée (V2)

---

## 7. Contraintes fonctionnelles

- **Mono-utilisateur** mais architecture multi-tenant ready.
- **Heures de marché** Euronext respectées (pas de scan hors session).
- **Latence** : décision → ordre < 5 s en conditions normales.
- **Disponibilité** : 99 % pendant heures d'ouverture marché.
