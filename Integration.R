#Installation des packages necessaires
install.packages("RSQLite")
install.packages("DBI")
library(DBI)
library(RSQLite)

#Initialisation de la base de donnees
base = dbConnect(RSQLite::SQLite(), "/Users/rs777/Documents/SAE_Integration/Base.sqlite")

#Creation de la table PAGE dans la base.sqlite
dbExecute(base,
          "Create table page (
          id_page bigint,
          url varchar(2083),
          constraint pk_idp primary key (id_page));")

#Creation de la table CATEGORIE dans la base.sqlite
dbExecute(base,
          "Create table categorie (
          id_categorie bigint,
          id_page bigint,
          nom_categ varchar(50),
          constraint pk_idc primary key (id_categorie),
          constraint fk_idp foreign key (id_page) references page (id_page));")

#Creation de la table AUTEUR dans la base.sqlite
dbExecute(base,
          "Create table auteur (
          id_auteur bigint,
          nom varchar(255),
          prenom varchar(255),
          sexe varchar(20),
          date_naissance date,
          constraint pk_ida primary key (id_auteur));")

#Creation de la table UTILISATEUR dans la base.sqlite
dbExecute(base,
          "create table utilisateur (
          id_utilisateur bigint,
          adresse_ip varchar(255),
          navigateur varchar(50),
          os varchar(50),
          date_connexion date,
          url varchar(255),
          nom varchar(50),
          prenom varchar(50),
          date_naiss date,
          sexe varchar(20),
          email varchar(255),
          telephone bigint,
          constraint pk_idu primary key (id_utilisateur));")

#Creation de la table LIVRAISON dans la base.sqlite
dbExecute(base,
          "create table livraison (
          id_livraison bigint,
          id_commande bigint,
          societe_livraison varchar(255),
          numero_colis bigint,
          constraint pk_idl primary key (id_livraison),
          constraint fk_idc foreign key (id_commande) references detail_commande (id_commande) );")

#Creation de la table DETAIL_COMMANDE dans la base.sqlite
dbExecute(base,
          "create table detail_commande (
          id_commande bigint,
          id_livraison bigint,
          adresse varchar(255),
          code_postal bigint,
          pays varchar(255),
          ville varchar(255),
          date_commande date,
          constraint pk_idc primary key (id_commande),
          constraint idl foreign key (id_livraison) references livraison (id_livraison));")

#Creation de la table COMMANDE dans la base.sqlite
dbExecute(base,
          "create table commande ( 
          id_utilisateur bigint,
          id_livre bigint,
          id_commande bigint,
          date_commande date,
          quantite bigint,
          constraint idu foreign key (id_utilisateur) references utilisateur (id_utilisateur),
          constraint idl foreign key (id_livre) references livre (utilisateur),
          constraint idc foreign key (id_commande) references detail_commande (id_commande));")

#Creation de la table LIVRE dans la base.sqlite
dbExecute(base,
          "create table livre ( 
          id_livre bigint,
          id_auteur bigint,
          id_categorie bigint,
          titre varchar(255),
          editeur varchar(100),
          Date_parution date,
          poids float,
          nb_page int,
          distributeur varchar(50),
          epaisseur float,
          langue varchar(35),
          dimension varchar (50),
          prix float,
          constraint idl primary key (id_livre),
          constraint ida foreign key (id_auteur) references auteur (id_auteur),
          constraint ida foreign key (id_categorie) references categorie (id_categorie));")

#Creation de la table NAVIGATION dans la base.sqlite
dbExecute(base,
          "create table navigation ( 
          id_utilisateur bigint,
          id_page bigint,
          date date,
          constraint ul foreign key (id_utilisateur) references utilisateur (id_utilisateur),
          constraint pa foreign key (id_page) references page (id_page));")

#Lister toutes les tables dans la base
dbListTables(base)

#Lister les attributs dans chaque table
dbListFields(base, "utilisateur")
dbListFields(base, "livraison")


#Imporation de nos donneees depuis Excel (Les donnees generees ont ete stockees dans des fichiers Excel)
library(readxl)
auteur_data <- read_excel("data_projetsid.xlsx", sheet = "Auteur")
livre_data <- read_excel("data_projetsid.xlsx", sheet = "Livre")
categorie_data <-read_excel("data_projetsid.xlsx", sheet = "Categorie")
commande_data <-read_excel("data_projetsid.xlsx", sheet = "Commande")
detail_commande_data <-read_excel("data_projetsid.xlsx", sheet = "Detail_commande")
livraison_data <-read_excel("data_projetsid.xlsx", sheet = "Livraison")
navigation_data <- read_excel("data_projetsid.xlsx", sheet = "Navigation")
page_data <-read_excel("data_projetsid.xlsx", sheet = "Page")
utilisateur_data <- read_excel("data_projetsid.xlsx", sheet = "Utilisateur")

