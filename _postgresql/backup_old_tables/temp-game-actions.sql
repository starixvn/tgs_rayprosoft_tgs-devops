
CREATE TABLE IF NOT EXISTS backup.game_actions_bak
(
    id uuid NOT NULL,
    round_id uuid NOT NULL,
    player_code text COLLATE pg_catalog."default" NOT NULL,
    external_transaction_id character varying(128) COLLATE pg_catalog."default" NOT NULL,
    type smallint NOT NULL,
    amount numeric(18,6) NOT NULL,
    turnover numeric(18,6) NOT NULL,
    win_loss numeric(18,6) NOT NULL,
    unsettled_bets numeric(18,6) NOT NULL,
    balance numeric(18,6) NOT NULL,
    bet_type character varying(128) COLLATE pg_catalog."default",
    external_bet_id character varying(128) COLLATE pg_catalog."default" NOT NULL,
    external_game_action_group_id character varying(128) COLLATE pg_catalog."default" NOT NULL,
    referenced_game_action_id uuid,
    game_action_batch_id uuid,
    recorded_on timestamp with time zone NOT NULL,
    sent_on timestamp with time zone,
    is_closing_round boolean NOT NULL,
    closing_round_explicit_request boolean,
    player_ip character varying(128) COLLATE pg_catalog."default" NOT NULL,
    extra_data text COLLATE pg_catalog."default",
    jackpot_contribution jsonb,
    stored_on timestamp with time zone NOT NULL DEFAULT now(),
    CONSTRAINT game_actions_bak_pkey PRIMARY KEY (id, recorded_on)
);

ALTER TABLE backup.game_actions_bak
    OWNER to postgres;

GRANT ALL ON TABLE backup.game_actions_bak TO postgres;

GRANT SELECT, INSERT, REFERENCES, DELETE, UPDATE ON TABLE backup.game_actions_bak TO tgs_app;
-- Index: game_actions_bak_external_game_action_group_id_idx

-- DROP INDEX backup.game_actions_bak_external_game_action_group_id_idx;

CREATE INDEX game_actions_bak_external_game_action_group_id_idx
    ON backup.game_actions_bak USING btree
    (external_game_action_group_id COLLATE pg_catalog."default" ASC NULLS LAST)
;
-- Index: game_actions_bak_external_transaction_id_idx

-- DROP INDEX backup.game_actions_bak_external_transaction_id_idx;

CREATE INDEX game_actions_bak_external_transaction_id_idx
    ON backup.game_actions_bak USING btree
    (external_transaction_id COLLATE pg_catalog."default" ASC NULLS LAST)
;
-- Index: game_actions_bak_game_action_batch_id_idx

-- DROP INDEX backup.game_actions_bak_game_action_batch_id_idx;

CREATE INDEX game_actions_bak_game_action_batch_id_idx
    ON backup.game_actions_bak USING btree
    (game_action_batch_id ASC NULLS LAST)
;
-- Index: game_actions_bak_player_code_idx

-- DROP INDEX backup.game_actions_bak_player_code_idx;

CREATE INDEX game_actions_bak_player_code_idx
    ON backup.game_actions_bak USING btree
    (player_code COLLATE pg_catalog."default" ASC NULLS LAST)
;
-- Index: game_actions_bak_recorded_on_idx

-- DROP INDEX backup.game_actions_bak_recorded_on_idx;

CREATE INDEX game_actions_bak_recorded_on_idx
    ON backup.game_actions_bak USING btree
    (recorded_on DESC NULLS FIRST)
;
-- Index: game_actions_bak_referenced_game_action_id_idx

-- DROP INDEX backup.game_actions_bak_referenced_game_action_id_idx;

CREATE INDEX game_actions_bak_referenced_game_action_id_idx
    ON backup.game_actions_bak USING btree
    (referenced_game_action_id ASC NULLS LAST)
;
-- Index: game_actions_bak_round_id_idx

-- DROP INDEX backup.game_actions_bak_round_id_idx;

CREATE INDEX game_actions_bak_round_id_idx
    ON backup.game_actions_bak USING btree
    (round_id ASC NULLS LAST)
;



--- insert DATA

insert into backup.game_actions_bak
select * from backup.game_actions where recorded_on < '2022-01-01'