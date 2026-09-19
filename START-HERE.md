# START HERE — Getting these four projects onto GitHub

You have four folders. By the end of this guide each one is a live GitHub repository with a link you
can paste on your CV, and one of them is a running web app anyone can click.

Budget about **90 minutes** for the first repo and **10 minutes each** for the rest.

---

## Before anything else: one honest thing

Every dataset in these repos is **synthetic**, and every README says so out loud. Keep it that way.

The reason is practical, not moral. If a recruiter asks "where did this data come from?" and the
answer is a confident lie, the interview is over. If the answer is "it's generated — I wanted the
method to be reproducible and I couldn't share real data," that is a normal, respected answer that
most analysts give about their portfolio work.

The one thing you **must** do: read the code before you publish it. Every file here is commented and
none of it is exotic, but you need to be able to explain any line of it in an interview. If there's
something you don't follow, either learn it or delete it. A smaller repo you fully own beats a
bigger one you can't defend.

---

## Part 1 — One-time setup (do this once, ever)

### 1.1 Create a GitHub account

Go to [github.com/signup](https://github.com/signup).

**Pick your username carefully.** It becomes part of every link on your CV. Use your real name if
it's available: `github.com/priyasharma`, not `github.com/coder_xyz_2001`.

### 1.2 Install Git

| OS | How |
|---|---|
| Windows | Download from [git-scm.com/download/win](https://git-scm.com/download/win), accept every default |
| macOS | Open Terminal, type `git --version`, accept the install prompt |
| Linux | `sudo apt install git` |

Check it worked — open Terminal (macOS/Linux) or Git Bash (Windows) and run:

```bash
git --version
```

### 1.3 Tell Git who you are

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

Use the same email as your GitHub account, otherwise your commits won't show on your profile's
contribution graph.

### 1.4 Set up authentication

GitHub stopped accepting passwords in 2021. You need a **Personal Access Token**, which is just a
long password that Git uses instead.

1. Go to [github.com/settings/tokens](https://github.com/settings/tokens)
2. **Generate new token → Generate new token (classic)**
3. Note: `laptop`. Expiration: 90 days. Tick the **`repo`** checkbox.
4. **Generate token** → copy the string that appears

⚠️ **Copy it now.** GitHub never shows it again. Paste it into your password manager or a note.

The first time you push, Git asks for a username and password. Username = your GitHub username.
Password = **paste the token**, not your actual password. (You won't see characters appear as you
paste — that's normal, just press Enter.)

---

## Part 2 — Publishing your first repo

We'll do `sales-funnel-diagnostic` in full. The other three are identical.

### 2.1 Personalise the files first

Three small edits before publishing:

| File | Find | Replace with |
|---|---|---|
| `README.md` | `YOUR-USERNAME` | your GitHub username |
| `LICENSE` | `YOUR NAME` | your actual name |

In `README.md` the placeholder appears once, in the clone command. Use Find & Replace in any text
editor (VS Code, Notepad++, even Notepad).

### 2.2 Verify it runs

Never publish code you haven't run.

```bash
cd sales-funnel-diagnostic
pip install -r requirements.txt

python scripts/generate_data.py
python scripts/run_analysis.py
python scripts/make_charts.py
```

You should see `results/findings.md` regenerate and the charts rebuild. If something errors, fix it
before it's public.

### 2.3 Create the empty repo on GitHub

1. Click **+** (top right) → **New repository**
2. Repository name: `sales-funnel-diagnostic`
3. Description: `SQL funnel diagnostic across 1,300+ leads and 5 acquisition channels — window functions, conditional aggregation, SQLite`
4. **Public**
5. ⚠️ **Do NOT** tick "Add a README", "Add .gitignore", or "Choose a license" — you already have all three, and ticking them creates a conflict that is annoying to resolve on your first day
6. **Create repository**

### 2.4 Push your folder up

GitHub now shows you a page of commands. Ignore it and use these, run from inside your project
folder:

```bash
cd sales-funnel-diagnostic

git init                                      # turn the folder into a Git repo
git add .                                     # stage every file
git commit -m "Sales funnel and lead conversion diagnostic"
git branch -M main                            # name the branch 'main'
git remote add origin https://github.com/YOUR-USERNAME/sales-funnel-diagnostic.git
git push -u origin main                       # upload
```

Enter your username and paste your token when prompted.

Refresh the GitHub page. Your README renders with the charts. **That's a live link you can put on
your CV.**

### 2.5 Polish the repo page

Small things, real signal. On the repo page:

- Click the **⚙️ gear** next to "About" (right-hand side)
- **Description**: the one-liner from 2.3
- **Topics**: `sql`, `sqlite`, `data-analysis`, `window-functions`, `analytics`, `funnel-analysis`
- Tick **Releases** and **Packages** off — they're empty and look unfinished

### 2.6 Repeat for the other two SQL projects

Same six commands, different folder and repo name:

| Folder | Repo name | Topics |
|---|---|---|
| `b2b-usage-attribution` | `b2b-usage-attribution` | `sql`, `sqlite`, `cte`, `churn-prediction`, `saas-analytics`, `python` |
| `ott-retention-diagnostic` | `ott-retention-diagnostic` | `sql`, `sqlite`, `retention-analysis`, `product-analytics`, `data-analysis` |

---

## Part 3 — Making the fourth project a *live* app

This is the one that gets clicked. `candidate-role-alignment` deploys to Streamlit Community Cloud
for free and gives you a permanent URL.

### 3.1 Push it to GitHub first

Same as Part 2. Repo name: `candidate-role-alignment`.

### 3.2 Deploy

1. Go to [share.streamlit.io](https://share.streamlit.io) and sign in **with GitHub**
2. **Create app** → **Deploy a public app from GitHub**
3. Repository: `YOUR-USERNAME/candidate-role-alignment`
4. Branch: `main`
5. Main file path: `app.py`
6. Click **Advanced settings** → in the **Secrets** box paste:
   ```toml
   GROQ_API_KEY = "your_key_here"
   ```
   *Skip this if you don't have a key — the app runs in heuristic mode without one.*
7. **Deploy**

First build takes 2–4 minutes. You get a URL like
`https://candidate-role-alignment.streamlit.app`.

### 3.3 Get a free LLaMA 3 70B key (optional but worth it)

The live demo works without a key. But the LLM mode is what your CV bullet actually claims, so it's
better if it's switched on.

1. [console.groq.com](https://console.groq.com) → sign up free
2. **API Keys** → **Create API Key** → copy it
3. Paste into the Streamlit secrets box from step 3.2 (**Settings → Secrets** if the app is already
   deployed)

Groq's free tier is rate-limited, not time-limited, which is fine for a demo that gets clicked a few
times a week.

⚠️ **Never commit the key to GitHub.** `.gitignore` already excludes `.env` and
`.streamlit/secrets.toml`. If you ever paste a key into a file and push it, assume it's compromised
and revoke it immediately — GitHub is scraped constantly by bots for exactly this.

### 3.4 Put the live link in the README

Open `README.md`, find this line near the top:

```markdown
### ▶️ [Try the live app](https://YOUR-APP-NAME.streamlit.app)
```

Replace the URL with your real one, then:

```bash
git add README.md
git commit -m "Add live demo link"
git push
```

---

## Part 4 — Making your profile work for you

A recruiter who clicks your GitHub link lands on your **profile**, not your repo. Three things
change what they see.

### 4.1 Pin your four repos

On your profile page → **Customize your pins** → select all four → **Save**.

Without this, GitHub shows your most recently updated repos, which might be a half-finished tutorial
from last year.

### 4.2 Add a profile README

This is the single highest-leverage thing on this page. It creates a card at the top of your profile
that most candidates don't have.

1. **New repository**
2. Repository name: **exactly your username** (e.g. `priyasharma` — GitHub will show a "✨ You found
   a secret!" message when you get it right)
3. **Public**, tick **Add a README file**
4. **Create repository** → edit `README.md` → paste and adapt the template in `profile-README-template.md`

### 4.3 Fill in your profile details

Settings → Public profile: real name, a one-line bio, location, and a link to your LinkedIn. A
profile photo roughly doubles the chance someone reads further.

---

## Part 5 — Putting the links on your CV

### The format

Don't paste raw URLs — they're long and ugly on paper. Hyperlink short text instead.

**In Word / Google Docs:** select the text → `Ctrl+K` (`Cmd+K` on Mac) → paste the URL.

**In LaTeX:**
```latex
\href{https://github.com/YOUR-USERNAME/sales-funnel-diagnostic}{GitHub}
```

### Your bullets, with links added

Keep your existing wording. Just append a linked `[GitHub]` or `[Code]` to the project heading:

> **Sales Funnel & Lead Conversion Diagnostic** | SQL (SQLite) | [GitHub] · Sep 2026
> • Built a conversion-funnel diagnostic using window functions and conditional aggregation across
> 1,300+ leads spanning 5 acquisition channels; surfaced a 28-point conversion-rate gap between the
> strongest and weakest channels (30% vs. 2%), highlighting where outreach spend underperformed

> **B2B Revenue & Usage Attribution Pipeline** | SQL (SQLite), Python | [GitHub] · Sep 2026

> **Candidate-Role Alignment Model** | Python, LLaMA 3 70B | [Live Demo] · [GitHub] · Jun 2026

> **Viewer Retention Diagnostic — OTT Platform** | SQL, Strategy & Analytics | [GitHub] · Dec 2025

Also add one line to your CV header, next to your email and LinkedIn:

> `github.com/YOUR-USERNAME`

### Two small things that matter

- **Check every link before sending.** Open the CV as a PDF and click each one. Broken portfolio
  links are worse than no portfolio links.
- **Put the live demo first** among your links for the LLM project. A clickable working app is the
  rarest thing in a junior analyst's application.

---

## Part 6 — Order of operations

Don't do this all at once. Suggested sequence:

**Day 1** — Parts 1 and 2. Get `sales-funnel-diagnostic` live. The first repo is the hard one; the
rest are muscle memory.

**Day 2** — Push the other two SQL repos. 20 minutes total.

**Day 3** — Part 3. Deploy the Streamlit app, get the Groq key, update the README link.

**Day 4** — Part 4. Pins, profile README, profile details.

**Day 5** — Part 5. Update the CV, export to PDF, click every link.

---

## Checklist

```
Setup
[ ] GitHub account with a professional username
[ ] Git installed and configured with name + email
[ ] Personal Access Token created and saved safely

Per repo (×4)
[ ] YOUR-USERNAME replaced in README.md
[ ] YOUR NAME replaced in LICENSE
[ ] Scripts run locally without errors
[ ] Pushed to GitHub, README renders with charts
[ ] Description and topics filled in

Live app
[ ] Streamlit app deployed and loads
[ ] Groq key added to Streamlit secrets (optional)
[ ] Live URL added to the README and pushed

Profile
[ ] Four repos pinned
[ ] Profile README created
[ ] Photo, bio, location, LinkedIn filled in

CV
[ ] github.com/YOUR-USERNAME in the header
[ ] Linked [GitHub] on all four projects
[ ] Linked [Live Demo] on the LLM project
[ ] Exported to PDF and every link clicked
```

---

## Commands you'll actually use

Ninety percent of Git, for your purposes, is four commands:

```bash
git status                       # what have I changed?
git add .                        # stage everything
git commit -m "what I changed"   # save a snapshot
git push                         # upload it
```

After the first `git push -u origin main`, every later push is just `git push`.

### If something goes wrong

| Problem | Fix |
|---|---|
| `fatal: not a git repository` | You're in the wrong folder. `cd` into the project folder |
| `Authentication failed` | You typed your password instead of the token. Use the token |
| `remote origin already exists` | `git remote set-url origin <the-url>` |
| `Updates were rejected` | Someone (or you, on the web) changed the repo. `git pull --rebase` then `git push` |
| Pushed a secret by accident | Revoke the key at the provider immediately, then generate a new one. Deleting the commit is not enough |
| Charts don't show in the README | The `results/*.png` files weren't committed. `git add results/ -f` then commit and push |

---

## What to expect from this

Being direct about the payoff: four public repos won't get you hired on their own. What they do is
change the conversation. Instead of a recruiter reading "built a conversion-funnel diagnostic" and
having to take your word for it, they can click through and see the queries. And in the interview,
you get to talk about decisions you actually made — why two churn rules instead of one, why NTILE
instead of a fixed threshold — rather than reciting a bullet point.

That shift, from claim to evidence, is the whole point.
