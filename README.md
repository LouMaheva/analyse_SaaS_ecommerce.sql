📊 analysis_SaaS_ecommerce.sql

## BI & Product Analytics Architecture for an Omnichannel E-commerce SaaS in Abidjan

This project showcases the data architecture and Business Intelligence queries designed to analyze the activity of a web application (SaaS) that I developed using Bubble.io. The application enables e-commerce merchants in Abidjan to centralize all customer orders coming from WhatsApp, Facebook, Instagram, and TikTok into a single platform.

**Note:** To validate the robustness of this end-to-end analytics pipeline, all analyses are based on a simulated dataset that accurately reflects Ivorian logistics operations as well as common data encoding issues found in production applications.

[1. Bubble Export] ──> [2. Power Query Data Cleaning] ──> [3. SQL Database] ──> [4. Tableau Dashboard]


## 🎯 Project Objectives

* Data Cleasing & Modeling: Build a clean relational database from raw application exports (flat files).
* Business Performance Analysis: Calculate key business metrics such as Net Revenue and Revenue per merchants Value (CFA).
* Channel Performance Optimization: Compare profitability across WhatsApp, Facebook, Instagram, and TikTok sales channels.
* Delivery Volume Analysis: Analyze delivery volume by municipality to identify the areas with the highest number of completed deliveries in Abidjan.

## 🛠️ Technologies Used

* Excel / Power Query: Data cleaning, null value handling, and UTF-8 character encoding normalization.
* SQL: Database modeling (DDL), SQL queries, views, joins, and business performance analysis.
* Tableau: Interactive Business Intelligence dashboard design.

The following section contains the complete data cleaning and analysis code developed for this project.

-- Conversion des dates dans la table utilisateurs
UPDATE "Bubble_utilisateurs"
SET "Created Date" = SUBSTR("Created Date", 7, 4) || '-' || SUBSTR("Created Date", 4, 2) || '-' || SUBSTR("Created Date", 1, 2)
WHERE "Created Date" LIKE '__/__/____';

-- Conversion des dates dans la table commandes
UPDATE "Bubble_Liste_commandes"
SET "date_commande" = SUBSTR("date_commande", 7, 4) || '-' || SUBSTR("date_commande", 4, 2) || '-' || SUBSTR("date_commande", 1, 2)
WHERE "date_commande" LIKE '__/__/____';

-- REQUÊTE 1 : Performance globale de la plateforme (CA, Panier Moyen, Volume)
SELECT 
    COUNT(DISTINCT "Unique id") AS total_vendeurs_inscrits
FROM "Bubble_utilisateurs";

SELECT 
    COUNT("id_commande") AS total_commandes_generées,
    SUM("montant_articles_cfa") AS chiffre_affaires_articles_cfa,
    ROUND(AVG("montant_articles_cfa"), 0) AS panier_moyen_articles_cfa
FROM "Bubble_Liste_commandes"
WHERE "statut" = 'Terminé';

SELECT 
    ROUND(SUM("montant_articles_cfa") / COUNT(DISTINCT "Unique id"), 0) AS chiffre_affaires_moyen_par_vendeur_cfa
FROM "Bubble_Liste_commandes"
WHERE "statut" = 'Terminé';

-- REQUÊTE 2 : Analyse Omnicanale (WhatsApp, Facebook, Instagram, TikTok)
SELECT 
    "canal_provenance",
    COUNT("id_commande") AS nombre_commandes,
    SUM("montant_total_cfa") AS chiffre_affaires_total_cfa,
    ROUND(AVG("montant_total_cfa"), 0) AS panier_moyen_total_cfa,
    ROUND(COUNT(CASE WHEN "statut" = 'Annulé' THEN 1 END) * 100.0 / COUNT("id_commande"), 2) AS taux_annulation_pourcent
FROM "Bubble_Liste_commandes"
GROUP BY "canal_provenance";


-- REQUÊTE 3 : Analyse Logistique - Tarif moyen de livraison par quartier d'Abidjan

--Sécurité : On supprime l'ancien dictionnaire s'il existait déjà
DROP TABLE IF EXISTS referentiel_communes;

-- Crée une table dictionnaire pour stocker la liste propre des communes d'Abidjan
CREATE TABLE referentiel_communes (
    nom_officiel TEXT PRIMARY KEY
);
-- Remplit le dictionnaire avec les vrais noms des quartiers et communes de votre business
INSERT INTO referentiel_communes (nom_officiel) VALUES 
('Cocody'), ('Yopougon'), ('Marcory'), ('Abobo'), 
('Adjamé'), ('Riviera'), ('Plateau'), ('Zone 4'), 
('Treichville'), ('Koumassi'), ('Angré'),('Port-Bouët'),('Bingerville');

ALTER TABLE "Bubble_Liste_commandes" ADD COLUMN "quartier" TEXT;

UPDATE "Bubble_Liste_commandes"
SET "quartier" = (
    SELECT nom_officiel 
    FROM referentiel_communes 
    WHERE "Bubble_Liste_commandes"."client_info" LIKE '%' || nom_officiel || '%'
    LIMIT 1
);
UPDATE "Bubble_Liste_commandes"
SET "quartier" = 'Autre / Inconnu'
WHERE "quartier" IS NULL;

SELECT 
    "quartier", 
    ROUND(AVG("montant_livraison_cfa"), 0) AS tarif_moyen_livraison_cfa,
    COUNT("id_commande") AS nombre_de_livraisons_effectuees
FROM "Bubble_Liste_commandes"
WHERE "statut" = 'Terminé'
GROUP BY "quartier"
ORDER BY tarif_moyen_livraison_cfa DESC;

-- REQUÊTE 4 : Engagement Produit - Top 5 des boutiques les plus actives
SELECT 
    u."Nom boutique",
    u."Description" AS categorie_activite,
    COUNT(c."id_commande") AS total_commandes_enregistrées,
    SUM(c."montant_articles_cfa") AS volume_affaires_généré_cfa
FROM "Bubble_utilisateurs" u
JOIN "Bubble_Liste_commandes" c ON u."Unique id" = c."Unique id"
WHERE c."statut" = 'Terminé'
GROUP BY u."Unique id", u."Nom boutique", u."Description"
ORDER BY total_commandes_enregistrées DESC
LIMIT 5;

-- Bloc final : Crée une table unique pour Tableau avec TOUTES vos requêtes assemblées
DROP TABLE IF EXISTS table_reporting_tableau;

CREATE TABLE table_reporting_tableau AS
SELECT 
    c."id_commande",
    c."date_commande",
    c."canal_provenance",
    c."quartier" AS commune_livraison,
    c."montant_articles_cfa",
    c."montant_livraison_cfa",
    c."montant_total_cfa",
    c."statut" AS statut_commande,
    u."Nom boutique",
    u."Description" AS categorie_boutique,
    (SELECT COUNT(DISTINCT "Unique id") FROM "Bubble_utilisateurs") AS total_vendeurs_plateforme
FROM "Bubble_Liste_commandes" c
JOIN "Bubble_utilisateurs" u ON c."Unique id" = u."Unique id";



