WITH
  stadium_frequency AS (
  SELECT
    stadium,
    home_team_state,
    COUNT(*) AS `number_of_matches`,
    FIRST_VALUE(home_team_state) OVER (PARTITION BY stadium ORDER BY COUNT(*) DESC) AS `state`
  FROM
    `1_bronze.matches`
  GROUP BY
    stadium,
    home_team_state
  ORDER BY
    stadium,
    COUNT(*) DESC )

SELECT
  DISTINCT ROW_NUMBER() OVER (ORDER BY stadium ASC) + 100000 AS pk_stadium,
  stadium,
  state
FROM
  stadium_frequency
GROUP BY
  stadium,
  state
