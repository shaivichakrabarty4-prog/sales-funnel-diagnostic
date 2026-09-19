-- =====================================================================
-- Sales Funnel & Lead Conversion Diagnostic
-- Schema definition (SQLite)
-- =====================================================================

DROP TABLE IF EXISTS lead_events;
DROP TABLE IF EXISTS leads;

-- One row per lead captured by the marketing / SDR motion
CREATE TABLE leads (
    lead_id              INTEGER PRIMARY KEY,
    channel              TEXT    NOT NULL,  -- acquisition channel
    created_date         TEXT    NOT NULL,  -- ISO date the lead entered the funnel
    region               TEXT    NOT NULL,
    company_size         TEXT    NOT NULL,  -- SMB / Mid-Market / Enterprise
    acquisition_cost_usd REAL    NOT NULL   -- blended cost to source this lead
);

-- One row per funnel stage a lead actually reached.
-- Modelled as an event log rather than a status column so that drop-off
-- can be measured at every step instead of only at the final state.
CREATE TABLE lead_events (
    event_id    INTEGER PRIMARY KEY,
    lead_id     INTEGER NOT NULL REFERENCES leads(lead_id),
    stage       TEXT    NOT NULL,  -- lead_created > contacted > qualified > demo > proposal > closed_won
    stage_order INTEGER NOT NULL,  -- 1..6, keeps window-function ordering explicit
    event_date  TEXT    NOT NULL
);

CREATE INDEX idx_events_lead   ON lead_events(lead_id);
CREATE INDEX idx_events_stage  ON lead_events(stage_order);
CREATE INDEX idx_leads_channel ON leads(channel);
