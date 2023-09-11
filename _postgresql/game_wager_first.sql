-- dbo.game_wager_firsts definition

-- Drop table

DROP TABLE dbo.game_wager_firsts;

CREATE TABLE dbo.game_wager_firsts (
	game_provider_id uuid NOT NULL, -- 遊戲供應商識別碼
	game_id int4 NOT NULL, -- 遊戲識別碼
	wallet_id uuid NOT NULL, -- 錢包識別碼
	external_wager_id varchar(255) NOT NULL, -- 三方投注識別碼
	first_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 首筆時間
	wager_id int8 NOT NULL, -- 投注識別碼
	game_provider_configuration_id uuid NOT NULL, -- 遊戲供應商設定識別碼
	reseller_id uuid NOT NULL, -- 公司識別碼
	licensee_id uuid NOT NULL, -- 分公司識別碼
	brand_id uuid NOT NULL, -- 平台識別碼
	player_code text NOT NULL, -- 玩家代碼
	currency_code varchar(16) NOT NULL, -- 貨幣代碼
	wager_state int4 NOT NULL DEFAULT 0, -- 投注狀態
	wager_type int4 NOT NULL DEFAULT 0, -- 投注類型
	closed_state int4 NOT NULL DEFAULT 0, -- 關閉狀態
	void_state int4 NOT NULL DEFAULT 0, -- 作廢狀態
	cancel_state int4 NOT NULL DEFAULT 0, -- 取消狀態
	free_game_state int4 NOT NULL DEFAULT 0, -- 免費遊戲狀態
	gamble_state int4 NOT NULL DEFAULT 0, -- 博取遊戲狀態
	cashout_state int4 NOT NULL DEFAULT 0, -- 兌現狀態
	resettle_state int4 NOT NULL DEFAULT 0, -- 重新結算狀態
	external_round_id varchar(255) NOT NULL, -- 三方局/回合識別碼
	external_created_on timestamptz NOT NULL DEFAULT '1970-01-01 08:00:00+08'::timestamp with time zone, -- 三方下注/創建時間
	external_closed_on timestamptz NOT NULL DEFAULT '1970-01-01 08:00:00+08'::timestamp with time zone, -- 三方結算/結束時間
	external_payoff_on timestamptz NOT NULL DEFAULT '1970-01-01 08:00:00+08'::timestamp with time zone, -- 三方派彩時間
	external_resettle_on timestamptz NOT NULL DEFAULT '1970-01-01 08:00:00+08'::timestamp with time zone, -- 三方重新結算時間
	currency_ratio numeric(18, 6) NOT NULL DEFAULT 0.0, -- 貨幣比例
	bet numeric(18, 6) NOT NULL DEFAULT 0.0, -- 下注
	valid_bet numeric(18, 6) NOT NULL DEFAULT 0.0, -- 實際/有效下注
	settle numeric(18, 6) NOT NULL DEFAULT 0.0, -- 結算(包含本金)
	commission numeric(18, 6) NOT NULL DEFAULT 0.0, -- 傭金
	turnover numeric(18, 6) NOT NULL DEFAULT 0.0, -- 有效投注
	win_loss numeric(18, 6) NOT NULL DEFAULT 0.0, -- 玩家損益/淨利
	created_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 創建時間
	closed_on timestamptz NOT NULL DEFAULT '1970-01-01 08:00:00+08'::timestamp with time zone, -- 結束時間
	updated_on timestamptz NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 修改時間
	CONSTRAINT pk_game_wager_firsts PRIMARY KEY (first_on, game_provider_id, game_id, wallet_id, external_wager_id)
)PARTITION BY RANGE (first_on);

CREATE INDEX ix_game_wager_firsts ON dbo.game_wager_firsts USING btree (game_provider_id, game_id, wallet_id, external_wager_id);
CREATE INDEX ix_game_wager_firsts_external_round_id ON dbo.game_wager_firsts USING btree (external_round_id);
CREATE INDEX ix_game_wager_firsts_external_wager_id ON dbo.game_wager_firsts USING btree (external_wager_id);
CREATE INDEX ix_game_wager_firsts_first_on_brand_id ON dbo.game_wager_firsts USING btree (first_on, brand_id);
CREATE INDEX ix_game_wager_firsts_first_on_brand_id_player_code ON dbo.game_wager_firsts USING btree (first_on, brand_id, player_code);
CREATE INDEX ix_game_wager_firsts_first_on_external_round_id ON dbo.game_wager_firsts USING btree (first_on, external_round_id);
CREATE INDEX ix_game_wager_firsts_first_on_external_wager_id ON dbo.game_wager_firsts USING btree (first_on, external_wager_id);
CREATE INDEX ix_game_wager_firsts_first_on_game_id ON dbo.game_wager_firsts USING btree (first_on, game_id);
CREATE INDEX ix_game_wager_firsts_first_on_game_provider_id ON dbo.game_wager_firsts USING btree (first_on, game_provider_id);
CREATE INDEX ix_game_wager_firsts_first_on_player_code ON dbo.game_wager_firsts USING btree (first_on, player_code);
CREATE INDEX ix_game_wager_firsts_first_on_wager_id ON dbo.game_wager_firsts USING btree (first_on, wager_id);
CREATE INDEX ix_game_wager_firsts_wager_id ON dbo.game_wager_firsts USING btree (wager_id);

