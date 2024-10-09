
--Step 1 複製資料
select * into dbo.game_wager_stat_closes_default_temp from dbo.game_wager_stat_closes_default;

--Step 2 刪除資料
delete from from dbo.game_wager_stat_closes_default

--Step 3 建立分割表
DO $$
DECLARE
    start_date DATE := '2024-08-05';
    end_date DATE := '2024-09-10';
    partition_date DATE;
    partition_name TEXT;
BEGIN
    partition_date := start_date;
    WHILE partition_date <= end_date LOOP
        partition_name := 'game_wager_stat_closes_p' || to_char(partition_date, 'YYYY_MM_DD');
        
        EXECUTE format('
            CREATE TABLE IF NOT EXISTS dbo.%I PARTITION OF dbo.game_wager_stat_closes
            FOR VALUES FROM (''%s'') TO (''%s'');
        ', partition_name, partition_date, partition_date + INTERVAL '1 day');

        partition_date := partition_date + INTERVAL '1 day';
    END LOOP;
END $$;


--Step 4 還原資料
insert into dbo.game_wager_stat_closes 
select * from dbo.game_wager_stat_closes_default_temp


--Step 5 確認排程運作是否正常
SELECT partman.run_maintenance('dbo.game_wager_stat_closes', p_jobmon := 't', p_debug := 'f')
CALL partman.run_maintenance_proc()


--Step 6 刪除暫存資料表
drop table dbo.game_wager_stat_closes_default_temp