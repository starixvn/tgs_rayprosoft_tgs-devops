-- Table: report.round_aggregates_p2021_05_15

-- DROP TABLE report.round_aggregates_p2021_05_15;

CREATE TABLE IF NOT EXISTS backup.round_aggregates
(
    id integer NOT NULL,
    brand_id uuid NOT NULL,
    agent_id uuid,
    player_code text COLLATE pg_catalog."default" NOT NULL,
    game_provider_id uuid NOT NULL,
    game_type smallint NOT NULL,
    hour integer NOT NULL,
    minute integer NOT NULL,
    bet_amount numeric(18,6) NOT NULL,
    valid_bet_amount numeric(18,6) NOT NULL,
    turnover numeric(18,6) NOT NULL,
    win_loss numeric(18,6) NOT NULL,
    report_date timestamp with time zone NOT NULL,
    created_on timestamp with time zone NOT NULL,
    game_id integer NOT NULL DEFAULT 0,
    original_turnover numeric(18,6) NOT NULL DEFAULT 0.0,
    CONSTRAINT round_aggregates_pkey PRIMARY KEY (id, created_on)
)PARTITION BY RANGE (created_on);


ALTER TABLE backup.round_aggregates
    OWNER to postgres;

GRANT ALL ON TABLE backup.round_aggregates TO staging_app;

GRANT ALL ON TABLE backup.round_aggregates TO staging_migration;

GRANT ALL ON TABLE backup.round_aggregates TO tgs_app;

GRANT ALL ON TABLE backup.round_aggregates TO tgs_migration;

GRANT ALL ON TABLE backup.round_aggregates TO postgres;


GRANT SELECT ON TABLE backup.round_aggregates TO tgs_reader;
-- Index: round_aggregates_created_on_idx

-- DROP INDEX backup.round_aggregates_created_on_idx;

CREATE INDEX round_aggregates_created_on_idx
    ON backup.round_aggregates USING btree
    (created_on DESC NULLS FIRST);
-- Index: round_aggregates_player_code_idx

-- DROP INDEX backup.round_aggregates_player_code_idx;

CREATE INDEX round_aggregates_player_code_idx
    ON backup.round_aggregates USING btree
    (player_code COLLATE pg_catalog."default" ASC NULLS LAST);
-- Index: round_aggregates_report_date_hour_minute_idx

-- DROP INDEX backup.round_aggregates_report_date_hour_minute_idx;

CREATE INDEX round_aggregates_report_date_hour_minute_idx
    ON backup.round_aggregates USING btree
    (report_date ASC NULLS LAST, hour ASC NULLS LAST, minute ASC NULLS LAST);