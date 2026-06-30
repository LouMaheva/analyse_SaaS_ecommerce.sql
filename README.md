## 📊 analyse_SaaS_ecommerce.sql

## Architecture BI & Product Analytics pour un SaaS E-commerce Omnicanal à Abidjan

Ce projet présente l'architecture de données et les requêtes de Business Intelligence conçues pour analyser l'activité d'une application web (SaaS) que j'ai développé sur Bubble.io. L'application permet aux e-commerçants d'Abidjan de centraliser toutes leurs commandes issues de WhatsApp, Facebook, Instagram et TikTok.

Note : Pour valider la robustesse de ce pipeline de bout en bout, les analyses s'appuient sur un jeu de données simulées (Mock Data) reproduisant fidèlement les réalités logistiques ivoiriennes et les anomalies d'encodage applicatives courantes.

[1. Export Bubble] ──> [2. Nettoyage Power Query] ──> [3. Stockage SQL] ──> [4. Dashboard Tableau]

## 🎯 Objectifs du projet

* Modélisation de données : Structurer une base de données relationnelle propre à partir d'exports applicatifs bruts (fichiers plats).
* Analyse de la performance commerciale : Calculer les indicateurs clés globaux (Chiffre d'Affaires net, Panier Moyen en CFA).
* Optimisation des canaux : Comparer la rentabilité et les taux d'annulation entre les flux WhatsApp, Facebook, Instagram et TikTok.
* Analyse d'impact logistique : Cartographier les performances et les tarifs de livraison par commune d'Abidjan (Cocody, Yopougon, Abobo, Marcory...).
* Product Analytics (SaaS Metrics) : Mesurer l'engagement des vendeurs et leur taux de rétention hebdomadaire sur la plateforme Bubble.

## 🛠️ Technologies utilisées

* Excel / Power Query : Nettoyage de données (Data Cleaning), gestion des valeurs nulles et normalisation des encodages de caractères (UTF-8).
* SQL (PostgreSQL) : Modélisation (DDL), requêtage complexe, vues consolidées, jointures, agrégations et calcul des cohortes de rétention.
* Tableau Software : Conception d'un dashboard interactif d'aide à la décision (Cartographie choroplèthe, Heatmap de rétention, KPI cards).



