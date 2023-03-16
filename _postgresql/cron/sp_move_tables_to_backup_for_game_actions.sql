-- FUNCTION: backup.move_game_actions_tables_to_backup()

-- DROP FUNCTION backup.move_game_actions_tables_to_backup();
-- select backup.move_game_actions_tables_to_backup() 
-- SELECT cron.schedule('move game_actions table', '2 0 * * *', 'select backup.move_game_actions_tables_to_backup()');
-- update cron.job set database = 'tgsstaging', jobname='move game_actions table' where jobid = 7
-- update cron.job set database = 'tgs', jobname='move game_actions table' where jobid = 7

CREATE OR REPLACE FUNCTION backup.move_game_actions_tables_to_backup()
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
	start_date date := current_date  - 183 * interval '1 days';
	end_date date :=  current_date  - 182 * interval '1 days';
	partition_table varchar;
	counter integer := 0;
begin
	select  'game_actions_p' || to_char(start_date,'yyyy_MM_dd') into partition_table;
	raise notice 'game_actions partition table is %', partition_table;
	
    EXECUTE 'CREATE TABLE IF NOT EXISTS backup.'|| partition_table
		|| ' PARTITION OF backup.game_actions FOR VALUES FROM (''' || start_date || ' 00:00:00+00'') TO (''' || end_date || ' 00:00:00+00'');';
	
	EXECUTE 'insert into backup.game_actions select * from bet.' || partition_table;
	
	EXECUTE 'drop table bet.' || partition_table;

end
$BODY$;

ALTER FUNCTION backup.move_round_data_to_backup()
    OWNER TO postgres;
