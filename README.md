# sql_analise_geracao_solar

Objetivo do Projeto: Analisar a performance operacional e financeira de três centrais fotovoltaicas (Alphaville, Brumadinho e Campos Altos).

Tecnologias Utilizadas: SQLite para processamento de dados e estruturação de queries.

Principais Insights:

Eficiência: A Usina Brumadinho apresentou o maior fator de geração médio, apesar de não ser a maior em capacidade instalada, enquanto a usina de Campos Altos apresentou uma estabilidade maior ao longo dos meses, sem uma redução brusca nos períodos de inverno;
<img width="617" height="376" alt="image" src="https://github.com/user-attachments/assets/4b0e2679-83b2-4bb4-ae79-f576d0e336d1" />

Manutenção: Com o script criado para análise dos dias de baixa geração (abaixo de 50% da média diária), conseguimos identificar quais dias tiveram uma geração fora do padrão, podendo ser um indicativo de falhas, ou então de tempo nublado.
Foi criado também um script para identificação do desvio de geração dos inversores, com base na média de geração por inversor esperada para cada usina, tornando possível a identificação de falhas individuais em cada equipamento.

Financeiro: O sistema gerou uma economia total estimada para cada uma das usinas, sendo que a unidade de Campos Altos obteve o maior retorno, de R$ 57.714,05.

Os dados foram obtidos através de uma plataforma de monitoramento online, porém, os nomes das usinas e os SNs dos inversores foram alterados por questões de segurança.

Para replicar os resultados, basta executar os códigos na seguinte sequência:

Create_Tables;
Insert_Data;
Consultas.

https://www.linkedin.com/in/gabriel-gomes-454406264/
