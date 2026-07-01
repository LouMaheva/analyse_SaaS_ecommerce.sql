-- 1. CRÉATION DES TABLES (DÉFINITION DU SCHÉMA RELATIONNEL)

CREATE TABLE utilisateurs (
    unique_id VARCHAR(50) PRIMARY KEY,
    nom_boutique VARCHAR(100),
    description VARCHAR(255),
    email VARCHAR(100),
    created_date DATE
);

CREATE TABLE livraisons (
    unique_id VARCHAR(50),
    quartier VARCHAR(100),
    tarif_cfa INT,
    FOREIGN KEY (unique_id) REFERENCES utilisateurs(unique_id)
);

CREATE TABLE commandes (
    id_commande VARCHAR(20) PRIMARY KEY,
    unique_id VARCHAR(50),
    date_commande DATE,
    client_info VARCHAR(255),
    statut VARCHAR(50),
    montant_articles_cfa INT,
    montant_livraison_cfa INT,
    montant_total_cfa INT,
    canal_provenance VARCHAR(50),
    commune_livraison VARCHAR(100),
    FOREIGN KEY (unique_id) REFERENCES utilisateurs(unique_id)
);

CREATE TABLE details_commandes (
    id_commande VARCHAR(20),
    article_nom VARCHAR(100),
    quantite INT,
    prix_unitaire_cfa INT,
    FOREIGN KEY (id_commande) REFERENCES commandes(id_commande)
);

-- 2. REQUÊTES BUSINESS D'ANALYSE (PERFORMANCE & KEY METRICS)

-- REQUÊTE 1 : Performance globale de la plateforme (CA, Panier Moyen, Volume)
SELECT 
    COUNT(id_commande) AS total_commandes_generées,
    SUM(montant_articles_cfa) AS chiffre_affaires_articles_cfa,
    ROUND(AVG(montant_articles_cfa), 0) AS panier_moyen_articles_cfa
FROM commandes
WHERE statut != 'Annulé';

-- REQUÊTE 2 : WhatsApp vs Facebook - Quel canal convertit le mieux ?
SELECT 
    canal_provenance,
    COUNT(id_commande) AS nombre_commandes,
    SUM(montant_total_cfa) AS chiffre_affaires_total_cfa,
    ROUND(AVG(montant_total_cfa), 0) AS panier_moyen_total_cfa,
    ROUND(COUNT(CASE WHEN statut = 'Annulé' THEN 1 END) * 100.0 / COUNT(id_commande), 2) AS taux_annulation_pourcent
FROM commandes
GROUP BY canal_provenance;

-- REQUÊTE 3 : Analyse Logistique - Tarif moyen de livraison par quartier d'Abidjan
SELECT 
    commune_livraison AS quartier, 
    ROUND(AVG(montant_livraison_cfa), 0) AS tarif_moyen_livraison_cfa,
    COUNT(id_commande) AS nombre_de_livraisons_effectuees
FROM commandes
WHERE statut = 'Terminé'
GROUP BY commune_livraison
ORDER BY tarif_moyen_livraison_cfa DESC;

-- REQUÊTE 4 : Engagement Produit - Top 5 des boutiques les plus actives (SaaS Analytics)
SELECT 
    u.nom_boutique,
    u.description AS categorie_activite,
    COUNT(c.id_commande) AS total_commandes_enregistrées,
    SUM(c.montant_articles_cfa) AS volume_affaires_généré_cfa
FROM utilisateurs u
JOIN commandes c ON u.unique_id = c.unique_id
WHERE c.statut = 'Terminé'
GROUP BY u.unique_id, u.nom_boutique, u.description
ORDER BY total_commandes_enregistrées DESC
LIMIT 5;

-- REQUÊTE 5 : Analyse de la Rétention Hebdomadaire (SaaS Metrics)
WITH premiere_activite AS (
    SELECT unique_id, MIN(EXTRACT(WEEK FROM date_commande)) AS semaine_inscription
    FROM commandes GROUP BY unique_id
),
activite_semaines AS (
    SELECT DISTINCT c.unique_id, p.semaine_inscription, EXTRACT(WEEK FROM c.date_commande) AS semaine_activite
    FROM commandes c JOIN premiere_activite p ON c.unique_id = p.unique_id
)
SELECT 
    CONCAT('Semaine ', semaine_inscription) AS cohorte_vendeurs,
    COUNT(DISTINCT CASE WHEN semaine_activite = semaine_inscription THEN unique_id END) AS inscrits,
    COUNT(DISTINCT CASE WHEN semaine_activite = semaine_inscription + 1 THEN unique_id END) AS revenus_semaine_suivante
FROM activite_semaines
GROUP BY semaine_inscription;

-- REQUÊTE 6 : Audit de Qualité de Données (Data Integrity Check)
SELECT 
    c.id_commande,
    c.montant_articles_cfa AS montant_commande,
    SUM(d.quantite * d.prix_unitaire_cfa) AS montant_panier_calculé,
    (c.montant_articles_cfa - SUM(d.quantite * d.prix_unitaire_cfa)) AS ecart_controle
FROM commandes c
JOIN details_commandes d ON c.id_commande = d.id_commande
GROUP BY c.id_commande, c.montant_articles_cfa
HAVING (c.montant_articles_cfa - SUM(d.quantite * d.prix_unitaire_cfa)) != 0;

