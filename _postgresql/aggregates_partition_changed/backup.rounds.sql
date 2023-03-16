-- Table: backup.rounds_p2021_05_12

-- DROP TABLE backup.rounds_p2021_05_12;

CREATE TABLE IF NOT EXISTS backup.rounds
(
    id uuid NOT NULL,
    external_round_id character varying(255) COLLATE pg_catalog."default" NOT NULL,
    game_provider_id uuid NOT NULL,
    player_code text COLLATE pg_catalog."default" NOT NULL,
    game_id integer NOT NULL,
    currency_code character varying(10) COLLATE pg_catalog."default" NOT NULL,
    status smallint NOT NULL,
    game_provider_configuration_id uuid NOT NULL,
    wallet_id uuid NOT NULL,
    created_on timestamp with time zone NOT NULL,
    closed_on timestamp with time zone,
    updated_on timestamp with time zone NOT NULL,
    brand_id uuid NOT NULL,
    external_created_on timestamp with time zone,
    external_closed_on timestamp with time zone,
    bet_amount numeric(18,6),
    valid_bet_amount numeric(18,6),
    settle_amount numeric,
    commission numeric(18,6),
    turnover numeric,
    win_loss numeric(18,6),
    tie_bet_adjustment numeric(18,6),
    client_status smallint NOT NULL,
    reopen_turnover_adjustment numeric,
    reopened_on timestamp with time zone,
    effective_betting_percentage numeric(18,6),
    CONSTRAINT rounds_pkey PRIMARY KEY (id, created_on)
)PARTITION BY RANGE (created_on);

ALTER TABLE backup.rounds
    OWNER to postgres;

GRANT ALL ON TABLE backup.rounds TO postgres;

GRANT SELECT, INSERT, REFERENCES, DELETE, UPDATE ON TABLE backup.rounds TO tgs_app;
-- Index: rounds_brand_id_idx

-- DROP INDEX backup.rounds_brand_id_idx;

CREATE INDEX rounds_brand_id_idx
    ON backup.rounds USING btree
    (brand_id ASC NULLS LAST);
-- Index: rounds_closed_on_brand_id_idx

-- DROP INDEX backup.rounds_closed_on_brand_id_idx;

CREATE INDEX rounds_closed_on_brand_id_idx
    ON backup.rounds USING btree
    (closed_on ASC NULLS LAST, brand_id ASC NULLS LAST);
-- Index: rounds_closed_on_idx

-- DROP INDEX backup.rounds_closed_on_idx;

CREATE INDEX rounds_closed_on_idx
    ON backup.rounds USING brin
    (closed_on);
-- Index: rounds_created_on_idx

-- DROP INDEX backup.rounds_created_on_idx;

CREATE INDEX rounds_created_on_idx
    ON backup.rounds USING btree
    (created_on DESC NULLS FIRST);
-- Index: rounds_created_on_idx1

-- DROP INDEX backup.rounds_created_on_idx1;

CREATE INDEX rounds_created_on_idx1
    ON backup.rounds USING brin
    (created_on);
-- Index: rounds_external_closed_on_game_provider_id_idx

-- DROP INDEX backup.rounds_external_closed_on_game_provider_id_idx;

CREATE INDEX rounds_external_closed_on_game_provider_id_idx
    ON backup.rounds USING btree
    (external_closed_on ASC NULLS LAST, game_provider_id ASC NULLS LAST);
-- Index: rounds_external_closed_on_idx

-- DROP INDEX backup.rounds_external_closed_on_idx;

CREATE INDEX rounds_external_closed_on_idx
    ON backup.rounds USING brin
    (external_closed_on);
-- Index: rounds_external_round_id_game_provider_id_game__idx

-- DROP INDEX backup.rounds_external_round_id_game_provider_id_game__idx;

CREATE INDEX rounds_external_round_id_game_provider_id_game__idx
    ON backup.rounds USING btree
    (external_round_id COLLATE pg_catalog."default" ASC NULLS LAST, game_provider_id ASC NULLS LAST, game_id ASC NULLS LAST, wallet_id ASC NULLS LAST);
-- Index: rounds_external_round_id_player_code_game_prov_idx1

-- DROP INDEX backup.rounds_external_round_id_player_code_game_prov_idx1;

CREATE INDEX rounds_external_round_id_player_code_game_prov_idx1
    ON backup.rounds USING btree
    (external_round_id COLLATE pg_catalog."default" ASC NULLS LAST, player_code COLLATE pg_catalog."default" ASC NULLS LAST, game_provider_id ASC NULLS LAST, game_id ASC NULLS LAST);
-- Index: rounds_external_round_id_player_code_game_provi_idx

-- DROP INDEX backup.rounds_external_round_id_player_code_game_provi_idx;

-----
----- INCLUDE 會有問題
-----
CREATE UNIQUE INDEX rounds_external_round_id_player_code_game_provi_idx
    ON backup.rounds USING btree
    (external_round_id COLLATE pg_catalog."default" ASC NULLS LAST, player_code COLLATE pg_catalog."default" ASC NULLS LAST, game_provider_id ASC NULLS LAST, game_id ASC NULLS LAST)
    INCLUDE(game_provider_configuration_id, wallet_id);
-- Index: rounds_game_id_idx

-- DROP INDEX backup.rounds_game_id_idx;

CREATE INDEX rounds_game_id_idx
    ON backup.rounds USING btree
    (game_id ASC NULLS LAST);
-- Index: rounds_game_provider_id_idx

-- DROP INDEX backup.rounds_game_provider_id_idx;

CREATE INDEX rounds_game_provider_id_idx
    ON backup.rounds USING btree
    (game_provider_id ASC NULLS LAST);
-- Index: rounds_player_code_idx

-- DROP INDEX backup.rounds_player_code_idx;

CREATE INDEX rounds_player_code_idx
    ON backup.rounds USING btree
    (player_code COLLATE pg_catalog."default" ASC NULLS LAST);