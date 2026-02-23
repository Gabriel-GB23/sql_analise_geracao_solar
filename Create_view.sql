Create view Geracao_Alphaville AS 
SELECT strftime('%Y/%m', data_geracao) "Ano/Mes", replace(SUM(g.energia_kwh),'.',',') Geracao_Alphaville
from Geracao g
join Inversores i on g.num_serial_inversor = i.num_serial
where i.usina_id = 1
group by "Ano/Mes";

Create view Geracao_Brumadinho AS 
SELECT strftime('%Y/%m', data_geracao) "Ano/Mes", replace(SUM(g.energia_kwh),'.',',') Geracao_Brumadinho
from Geracao g
join Inversores i on g.num_serial_inversor = i.num_serial
where i.usina_id = 2
group by "Ano/Mes";

Create view Geracao_Campos_Altos AS 
SELECT strftime('%Y/%m', data_geracao) "Ano/Mes", REPLACE(SUM(g.energia_kwh),'.',',') Geracao_Campos_Altos
from Geracao g
join Inversores i on g.num_serial_inversor = i.num_serial
where i.usina_id = 3
group by "Ano/Mes";

create view Visao_Geral AS
SELECT strftime('%Y/%m', data_geracao) "Ano/Mes",
REPLACE(SUM(CASE WHEN i.usina_id = 1 THEN g.energia_kwh ELSE 0 END),'.',',') Geracao_Alphaville,   -- Substituição dos pontos por vírgulas para facilitação após a exportação dos dados para CSV.
REPLACE(SUM(CASE WHEN i.usina_id = 2 THEN g.energia_kwh ELSE 0 END),'.',',') Geracao_Brumadinho,
REPLACE(SUM(CASE WHEN i.usina_id = 3 THEN g.energia_kwh ELSE 0 END),'.',',') Geracao_Campos_Altos
from Geracao g
join Inversores i on g.num_serial_inversor = i.num_serial
join Usinas u on u.id_usina  = i.usina_id
group by "Ano/Mes"
order by "Ano/Mes";
