SELECT count(1)	FROM backup.rounds_bak;

insert into backup.rounds_bak
select * from backup.rounds where created_on >= '2022-03-01' and created_on < '2022-04-01'


drop table backup.rounds_p2022_07_01;
drop table backup.rounds_p2022_07_02;
drop table backup.rounds_p2022_07_03;
drop table backup.rounds_p2022_07_04;
drop table backup.rounds_p2022_07_05;
drop table backup.rounds_p2022_07_06;
drop table backup.rounds_p2022_07_07;
drop table backup.rounds_p2022_07_08;
drop table backup.rounds_p2022_07_09;
drop table backup.rounds_p2022_07_10;

drop table backup.rounds_p2022_07_11;
drop table backup.rounds_p2022_07_12;
drop table backup.rounds_p2022_07_13;
drop table backup.rounds_p2022_07_14;
drop table backup.rounds_p2022_07_15;
drop table backup.rounds_p2022_07_16;
drop table backup.rounds_p2022_07_17;
drop table backup.rounds_p2022_07_18;
drop table backup.rounds_p2022_07_19;
drop table backup.rounds_p2022_07_20;

drop table backup.rounds_p2022_07_21;
drop table backup.rounds_p2022_07_22;
drop table backup.rounds_p2022_07_23;
drop table backup.rounds_p2022_07_24;
drop table backup.rounds_p2022_07_25;
drop table backup.rounds_p2022_07_26;
drop table backup.rounds_p2022_07_27;
drop table backup.rounds_p2022_07_28;
drop table backup.rounds_p2022_07_29;
drop table backup.rounds_p2022_07_30;
drop table backup.rounds_p2022_07_31;


CREATE TABLE IF NOT EXISTS backup.rounds_p2022_02 PARTITION OF backup.rounds
    FOR VALUES FROM ('2022-02-01 00:00:00+00') TO ('2022-03-01 00:00:00+00')
TABLESPACE pg_default;

ALTER TABLE backup.rounds_p2022_02
    OWNER to postgres;
	
insert into backup.rounds
select * from backup.rounds_bak 

select count(1) from backup.rounds_p2022_02;
select count(1) from backup.rounds where created_on >= '2022-02-01' and created_on < '2022-03-01';

truncate table backup.rounds_bak 

