<img width="557" alt="image" src="https://github.com/user-attachments/assets/72d2b1c4-1deb-4eab-9795-e116f27e6af5">


# Projet de Migration Cloud pour Proven-FR

L'entreprise Proven-FR souhaite migrer son infrastructure vers le cloud. Pour ce faire, elle a fait appel à un architecte AWS afin qu'il propose une architecture cloud garantissant la résilience, la scalabilité et surtout la sécurité de ses applications.

## Proposition de l'Architecte AWS

L'architecte a conçu une infrastructure structurée comme suit :

- **VPC (Virtual Private Cloud)** : 
  - CIDR : `10.0.0.0/16`
  - Composé de deux sous-réseaux :
    - **Sous-réseau public** : 
      - CIDR : `10.0.0.0/24`
      - Destiné à héberger les applications web.
    - **Sous-réseau privé** : 
      - CIDR : `10.0.2.0/23`
      - Destiné à héberger le backend des applications et les bases de données.

- **Passerelle Internet** : 
  - Permet aux ressources du sous-réseau public d'accéder à Internet.

- **Passerelle NAT** : 
  - Permet aux machines du sous-réseau privé d'accéder à Internet tout en restant inaccessibles depuis l'extérieur.

- **Tables de routage** : 
  - Chaque sous-réseau dispose d'une table de routage spécifique :
    - **Table de routage du sous-réseau public** : 
      - Route vers la passerelle Internet, permettant aux instances de ce sous-réseau d'accéder à Internet.
    - **Table de routage du sous-réseau privé** : 
      - Route vers la passerelle NAT, permettant aux instances de ce sous-réseau de faire des requêtes sortantes vers Internet.

- **Zone de disponibilité** : 
  - Les deux sous-réseaux se trouvent dans la même zone de disponibilité pour assurer la performance et la disponibilité des services.

## Rôle du DevOps

L'architecte ayant finalisé la conception, l'entreprise fait appel à vous, en tant que DevOps, pour proposer une implémentation de cette infrastructure en utilisant Terraform. Vous serez chargé de :

- Écrire des fichiers de configuration Terraform pour créer le VPC, les sous-réseaux, les tables de routage, la passerelle Internet et la passerelle NAT.
- Assurer que l'architecture respecte les meilleures pratiques en matière de sécurité et de gestion des ressources.
- Tester et valider l'implémentation pour garantir une mise en œuvre réussie.

Cette approche permettra à Proven-FR de bénéficier d'une infrastructure cloud robuste, évolutive et sécurisée.
## PROPOSITION DE SOLUTION
Le projet est divisé en trois modules distincts :

1. **EC2 Module**: Pour la création des instances EC2.
2. **EIP Module**: Pour la création des Elastic IP (EIP).
3. **SG Module**: Pour la gestion des groupes de sécurité (Security Groups).

Chaque module contiendra trois fichiers principaux :

- `main.tf`: Contient la définition des ressources pour le module.
- `variables.tf`: Définit les variables utilisées dans le module.
- `outputs.tf`: Définit les sorties du module qui peuvent être utilisées par d'autres modules ou par la configuration principale.
### Fichier `main.tf` de l'Application Principale

Ce fichier est utilisé pour créer le VPC, les sous-réseaux et d'autres ressources globales. Voici un exemple simplifié :

```hcl
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "public" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.0.0/24"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/23"
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id    = aws_subnet.public.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}
