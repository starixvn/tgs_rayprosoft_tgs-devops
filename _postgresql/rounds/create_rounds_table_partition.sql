DO $$
declare 
start_date date  := '2022-11-19';
end_date date  := '2023-02-19';
date1 date;
date2 date;
round_partition_table varchar;
BEGIN
FOR date1 IN select generate_series(start_date,end_date,'1 day'::interval)::date 
LOOP
	select date1 + INTERVAL '1 day' into date2;
	select  'rounds2_p' || to_char(date1,'yyyy_MM_dd') into round_partition_table;
	
	raise notice 'round2 partition table is %', round_partition_table;
	
    Execute 'CREATE TABLE IF NOT EXISTS bet.'|| round_partition_table 
		|| ' PARTITION OF bet.rounds2 FOR VALUES FROM ('''|| date1 ||' 00:00:00+00'') TO ('''|| date2 || ' 00:00:00+00'');';
	
	Execute 'ALTER TABLE bet.' || round_partition_table || ' OWNER to tgs_migration';
END LOOP;	
END $$;



DO $$
declare 
start_date date  := '2022-11-21';
end_date date  := '2023-02-19';
date1 date;
date2 date;
round_partition_old_table varchar;
round_partition_new_table varchar;
BEGIN
FOR date1 IN select generate_series(start_date,end_date,'1 day'::interval)::date 
LOOP
	select 'rounds_p' || to_char(date1,'yyyy_MM_dd') into round_partition_old_table;
	select 'rounds2_p' || to_char(date1,'yyyy_MM_dd') into round_partition_new_table;
	
	Execute 'delete from bet.'|| round_partition_new_table || ';' ;
	
	Execute 'insert into bet.'|| round_partition_new_table ||' select * from bet.'|| round_partition_old_table || ';' ;
	
	raise notice 'round2 partition table is % done', round_partition_old_table; 
END LOOP;	
END $$;
