-- =====================================================================
-- PROJET BI & DATA ANALYTICS : PERFORMANCE COMMERCIAL SAAS E-COMMERCE
-- Auteur : [Votre Prénom] [Votre Nom]
-- Objectif : Analyser l'activité des boutiques et des canaux (WhatsApp/FB)
-- =====================================================================

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
    FOREIGN KEY (unique_id) REFERENCES utilisateurs(unique_id)
);

CREATE TABLE details_commandes (
    id_commande VARCHAR(20),
    article_nom VARCHAR(100),
    quantite INT,
    prix_unitaire_cfa INT,
    FOREIGN KEY (id_commande) REFERENCES commandes(id_commande)
);

-- =====================================================================
-- 2. REQUÊTES BUSINESS D'ANALYSE (PERFORMANCE & KEY METRICS)
-- =====================================================================

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
    quartier,
    ROUND(AVG(tarif_cfa), 0) AS tarif_moyen_livraison_cfa,
    COUNT(DISTINCT unique_id) AS nombre_boutiques_livrant_dans_cette_zone
FROM livraisons
GROUP BY quartier
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


-- REQUÊTE 5 : Audit de Qualité de Données (Data Integrity Check)
-- Vérifie que le montant total calculé depuis le panier (détails) correspond au montant de la table commande
SELECT 
    c.id_commande,
    c.montant_articles_cfa AS montant_commande,
    SUM(d.quantite * d.prix_unitaire_cfa) AS montant_panier_calculé,
    (c.montant_articles_cfa - SUM(d.quantite * d.prix_unitaire_cfa)) AS ecart_controle
FROM commandes c
JOIN details_commandes d ON c.id_commande = d.id_commande
GROUP BY c.id_commande, c.montant_articles_cfa
HAVING (c.montant_articles_cfa - SUM(d.quantite * d.prix_unitaire_cfa)) != 0;
