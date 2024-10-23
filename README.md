
# Terraform AWS VPC Setup

Ce dépôt contient un ensemble de fichiers Terraform pour créer une infrastructure de base sur AWS. Cette infrastructure inclut un VPC, des sous-réseaux, des passerelles Internet et NAT, ainsi que des groupes de sécurité.

## Prérequis

Avant d'utiliser ce template, assurez-vous d'avoir les éléments suivants :

- Un compte AWS actif.
- Terraform installé est configurer sur votre machine. Vous pouvez le télécharger depuis [le site officiel de Terraform](https://www.terraform.io/downloads).

## Structure des Fichiers

1. **`main.tf`** : Ce fichier définit les ressources principales de votre infrastructure AWS.
2. **`security.tf`** : Ce fichier configure les groupes de sécurité pour votre VPC.
3. **`providers.tf`** : Ce fichier configure le fournisseur AWS pour Terraform.

## Description des Ressources

### `main.tf`

- **VPC** : Crée un Virtual Private Cloud (VPC) avec le CIDR `10.0.0.0/16`.
- **Sous-réseau Public** : Crée un sous-réseau public avec le CIDR `10.0.1.0/24`, associé à une table de routage qui utilise une passerelle Internet pour permettre l'accès au réseau extérieur.
- **Sous-réseau Privé** : Crée un sous-réseau privé avec le CIDR `10.0.2.0/24`, associé à une table de routage qui utilise une passerelle NAT pour permettre aux instances dans ce sous-réseau d'accéder à Internet de manière sécurisée.
- **Passerelle Internet** : Crée une passerelle Internet pour permettre aux instances dans le sous-réseau public d'accéder à Internet.
- **Passerelle NAT** : Crée une passerelle NAT dans le sous-réseau public pour permettre aux instances dans le sous-réseau privé d'accéder à Internet.
- **Tables de Routage** : Crée des tables de routage pour le sous-réseau public et le sous-réseau privé, avec les routes appropriées vers la passerelle Internet et la passerelle NAT.

### `security.tf`

- **Groupe de Sécurité pour le Sous-Réseau Public** : Crée un groupe de sécurité pour le sous-réseau public qui autorise le trafic entrant sur les ports 80 (HTTP), 443 (HTTPS), et 22 (SSH) depuis n'importe quelle adresse IP. Le trafic sortant est autorisé pour toutes les destinations et tous les ports.

### `providers.tf`

- **Configuration du Fournisseur AWS** : Configure le fournisseur AWS avec la région `us-west-2`.

## Déploiement

1. **Initialiser Terraform** : Exécutez la commande suivante pour initialiser votre répertoire de travail Terraform et télécharger les plugins nécessaires :

   ```sh
   terraform init
## Plan

2. **Planifier le Déploiement** : Exécutez la commande suivante pour voir un aperçu des changements qui seront apportés par Terraform :

   ```sh
   terraform plan

## Apply 

3. **Appliquer le Déploiement** : Exécutez la commande suivante pour créer les ressources sur AWS. Vous devrez confirmer l'application des changements en entrant 'yes' lorsque Terraform vous le demandera :

   ```sh
   terraform apply

## Destroy/Nettoyage

4. **Appliquer le Déploiement** : Pour supprimer toutes les ressources créées par Terraform, exécutez la commande suivante. Assurez-vous de vérifier que vous ne détruisez pas accidentellement des ressources importantes :

   ```sh
   terraform destroy
