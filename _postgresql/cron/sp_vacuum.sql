-----------------
-- create cron --
-----------------
-- SELECT cron.schedule('move logs table', '2 0 * * *', 'select backup.move_logs_tables()');
-- update cron.job set database = 'tgsstaging', jobname='move logs table' where jobid = 6
-- update cron.job set database = 'tgs', jobname='move logs table' where jobid = 6

CREATE OR REPLACE FUNCTION backup.move_logs_tables()
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
	date_logs_to_delete date := current_date  - 32 * interval '1 days';
	date_to_add date :=  current_date  + 24 * interval '1 days';
	_date_logs_to_delete varchar;
	_date_to_add varchar;
begin
	select to_char(date_logs_to_delete,'yyyy_MM_dd') into _date_logs_to_delete;
	select to_char(date_to_add,'yyyy_MM_dd') into _date_to_add;
	
	EXECUTE 'drop table if exists log.admin_logs_p' || _date_logs_to_delete || ';';
	EXECUTE 'drop table if exists log.api_logs_p' || _date_logs_to_delete || ';';
	EXECUTE 'drop table if exists log.log_records_p' || _date_logs_to_delete || ';';

	EXECUTE 'ALTER TABLE bet.game_actions_p' || _date_to_add || ' OWNER TO tgs_migration;';
	EXECUTE 'ALTER TABLE bet.rounds_p' || _date_to_add || ' OWNER TO tgs_migration;';
	EXECUTE 'ALTER TABLE log.admin_logs_p' || _date_to_add  || ' OWNER TO tgs_migration;';
	EXECUTE 'ALTER TABLE log.api_logs_p' || _date_to_add  || ' OWNER TO tgs_migration;';
	EXECUTE 'ALTER TABLE log.log_records_p' || _date_to_add  || ' OWNER TO tgs_migration;';
end
$BODY$;