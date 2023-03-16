explain SELECT
r.id
FROM
bet.rounds AS r
WHERE
r.external_round_id = ?
AND r.game_provider_id = ?
AND r.game_id = ?
AND r.wallet_id = ?;



--有問題
explain SELECT
COUNT(*)::int
FROM
bet.rounds AS r
LEFT JOIN dbo.players AS p ON r.player_code = p.player_code
LEFT JOIN dbo.games AS g ON r.game_id = g.id
LEFT JOIN bet.round_details AS r0 ON r.id = r0.round_id
LEFT JOIN dbo.game_providers AS g0 ON r.game_provider_id = g0.id
LEFT JOIN dbo.brand_games AS b ON (r.brand_id = b.brand_id)
AND (r.game_id = b.game_id)
WHERE
r.status = 2;


explain SELECT
COUNT(*)::int
FROM
bet.rounds AS r
LEFT JOIN dbo.players AS p ON r.player_code = p.player_code
LEFT JOIN dbo.games AS g ON r.game_id = g.id
LEFT JOIN bet.round_details AS r0 ON r.id = r0.round_id
LEFT JOIN dbo.game_providers AS g0 ON r.game_provider_id = g0.id
LEFT JOIN dbo.brand_games AS b ON (r.brand_id = b.brand_id)
AND (r.game_id = b.game_id)
WHERE ((r.brand_id = 'ae3375fc-d369-49d3-b538-2c26f758746f')
AND ((r.created_on >= '2023-01-13 16:00:00+00')
AND (r.created_on < '2023-02-14 16:00:00+00')))
AND (r.player_code = '4uiwpyw4pvqu');



explain SELECT
gp.code AS "????",
b.code AS "Brand",
p.player_code AS "PlayerCode",
p.username AS "Username",
r.wallet_id AS "????",
r.external_round_id AS "????",
g.code AS "????"
FROM
bet.rounds r
JOIN dbo.game_providers gp ON r.game_provider_id = gp.id
JOIN dbo.brands b ON r.brand_id = b.id
JOIN dbo.players p ON r.player_code = p.player_code
JOIN dbo.games g ON r.game_id = g.id
WHERE
r.created_on >= '2023-02-13 00:00:00.000 +0800'
AND r.created_on < '2023-02-14 00:00:00.000 +0800'
GROUP BY
gp.code,
b.code,
p.player_code,
p.username,
r.wallet_id,
r.external_round_id,
g.code
HAVING
count(*) > 1;


explain SELECT
COUNT(*)
FROM (
SELECT
gp.code AS "????",
b.code AS "Brand",
p.player_code AS "PlayerCode",
p.username AS "Username",
r.wallet_id AS "????",
r.external_round_id AS "????",
g.code AS "????"
FROM
bet.rounds r
JOIN dbo.game_providers gp ON r.game_provider_id = gp.id
JOIN dbo.brands b ON r.brand_id = b.id
JOIN dbo.players p ON r.player_code = p.player_code
JOIN dbo.games g ON r.game_id = g.id
WHERE
r.created_on >= '2023-02-15 00:00:00.000 +0800'
AND r.created_on < '2023-02-16 00:00:00.000 +0800'
GROUP BY
gp.code,
b.code,
p.player_code,
p.username,
r.wallet_id,
r.external_round_id,
g.code
HAVING
count(*) > 1) dbvrcnt;

