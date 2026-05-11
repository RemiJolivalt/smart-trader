# Sécurité — Smart Trader

> Document opposable. Toute modification = ADR + revue dédiée.

---

## 1. Politique de divulgation responsable

Découverte d'une vulnérabilité ? Contact privé : *(à définir — email dédié)*. **Ne pas ouvrir d'issue publique.**

---

## 2. Gestion des secrets

### Stockage
| Type secret | Stockage | Rotation |
|---|---|---|
| API keys IBKR | DB Supabase, chiffrées AES-GCM (clé KMS env) | 90 jours |
| Supabase service role | Render/Fly env vars | 180 jours |
| Tokens Telegram / SMTP | Render/Fly env vars | 180 jours |
| GitHub Actions | GitHub Encrypted Secrets | 180 jours |
| Vercel | Vercel Env Vars (prod/preview/dev distincts) | 180 jours |

### Règles
- **Aucun secret en clair** dans le repo (`gitleaks` en CI, bloquant).
- Fichiers `.env` dans `.gitignore`. Seuls `.env.example` sont versionnés.
- Pas de secret dans les logs (filtres applicatifs).
- Pas de secret dans les URLs / query strings.
- Audit trimestriel des accès.

---

## 3. API keys broker

- Stockage **chiffré applicatif** (AES-GCM, IV unique, clé maître hors DB).
- Permissions IBKR au strict minimum (trading, lecture). Pas de retrait fonds.
- IP allowlist côté broker si possible.
- Mode **paper** par défaut. Bascule live = double validation + capital plafonné 7 jours.
- Rotation tous les 90 jours, traçée dans `decision-log.md`.

---

## 4. Accès cloud

| Service | MFA | Rôle minimum | Audit |
|---|---|---|---|
| GitHub | obligatoire | dev/admin séparés | logs activés |
| Vercel | obligatoire | viewer/dev/admin | logs |
| Supabase | obligatoire | service_role réservé backend | logs |
| Render/Fly | obligatoire | déploiement séparé de admin | logs |
| IBKR | obligatoire | API key dédiée | logs broker |

---

## 5. Authentification & autorisation utilisateur

- Supabase Auth + RLS Postgres systématique.
- MFA recommandé.
- Rate limit sur endpoints d'auth.
- Session JWT courte durée + refresh.
- Pas de cookies tiers, `SameSite=Lax` minimum.

---

## 6. Sécurité applicative (OWASP Top 10 — mapping)

| OWASP | Mesure |
|---|---|
| A01 Access Control | RLS, vérif `auth.uid()`, tests d'autorisation par endpoint |
| A02 Crypto | TLS 1.2+, AES-GCM secrets, hashing bcrypt/argon2 si applicable |
| A03 Injection | ORM SQLAlchemy, validation Pydantic, pas de string concat SQL |
| A04 Insecure Design | revue archi + ADR + threat modeling léger |
| A05 Misconfig | CSP stricte, headers sécu (HSTS, X-Content-Type-Options...), gitleaks |
| A06 Vulnerable Components | Dependabot weekly, `pip-audit`, `pnpm audit`, `bandit` |
| A07 Auth Failures | MFA, lockout, rate limit |
| A08 Data Integrity | signatures webhooks, vérif checksums broker, audit_log |
| A09 Logging Failures | logs structurés, alerting Sentry, conservation 90 j |
| A10 SSRF | whitelist URLs sortantes (data feeds), pas d'URL utilisateur |

---

## 7. Monitoring & audit

- **`audit_log`** Postgres : kill-switch, bascule mode, modif risk_settings, ordres > seuil, accès admin.
- **Sentry** : erreurs back + front (alertes P0/P1).
- **BetterStack** : logs structurés, recherche, alertes.
- **UptimeRobot** : ping `/health` toutes les 5 min.
- **Notifications P0** (kill-switch, erreur broker) : email + Telegram immédiats.
- **Revue logs hebdomadaire** : checklist dans `scripts/ops-checklist.md` (à créer Sprint 0).

---

## 8. Sauvegardes

- Supabase backups quotidiens (free tier inclus, conservation 7 j).
- Export hebdo manuel (script) → stockage chiffré local (Sprint 4).
- Test restore trimestriel.

---

## 9. Réponse à incident

| Sévérité | Délai détection | Délai réaction |
|---|---|---|
| P0 (perte capital, sécu critique) | < 5 min | < 15 min |
| P1 (broker KO, kill-switch déclenché) | < 15 min | < 1 h |
| P2 (bug fonctionnel) | < 1 j | < 3 j |
| P3 (cosmétique) | best effort | sprint suivant |

Procédure :
1. Activer kill-switch si doute.
2. Snapshot logs + état DB.
3. Isoler la cause, corriger en hotfix si P0/P1.
4. Post-mortem documenté dans `docs/decision-log.md`.

---

## 10. Secrets & variables CI/CD

### GitHub Actions — secrets requis

| Secret | Utilisation | Scope | Quand |
|---|---|---|---|
| `VERCEL_TOKEN` | Déploiement preview Vercel (`preview-deploy.yml`) | Repo secret | Sprint 0 (step Vercel) |

**Ajouter un secret** : Settings → Secrets and variables → Actions → New repository secret.

### GitHub Actions — variables repo requis

| Variable | Valeur | Utilisation | Quand |
|---|---|---|---|
| `VERCEL_ENABLED` | `true` | Active le job `vercel-preview` dans `preview-deploy.yml` | Après setup Vercel (Sprint 0) |

**Ajouter une variable** : Settings → Secrets and variables → Actions → Variables → New repository variable.

### Résumé des workflows et leurs dépendances

| Workflow | Déclencheur | Secrets / Variables requis |
|---|---|---|
| `ci.yml` | push/PR sur `main`, `develop` | aucun |
| `preview-deploy.yml` | PR vers `main`, `develop` | `VERCEL_TOKEN` (secret) + `VERCEL_ENABLED=true` (variable) |
| `labels-sync.yml` | push sur `main` (si `infra/github/labels.yml` modifié) | `GITHUB_TOKEN` (automatique) |

> `ci.yml` utilise gitleaks CLI directement (pas de licence requise). `preview-deploy.yml` est inactif tant que `VERCEL_ENABLED` n'est pas positionné.

---

## 11. Conformité & vie privée

- Données personnelles minimales (email).
- Pas de revente, pas de tracking tiers.
- RGPD : droit à l'effacement = suppression compte Supabase + données associées.
