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

Ce fichier est utilisé pour créer le VPC, les sous-réseaux et d'autres ressources globales. Et fait appel au module pour créer les instances EC2,des Groupes de sécurité ... :

```hcl
provider "aws" {
  region                   = "us-east-1"
}

# terraform {
#   backend "s3" {
#     bucket                  = "terraform-backend-lepro"
#     key                     = "Lepro-dev.tfstate"
#     region                  = "us-east-1"
#   }
# }

# Création du VPC
resource "aws_vpc" "my_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "my-vpc"
  }
}

# Création du sous-réseau public
resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Création du sous-réseau privé
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.2.0/24"
   availability_zone = "us-east-1b"
  tags = {
    Name = "private-subnet"
  }
}

# Création de l'Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "my-igw"
  }
}

# Création de la NAT Gateway
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "my-nat-gw"
  }
}

# Table de routage publique
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Association de la table de routage publique au sous-réseau public
resource "aws_route_table_association" "public_rta" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# Table de routage privée
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "private-rt"
  }
}

# Association de la table de routage privée au sous-réseau privé
resource "aws_route_table_association" "private_rta" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}


# Création du sg
module "sg" {
  source = "./modules/sg"
  vpc_id        = aws_vpc.my_vpc.id
}

# Création de l'EIP
module "eip" {
  source = "./modules/eip"
}

# Création de l'EC2
module "ec2" {
  source        = "./modules/ec2"
  instance_type = "t2.small"
  public_ip     = module.eip.output_eip
  sg_id       = module.sg.output_sg_id
  subnet_id     = aws_subnet.public_subnet.id
  server_name   = "public_server"

}

module "priv_ec2" {
  source        = "./modules/ec2"
  instance_type = "t2.small"
  #public_ip     = module.eip.output_eip
  sg_id       = module.sg.output_sg_id
  subnet_id     = aws_subnet.private_subnet.id
  server_name   = "private_server"

}
#Creation des associations nécessaires
resource "aws_eip_association" "eip_assoc" {
  instance_id   = module.ec2.output_ec2_id
  allocation_id = module.eip.output_eip_id
}
```
## configuration de son environnement pour communiquer avec aws:
### Récupération de la Clé d'Accès AWS

Pour communiquer avec AWS et effectuer des actions programmatiques, vous devez récupérer vos **clés d'accès**. Ces clés sont essentielles pour authentifier vos requêtes API vers AWS. Voici comment procéder :

1. **Connectez-vous à la console AWS** :
   - Allez sur [AWS Management Console](https://aws.amazon.com/console/).
   - Connectez-vous avec vos identifiants.

2. **Accédez à la section IAM** :
   - Dans la console, recherchez et sélectionnez **IAM** (Identity and Access Management).
    ![image](https://github.com/user-attachments/assets/48c65c02-3854-4e5e-90fe-fd641ba6d133)

3. **Gérez les utilisateurs** :
   - Cliquez sur **Users** dans le volet de navigation.
   - Sélectionnez l'utilisateur pour lequel vous souhaitez créer des clés d'accès. Si vous n'avez pas encore d'utilisateur, créez-en un.
      ![image](https://github.com/user-attachments/assets/b2670833-e95a-4d8f-a317-773425bd411c)

4. **Créer des clés d'accès** :
   - Dans l'onglet **Security credentials**, faites défiler vers le bas jusqu'à la section **Access keys**.
   - Cliquez sur **Create access key**.
   - Une nouvelle clé d'accès sera générée. Notez bien la **Access Key ID** et la **Secret Access Key**. 
  ![image](https://github.com/user-attachments/assets/7b502b0d-bd2e-4227-af26-b7ecbc335e60)


   > **Important** : Conservez ces informations en lieu sûr. Vous ne pourrez pas récupérer la **Secret Access Key** après avoir quitté la page.

5. **Configurer votre environnement** :
   - Vous pouvez configurer vos clés d'accès dans votre environnement local en utilisant AWS CLI ou directement dans votre code Terraform.
   - sur votre terminale :
   ```bash
   export AWS_ACCESS_KEY_ID=
   export AWS_SECRET_ACCESS_KEY=```

#### Exemples de configuration avec AWS CLI

Vous pouvez configurer vos clés d'accès en utilisant la commande suivante :

```bash
 aws configure```

## Récupération de la Paire de Clés SSH

Pour se connecter à vos instances EC2 par SSH, vous devez créer et télécharger une **paire de clés SSH**. Voici les étapes à suivre :

1. **Connectez-vous à la console AWS** :
   - Rendez-vous sur [AWS Management Console].
   - Connectez-vous avec vos identifiants.

2. **Accédez à la section EC2** :
   - Dans la console, recherchez et sélectionnez **EC2**.

3. **Créer une paire de clés** :
   - Dans le volet de navigation, cliquez sur **Key Pairs** sous la section **Network & Security**.
   - Cliquez sur le bouton **Create key pair**.
   - Donnez un nom à votre paire de clés (par exemple, `my-key-pair`).

4. **Télécharger la clé** :
   - Choisissez le format de fichier (`.pem` pour Linux/Mac ou `.ppk` pour Windows avec PuTTY).
   - Cliquez sur **Create** pour générer votre paire de clés.
   - Le fichier de clé privée sera automatiquement téléchargé. **Conservez-le en lieu sûr**, car vous ne pourrez pas le récupérer plus tard.

5. **Configurer les permissions de la clé** (pour Linux/Mac) :
   - Ouvrez un terminal et exécutez la commande suivante pour restreindre l'accès à votre clé :
   ```bash
   chmod 400 /path/to/your/my-key-pair.pem

## Commandes Terraform à Exécuter

1. **Initialiser le projet** :
   ```bash
   terraform init```

2. **Planifier l'infrastructure** :
   ```bash
   terraform plan```
3. **Appliquer les changements** :
   ```bash
   terraform apply```
4. **Destruction de l'infrastructure** :
   ```bash
   terraform destroy```
