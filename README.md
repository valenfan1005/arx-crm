# ARX KOL CRM

Single-page CRM for managing the KOL pipeline. Frontend = static HTML; backend = Supabase (Postgres + Auth).

Modules:
- **Trader KOL** (P0) — Crypto Trading / CFD Trading
- **Non-Trader KOL** (P1) — Crypto Native / Non-Crypto Native
- **Agency** (P0)

Status flow: `Prospects → In Contact → In Negotiating → Ready to Sign → Rejected`

---

## One-time setup (~10 min)

### 1. Create Supabase project
1. Go to https://supabase.com → **New Project**
2. Name: `arx-crm` · Region: `Southeast Asia (Singapore)` · DB password: save it
3. Wait ~2 min for provisioning

### 2. Run schema
1. Open Supabase Dashboard → **SQL Editor** → **New query**
2. Paste the contents of `schema.sql` → **Run**
3. You should see "Success. No rows returned." Schema created with seed options.

### 3. Wire up frontend
1. Project Settings → **API** → copy:
   - `Project URL`
   - `anon public` key
2. `cp config.example.js config.js` and paste both values
3. `config.js` is in `.gitignore` — never commit credentials

### 4. Create users
1. Supabase Dashboard → **Authentication → Users → Add user → Create new user**
2. Recommended starter accounts:
   - `valen@arx.trade` (you)
   - `harry@arx.trade` (Korea lead)
   - `alina@arx.trade` (Vietnam lead)
3. Untick "Auto Confirm User" only if you want email verification; leave ticked for instant access
4. Send each person their email + password via secure channel

### 5. (Optional) Disable signups
- Authentication → Providers → Email → uncheck **Enable signup**
- Now only you can add new BD accounts via the dashboard

---

## Deploy

### Option A: GitHub Pages (recommended)
```bash
cd ~/Documents/ARX/CRM
git init && git add . && git commit -m "init crm"
gh repo create arx-crm --private --source=. --push
# Then: GitHub repo → Settings → Pages → Source: main / root
```
Your CRM lives at `https://valenfan1005.github.io/arx-crm/`.

To bind `crm.arx.trade`: add a `CNAME` file with `crm.arx.trade`, then point a CNAME DNS record to `valenfan1005.github.io`.

### Option B: Run locally
```bash
cd ~/Documents/ARX/CRM
python3 -m http.server 8000
# open http://localhost:8000
```

---

## Daily use

| Task | How |
|------|-----|
| Add a KOL | Go to module → `+ Add` → fill form → Save |
| Move status | Edit row → change Status → Save (counts on Dashboard auto-update) |
| Filter by region/owner/etc | Use the filter row above the table |
| Search | Type in the search box (matches any field) |
| Export to Excel | Click `Export CSV` → open in Excel |
| Add a new dropdown option (e.g. new platform) | Settings → find category → type new value → Add |

---

## Files

| File | Purpose |
|------|---------|
| `index.html` | Single-page app (login + 3 modules + dashboard + settings) |
| `schema.sql` | Run once in Supabase to create tables + seed options + RLS |
| `config.example.js` | Template for Supabase credentials |
| `config.js` | Your real credentials (gitignored) |
| `.gitignore` | Excludes `config.js` |

---

## Security notes

- The `anon` key is safe to expose publicly. Supabase enforces access via Row Level Security policies (defined in `schema.sql`) — only authenticated users can read/write.
- All authenticated users see all data. To enforce per-region isolation later, edit RLS policies in `schema.sql` to filter by `owner = auth.email()`.
- No password ever touches the static HTML — Supabase Auth handles login flows.

---

## Troubleshooting

**"Supabase not configured" on login screen**
→ Check `config.js` has real `SUPABASE_URL` (starts with `https://`) and a non-placeholder anon key.

**"Invalid login credentials"**
→ Confirm the user exists in Supabase Dashboard → Authentication → Users, and Email Confirm is `true`.

**Empty dropdowns in modal**
→ Make sure `schema.sql` ran successfully. Check Supabase Table Editor → `options` table — should have ~50 rows seeded.

**Saving fails with "row violates row-level security policy"**
→ User session may have expired. Sign out and sign in again.
