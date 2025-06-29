



-- arrivée de la famille tout de suite ou après
SELECT
famille,
CASE 
	WHEN INSTR(famille, '|') = 2
		THEN 'dopo'
	ELSE 'subito'
END AS position, *
FROM v_personne_avec_proprietes_agg
WHERE length(ltrim(famille, '| ')) > 0;


- nombre de avec ou sans famille
WITH tw1 AS (
SELECT
CASE 
	WHEN INSTR(famille, '|') = 2
		THEN 'dopo'
	ELSE 'subito'
END AS position, *
FROM v_personne_avec_proprietes_agg
WHERE length(ltrim(famille, '| ')) > 0
)
SELECT position, COUNT(*) as numero
FROM tw1
group by position;



