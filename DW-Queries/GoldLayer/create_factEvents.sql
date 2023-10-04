SELECT 
    row_number() over(order by fk_match_id, minute, extra_time asc) + 2000000 as pk_fact_event
    , *
FROM(
  (SELECT
    rc.match_id AS fk_match_id,
    edt.pk_team AS fk_team_id,
    REPLACE(CAST(rf.date AS string), "-", "") AS fk_calendar_id,
    edj.pk_player AS fk_player_id,
    ede.pk_stadium AS fk_stadium_id,
    rc.card AS event,
    rc.minute,
    rc.extra_time
  FROM
    `brasileirao-362523.1_bronze.cards` as rc
  JOIN
    `brasileirao-362523.3_gold.dimTeam` as edt
      ON rc.club = edt.team 
      AND rc.match_id BETWEEN edt.start_id AND edt.end_id    
  JOIN
    `brasileirao-362523.1_bronze.matches` as rf 
      ON rc.match_id = rf.match_id
  JOIN
    `brasileirao-362523.3_gold.dimStadium` as ede 
      ON rf.stadium = ede.stadium
  JOIN
    `brasileirao-362523.3_gold.dimPlayer` as edj 
      ON initcap(replace(rc.player, '_', ' ')) = edj.player_name 
      AND rc.club = edj.club
      AND rc.match_id BETWEEN edj.first_match_id AND edj.last_match_id
  ORDER BY
    rc.match_id)

  UNION ALL

  (SELECT
    rg.match_id AS fk_match_id,
    edt.pk_team AS fk_team_id,
    REPLACE(CAST(rf.date AS string), "-", "") AS fk_calendar_id,
    edj.pk_player AS fk_player_id,
    ede.pk_stadium AS fk_stadium_id,
    'goal' AS event,
    rg.minute,
    coalesce(rg.extra_time, 0) AS extra_time
  FROM
    `brasileirao-362523.1_bronze.goals` as rg
  JOIN
    `brasileirao-362523.3_gold.dimTeam` as edt 
      ON rg.club = edt.team
      AND rg.match_id BETWEEN edt.start_id AND edt.end_id
  JOIN
    `brasileirao-362523.1_bronze.matches` as rf 
      ON rg.match_id = rf.match_id
  JOIN
    `brasileirao-362523.3_gold.dimStadium` as ede 
      ON rf.stadium = ede.stadium
  JOIN
    `brasileirao-362523.3_gold.dimPlayer` as edj 
      ON initcap(replace(rg.player, '_', ' ')) = edj.player_name
      AND rg.club = edj.club
      AND rg.match_id BETWEEN edj.first_match_id AND edj.last_match_id
  ORDER BY
    rg.match_id)
  )
ORDER BY 
  fk_match_id, 
  minute, 
  extra_time
