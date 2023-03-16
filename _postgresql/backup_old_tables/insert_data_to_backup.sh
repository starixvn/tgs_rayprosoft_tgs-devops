### game_actions

insert into backup.game_actions 
select a.* from 
(select * from bet.game_actions where recorded_on <= '2022-02-07') a 
left join 
(select * from backup.game_actions where recorded_on <= '2022-02-07') b on a.id=b.id
where b.id is null

### rounds

insert into backup.rounds 
select a.* from 
(select * from bet.rounds where created_on <= '2022-02-07') a 
left join 
(select * from backup.rounds where created_on <= '2022-02-07') b on a.id=b.id
where b.id is null


### player_aggregates

ALTER TABLE backup.player_aggregates
ADD COLUMN bonus_adjust_amount numeric(18, 6) not null default 0;

ALTER TABLE backup.player_aggregates
ADD COLUMN no_include_net_profit_bonus_adjust_amount numeric(18,6)  not null default 0;

ALTER TABLE backup.player_aggregates
ADD COLUMN deposit_handling_fee numeric(18,6)  not null default 0;

ALTER TABLE backup.player_aggregates
ADD COLUMN withdraw_handling_fee numeric(18,6) not null default 0;


update report.player_aggregates 
set created_on = report_date
where created_on < '0001-01-01'


insert into backup.player_aggregates 
select a.* from 
(select * from report.player_aggregates where created_on <= '2022-02-07') a 
left join 
(select * from backup.player_aggregates where created_on <= '2022-02-07') b on a.id=b.id
where b.id is null



### round_aggregates

insert into backup.round_aggregates 
select a.* from 
(select * from report.round_aggregates where created_on <= '2022-02-07') a 
left join 
(select * from backup.round_aggregates where created_on <= '2022-02-07') b on a.id=b.id
where b.id is null







########  BAK

insert into backup.rounds_bak
select * from backup.rounds where created_on < '2022-01-01'

insert into backup.game_actions_bak
select * from backup.game_actions where recorded_on < '2022-01-01'

insert into backup.round_aggregates_bak
select * from backup.round_aggregates where created_on < '2022-01-01'

insert into backup.player_aggregates_bak
select * from backup.player_aggregates where created_on < '2022-01-01'




CREATE TABLE IF NOT EXISTS backup.rounds_p2021 PARTITION OF backup.rounds FOR VALUES FROM ('2021-01-01 00:00:00+00') TO ('2022-01-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS backup.game_actions_p2021 PARTITION OF backup.game_actions FOR VALUES FROM ('2021-01-01 00:00:00+00') TO ('2022-01-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS backup.player_aggregates_p2021 PARTITION OF backup.player_aggregates FOR VALUES FROM ('2021-01-01 00:00:00+00') TO ('2022-01-01 00:00:00+00');
CREATE TABLE IF NOT EXISTS backup.round_aggregates_p2021 PARTITION OF backup.round_aggregates FOR VALUES FROM ('2021-01-01 00:00:00+00') TO ('2022-01-01 00:00:00+00');


insert into backup.game_actions 
select * from backup.game_actions_bak;

insert into backup.rounds 
select * from backup.rounds_bak;

insert into backup.round_aggregates 
select * from backup.round_aggregates_bak;

insert into backup.player_aggregates 
select * from backup.player_aggregates_bak;


delete from backup.game_actions_bak;
delete from backup.rounds_bak;
delete from backup.player_aggregates_bak;
delete from backup.round_aggregates_bak;
