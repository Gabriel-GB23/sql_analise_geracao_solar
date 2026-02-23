# sql_analise_geracao_solar

Objetivo do Projeto: Analisar a performance operacional e financeira de três centrais fotovoltaicas (Alphaville, Brumadinho e Campos Altos).

Tecnologias Utilizadas: SQLite para processamento de dados e estruturação de queries.

Principais Insights:

Eficiência: A Usina Brumadinho apresentou o maior fator de geração médio, apesar de não ser a maior em capacidade instalada;
Manutenção: O algoritmo de desvio identificou inversores operando abaixo da média da usina, permitindo manutenção preditiva;
Financeiro: O sistema gerou uma economia total estimada para cada uma das usinas, sendo que a unidade de Campos Altos obteve o maior retorno, de R$ 57.714,05.

Os dados foram obtidos através de uma plataforma de monitoramento online, porém, os nomes das usinas e os SNs dos inversores foram alterados por questões de segurança.

Para replicar os resultados, basta executar os códigos na seguinte sequência:

Create_Tables;
Insert_Data;
Consultas.

Resumo dos resultados obtidos:

Eficiência Operacional: Foi possível identificar que a usina de Brumadinho possui o maior fator de geração, ou seja, a maior quantidade de geração por kWp instalado, totalizando 125,93 kWh/kWp em uma média anual.
<img width="618" height="379" alt="image" src="https://github.com/user-attachments/assets/eb0c966a-0ba5-47b2-8cc1-353c42f22372" />

Manutenção Preditiva: Com o script criado para análise dos dias de baixa geração (abaixo de 50% da média diária), conseguimos identificar quais dias tiveram uma geração fora do padrão, podendo ser um indicativo de falhas, ou então de tempo nublado.
Foi criado também um script para identificação do desvio de geração dos inversores, com base na média de geração por inversor esperada para cada usina, tornando possível a identificação de falhas individuais em cada equipamento.

Impacto Financeiro: Cálculo da economia total gerada, convertendo a produção técnica em valor monetário real (R$) por usina.
