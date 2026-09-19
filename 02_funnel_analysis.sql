-- =====================================================================
-- Sales Funnel & Lead Conversion Diagnostic
-- Analysis queries (SQLite 3.25+ for window functions)
-- Each query is independent; run the whole file or one block at a time.
-- =====================================================================


-- ---------------------------------------------------------------------
-- Q1. Channel scoreboard
-- Conditional aggregation collapses the event log into one row per
-- channel, then window functions rank channels and express each one
-- against the best performer.
-- ---------------------------------------------------------------------
WITH lead_progress AS (
    SELECT
        l.lead_id,
        l.channel,
        l.acquisition_cost_usd,
        MAX(e.stage_order) AS furthest_stage
    FROM leads l
    JOIN lead_events e ON e.lead_id = l.lead_id
    GROUP BY l.lead_id, l.channel, l.acquisition_cost_usd
),
channel_rollup AS (
    SELECT
        channel,
        COUNT(*)                                            AS leads,
        SUM(CASE WHEN furthest_stage >= 3 THEN 1 ELSE 0 END) AS qualified,
        SUM(CASE WHEN furthest_stage >= 4 THEN 1 ELSE 0 END) AS demos,
        SUM(CASE WHEN furthest_stage >= 6 THEN 1 ELSE 0 END) AS closed_won,
        ROUND(SUM(acquisition_cost_usd), 0)                  AS spend_usd
    FROM lead_progress
    GROUP BY channel
)
SELECT
    channel,
    leads,
    qualified,
    closed_won,
    ROUND(100.0 * closed_won / leads, 1)                     AS conv_rate_pct,
    ROUND(100.0 * qualified / leads, 1)                      AS qualification_rate_pct,
    RANK() OVER (ORDER BY 1.0 * closed_won / leads DESC)     AS rank_by_conv,
    ROUND(100.0 * closed_won / leads
          - MAX(100.0 * closed_won / leads) OVER (), 1)      AS gap_to_best_pts,
    spend_usd,
    CASE WHEN closed_won = 0 THEN NULL
         ELSE ROUND(spend_usd / closed_won, 0) END           AS cost_per_won_usd
FROM channel_rollup
ORDER BY conv_rate_pct DESC;


-- ---------------------------------------------------------------------
-- Q2. Stage-by-stage funnel drop-off (overall)
-- LAG() gives the previous stage's survivor count, so step conversion
-- and leakage fall out of a single pass.
-- ---------------------------------------------------------------------
WITH stage_counts AS (
    SELECT stage, stage_order, COUNT(DISTINCT lead_id) AS leads_reached
    FROM lead_events
    GROUP BY stage, stage_order
)
SELECT
    stage_order,
    stage,
    leads_reached,
    LAG(leads_reached) OVER (ORDER BY stage_order)           AS prev_stage_leads,
    ROUND(100.0 * leads_reached
          / LAG(leads_reached) OVER (ORDER BY stage_order), 1) AS step_conv_pct,
    LAG(leads_reached) OVER (ORDER BY stage_order) - leads_reached AS leads_lost,
    ROUND(100.0 * leads_reached
          / FIRST_VALUE(leads_reached) OVER (ORDER BY stage_order), 1) AS pct_of_top_of_funnel
FROM stage_counts
ORDER BY stage_order;


-- ---------------------------------------------------------------------
-- Q3. Where each channel leaks
-- Same LAG pattern, partitioned by channel: shows that Cold Outreach
-- dies at first contact while Paid Search survives contact and dies later.
-- ---------------------------------------------------------------------
WITH channel_stage AS (
    SELECT l.channel, e.stage, e.stage_order,
           COUNT(DISTINCT e.lead_id) AS leads_reached
    FROM lead_events e
    JOIN leads l ON l.lead_id = e.lead_id
    GROUP BY l.channel, e.stage, e.stage_order
)
SELECT
    channel,
    stage_order,
    stage,
    leads_reached,
    ROUND(100.0 * leads_reached
          / LAG(leads_reached) OVER (PARTITION BY channel ORDER BY stage_order), 1)
        AS step_conv_pct
FROM channel_stage
ORDER BY channel, stage_order;


-- ---------------------------------------------------------------------
-- Q4. Funnel velocity
-- Days from lead creation to close, per channel, plus a median via
-- NTILE-style row numbering.
-- ---------------------------------------------------------------------
WITH won_leads AS (
    SELECT
        l.channel,
        l.lead_id,
        JULIANDAY(MAX(CASE WHEN e.stage = 'closed_won' THEN e.event_date END))
      - JULIANDAY(MIN(CASE WHEN e.stage = 'lead_created' THEN e.event_date END))
            AS days_to_close
    FROM leads l
    JOIN lead_events e ON e.lead_id = l.lead_id
    GROUP BY l.channel, l.lead_id
    HAVING days_to_close IS NOT NULL
),
ranked AS (
    SELECT channel, days_to_close,
           ROW_NUMBER() OVER (PARTITION BY channel ORDER BY days_to_close) AS rn,
           COUNT(*)    OVER (PARTITION BY channel)                          AS n
    FROM won_leads
)
SELECT
    channel,
    n                                   AS won_deals,
    ROUND(AVG(days_to_close), 1)        AS avg_days_to_close,
    MAX(CASE WHEN rn = (n + 1) / 2 THEN days_to_close END) AS median_days_to_close
FROM ranked
GROUP BY channel, n
ORDER BY avg_days_to_close;


-- ---------------------------------------------------------------------
-- Q5. Segment cut - does company size explain the channel gap?
-- Guards against the obvious "it's just a mix effect" objection.
-- ---------------------------------------------------------------------
WITH lead_progress AS (
    SELECT l.lead_id, l.channel, l.company_size, MAX(e.stage_order) AS furthest_stage
    FROM leads l
    JOIN lead_events e ON e.lead_id = l.lead_id
    GROUP BY l.lead_id, l.channel, l.company_size
)
SELECT
    company_size,
    COUNT(*)                                                 AS leads,
    SUM(CASE WHEN furthest_stage >= 6 THEN 1 ELSE 0 END)     AS closed_won,
    ROUND(100.0 * SUM(CASE WHEN furthest_stage >= 6 THEN 1 ELSE 0 END) / COUNT(*), 1)
        AS conv_rate_pct
FROM lead_progress
GROUP BY company_size
ORDER BY conv_rate_pct DESC;
