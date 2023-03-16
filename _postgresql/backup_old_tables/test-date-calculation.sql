-- Table: backup.game_actions_p2021_05_10

-- DROP TABLE backup.game_actions_p2021_05_10;



raise notice 'Value: %', deletedContactId;



CREATE TABLE IF NOT EXISTS backup.game_actions_p2021_05_10 PARTITION OF backup.game_actions FOR VALUES FROM ('2021-05-10 00:00:00+00') TO ('2021-05-11 00:00:00+00')
	
TABLESPACE pg_default;


ALTER TABLE backup.game_actions_p2021_05_10
    OWNER to postgres;
	
	
	SELECT CURRENT_DATE;
	
	SELECT NOW()::date;
	
	select date '2021-05-14' +  1 * integer '1'
	
	select date '2021-05-14' + (7 || ' days')::INTERVAL
	
	
do $$
begin
   for cnt in reverse 10..1 loop
      raise notice 'cnt: %', cnt;
	  EXECUTE FORMAT('select date ''2021-05-14'' + 10', cnt);
	  --select date 2021-05-14' +  cnt * integer '1';
   end loop;
end; $$
   
   
   select date 2021-05-14 + 10
   
   
   
	select generate_series()
