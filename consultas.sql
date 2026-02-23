-- Geração Anual por usina
select u.nome_usina, SUM(g.energia_kwh) GeraçãoAnual from Geracao g  --Esta consulta fornece uma visão executiva do volume total de energia gerada por cada usina, permitindo o acompanhamento de metas anuais de geração.
join Inversores i on g.num_serial_inversor = i.num_serial
join Usinas u on u.id_usina = i.usina_id
group by u.nome_usina;


-- Ranking de Produtividade (Fator de Geração) - Quanto cada kWp gera de kWh por mês
SELECT Nome_Da_Usina, Potencia_da_usina_kWp, ROUND(AVG(Soma_Mes)/Potencia_da_usina_kWp, 2) Fator_de_geracao from(
  select u.nome_usina Nome_Da_Usina, u.potencia_kwp Potencia_da_usina_kWp, strftime ('%Y/%m', g.data_geracao) "Ano/Mes", SUM(g.energia_kwh) Soma_Mes from Geracao g -- Cálculo do rendimento específico médio (kWh/kWp).
  join Inversores i on i.num_serial = g.num_serial_inversor
  join Usinas u on u.id_usina = i.usina_id
  group by Nome_Da_Usina, "Ano/Mes" 
  order by "Ano/Mes")
group by Nome_Da_Usina;

-- Fator de Geração por Mês 
select strftime('%Y/%m', g.data_geracao) "Ano/Mes", u.nome_usina Nome_Da_Usina, u.potencia_kwp Potencia_da_usina_kWp, 
ROUND(SUM(g.energia_kwh)/u.potencia_kwp,2) Fator_de_geracao_mes from Geracao g -- Análise temporal de eficiência. Essencial para identificar meses de alta e baixa produção (sazonalidade) e 
join Inversores i on i.num_serial = g.num_serial_inversor                      -- e validar se o desempenho está de acordo com o projeto de engenharia para cada mês do ano.
join Usinas u on u.id_usina = i.usina_id
group by Nome_Da_Usina, "Ano/Mes" 
order by Nome_Da_Usina, "Ano/Mes";
  
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
with Total_por_inversor AS
(
select strftime('%Y/%m', g.data_geracao) "Ano/Mes", g.num_serial_inversor, ROUND(SUM(g.energia_kwh),2) Geracao_inversor from Geracao g 
join Inversores i on i.num_serial = g.num_serial_inversor
GROUP by g.num_serial_inversor, "Ano/Mes"
ORDER by num_serial_inversor
), 
Media_por_inversor As
(
  select ti."Ano/Mes", i.usina_id id_da_usina, ROUND(AVG(ti.Geracao_inversor),2) Media_inversor_usina from Total_por_inversor ti
  join Inversores i on i.num_serial = ti.num_serial_inversor
  group by i.usina_id, ti."Ano/Mes")
  
SELECT ti."Ano/Mes", ti.num_serial_inversor, mi.Media_inversor_usina, ti.Geracao_inversor, ROUND((ti.Geracao_inversor/mi.Media_inversor_usina - 1) * 100,2) as Desvio
from Total_por_inversor ti
join Inversores i on i.num_serial = ti.num_serial_inversor
join Media_por_inversor mi on mi.id_da_usina = i.usina_id AND mi."Ano/Mes" = ti."Ano/Mes" -- Diagnóstico técnico detalhado que utiliza o desvio percentual em relação à média do site. Ajuda a identificar problemas localizados, como sujeira excessiva em 
WHERE Desvio < 0
order by Desvio;                                                                          -- um conjunto de placas específico ou degradação acelerada de componentes de um único inversor.
  
-- Retorno Financeiro 
select u.nome_usina, 
ROUND(SUM(g.energia_kwh),2) Energia_Total_kWh,
ROUND(SUM(g.energia_kwh) * 1.12,2) Economia_Total_R$, -- Considerando uma tarifa de 1,12R$/kWh
ROUND((SUM(g.energia_kwh) * 1.12) / COUNT(DISTINCT strftime('%Y%m', g.data_geracao)), 2) Media_Economia_Mensal_R$
from Geracao g 
join Inversores i on i.num_serial = g.num_serial_inversor -- Calcula o retorno financeiro anual de cada usina, além de uma média mensal, com base em uma tarifa média da região.
join Usinas u on i.usina_id = u.id_usina
group by u.nome_usina
                     
