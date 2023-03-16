-- Table: report.player_aggregates_p2021_05_17

-- DROP TABLE report.player_aggregates_p2021_05_17;

CREATE TABLE IF NOT EXISTS backup.player_aggregates
(
    id integer NOT NULL,
    brand_id uuid NOT NULL,
    agent_id uuid,
    player_code character varying(16) COLLATE pg_catalog."default" NOT NULL,
    hour integer NOT NULL,
    minute integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    report_date timestamp with time zone NOT NULL,
    registered_count integer NOT NULL,
    first_fund_in_count integer NOT NULL,
    deposit_amount numeric(18,6) NOT NULL,
    withdrawal_amount numeric(18,6) NOT NULL,
    company_adjust_amount numeric(18,6) NOT NULL,
    bonus_amount numeric(18,6) NOT NULL,
    bet_amount numeric(18,6) NOT NULL,
    turnover numeric(18,6) NOT NULL,
    win_loss_amount numeric(18,6) NOT NULL,
    rebate_amount numeric(18,6) NOT NULL DEFAULT 0.0,
    dividend_amount numeric(18,6) NOT NULL DEFAULT 0.0,
    promotion_amount numeric(18,6) NOT NULL DEFAULT 0.0,
    original_turnover numeric(18,6) NOT NULL DEFAULT 0.0,
    valid_bet_amount numeric(18,6) NOT NULL DEFAULT 0.0,
    all_agent_rebate_amount numeric(18,6) NOT NULL DEFAULT 0.0,
    agent_adjust_amount numeric(18,6) NOT NULL DEFAULT 0.0,
    system_adjust_amount numeric(18,6) NOT NULL DEFAULT 0.0,
    no_include_net_profit_agent_adjust_amount numeric(18,6) NOT NULL DEFAULT 0.0,
    no_include_net_profit_company_adjust_amount numeric(18,6) NOT NULL DEFAULT 0.0,
    CONSTRAINT player_aggregates_pkey PRIMARY KEY (id, created_on)
)PARTITION BY RANGE (created_on);

ALTER TABLE backup.player_aggregates
    OWNER to postgres;

GRANT ALL ON TABLE backup.player_aggregates TO tgs_app;

GRANT ALL ON TABLE backup.player_aggregates TO tgs_migration;

GRANT SELECT ON TABLE backup.player_aggregates TO postgres;
-- Index: player_aggregates_agent_id_idx

-- DROP INDEX backup.player_aggregates_agent_id_idx;

CREATE INDEX player_aggregates_agent_id_idx
    ON backup.player_aggregates USING btree
    (agent_id ASC NULLS LAST);
-- Index: player_aggregates_created_on_idx

-- DROP INDEX backup.player_aggregates_created_on_idx;

CREATE INDEX player_aggregates_created_on_idx
    ON backup.player_aggregates USING btree
    (created_on DESC NULLS FIRST);
-- Index: player_aggregates_report_date_brand_id_agent_id_idx

-- DROP INDEX backup.player_aggregates_report_date_brand_id_agent_id_idx;

CREATE INDEX player_aggregates_report_date_brand_id_agent_id_idx
    ON backup.player_aggregates USING btree
    (report_date ASC NULLS LAST, brand_id ASC NULLS LAST, agent_id ASC NULLS LAST, player_code COLLATE pg_catalog."default" ASC NULLS LAST);