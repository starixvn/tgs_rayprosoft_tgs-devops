-- FUNCTION: backup.move_round_data_to_backup(date, date)

-- DROP FUNCTION backup.move_round_data_to_backup(date, date);

CREATE OR REPLACE FUNCTION backup.move_round_data_to_backup(
	start_date date,
	end_date date)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
	date1 date;
	date2 date;
	round_partition_table varchar;
	counter integer := 0;
	sql1 varchar;
begin
    FOR date1 IN select generate_series(start_date,end_date,'1 day'::interval)::date 
    LOOP
		select date1 + INTERVAL '1 day' into date2;
		select  'rounds_p' || to_char(date1,'yyyy_MM_dd') into round_partition_table;
		raise notice 'round partition table is %', round_partition_table;
		
		EXECUTE 'CREATE TABLE IF NOT EXISTS backup.'|| round_partition_table
			|| ' PARTITION OF backup.rounds FOR VALUES FROM (''' || date1 || ' 00:00:00+00'') TO (''' || date2 || ' 00:00:00+00'');';
		
		EXECUTE 'insert into backup.rounds select * from bet.' || round_partition_table;
		
		EXECUTE 'drop table bet.' || round_partition_table;
		
		EXECUTE 'insert into bet.rounds select * from backup.' ||  round_partition_table || ' where not (status=2 and client_status !=1)';

		insert into backup.round_details
		select d.* from bet.round_details d
		join backup.rounds r on r.id = d.round_id 
		where r.created_on >= date1 and r.created_on < date2;

		EXECUTE 'delete FROM bet.round_details d using backup.' 
			||  round_partition_table || ' d2 where  d.round_id = d2.id and  d2.created_on >= ''' || date1 || ''' and d2.created_on < ''' || date2 || ''';';	
	END LOOP;	
end
$BODY$;

ALTER FUNCTION backup.move_round_data_to_backup(date, date)
    OWNER TO postgres;
