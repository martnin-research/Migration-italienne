


SELECT vp.*, m.pk_mention, me.*, me.classement_3,  me.classement_4 
FROM v_personne vp 
	JOIN Mention m  ON m.pk_personne = vp.pk_personne 
	JOIN metier me ON me.metier_pk = m.fk_metier 
order by vp.person;





WITH tw1 AS (
SELECT vp.*, me.classement_2,  me.classement_3
FROM v_personne vp 
	JOIN Mention m  ON m.pk_personne = vp.pk_personne 
	JOIN metier me ON me.metier_pk = m.fk_metier 
)
select classement_2,  classement_3, count(*) AS number
from tw1
--WHERE SUBSTRING(min_date_permis,1,4) between '1848' AND '1854'
WHERE SUBSTRING(min_date_permis,1,4) between '1855' AND '1860'
--WHERE SUBSTRING(min_date_permis,1,4) between '1861' AND '1870'
group by classement_2,  classement_3
order by number DESC;




WITH tw1 AS (
SELECT vp.*,
me.classement_3
FROM v_personne vp 
	JOIN Mention m  ON m.pk_personne = vp.pk_personne 
	JOIN metier me ON me.metier_pk = m.fk_metier 
)
select classement_3, count(*) AS number
from tw1
group by classement_3
--HAVING COUNT(*) > 5 
order by number DESC;




WITH tw1 AS (
SELECT vp.*, 
CASE 
	WHEN SUBSTRING(min_date_permis,1,4) between '1848' AND '1854'
	THEN '1848-1854'
	WHEN SUBSTRING(min_date_permis,1,4) between '1855' AND '1860'
	THEN '1855-1860'
	WHEN SUBSTRING(min_date_permis,1,4) between '1861' AND '1870'
	THEN '1861-1870'
END AS period,
me.classement_3
FROM v_personne vp 
	JOIN Mention m  ON m.pk_personne = vp.pk_personne 
	JOIN metier me ON me.metier_pk = m.fk_metier 
)
select classement_3, period, count(*) AS number
from tw1
group by classement_3, period
--HAVING COUNT(*) > 5 
order by period, number DESC;




/*
 * Synthèse: mention de personne, genre, periode, domicile, classe métier
 */


DROP VIEW v_mention_domicile_metier_periode;
CREATE VIEW v_mention_domicile_metier_periode AS
SELECT 
m.date_permis_modifiee,
m.pk_mention,
vp.pk_personne,
vp.person,
vp.genre,
ldp.periode,
ldp.partie_b, ldp.domicile,
CASE 
	WHEN classement_4 > ''
	THEN classement_4
	ELSE 
	CASE
		WHEN classement_2 > ''
		THEN classement_2
		ELSE classement_3
	END	
END AS classement_calcule,
me.classement_2, me.classement_3,  me.classement_4,
vp.*, 
me.*
FROM v_personne vp 
	JOIN Mention m  ON m.pk_personne = vp.pk_personne 
	JOIN metier me ON me.metier_pk = m.fk_metier 
	JOIN v_mention_lieu_domicile_periode ldp ON ldp.pk_mention = m.pk_mention
order by vp.person, m.date_permis_modifiee;


SELECT * FROM v_mention_domicile_metier_periode;




SELECT pk_personne, person, genre, periode, partie_b, classement_calcule 
FROM v_mention_domicile_metier_periode;


select * from metier 
where classement_4 like 'horlo%';


select * from metier 
where classement_3 like 'agri%';

select * from metier 
where classement_2 like 'usin%';

SELECT classement_calcule, COUNT(*) as effectif
FROM v_mention_domicile_metier_periode
--WHERE genre = 'femme'
GROUP BY classement_calcule
ORDER BY effectif DESC;


--- pour les petits effectifs : divers ???



-- Tableau qui sera analyse dans QGis

SELECT periode, classement_calcule, genre, COUNT(*) as effectif
FROM v_mention_domicile_metier_periode
--WHERE genre = 'femme'
GROUP BY periode, classement_calcule, genre
ORDER BY periode, effectif DESC, classement_calcule, genre;