-- Column comments

COMMENT ON COLUMN dbo.game_wager_firsts.game_provider_id IS '遊戲供應商識別碼';
COMMENT ON COLUMN dbo.game_wager_firsts.game_id IS '遊戲識別碼';
COMMENT ON COLUMN dbo.game_wager_firsts.wallet_id IS '錢包識別碼';
COMMENT ON COLUMN dbo.game_wager_firsts.external_wager_id IS '三方投注識別碼';
COMMENT ON COLUMN dbo.game_wager_firsts.first_on IS '首筆時間';
COMMENT ON COLUMN dbo.game_wager_firsts.wager_id IS '投注識別碼';
COMMENT ON COLUMN dbo.game_wager_firsts.game_provider_configuration_id IS '遊戲供應商設定識別碼';
COMMENT ON COLUMN dbo.game_wager_firsts.reseller_id IS '公司識別碼';
COMMENT ON COLUMN dbo.game_wager_firsts.licensee_id IS '分公司識別碼';
COMMENT ON COLUMN dbo.game_wager_firsts.brand_id IS '平台識別碼';
COMMENT ON COLUMN dbo.game_wager_firsts.player_code IS '玩家代碼';
COMMENT ON COLUMN dbo.game_wager_firsts.currency_code IS '貨幣代碼';
COMMENT ON COLUMN dbo.game_wager_firsts.wager_state IS '投注狀態';
COMMENT ON COLUMN dbo.game_wager_firsts.wager_type IS '投注類型';
COMMENT ON COLUMN dbo.game_wager_firsts.closed_state IS '關閉狀態';
COMMENT ON COLUMN dbo.game_wager_firsts.void_state IS '作廢狀態';
COMMENT ON COLUMN dbo.game_wager_firsts.cancel_state IS '取消狀態';
COMMENT ON COLUMN dbo.game_wager_firsts.free_game_state IS '免費遊戲狀態';
COMMENT ON COLUMN dbo.game_wager_firsts.gamble_state IS '博取遊戲狀態';
COMMENT ON COLUMN dbo.game_wager_firsts.cashout_state IS '兌現狀態';
COMMENT ON COLUMN dbo.game_wager_firsts.resettle_state IS '重新結算狀態';
COMMENT ON COLUMN dbo.game_wager_firsts.external_round_id IS '三方局/回合識別碼';
COMMENT ON COLUMN dbo.game_wager_firsts.external_created_on IS '三方下注/創建時間';
COMMENT ON COLUMN dbo.game_wager_firsts.external_closed_on IS '三方結算/結束時間';
COMMENT ON COLUMN dbo.game_wager_firsts.external_payoff_on IS '三方派彩時間';
COMMENT ON COLUMN dbo.game_wager_firsts.external_resettle_on IS '三方重新結算時間';
COMMENT ON COLUMN dbo.game_wager_firsts.currency_ratio IS '貨幣比例';
COMMENT ON COLUMN dbo.game_wager_firsts.bet IS '下注';
COMMENT ON COLUMN dbo.game_wager_firsts.valid_bet IS '實際/有效下注';
COMMENT ON COLUMN dbo.game_wager_firsts.settle IS '結算(包含本金)';
COMMENT ON COLUMN dbo.game_wager_firsts.commission IS '傭金';
COMMENT ON COLUMN dbo.game_wager_firsts.turnover IS '有效投注';
COMMENT ON COLUMN dbo.game_wager_firsts.win_loss IS '玩家損益/淨利';
COMMENT ON COLUMN dbo.game_wager_firsts.created_on IS '創建時間';
COMMENT ON COLUMN dbo.game_wager_firsts.closed_on IS '結束時間';
COMMENT ON COLUMN dbo.game_wager_firsts.updated_on IS '修改時間';


grant all privileges on table dbo.game_wager_firsts to tgs_migration;
grant all privileges on table dbo.game_wager_firsts to tgs_app;
grant select on table dbo.game_wager_firsts to tgs_reader;

SELECT partman.create_parent(p_parent_table => 'dbo.game_wager_firsts',
 p_control => 'first_on',
 p_type => 'native',
 p_interval=> 'daily',							 
 p_premake => 24);

CALL partman.run_maintenance_proc(); 

select count(1) from partman.show_partitions ('dbo.game_wager_firsts');
