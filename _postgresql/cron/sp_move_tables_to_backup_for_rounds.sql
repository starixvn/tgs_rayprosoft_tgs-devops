-- FUNCTION: backup.move_round_data_to_backup()

-- DROP FUNCTION backup.move_round_data_to_backup();
-- select backup.move_round_data_to_backup() 

CREATE OR REPLACE FUNCTION backup.move_round_data_to_backup(start_date date, end_date date)
    RETURNS void
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE PARALLEL UNSAFE
AS $BODY$
declare 
	start_date date := current_date  - 93 * interval '1 days';
	end_date date :=  current_date  - 92 * interval '1 days';
	round_partition_table varchar;
	counter integer := 0;
begin
	select  'rounds_p' || to_char(start_date,'yyyy_MM_dd') into round_partition_table;
	raise notice 'round partition table is %', round_partition_table;
	
    EXECUTE 'CREATE TABLE IF NOT EXISTS backup.'|| round_partition_table
		|| ' PARTITION OF backup.rounds FOR VALUES FROM (''' || start_date || ' 00:00:00+00'') TO (''' || end_date || ' 00:00:00+00'');';
	
	EXECUTE 'insert into backup.rounds 
	select * from bet.' || round_partition_table;
	
	EXECUTE 'drop table bet.' || round_partition_table;
	
	EXECUTE 'insert into bet.rounds select * from backup.' ||  round_partition_table || ' where not (status=2 and client_status !=1)';
	
	select 
		count(1) into counter 
	from bet.round_details d
	join backup.rounds r on r.id = d.round_id 
	where r.created_on >= start_date and r.created_on < end_date;
	
	raise notice 'Counter in the outer block is %', counter;
	
	insert into backup.round_details
	select d.* from bet.round_details d
	join backup.rounds r on r.id = d.round_id 
	where r.created_on >= current_date  - start_date_count * interval '1 days' and r.created_on < current_date  - end_date_count * interval '1 days';

	EXECUTE 'delete FROM bet.round_details d using backup.' 
		||  round_partition_table || ' where  d.round_id = d2.id and  d2.created_on >= ' || start_date || ' and d2.created_on < ' || end_date ';';
end
$BODY$;

ALTER FUNCTION backup.move_round_data_to_backup()
    OWNER TO postgres;
