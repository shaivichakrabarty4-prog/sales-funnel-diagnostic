"""
Render the two headline charts embedded in the README.

Run:  python scripts/make_charts.py
Out:  results/channel_conversion.png, results/funnel_dropoff.png
"""
import os
import sqlite3

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import pandas as pd

DB_PATH = os.path.join("data", "funnel.db")
INK, ACCENT, MUTED = "#1f2933", "#2f6f4e", "#b03a2e"

CHANNEL_SQL = """
WITH lead_progress AS (
    SELECT l.lead_id, l.channel, MAX(e.stage_order) AS furthest_stage
    FROM leads l JOIN lead_events e ON e.lead_id = l.lead_id
    GROUP BY l.lead_id, l.channel
)
SELECT channel,
       COUNT(*) AS leads,
       ROUND(100.0 * SUM(CASE WHEN furthest_stage >= 6 THEN 1 ELSE 0 END) / COUNT(*), 1) AS conv_rate_pct
FROM lead_progress GROUP BY channel ORDER BY conv_rate_pct DESC;
"""

FUNNEL_SQL = """
SELECT stage, stage_order, COUNT(DISTINCT lead_id) AS leads_reached
FROM lead_events GROUP BY stage, stage_order ORDER BY stage_order;
"""


def style(ax):
    for side in ("top", "right"):
        ax.spines[side].set_visible(False)
    ax.spines["left"].set_color("#cbd2d9")
    ax.spines["bottom"].set_color("#cbd2d9")
    ax.tick_params(colors=INK, labelsize=9)


def main():
    os.makedirs("results", exist_ok=True)
    conn = sqlite3.connect(DB_PATH)
    channels = pd.read_sql_query(CHANNEL_SQL, conn)
    funnel = pd.read_sql_query(FUNNEL_SQL, conn)
    conn.close()

    # --- Chart 1: conversion rate by channel -------------------------------
    fig, ax = plt.subplots(figsize=(8, 4.2), dpi=160)
    colours = [ACCENT] + ["#7b8794"] * (len(channels) - 2) + [MUTED]
    bars = ax.barh(channels["channel"][::-1], channels["conv_rate_pct"][::-1],
                   color=colours[::-1], height=0.62)
    for bar, value in zip(bars, channels["conv_rate_pct"][::-1]):
        ax.text(bar.get_width() + 0.5, bar.get_y() + bar.get_height() / 2,
                f"{value}%", va="center", fontsize=9, color=INK)
    ax.set_xlabel("Lead-to-closed-won conversion rate (%)", fontsize=9, color=INK)
    ax.set_title("Referral converts 28 points higher than Cold Outreach",
                 fontsize=12, color=INK, loc="left", pad=12)
    ax.set_xlim(0, max(channels["conv_rate_pct"]) * 1.18)
    style(ax)
    fig.tight_layout()
    fig.savefig(os.path.join("results", "channel_conversion.png"))
    plt.close(fig)

    # --- Chart 2: overall funnel drop-off ----------------------------------
    fig, ax = plt.subplots(figsize=(8, 4.2), dpi=160)
    labels = [s.replace("_", " ").title() for s in funnel["stage"]]
    bars = ax.bar(labels, funnel["leads_reached"], color=ACCENT, width=0.6)
    top = funnel["leads_reached"].iloc[0]
    for bar, value in zip(bars, funnel["leads_reached"]):
        ax.text(bar.get_x() + bar.get_width() / 2, value + top * 0.015,
                f"{value}\n({value / top:.0%})", ha="center", fontsize=8, color=INK)
    ax.set_ylabel("Leads reaching stage", fontsize=9, color=INK)
    ax.set_title("Largest single leak sits between Qualified and Demo",
                 fontsize=12, color=INK, loc="left", pad=12)
    ax.set_ylim(0, top * 1.18)
    style(ax)
    fig.tight_layout()
    fig.savefig(os.path.join("results", "funnel_dropoff.png"))
    plt.close(fig)

    print("Wrote results/channel_conversion.png and results/funnel_dropoff.png")


if __name__ == "__main__":
    main()
