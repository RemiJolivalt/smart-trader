# Supabase — Infrastructure Smart Trader

## Projets

| Environnement | Projet Supabase | Région |
|---|---|---|
| Développement | `smart-trader-dev` | EU West (Ireland) |
| Production | `smart-trader-prod` | EU West (Ireland) |

---

## Distribution des secrets

> **Règle absolue** : aucune clé en clair dans le repo. Les valeurs ci-dessous sont à récupérer dans le dashboard Supabase (Settings → API).

| Secret | Dev | Prod |
|---|---|---|
| `SUPABASE_URL` | Render env var + GitHub Secret `SUPABASE_URL_DEV` | Render env var + GitHub Secret `SUPABASE_URL_PROD` |
| `SUPABASE_ANON_KEY` | Vercel env var (preview) | Vercel env var (production) |
| `SUPABASE_SERVICE_ROLE_KEY` | Render env var uniquement | Render env var uniquement |

⚠ La `service_role` key ne doit **jamais** aller côté frontend ni dans les logs.

---

## Migrations

- Répertoire : `infra/supabase/migrations/`
- Convention de nommage : `<timestamp_utc>_<description_courte>.sql`
  - Exemple : `20260511120000_init_schema.sql`
- Appliquer via la CLI Supabase :

```bash
# Installer la CLI Supabase
npm install -g supabase

# Lier au projet dev
supabase link --project-ref <project-ref-dev>

# Appliquer les migrations
supabase db push
```

- En CI/CD (Sprint 1+) : `supabase db push` dans un job dédié après les tests d'intégration.

---

## Configuration Auth (à faire manuellement dans le dashboard)

### Paramètres recommandés (Authentication → Settings)

| Paramètre | Valeur |
|---|---|
| JWT expiry | `3600` secondes (1h) |
| Enable email confirmations | `true` |
| Minimum password length | `12` |
| Enable MFA (TOTP) | `true` (recommandé) |
| Disable sign-ups | `false` (MVP : 1 seul user) |

### Providers activés

- Email/Password ✅
- Google, GitHub, etc. : désactivés pour le MVP

---

## RLS (Row Level Security)

Toutes les tables applicatives doivent avoir RLS **activé** avant toute migration.  
Pattern de policy systématique :

```sql
-- Activer RLS sur une table
ALTER TABLE public.<table> ENABLE ROW LEVEL SECURITY;

-- Policy de base : accès uniquement à ses propres données
CREATE POLICY "user_own_data" ON public.<table>
  FOR ALL USING (auth.uid() = user_id);
```

Les migrations Sprint 1 appliqueront ce pattern sur toutes les tables du schéma.

---

## Schéma cible (Sprint 1)

Tables à créer (cf. `docs/technical-spec.md` §3) :

| Table | RLS | Notes |
|---|---|---|
| `users` | ✅ | Profil étendu de `auth.users` |
| `accounts` | ✅ | Compte broker (paper/live) |
| `instruments` | ❌ | Table publique en lecture |
| `positions` | ✅ | Positions ouvertes/fermées |
| `orders` | ✅ | Historique ordres |
| `decisions` | ✅ | Décisions IA horodatées |
| `scans` | ✅ | Sessions de scan IA |
| `risk_settings` | ✅ | Garde-fous par compte |
| `audit_log` | ✅ | Immutable, insert-only |
| `notifications` | ✅ | Alertes envoyées |

---

## Checklist setup manuel (Sprint 0)

- [ ] Créer projet `smart-trader-dev` sur [supabase.com](https://supabase.com) (région EU West)
- [ ] Créer projet `smart-trader-prod` sur [supabase.com](https://supabase.com) (région EU West)
- [ ] Configurer Auth sur **dev** : JWT 1h, confirmation email, MFA TOTP
- [ ] Configurer Auth sur **prod** : idem + vérifier "Disable sign-ups" en prod après création du compte admin
- [ ] Récupérer `URL`, `anon key`, `service_role key` pour les deux projets
- [ ] Ajouter les secrets dans Render (backend dev/prod env vars)
- [ ] Ajouter `NEXT_PUBLIC_SUPABASE_URL` + `NEXT_PUBLIC_SUPABASE_ANON_KEY` dans Vercel (preview=dev, prod=prod)
- [ ] Ajouter `SUPABASE_URL` + `SUPABASE_SERVICE_ROLE_KEY` dans GitHub Encrypted Secrets (si jobs CI DB)
- [ ] Tester Auth : créer un compte de test, vérifier email, supprimer le compte
- [ ] Vérifier dans le dashboard que RLS est bien activé par défaut sur les nouvelles tables
