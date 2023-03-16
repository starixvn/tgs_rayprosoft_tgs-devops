CREATE TABLE IF NOT EXISTS bet.rounds2
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
    CONSTRAINT pk_rounds2 PRIMARY KEY (id, created_on)
) PARTITION BY RANGE (created_on);

ALTER TABLE bet.rounds2 OWNER to tgs_migration;

GRANT ALL ON TABLE bet.rounds2 TO tgs_app;

GRANT ALL ON TABLE bet.rounds2 TO tgs_migration;

GRANT select ON TABLE bet.rounds2 TO tgs_reader;

--CREATE INDEX ix_partition_rounds2_created_on
--    ON bet.rounds2 USING btree
--    (created_on DESC NULLS FIRST);
	
CREATE INDEX ix_rounds2_brand_id
    ON bet.rounds2 USING btree
    (brand_id ASC NULLS LAST);

CREATE INDEX ix_rounds2_closed_on
    ON bet.rounds2 USING brin
    (closed_on);

CREATE INDEX ix_rounds2_closed_on_brand_id
    ON bet.rounds2 USING btree
    (closed_on ASC NULLS LAST, brand_id ASC NULLS LAST);

CREATE INDEX ix_rounds2_created_on
    ON bet.rounds2 USING brin
    (created_on);

CREATE INDEX ix_rounds2_external_closed_on
    ON bet.rounds2 USING brin
    (external_closed_on);

CREATE INDEX ix_rounds2_external_closed_on_game_provider_id
    ON bet.rounds2 USING btree
    (external_closed_on ASC NULLS LAST, game_provider_id ASC NULLS LAST);

CREATE INDEX ix_rounds2_external_round_id_player_code_game_provider
    ON bet.rounds USING btree
    (external_round_id COLLATE pg_catalog."default" ASC NULLS LAST, player_code COLLATE pg_catalog."default" ASC NULLS LAST, game_provider_id ASC NULLS LAST, game_id ASC NULLS LAST)
;

--CREATE INDEX ix_rounds2_external_round_id_composite
--    ON bet.rounds2 USING btree
--    (external_round_id COLLATE pg_catalog."default" ASC NULLS LAST, player_code COLLATE pg_catalog."default" ASC NULLS LAST, game_provider_id ASC NULLS LAST, game_id ASC NULLS LAST);

CREATE INDEX ix_rounds2_status
    ON bet.rounds2 USING btree
    (status ASC NULLS LAST);
	
CREATE INDEX ix_rounds2_game_id
    ON bet.rounds USING btree
    (game_id ASC NULLS LAST);
	
CREATE INDEX ix_rounds2_game_provider_id
    ON bet.rounds2 USING btree
    (game_provider_id ASC NULLS LAST);

CREATE INDEX ix_rounds2_player_code
    ON bet.rounds2 USING btree
    (player_code COLLATE pg_catalog."default" ASC NULLS LAST);

CREATE INDEX ix_rounds2_wallet_id_composite
    ON bet.rounds2 USING btree
    (external_round_id COLLATE pg_catalog."default" ASC NULLS LAST, game_provider_id ASC NULLS LAST, game_id ASC NULLS LAST, wallet_id ASC NULLS LAST);

	
CREATE TABLE IF NOT EXISTS bet.rounds2_default PARTITION OF bet.rounds2
    DEFAULT;

ALTER TABLE bet.rounds2_default OWNER to tgs_migration;