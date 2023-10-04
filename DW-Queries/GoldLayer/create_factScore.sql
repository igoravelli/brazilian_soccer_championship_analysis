WITH points_per_match AS (
  SELECT
    dm.pk_match,
    dm.home_team AS home_team,
    dm.away_team AS away_team,
    dm.championship_year,
    CASE
      WHEN dm.winner is not null THEN dm.winner
      WHEN dm.winner is null THEN dm.home_team
    END AS `winner_or_draw1`,
    CASE
      WHEN dm.winner is not null THEN 3
      WHEN dm.winner is null THEN 1
    END AS `points_team1`,
      CASE
      WHEN dm.loser is not null THEN dm.loser
      WHEN dm.loser is null THEN dm.away_team
    END AS `loser_or_draw2`,
      CASE
      WHEN dm.loser is not null THEN 0
      WHEN dm.loser is null THEN 1
    END AS `points_team2`
  FROM
    `3_gold.dimMatch` dm
  ORDER BY
    dm.pk_match
),

scores AS (
  SELECT distinct
    championship_year,
    `winner_or_draw1` AS team,
    SUM(`points_team1`) OVER (PARTITION BY championship_year, `winner_or_draw1`) AS score,
  FROM
    points_per_match ppm

    UNION ALL

  SELECT distinct
    championship_year,
    `loser_or_draw2` AS team,
    SUM(`points_team2`) OVER (PARTITION BY championship_year, `loser_or_draw2`) AS score
  FROM
    points_per_match ppm
  ),

number_of_wins as (
  SELECT
    COALESCE(home.championship_year, away.championship_year) AS championship_year,
    COALESCE(home.team, away.team) AS team,
    home_team_wins,
    away_team_wins
  FROM(
    SELECT distinct
      championship_year,
      home_team AS team,
      COALESCE((SUM(`points_team1`) OVER (PARTITION BY championship_year, `winner_or_draw1`)) / 3, 0) AS home_team_wins -- Add up the score and divide by 3 to calculate the number of victories
    FROM
      points_per_match ppm
    WHERE
      home_team = `winner_or_draw1`
      AND `points_team1` = 3
  ) home
  FULL OUTER JOIN(
    SELECT distinct
      championship_year,
      away_team AS team,
      COALESCE((SUM(`points_team1`) OVER (PARTITION BY championship_year, `winner_or_draw1`)) / 3, 0) AS away_team_wins
    FROM
      points_per_match ppm
    WHERE
      away_team = `winner_or_draw1`
      AND `points_team1` = 3
  ) away ON home.championship_year = away.championship_year AND home.team = away.team
),

cte_fk_team AS (
    SELECT
        match.championship_year  
      , events.fk_team_id
      , team.team as team_name
    FROM
      `brasileirao-362523.3_gold.factEvents` AS events
    INNER JOIN
      `brasileirao-362523.3_gold.dimMatch` AS match
          ON match.pk_match = events.fk_match_id
          AND match.round = 38        # last match of the season only
    INNER JOIN 
        `brasileirao-362523.3_gold.dimTeam` as team
          ON team.pk_team = events.fk_team_id
    GROUP BY
        match.championship_year  
      , events.fk_team_id 
      , team.team                          
)

SELECT
    ROW_NUMBER() OVER (ORDER BY championship_year DESC, position ASC) + 4000000 pk_score,
    *
FROM (
  SELECT
    t.championship_year,
    ROW_NUMBER() OVER (PARTITION BY t.championship_year ORDER BY score DESC, home_team_wins + away_team_wins DESC) as position,
    fkt.fk_team_id,
    score,
    home_team_wins + away_team_wins as number_of_wins,
    home_team_wins,
    away_team_wins
  FROM (
    SELECT distinct
      scr.championship_year,
      scr.team, -- team's name
      SUM(`score`) OVER (PARTITION BY scr.championship_year, scr.team) AS score,
      COALESCE(cast(home_team_wins as int), 0) AS home_team_wins,
      COALESCE(cast(away_team_wins as int), 0) AS away_team_wins
    FROM
      scores scr
    INNER JOIN
      number_of_wins nwn ON scr.championship_year = nwn.championship_year AND scr.team = nwn.team
  ) t
  INNER JOIN
    cte_fk_team fkt ON t.team = fkt.team_name AND t.championship_year = fkt.championship_year
)
ORDER BY
  championship_year DESC,
  position ASC,
  number_of_wins DESC
