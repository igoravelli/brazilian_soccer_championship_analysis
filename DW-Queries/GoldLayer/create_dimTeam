WITH stadium_frequency AS (
  SELECT
    home_team,
    stadium,
    COUNT(*) AS `number_of_matches`,
    FIRST_VALUE(stadium) OVER (PARTITION BY home_team ORDER BY COUNT(*) DESC) AS `main_stadium`
  FROM
    `1_bronze.matches`
  GROUP BY
    home_team, stadium
  ORDER BY
    home_team, COUNT(*) DESC
),

initial_merge_matches_cte AS ( --Initial CTE responsible for the flow of filling in the 'coach' field for the case where the team is the home team, since in the table the 'home_coach' and 'away_coach' columns are the same, referring to the away team.
  SELECT
    match_id,
    away_team AS team,
    away_team_coach AS coach
  FROM
    `1_bronze.matches`

    UNION ALL

  SELECT
    match_id,
    home_team AS team,
    NULL AS coach
  FROM
    `1_bronze.matches`
),

lag_merge_matches AS (
  SELECT *,
    LAG(coach) OVER (PARTITION BY team ORDER BY match_id ASC) AS lag_coach,
    IF(
      (coach is NOT NULL AND LAG(coach) OVER (PARTITION BY team ORDER BY match_id ASC) is NULL) -- Identifies the moment of change from null to a valid coach.
      OR (coach <> LAG(coach) OVER (PARTITION BY team ORDER BY match_id ASC) AND coach is NOT NULL), -- Identifies the moment of change between valid coaches.
      1, 0) AS comparative
  FROM
    initial_merge_matches_cte
  ORDER BY
    match_id
),

sum_merge_matches AS (
  SELECT *,
    SUM(comparative) OVER (PARTITION BY team ORDER BY match_id ASC) AS asc_block, -- This command will set the majority of null coaches (given priority in COALESCE).
    SUM(comparative) OVER (PARTITION BY team ORDER BY match_id DESC) AS desc_block -- Command necessary for cases where the team has null as the first coach.
  FROM
    lag_merge_matches
  ORDER BY
    team, match_id
),

final_merge_matches_cte AS (
  SELECT match_id, team,
    COALESCE(FIRST_VALUE(coach) OVER (PARTITION BY team, asc_block ORDER BY match_id ASC), FIRST_VALUE(coach) OVER (PARTITION BY team, desc_block ORDER BY match_id DESC)) AS coach
  FROM
    sum_merge_matches
  ORDER BY
    team, match_id
  ),

initial_scd_coach_cte as (
 SELECT
  match_id,
  team,
  coach,
  LEAD(coach) OVER (PARTITION BY team ORDER BY match_id ASC) AS lead_coach,
  IF(coach <> LEAD(coach) OVER (PARTITION BY team ORDER BY match_id ASC), 1, 0) AS flag_diff,
 FROM
  final_merge_matches_cte
 ORDER BY
  team, match_id),

 lead_flag_diff_cte AS ( -- CTE uniquely created to apply the 'lead' function to 'flag_diff', so that the value '1' identifies the start of a coach's work.
  SELECT
    match_id,
    team,
    coach,
    lead_coach,
    flag_diff,
    coalesce(LAG(flag_diff) OVER (PARTITION BY team ORDER BY match_id ASC), 0) AS lead_flag_diff
  FROM initial_scd_coach_cte),

  var_bloco_creation_cte AS (
  SELECT
    match_id,
    team,
    coach,
    lead_coach,
    lead_flag_diff,
    SUM(lead_flag_diff) OVER (PARTITION BY team ORDER BY match_id ASC) AS block
  FROM lead_flag_diff_cte),

  final_scd_coach_cte AS (
  SELECT
    match_id,
    team,
    coach,
    FIRST_VALUE(match_id) OVER (PARTITION BY team, coach, block ORDER BY match_id ASC) AS start_id,
    FIRST_VALUE(match_id) OVER (PARTITION BY team, coach, block ORDER BY match_id DESC) AS end_id
  FROM var_bloco_creation_cte
  ORDER BY
    team, match_id)

-- main
SELECT
  row_number() over (order by `1_bronze.matches`.home_team, cch.start_id asc) + 1000 AS pk_team,
  `1_bronze.matches`.home_team AS team,
  `1_bronze.matches`.home_team_state AS state,
  freq.`main_stadium` AS stadium,
  cch.coach,
  cch.start_id, -- ID indicating the start of the coach's work.
  cch.end_id -- ID indicating the end of the coach's work.
FROM
  `1_bronze.matches`
JOIN
  stadium_frequency freq ON freq.home_team = `1_bronze.matches`.home_team
JOIN
  final_scd_coach_cte cch ON cch.team = `1_bronze.matches`.home_team
GROUP BY
  `1_bronze.matches`.home_team, home_team_state, freq.`main_stadium`, cch.coach, cch.start_id, cch.end_id
ORDER BY 
  `1_bronze.matches`.home_team, cch.start_id
