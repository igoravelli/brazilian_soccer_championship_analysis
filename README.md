# Brazilian Soccer Championship Analysis
## Summary
> O que é
> 
> O que foi usado (ferramentas e conceitos)
>
> Funções de cada um no projeto

This project aims to analyze the Brazilian Soccer Championship, also known as "Brasileirão", which is the top-tier professional football league in Brazil. The analysis is based on the historical data of the championship, including match results, player statistics, and other relevant factors.

The project was divided into 3 steps:

1. Choose the data
2. Manipule the data
3. Use the data

<br>


# 1. Choose the data <br>
The first step was consisted by choose the datasets to be used on the project. The ones that we has choosen are available [here](https://www.kaggle.com/datasets/adaoduque/campeonato-brasileiro-de-futebol).
Once the data has picked, we loaded it on the BigQuery as "raws" tables.

<br>

# 2. Manipulate the data <br>
At the second step our goal was to build a datawarehouse to be easier to use the data.
We decided to build a main data model (datamart) with a center table called `factEvents` and others 5 dimensions called `dimMatch`, `dimPlayer`, `dimArena`, `dimTeams` and `dimCalendar`.

![](datamodel_picture.png)

The model entire model is represented [here](https://drive.google.com/file/d/1ejlKub_w4EP8wMyLYU0ykyO7PT3yaIc9/view?usp=sharing).



### ETL process
To start, this project was built an ETL process using python and SQL to extract the data from the csv files, manipulate them and create a star schema data model to be used to answer the business questions.

@TODO [UM DESENHO DO PROCESSO DE ETL]

To storage the data, was used the BigQuery platform. On it, was created 3 layers to process the data by phase.

👉 **Raw layer (raw_brasileiro_tables)**: This layer contains raw tables from csv files.

👉 **Staging layer (stg_brasileiro_tables)**: This layer contains two intermediary tables used on the `exp_dimJogador` creating process.

👉 **Exposure layer (exp_brasileiro_tables)**: This layer contains the final tables with curated data ready to be used.

>📢 *Some data was cleaned before loading them into the raw layer.*



### Data model
This data model contains 5 dimensions and 1 fact.

@TODO [EXPLICACAO DE CADA TABELA E COLUNA]

- Explicar sobre os tipos de scd utilizados
    - dimTime - a partir da tabela brasileiro_full e do os id´s de partidas como sat_id e end_id
    - dimJogador - a partir das tabelas de stg, que por sua vez utilizaram as tabelas de eventos e gols. Porém, como apenas a tabela de eventos possuía posição e nº da camisa, o scd criado utilizado como end_id, o valor de start_id-1 (subtração) da linha seguinte


<br>


# 3. Use the data