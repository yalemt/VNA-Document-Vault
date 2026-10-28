# VNA Document Vault
Secure cloud document system for the **Veterans of the Nation Association**: store, retrieve, upload, download, edit and organise records, with member login and a private file store.

## Architecture
```
Browser (index.html, static)  ──HTTPS──▶  Supabase (free plan)
 GitHub Pages hosts it                    ├─ Auth      member sign-in
                                          ├─ Postgres  documents + members tables (Row Level Security)
                                          └─ Storage   private bucket "vault" (signed, expiring links)
```
The page is plain HTML/JS with no build step. All access rules are enforced by the database, not by the page.

## Recommended free private storage: Supabase
| Need | Supabase free plan (checked mid-2026) |
|---|---|
| Private files + login + database in one | Yes: Auth, Postgres and Storage included |
| File storage | 1 GB, 20 MB per file as configured here |
| Database | 500 MB |
| Bandwidth | 5 GB/month |
| Members | up to 50,000 monthly active users |
| Catch | Project pauses after 7 days of inactivity; `keepalive.yml` pings it twice a week, and a paused project can be restored from the dashboard without data loss |

Limits change, so confirm at supabase.com/pricing before relying on them. 1 GB holds roughly 1,000+ typical scanned PDFs; when you outgrow it, the Pro plan is $25/month.
Alternatives to consider (figures from memory, verify first): Cloudflare R2 and Backblaze B2 both advertise about 10 GB free for files but need separate login/database code; Google Drive/OneDrive suit teams already using them but need OAuth integration work.

## Setup (about 20 minutes)
1. **Supabase:** create a free account and a new project (choose a strong database password and a region near your users). 
2. **Schema:** Project > SQL Editor > paste `supabase/schema.sql` > Run.
3. **First user:** Authentication > Users > *Add user* (email + password, tick auto-confirm). Copy the user's UUID, then run in SQL Editor:
   `insert into public.members(user_id,role) values ('UUID','admin');`
4. **Lock sign-ups:** Authentication > Sign In / Providers > turn **off** "Allow new users to sign up". Add each member yourself (step 3, role `member`).
5. **Keys:** Project Settings > API: copy *Project URL* and the *anon public* key.
6. **Run locally:** copy `config.example.js` to `config.js`, fill in the two values, and open `index.html` through a local server (`python3 -m http.server`).
7. **GitHub:** create a repository, push these files (`config.js` is git-ignored).
   Repo > Settings > Secrets and variables > Actions: add `SUPABASE_URL` and `SUPABASE_ANON_KEY`.
   Repo > Settings > Pages > Source: **GitHub Actions**. Push to `main`; the site deploys to `https://<user>.github.io/<repo>/`.
   GitHub Pages from a *private* repository needs a paid GitHub plan, so use a public repository. That is safe here because the repository holds no secrets or documents.

## Roles
* **member:** view, upload, download, edit details and notes.
* **admin:** everything above plus delete files and manage members.

## Security checklist
* Never commit the `service_role` key; only the anon key belongs in `config.js`.
* Keep sign-ups disabled; use strong passwords and enable MFA on Supabase and GitHub accounts.
* Files are private: the page uses signed links that expire in 5 minutes.
* Backups: use *Export index (JSON)* regularly and periodically download the bucket (Storage > vault) to an offline drive. Do not rely on one free project as the only copy of important records.
* Do not upload anything sensitive (ID numbers, medical records) without agreeing a data-protection policy for members first.

## Customising
* Categories: edit the `CATS` array in `index.html`.
* Upload size: change `file_size_limit` in `schema.sql` (free plan global cap applies).
* Rename: change the header text and `assets/logo.png`.

## Integrating other clouds later
Keep Supabase as the system of record and add a scheduled GitHub Action that copies new files to Google Drive, OneDrive or S3 using that provider's API with its credentials stored as GitHub Secrets.

## Files
`index.html` app · `config.example.js` settings template · `supabase/schema.sql` database + security rules · `.github/workflows/deploy.yml` publish to Pages · `.github/workflows/keepalive.yml` stop free-plan pausing · `assets/logo.png` logo
