"""
Generate the synthetic lead dataset used by the funnel diagnostic.

The data is SYNTHETIC but deliberately shaped like a real B2B SaaS funnel:
channels differ in both volume and quality, and non-converting leads die at
different stages depending on how they were sourced.

Run:  python scripts/generate_data.py
Out:  data/funnel.db
"""
import os
import random
import sqlite3
from datetime import date, timedelta

RANDOM_SEED = 42
DB_PATH = os.path.join("data", "funnel.db")
START_DATE = date(2025, 10, 1)
WINDOW_DAYS = 180

STAGES = [
    ("lead_created", 1),
    ("contacted", 2),
    ("qualified", 3),
    ("demo", 4),
    ("proposal", 5),
    ("closed_won", 6),
]

# channel -> volume, closed-won count, where losers drop (last stage reached, 1-5),
# and blended cost per lead
CHANNELS = {
    "Referral":             dict(leads=180, won=54, drop=[0.05, 0.08, 0.17, 0.30, 0.40], cost=18.0),
    "Inbound Demo Request": dict(leads=240, won=60, drop=[0.08, 0.12, 0.22, 0.28, 0.30], cost=42.0),
    "Webinar":              dict(leads=285, won=37, drop=[0.15, 0.18, 0.30, 0.22, 0.15], cost=65.0),
    "Paid Search":          dict(leads=322, won=26, drop=[0.22, 0.20, 0.30, 0.18, 0.10], cost=110.0),
    "Cold Outreach":        dict(leads=320, won=6,  drop=[0.30, 0.34, 0.22, 0.10, 0.04], cost=88.0),
}

REGIONS = ["North America", "EMEA", "APAC"]
SIZES = ["SMB", "Mid-Market", "Enterprise"]
SIZE_WEIGHTS = [0.45, 0.35, 0.20]


def build():
    rng = random.Random(RANDOM_SEED)
    os.makedirs("data", exist_ok=True)
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)

    conn = sqlite3.connect(DB_PATH)
    with open(os.path.join("sql", "01_schema.sql")) as fh:
        conn.executescript(fh.read())

    leads, events = [], []
    lead_id = event_id = 0

    for channel, cfg in CHANNELS.items():
        # Decide which leads convert up front so headline rates are reproducible.
        winners = set(rng.sample(range(cfg["leads"]), cfg["won"]))

        for i in range(cfg["leads"]):
            lead_id += 1
            created = START_DATE + timedelta(days=rng.randint(0, WINDOW_DAYS))
            leads.append((
                lead_id,
                channel,
                created.isoformat(),
                rng.choice(REGIONS),
                rng.choices(SIZES, weights=SIZE_WEIGHTS)[0],
                round(cfg["cost"] * rng.uniform(0.75, 1.25), 2),
            ))

            if i in winners:
                furthest = 6
            else:
                furthest = rng.choices([1, 2, 3, 4, 5], weights=cfg["drop"])[0]

            cursor = created
            for stage_name, stage_order in STAGES[:furthest]:
                if stage_order > 1:
                    cursor += timedelta(days=rng.randint(1, 14))
                event_id += 1
                events.append((event_id, lead_id, stage_name, stage_order, cursor.isoformat()))

    conn.executemany("INSERT INTO leads VALUES (?,?,?,?,?,?)", leads)
    conn.executemany("INSERT INTO lead_events VALUES (?,?,?,?,?)", events)
    conn.commit()
    conn.close()
    print(f"Wrote {len(leads):,} leads and {len(events):,} funnel events -> {DB_PATH}")


if __name__ == "__main__":
    build()
