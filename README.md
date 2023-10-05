# Brazilian Soccer Championship Analysis
## Summary
> O que é
> 
> O que foi usado (ferramentas e conceitos)
>
> Funções de cada um no projeto

This project aims to analyze the Brazilian Soccer Championship, also known as "Brasileirão", which is the top-tier professional football league in Brazil. The analysis is based on the historical data of the championship, including match results, player statistics, and other relevant factors.

The project was divided into 3 steps:

1. Data Selection
2. Data Manipulation
3. Data Analysis and Vizualization

<br>


# 1. Data Selection <br>
The first step consisted of selecting the datasets to be used in the project. The ones we choose are available [here](https://www.kaggle.com/datasets/adaoduque/campeonato-brasileiro-de-futebol).
After the dataset was selected, it was loaded into Google Sheets for a preliminary verification of data quality and to ensure uniform formatting.

With the initials adjustments done, the tables were lodaded into BigQuery as "raw" tables (bronze layer) to begin the massive transformations.

<br>

# 2. Data Manipulation <br>
In the second step, our objective was to build a data warehouse architecture and model all the raw data that had been extracted. The structure was designed based on 3 data marts.

- The main data mart stores the data about events in each match. It comprises a transactional table named `factEvents` and five additional dimensions: `dimMatch`, `dimPlayer`, `dimStadium`, `dimTeam` and `dimCalendar`.
- The second data mart contains data regarding match statistics, with a central table named `factStatistics` that relates to `dimTeam` and `dimMatch`.
- The third and final data mart records the final score table for each year and the main table `factScore` is also related to `dimTeam`.

Subsequently, the ETL process as well as the final tables will be presented in a detailed manner below.

![](./assets/datamodel_picture.png)
*ERD of brasileirao championship data model*

<br>

The entire model is represented [here](https://drive.google.com/file/d/1ejlKub_w4EP8wMyLYU0ykyO7PT3yaIc9/view?usp=sharing).


### ETL process
After the completion of the extraction phase, the data transformation step was initiated. For this stage, an ETL process was developed using SQL to establish the data warehousing solution. Given the structure of the raw data, the dimensional modeling "star schema" was chosen as the optimal option to address the business questions.

For data storage and the execution of all transformation steps, the BigQuery platform was employed. Within BigQuery, three layers were created to process the data according to the phase and data application.

👉 **Bronze layer**: This layer contains raw tables from Google Sheets files.

👉 **Silver layer**: This layer contains two intermediary tables used specifically on the `dimPlayer` creation process.

👉 **Gold layer**: This layer contains the final data warehouse tables (fact-s and dim´s) with curated data ready to be used.

@TODO [UM DESENHO DO PROCESSO DE ETL]

@TODO [FALAR SOBRE OS ACESSOS AO BIGQUERY - TABELAS DO DW E QUERIES]

### Data model
As mentioned earlier, the model consists of 3 fact tables and 5 dimensional tables that are related to each other through a star schema modeling across 3 data marts. Subsequently, a detailed explanation of each table stored in the data warehouse will follow.

⚽ `dimMatch`: Information about the matches such as the winner team, stadium and match date.

🏃🏽‍♂️ `dimPlayer`: Table containing data about each identified player. 'Player_name', 'Position' and 'Jersey_number' are some of the columns in this table.

🏟 `dimStadium`: Store data about the stadium names and locations.

🛡 `dimTeam`: This is one of the tables that uses Slowly Changing Dimensions (SCD) due to coach changes over time.

📅 `dimCalendar`: The last dimension is a table that stores date-related data for time-based analysis.

🥅 `factEvents`: This is the main table table in the model. It´s related to all dimensional tables and store all the goals, red cards and yellow cards and when they occurred.

🔢 `factStatistics`: Some statistical reports can be extracted from here, such as ball possession, passing accuracy and offsides.

🏅 `factScore`: The third fact table store the final league position and score, as well as the number of wins separated by home and away mathces.

- Explicar sobre os tipos de scd utilizados
    - dimTime - a partir da tabela brasileiro_full e do os id´s de partidas como sat_id e end_id
    - dimJogador - a partir das tabelas de stg, que por sua vez utilizaram as tabelas de eventos e gols. Porém, como apenas a tabela de eventos possuía posição e nº da camisa, o scd criado utilizado como end_id, o valor de start_id-1 (subtração) da linha seguinte


<br>


# 3. Data Analysis and Vizualization
In the third phase of the project, the data analysis itself was made using the data model that had been created previously.

To do that was raised some hyphotesis to be validated outputting on acceptance or rejection. 

About the hypothesis, some that are highlighted are:

- 📌 *Home teams win more frequently*
- 📌 *Home teams receive fewer cards*
- 📌 *Teams with an expelled player in the first half have more chance to lose the game*
- 📌 *Champions teams have more pass accuracy*
- 📌 *The matches of the second turn have more events (goals and cards) than the matches of the first*


To accomplish the analysis, some ETL processes were, all of them written in Python, using Google Colab as the processing tool, and to get the data, a direct connection between Colab and BigQuery was made using its native integration.

> 📘 **_Google Colab_ was chosen because of its easy connection between notebooks and BigQuery, being the latter where the data is.**

Below are the notebooks used to do the data analysis:

- [Home teams win more frequently](https://github.com/igoravelli/brazilian_soccer_championship_analysis/blob/readme-file/Win_frequency_in_home_matches.ipynb)
- [Home teams receive fewer cards](https://github.com/igoravelli/brazilian_soccer_championship_analysis/blob/main/Average_of_cards_in_home_team_matches.ipynb)
- [Teams with an expelled player in the first half have more chance to lose the game](https://github.com/igoravelli/brazilian_soccer_championship_analysis/blob/main/Number_of_matches_with_expelled_players.ipynb)
- [Champions teams have more pass accuracy](https://github.com/igoravelli/brazilian_soccer_championship_analysis/blob/main/Teams_accuracy_pass.ipynb)
- [The matches of the second turn have more events (goals and cards) than the matches of the first](https://github.com/igoravelli/brazilian_soccer_championship_analysis/blob/main/Events_frequency_along_the_turns_.ipynb)


⏩ There is a conclusion of the analysis by the end of each notebook

<br>

Besides the hypothesis mentioned before, also was proposed the following discussion:
> 📢 Is there a pattern about when (during the game) each winning team scores? Does the landscape change when the winner is the home team?
> 
> 🔎 [notebook with the analysis](https://github.com/igoravelli/brazilian_soccer_championship_analysis/blob/main/Goal_scoring_distribution_by_team.ipynb)
>
> As an output of this discussion, the following chart shows the goals score distribution throughout the match by team in 2014.
> 
> ![](./assets/goal_score_distribuition.png)
> *goals score distribution throughout the match by team in 2014*

<br>

# References
KIMBALL, Ralph. The data warehouse toolkit: practical techniques for building dimensional data warehouses. John Wiley & Sons, Inc., 1996.

MUNZNER, Tamara et al. Exploratory data analysis.

Google Cloud. (2023). Google BigQuery Documentation. Retrieved from (https://cloud.google.com/bigquery/docs)

Google. (2023). Google Colab Documentation. Retrieved from (https://colab.research.google.com/notebooks/intro.ipynb)
