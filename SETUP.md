# The Grind — setup

A multi-player LeetCode tracker that syncs live between everyone's laptops through a free
Supabase database. Add as many people as you want; it ranks them on a live leaderboard.

Files here:
- `index.html` — the app
- `schema.sql` — database setup (copy-paste)
- `SETUP.md` — this file

There are two one-time jobs: **A) connect the database** (required), and **B) put it on a
URL** so everyone just clicks a link (recommended). Both need *your own* free accounts —
nobody can create those for you — but each takes about 2 minutes.

---

## A. Connect the database (~2 min)

### 1. Create a free Supabase project
1. **https://supabase.com** → sign in → **New project**.
2. Name it (e.g. `the-grind`), set any database password, pick a nearby region.
3. Wait ~1 minute for provisioning.

### 2. Create the tables
1. Open **SQL Editor** → **New query**.
2. Copy everything in `schema.sql`, paste, click **Run**. You should see “Success.”

### 3. Paste your keys into the app
1. **Project Settings → API**. Copy the **Project URL** and the **anon public** key.
2. Open `index.html` in a text editor, find the `CONFIG` block near the top of the script:
   ```js
   var CONFIG = {
     url:     "https://YOUR-PROJECT-REF.supabase.co",
     anonKey: "YOUR-PUBLIC-ANON-KEY"
   };
   ```
   Replace the two placeholders. Save.

### 4. Open it and build your crew
- Double-click `index.html` (or use the hosted URL from part B). Enter a room code — make one
  up, e.g. `squad-grind` — and hit **Enter the grind**. Green dot = synced.
- Click **+ Add person** once per teammate (add all four of you). Rename anyone by clicking
  their name on their card.
- Log a solve — it appears on everyone's screen within a second. 🎉

> Adding/removing people and everything else syncs live. Removing a person also removes their
> solves. **Clear solves** wipes solves but keeps the people. **Export** saves a JSON backup.

---

## B. Put it on a URL (recommended)

So nobody has to pass a file around — everyone opens the same link. Pick one:

### Option 1 — Cloudflare Pages (no terminal, easiest)
1. **https://dash.cloudflare.com** → sign up (free) → **Workers & Pages** → **Create** →
   **Pages** → **Upload assets**.
2. Drag this whole `leetcode-grind` folder in → **Deploy**.
3. You get a URL like `the-grind.pages.dev`. Share it with the group. Done.
   (To update later, re-upload the folder.)

*Netlify works the same way: **https://app.netlify.com/drop** → drag the folder in.*

### Option 2 — GitHub Pages (uses git; I've pre-committed the repo)
This folder is already a git repo with a commit ready to go.
1. Create a new **empty** repo on **https://github.com/new** (e.g. `the-grind`). Don't add a
   README.
2. Back in this folder, connect and push (swap in your username):
   ```sh
   git remote add origin https://github.com/YOUR-USERNAME/the-grind.git
   git push -u origin main
   ```
3. On GitHub: repo **Settings → Pages** → Source: **Deploy from a branch** → Branch: **main**
   / **/(root)** → Save. Your link appears in a minute at
   `https://YOUR-USERNAME.github.io/the-grind/`.

> Heads up: hosting publishes your Supabase **anon key** in the page (that's normal for
> front-end apps). Combined with the open access policy, a technical person who has the URL
> could read *any* room's data, not just yours. For a LeetCode tracker that's fine — just
> don't reuse this project for anything sensitive. Want real per-account privacy later? Ask me
> to add Supabase magic-link login.

---

## How it works
- Each solve is a row in `grind_solves` tagged with a `room` code and a `player_id`.
- People live in `grind_players`. The app subscribes to changes for your room over a
  websocket, so any add / delete / rename / new-person shows up everywhere instantly.
- Points: Easy 1, Medium 3, Hard 5. Streak = consecutive days with ≥1 solve. Cards are ranked
  by score, 👑 marks the leader.

## Troubleshooting
| Symptom | Fix |
|---|---|
| “Almost there” screen | Keys not pasted into `CONFIG` yet (A-3). |
| “Couldn't reach the database” | URL/key wrong, or you skipped the SQL (A-2). |
| Dot stays red / “Reconnecting” | Re-run `schema.sql` (enables realtime); or use the hosted URL. |
| A teammate's change didn't appear | Re-run `schema.sql` — the `replica identity full` lines make deletes propagate. |
| Can't add a person / insert fails | Re-run `schema.sql` — the grants + policies allow it. |
| “Couldn't save the LeetCode username” | Re-run `schema.sql` — it adds the optional `leetcode_username` / `lc_stats` / `lc_synced_at` columns that LeetCode sync writes to. |
| “Couldn't set admin” / roles do nothing | Re-run `schema.sql` — it adds the `grind_rooms` table that holds the admin passcode. |
