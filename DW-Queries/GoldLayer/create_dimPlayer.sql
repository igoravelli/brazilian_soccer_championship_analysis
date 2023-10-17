WITH all_events AS ( 
  SELECT
    match_id,
    initcap(replace(player, '_', ' ')) AS player_name,
    club,
    NULL AS position,
    NULL AS jersey_number,
    'goal' AS event
  FROM
    `brasileirao-362523.1_bronze.goals`
UNION ALL
  SELECT
    match_id,
    initcap(replace(player, '_', ' ')) AS player_name,
    club,
    position,
    jersey_number,
    card
  FROM
    `brasileirao-362523.1_bronze.cards`
)

, most_used_jersey_number as (
  SELECT
    player,
    club,
    jersey_number
  FROM
    (
      SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY player, club ORDER BY match_id_diff DESC) AS rn
      FROM
        `brasileirao-362523.2_silver.players_jersey_number_scd`
      ORDER BY
        match_id_diff DESC
    )
  WHERE
    rn = 1
  ORDER BY
    player
)

, most_used_position AS (
  SELECT
    player,
    club,
    position
  FROM
    (
      SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY player, club ORDER BY match_id_diff DESC) AS rn
      FROM
        `brasileirao-362523.2_silver.players_positions_scd`
      ORDER BY
        match_id_diff DESC
    )
  WHERE
    rn = 1
  ORDER BY
    player
)


, all_data AS (
  SELECT
    events.match_id,
    events.player_name,
    events.club, 
    COALESCE(positions_scd.position, mup.position) as position,
    COALESCE(jersey_number_scd.jersey_number, munc.jersey_number) as jersey_number
  FROM
    all_events as events
  LEFT JOIN 
    `brasileirao-362523.2_silver.players_jersey_number_scd` as jersey_number_scd
      ON events.player_name = jersey_number_scd.player
      AND events.club = jersey_number_scd.club
      AND events.match_id BETWEEN jersey_number_scd.min_match_id AND jersey_number_scd.max_match_id
  LEFT JOIN
    `brasileirao-362523.2_silver.players_positions_scd` as positions_scd
      ON events.player_name = positions_scd.player
      AND events.club = positions_scd.club
      AND events.match_id BETWEEN positions_scd.min_match_id AND positions_scd.max_match_id
  LEFT JOIN 
    most_used_jersey_number as munc
      ON munc.player = events.player_name
      AND munc.club = events.club
  LEFT JOIN 
    most_used_position as mup
      ON mup.player = events.player_name
      AND mup.club = events.club
  ORDER BY
    match_id ASC
)



--- MAIN ---
SELECT 
  ROW_NUMBER() OVER(ORDER BY player_name, season ASC) + 10000 AS pk_player,
  player_name,
  club,
  season,
  position,
  jersey_number,
  MIN(match_id) AS first_match_id,
  MAX(match_id) AS last_match_id
FROM
(
  SELECT 
    *,
    SUM(
      CASE 
        WHEN is_different_position OR is_different_jersey_number OR rn = 1 THEN 1
        ELSE 0
      END
    ) OVER(PARTITION BY player_name ORDER BY match_id) AS season
  FROM
    (
      SELECT 
        *,
        position <> LAG(position) OVER(PARTITION BY player_name, club ORDER BY match_id) AS is_different_position,
        jersey_number <> LAG(jersey_number) OVER(PARTITION BY player_name, club ORDER BY match_id) AS is_different_jersey_number,
        ROW_NUMBER() OVER(PARTITION BY player_name, club ORDER BY match_id) AS rn
      FROM 
        all_data
      ORDER BY 
        match_id
    )
  ORDER BY
    match_id,
    player_name
)
GROUP BY 
  player_name,
  club,
  position,
  jersey_number,
  season
ORDER BY 
  player_name,
  first_match_id
