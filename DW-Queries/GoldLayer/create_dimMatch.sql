SELECT
    matches.match_id as pk_match,
    matches.stadium,
    matches.away_team,
    matches.home_team,
    matches.round,
    cast(concat(matches.date," ", matches.hour, ":00") as datetime) as match_date,
    if(cast(matches.date as datetime) between '2021-01-01' and '2021-03-01', -- Due to COVID, some matches of 2020 has been played in the beginning of 2021
       cast(2020 as string),
       substring(cast(matches.date as string),1, 4) 
    ) as championship_year,
    matches.home_team_squad,
    matches.away_team_squad,
    case
        when matches.winner = '-' then null
        when matches.winner = matches.home_team then matches.home_team
        else matches.away_team
    end as winner,
    case
        when matches.winner = '-' then null
        when matches.winner = matches.home_team then matches.away_team
        else matches.home_team
    end as loser
FROM
    `brasileirao-362523.1_bronze.matches` as matches
