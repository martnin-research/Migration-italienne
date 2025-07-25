

SELECT *
FROM v_personne_avec_proprietes_agg;

SELECT *
FROM v_personne_avec_proprietes_agg
WHERE pays_origine like '%Autriche%';

WITH tw1 AS (
SELECT SUBSTRING(min_date_permis,1,4) annee_arrivee, pays_origine_code
FROM v_personne_avec_proprietes_agg
)
SELECT annee_arrivee, pays_origine_code, COUNT(*) number
FROM tw1
GROUP BY annee_arrivee, pays_origine_code;


SELECT pays_origine_code, COUNT(*) number
FROM v_personne_avec_proprietes_agg
GROUP BY pays_origine_code
ORDER BY number DESC ;



SELECT pays_origine_code, genre, COUNT(*) number
FROM v_personne_avec_proprietes_agg
GROUP BY genre, pays_origine_code
ORDER BY pays_origine_code, genre;




/*
 * Origines en relation avec les périodes et les enregistrements
 */

-- inverser long et lag, pour que les données soitent correctes
UPDATE "Ville origine" set long_corr = lat, lat_corr = long;
UPDATE "Ville origine" set long = long_corr , lat = lat_corr;


SELECT vp.*, m.date_permis_modifiee, vo.*
FROM v_mention_domicile_metier_periode vp
	JOIN Mention m ON m.pk_personne = vp.pk_personne 
	JOIN "Ville origine" vo ON m.fk_ville_origine = vo.pk_ville_origine
WHERE long NOT NULL AND lat NOT NULL;


-- corrections
update "Ville origine" SET long = NULL, lat = NULL
where pk_ville_origine IN (17, 60, 99, 111);


-- données à analyser
-- il y a quelques doubles origines ! cf. ci-dessous
SELECT DISTINCT vp.pk_personne, vp.person, vp.date_permis_modifiee, vp.classement_calcule, vp.periode, 
vo.region, vo.province, vo.nom_ville, vo.long, vo.lat
FROM v_mention_domicile_metier_periode vp
	JOIN Mention m ON m.pk_personne = vp.pk_personne 
	JOIN "Ville origine" vo ON m.fk_ville_origine = vo.pk_ville_origine
WHERE long NOT NULL AND lat NOT NULL;


-- max une dizaine doubles lieux, je laisse sans correction
with tw1 AS
(SELECT DISTINCT vp.pk_personne, vp.person, vp.date_permis_modifiee, vp.classement_calcule, vp.periode, vo.*
FROM v_mention_domicile_metier_periode vp
	JOIN Mention m ON m.pk_personne = vp.pk_personne 
	JOIN "Ville origine" vo ON m.fk_ville_origine = vo.pk_ville_origine
WHERE long NOT NULL AND lat NOT NULL)
SELECT pk_personne, person, classement_calcule, periode, group_concat(distinct nom_ville) noms_villes, group_concat(distinct region) regions
FROM tw1
group by pk_personne, person, classement_calcule, periode;



-- periode, region, metier
with tw1 AS
(SELECT DISTINCT vp.pk_personne, vp.person, vp.date_permis_modifiee, vp.classement_calcule, vp.periode, vo.*
FROM v_mention_domicile_metier_periode vp
	JOIN Mention m ON m.pk_personne = vp.pk_personne 
	JOIN "Ville origine" vo ON m.fk_ville_origine = vo.pk_ville_origine
WHERE long NOT NULL AND lat NOT NULL)
SELECT periode, region, classement_calcule, count(*) as effectif
FROM tw1
group by periode, region, classement_calcule;


-- lieu, periode
with tw1 AS
(SELECT DISTINCT vp.pk_personne, vp.person, vp.date_permis_modifiee, vp.classement_calcule, vp.periode, vo.*
FROM v_mention_domicile_metier_periode vp
	JOIN Mention m ON m.pk_personne = vp.pk_personne 
	JOIN "Ville origine" vo ON m.fk_ville_origine = vo.pk_ville_origine
WHERE long NOT NULL AND lat NOT NULL)
SELECT  nom_ville, long, lat, periode, count(*) as effectif
FROM tw1
group by nom_ville, periode
order by nom_ville, periode, effectif ;


-- region, periode
with tw1 AS
(SELECT DISTINCT vp.pk_personne, vp.person, vp.date_permis_modifiee, vp.classement_calcule, vp.periode, vo.*
FROM v_mention_domicile_metier_periode vp
	JOIN Mention m ON m.pk_personne = vp.pk_personne 
	JOIN "Ville origine" vo ON m.fk_ville_origine = vo.pk_ville_origine
WHERE long NOT NULL AND lat NOT NULL)
SELECT  region, periode, count(*) as effectif
FROM tw1
group by region, periode
order by region, periode, effectif ;


-- region, metier
with tw1 AS
(SELECT DISTINCT vp.pk_personne, vp.person, vp.date_permis_modifiee, vp.classement_calcule, vp.periode, vo.*
FROM v_mention_domicile_metier_periode vp
	JOIN Mention m ON m.pk_personne = vp.pk_personne 
	JOIN "Ville origine" vo ON m.fk_ville_origine = vo.pk_ville_origine
WHERE long NOT NULL AND lat NOT NULL)
SELECT  region, classement_calcule, count(*) as effectif
FROM tw1
group by region, classement_calcule
order by region, effectif DESC, classement_calcule ;






