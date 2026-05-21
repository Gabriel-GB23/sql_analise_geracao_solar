-- Apresentação das Views Criadas
-- Geração Brumadinho
SELECT * FROM Geracao_Brumadinho;

-- Geração Alphaville
SELECT * FROM Geracao_Alphaville;

-- Geração Campos Altos
SELECT * FROM Geracao_Campos_Altos;

-- Geração Anual por usina
SELECT u.nome_usina, SUM(g.energia_kwh) GeraçãoAnual FROM Geracao g  --Esta consulta fornece uma visão executiva do volume total de energia gerada por cada usina, permitindo o acompanhamento de metas anuais de geração.
JOIN Inversores i ON g.num_serial_inversor = i.num_serial
JOIN Usinas u ON u.id_usina = i.usina_id
GROUP BY u.nome_usina;


-- Ranking de Produtividade (Fator de Geração) - Quanto cada kWp gera de kWh em média por mês
SELECT Nome_Da_Usina, Potencia_da_usina_kWp, ROUND(AVG(Soma_Mes)/Potencia_da_usina_kWp, 2) Fator_de_geracao from(
  SELECT u.nome_usina Nome_Da_Usina, u.potencia_kwp Potencia_da_usina_kWp, strftime ('%Y/%m', g.data_geracao) "Ano/Mes", SUM(g.energia_kwh) Soma_Mes from Geracao g -- Cálculo do rendimento específico médio (kWh/kWp).
  JOIN Inversores i ON i.num_serial = g.num_serial_inversor
  JOIN Usinas u ON u.id_usina = i.usina_id
  GROUP BY Nome_Da_Usina, "Ano/Mes" 
  ORDER BY "Ano/Mes")
GROUP BY Nome_Da_Usina;

-- Fator de Geração por Mês 
SELECT strftime('%Y/%m', g.data_geracao) "Ano/Mes", u.nome_usina Nome_Da_Usina, u.potencia_kwp Potencia_da_usina_kWp, 
ROUND(SUM(g.energia_kwh)/u.potencia_kwp,2) Fator_de_geracao_mes FROM Geracao g -- Análise temporal de eficiência. Essencial para identificar meses de alta e baixa produção (sazonalidade) e 
JOIN Inversores i ON i.num_serial = g.num_serial_inversor                      -- e validar se o desempenho está de acordo com o projeto de engenharia para cada mês do ano.
JOIN Usinas u ON u.id_usina = i.usina_id
GROUP BY Nome_Da_Usina, "Ano/Mes" 
ORDER BY Nome_Da_Usina, "Ano/Mes";
  
-- Detecção de Anomalia operacional - Foram considerados dias com geração abaixo de 50% da média de geração para cada usina
WITH Geracao_Diaria_Por_Usina AS (
    SELECT 
        i.usina_id, 
        g.data_geracao, 
        SUM(g.energia_kwh) as Geracao_dia_usina
    FROM Geracao g
    JOIN Inversores i ON i.num_serial = g.num_serial_inversor
    GROUP BY i.usina_id, g.data_geracao
),
Media_Por_Usina AS (
    SELECT 
        usina_id, 
        ROUND(AVG(Geracao_dia_usina), 2) as media_diaria_kWh
    FROM Geracao_Diaria_Por_Usina
    GROUP BY usina_id
)
SELECT 
    gd.data_geracao, u.nome_usina, mu.media_diaria_kWh, -- Lógica de monitoramento ativo: identifica quedas bruscas de geração (abaixo de 50% da média histórica da própria usina). 
    ROUND(gd.Geracao_dia_usina, 2) Geracao_dia_usina    -- Este insight permite disparar alertas para equipes de manutenção verificarem falhas críticas ou desligamentos inesperados.
FROM Geracao_Diaria_Por_Usina gd
JOIN Media_Por_Usina mu ON gd.usina_id = mu.usina_id
JOIN Usinas u ON gd.usina_id = u.id_usina
WHERE gd.Geracao_dia_usina < (mu.media_diaria_kWh * 0.5) -- Filtro de 50%
ORDER BY gd.data_geracao;

-- Comparação de Operação de inversores em Cada Usina, em relação à média
WITH Total_por_inversor AS
(
SELECT strftime('%Y/%m', g.data_geracao) "Ano/Mes", g.num_serial_inversor, ROUND(SUM(g.energia_kwh),2) Geracao_inversor FROM Geracao g 
JOIN Inversores i ON i.num_serial = g.num_serial_inversor
GROUP BY g.num_serial_inversor, "Ano/Mes"
ORDER BY num_serial_inversor
), 
Media_por_inversor As
(
  SELECT ti."Ano/Mes", i.usina_id id_da_usina, ROUND(AVG(ti.Geracao_inversor),2) Media_inversor_usina FROM Total_por_inversor ti
  JOIN Inversores i ON i.num_serial = ti.num_serial_inversor
  GROUP BY i.usina_id, ti."Ano/Mes")
  
SELECT ti."Ano/Mes", ti.num_serial_inversor, mi.Media_inversor_usina, ti.Geracao_inversor, ROUND((ti.Geracao_inversor/mi.Media_inversor_usina - 1) * 100,2) AS Desvio
FROM Total_por_inversor ti
JOIN Inversores i ON i.num_serial = ti.num_serial_inversor
JOIN Media_por_inversor mi ON mi.id_da_usina = i.usina_id AND mi."Ano/Mes" = ti."Ano/Mes" -- Diagnóstico técnico detalhado que utiliza o desvio percentual em relação à média do site. Ajuda a identificar problemas localizados, como sujeira excessiva em 
WHERE Desvio < 0
ORDER BY Desvio;                                                                          -- um conjunto de placas específico ou degradação acelerada de componentes de um único inversor.
  
-- Retorno Financeiro 
SELECT u.nome_usina, 
ROUND(SUM(g.energia_kwh),2) Energia_Total_kWh,
ROUND(SUM(g.energia_kwh) * 1.12,2) Economia_Total_R$, -- Considerando uma tarifa de 1,12R$/kWh
ROUND((SUM(g.energia_kwh) * 1.12) / COUNT(DISTINCT strftime('%Y%m', g.data_geracao)), 2) Media_Economia_Mensal_R$
FROM Geracao g 
JOIN Inversores i ON i.num_serial = g.num_serial_inversor -- Calcula o retorno financeiro anual de cada usina, além de uma média mensal, com base em uma tarifa média da região.
JOIN Usinas u ON i.usina_id = u.id_usina
GROUP BY u.nome_usina
                     
