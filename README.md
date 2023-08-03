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


**1. Choose the data** <br>
At the first step was chosen the datasets available [here](https://www.kaggle.com/datasets/adaoduque/campeonato-brasileiro-de-futebol) and 


## ETL process
To start, this project was built an ETL process using python and SQL to extract the data from the csv files, manipulate them and create a star schema data model to be used to answer the business questions.

@TODO [UM DESENHO DO PROCESSO DE ETL]

To storage the data, was used the BigQuery platform. On it, was created 3 layers to process the data by phase.

👉 **Raw layer (raw_brasileiro_tables)**: This layer contains raw tables from csv files.

👉 **Staging layer (stg_brasileiro_tables)**: This layer contains two intermediary tables used on the `exp_dimJogador` creating process.

👉 **Exposure layer (exp_brasileiro_tables)**: This layer contains the final tables with curated data ready to be used.

<br>

>📢 *Some data was cleaned before loading them into the raw layer.*



## Data model
This data model contains 5 dimensions and 1 fact.

@TODO [EXPLICACAO DE CADA TABELA E COLUNA]

- Explicar sobre os tipos de scd utilizados
    - dimTime - a partir da tabela brasileiro_full e do os id´s de partidas como sat_id e end_id
    - dimJogador - a partir das tabelas de stg, que por sua vez utilizaram as tabelas de eventos e gols. Porém, como apenas a tabela de eventos possuía posição e nº da camisa, o scd criado utilizado como end_id, o valor de start_id-1 (subtração) da linha seguinte

## Business questions and Visualizations