#Ecrtiture de ces donnees dans lerus tables respectifs dans la base sqlite
dbWriteTable(base,"auteur",auteur_data, overwrite = TRUE)
dbWriteTable(base,"livre",livre_data, overwrite = TRUE)
dbWriteTable(base,"categorie",categorie_data, overwrite = TRUE)
dbWriteTable(base,"commande",commande_data, overwrite = TRUE)
dbWriteTable(base,"detail_commande",detail_commande_data, overwrite = TRUE)
dbWriteTable(base,"navigation",navigation_data, overwrite = TRUE)
dbWriteTable(base,"page",page_data, overwrite = TRUE)
dbWriteTable(base,"utilisateur",utilisateur_data, overwrite = TRUE)
dbWriteTable(base,"livraison",livraison_data, overwrite = TRUE)


#Probleme de date lors de l'importation de nos donnees issues d'excel dans notre base
#Resolution de ce probleme a l'aide de R

################################### Solution probleme date dans table auteur ###################################
# Convertion de la la colonne Date_commande en chaines de caracteres
auteur_data$Date_naissance <- as.character(auteur_data$Date_naissance)
# Verifier si la table existe
if (dbExistsTable(base, "auteur")) {
  dbExecute(base, "DROP TABLE auteur")
}
# Ecriture des donnees dans la table auteur
dbWriteTable(base, "auteur", auteur_data, row.names = FALSE)
# Requete de mise a jour pour reformater la colonne Date_naissance dans la base de donnees
requete_reformatage <- "UPDATE auteur SET Date_naissance = strftime('%Y-%m-%d', Date_naissance)"
# Execution de la requete
dbExecute(base, requete_reformatage)
dbGetQuery(base, "SELECT * FROM auteur")


################################### Solution probleme date dans table commande ###################################
# Convertion de la colonne Date en chaines de caracteres
navigation_data$Date_commande <- as.character(commande_data$Date_commande)
# Reecriture dans la table avec le changement
dbWriteTable(base, "commande", commande_data, row.names = FALSE)
dbGetQuery(base, "SELECT * FROM commande")


################################### Solution probleme  date dans table navigation ###################################
# Convertion de la colonne Date en chaines de caracteres
navigation_data$Date <- as.character(navigation_data$Date)
# Reecriture dans la table avec le changement
dbWriteTable(base, "navigation", navigation_data, overwrite = TRUE)
dbGetQuery(base, "SELECT * FROM navigation")


################################### Solution probleme  date dans table utilisateur ###################################
#Date connexion
# Convertion de la colonne Date en chaines de caracteres
utilisateur_data$Date_connexion <- as.character(utilisateur_data$Date_connexion)
# Reecriture dans la table avec le changement
dbWriteTable(base, "utilisateur", utilisateur_data, overwrite = TRUE)
dbGetQuery(base, "SELECT * FROM utilisateur")

#Date naissance
# Convertion la colonne Date_naissance en chaines de caracteres
utilisateur_data$Date_naissance <- as.character(utilisateur_data$Date_naissance)
# Reecriture dans la table avec le changement
dbWriteTable(base, "utilisateur", utilisateur_data, overwrite = TRUE)
dbGetQuery(base, "SELECT * FROM utilisateur")



################################### Solution probleme  date dans table livre ###################################
# Convertion de la colonne Date en chaines de caracteres
livre_data$Date_parution <- as.character(livre_data$Date_parution)
# Reecriture dans la table avec le changement
dbWriteTable(base, "livre", livre_data, overwrite = TRUE)
dbGetQuery(base, "SELECT * FROM livre")



####################################################REQUETE SELON LES MESURES #################################################################

# 1 - MESURE additive
# Montant total par commande
dbGetQuery(base, "Select commande.id_commande, sum(livre.prix*commande.quantite) as montant_total 
                    From Commande
                    left join Livre
                          on commande.id_livre = livre.id_livre
                    group by commande.id_commande")


# Nombre total de livre commande
dbGetQuery(base, "SELECT sum(ID_Livre) as nombre_livre_commande FROM commande")




# 2 - MESURE semi-additive
# Nombre de page differentes parcouru par utilisateur
dbGetQuery(base, "SELECT id_utilisateur, count(distinct (id_page)) as Nombre_de_page
           FROM navigation
           group by 1")

# Nombre d'auteur par categorie
dbGetQuery(base, "SELECT categorie.nom_categ as categorie, count(distinct auteur.id_auteur) as Nombre_auteur
           FROM auteur 
           left join Livre 
                  on auteur.id_auteur = Livre.id_auteur
           left join categorie
                  on Livre.id_categorie = categorie.id_categorie
           group by nom_categ;")




# 3 - MESURE Non-Additif 
dbGetQuery(base, "SELECT categorie.nom_categ as categorie, round(Avg(livre.prix),2) as Prix_moyen
           FROM livre 
           left join categorie
                  on Livre.id_categorie = categorie.id_categorie
           group by nom_categ;")



# Nombre moyen d article commande par commande 
dbGetQuery(base, "SELECT * from detail_commande limit 5")
dbGetQuery(base, "SELECT * from commande limit 5")


# Pourcentage du nombre de livre appartenenant E la categorie Science-fiction galactique
dbGetQuery(base, "SELECT count(*) FROM livre")# 73 livres

dbGetQuery(base, "SELECT concat(round((count(livre.id_livre)*100/73),2),'%') as Pourcentage_livre_sf, categorie.nom_categ as Categorie
                FROM Categorie 
                left join Livre
                      on livre.id_categorie = categorie.id_categorie
                where nom_categ == 'Science-fiction galactique'")































