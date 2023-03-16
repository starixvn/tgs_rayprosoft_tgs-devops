-- Index: ix_trgm_brands_code_name_description_operational_email

-- DROP INDEX dbo.ix_trgm_brands_code_name_description_operational_email;

drop index dbo.ix_trgm_brands_code_name_description_operational_email;
drop index dbo.ix_trgm_licensees_code_name_description_operational_email;
drop index dbo.ix_trgm_resellers_code_name_description_operational_email;
drop index dbo.ix_trgm_game_providers_name;
drop index dbo.ix_trgm_games_name;

drop index dbo.ix_trgm_payments_name;
drop index dbo.ix_trgm_users_username;
drop index dbo.ix_trgm_roles_name;
drop index dbo.ix_trgm_players_username;

drop index log.ix_api_logs_gist_trgm_ops;
TRUNCATE table log.api_logs



CREATE INDEX ix_trgm_brands_code_name_description_operational_email
    ON dbo.brands USING gin
    (code COLLATE pg_catalog."default" gin_trgm_ops, name COLLATE pg_catalog."default" gin_trgm_ops, description COLLATE pg_catalog."default" gin_trgm_ops, operational_email COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;

CREATE INDEX ix_trgm_licensees_code_name_description_operational_email
    ON dbo.licensees USING gin
    (code COLLATE pg_catalog."default" gin_trgm_ops, name COLLATE pg_catalog."default" gin_trgm_ops, description COLLATE pg_catalog."default" gin_trgm_ops, operational_email COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;

CREATE INDEX ix_trgm_resellers_code_name_description_operational_email
    ON dbo.resellers USING gin
    (code COLLATE pg_catalog."default" gin_trgm_ops, name COLLATE pg_catalog."default" gin_trgm_ops, description COLLATE pg_catalog."default" gin_trgm_ops, operational_email COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;
	
CREATE INDEX ix_trgm_users_username
    ON dbo.users USING gin
    (username COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;

CREATE INDEX ix_trgm_roles_name
    ON dbo.roles USING gin
    (name COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;
	
CREATE INDEX ix_trgm_game_providers_name
    ON dbo.game_providers USING gin
    (name COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;

CREATE INDEX ix_trgm_payments_name
    ON dbo.payments USING gin
    (name COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;

CREATE INDEX ix_trgm_games_name
    ON dbo.games USING gin
    (name COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;

CREATE INDEX ix_trgm_players_username
    ON dbo.players USING gin
    (username COLLATE pg_catalog."default" gin_trgm_ops)
    TABLESPACE pg_default;

CREATE INDEX ix_api_logs_gist_trgm_ops
    ON log.api_logs USING gist
    (prefix COLLATE pg_catalog."default" gist_trgm_ops)
;