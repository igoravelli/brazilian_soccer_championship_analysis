select
    row_number() over(order by match_id asc) + 3000000 as pk_statistics
    ,match_id as fk_match_id
    ,dtime.pk_team as fk_team_id
    ,estat.shots
    ,estat.shots_on_target
    ,cast(
        if(estat.ball_possession = "N/A", '0', estat.ball_possession)
        as FLOAT64
    ) as ball_possession
    ,estat.passes
    ,cast(
        if(estat.passing_accuracy = "N/A", '0', estat.passing_accuracy)
        as FLOAT64
    ) as passing_accuracy
    ,estat.fouls
    ,estat.yellow_card
    ,estat.red_card
    ,estat.offsides
    ,estat.corners
from
    `brasileirao-362523.1_bronze.statistics` as estat
left join 
    `brasileirao-362523.3_gold.dimTeam` as dtime
      on estat.club = dtime.team
      and estat.match_id between dtime.start_id and dtime.end_id
where 
    estat.match_id is not null -- because make no sense retrieve blank rows or data about matches without IDs
order by 
    estat.match_id


