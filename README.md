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

# 2. Manipulate the data <br>
In the second step, our objective was to build a data warehouse architecture and model all the raw data that had been extracted. The structure was designed based on 3 data marts.

- The main data mart stores the data about events in each match. It comprises a transactional table named `factEvents` and five additional dimensions: `dimMatch`, `dimPlayer`, `dimArena`, `dimTeams` and `dimCalendar`.
- The second data mart contains data regarding match statistics, with a central table named `factStatistics` that relates to `dimTeams`.
- The third and final data mart records the final score table for each year and the main table `factScore` is also related exclusively to `dimTeams`.

![](datamodel_picture.png)

The entire model is represented [here](https://drive.google.com/file/d/1ejlKub_w4EP8wMyLYU0ykyO7PT3yaIc9/view?usp=sharing).


### ETL process
To start, this project was built an ETL process using python and SQL to extract the data from the csv files, manipulate them and create a star schema data model to be used to answer the business questions.

@TODO [UM DESENHO DO PROCESSO DE ETL]

To storage the data, was used the BigQuery platform. On it, was created 3 layers to process the data by phase.

👉 **Bronze layer (raw_brasileiro_tables)**: This layer contains raw tables from Google Sheets files.

👉 **Silver layer (stg_brasileiro_tables)**: This layer contains two intermediary tables used on the `exp_dimJogador` creating process.

👉 **Gold layer (exp_brasileiro_tables)**: This layer contains the final tables with curated data ready to be used.



### Data model
This data model contains 5 dimensions and 1 fact.

@TODO [EXPLICACAO DE CADA TABELA E COLUNA]

- Explicar sobre os tipos de scd utilizados
    - dimTime - a partir da tabela brasileiro_full e do os id´s de partidas como sat_id e end_id
    - dimJogador - a partir das tabelas de stg, que por sua vez utilizaram as tabelas de eventos e gols. Porém, como apenas a tabela de eventos possuía posição e nº da camisa, o scd criado utilizado como end_id, o valor de start_id-1 (subtração) da linha seguinte


<br>


# 3. Use the data
