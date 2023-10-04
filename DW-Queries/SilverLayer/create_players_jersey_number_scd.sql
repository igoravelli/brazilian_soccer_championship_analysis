SELECT
  player,
  club,
  season,
  jersey_number,
  min_match_id,
  COALESCE(LEAD(min_match_id) OVER (PARTITION BY player ORDER BY min_match_id) - 1, tbl.max_match_id) max_match_id,
  match_id_diff
FROM(  
  SELECT 
    initcap(replace(player, '_', ' ')) player,
    club,
    season,
    jersey_number,
    min(match_id) as min_match_id,
    max(match_id) as max_match_id,
    max(match_id) - min(match_id) as match_id_diff
  FROM 
  (
    SELECT   
      *,
      sum (
        case 
          when is_different_team or is_different_position or rn = 1 then 1
          else 0
        end
      ) over(partition by player order by match_id) as season
    FROM
    (
        SELECT
        match_id,
        player,
        club,
        jersey_number,
        club <> lag(club) over(partition by player order by match_id asc) as is_different_team,
        position <> lag(position) over(partition by player order by match_id asc) as is_different_position,
        row_number() over(partition by player, club order by match_id asc) as rn
      FROM
        `brasileirao-362523.1_bronze.cards`
      ORDER BY
        player ASC,
        match_id ASC
    )
    ORDER BY 
      match_id ASC
  )
  GROUP BY 
    player,
    club,
    jersey_number,
    season
  ) tbl
ORDER BY 
  player,
  min_match_id
