
provider "aws" {
  region = "us-east-1" # Ajusta la región según tu necesidad
}

# 1. Crear VPC y Subnet (si no existen)
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "main" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
}

# 2. Security Group con reglas para SSH y FTP pasivo
resource "aws_security_group" "instance_sg" {
  name        = "instance-sg"
  description = "Permitir SSH y FTP pasivo"
  vpc_id      = aws_vpc.main.id

  # SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # PUERTO PPAL FTP
  ingress {
    description = "FTP CONTROL"
    from_port   = 21
    to_port     = 21
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # FTP pasivo (puertos 25000-25100)
  ingress {
    description = "FTP Pasivo"
    from_port   = 25000
    to_port     = 25100
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Salida libre
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

# Tabla de rutas pública
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Asociar la tabla de rutas a la subred
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.main.id
  route_table_id = aws_route_table.public_rt.id
}


# 3. Instancia Ubuntu 22.04
resource "aws_instance" "ubuntu" {
  ami           = "ami-0c398cb65a93047f2" # AMI Ubuntu 22.04 (ajusta según región)
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main.id
  security_groups = [aws_security_group.instance_sg.id]

  tags = {
    Name = "Ubuntu-FTP-SSH"
  }
}

# 4. Crear interfaz de red secundaria
resource "aws_network_interface" "secondary" {
  subnet_id       = aws_subnet.main.id
  security_groups = [aws_security_group.instance_sg.id]
}

# 5. Asociar la interfaz a la instancia
resource "aws_network_interface_attachment" "attach_secondary" {
  instance_id          = aws_instance.ubuntu.id
  network_interface_id = aws_network_interface.secondary.id
  device_index         = 1
}

# 6. Crear Elastic IP y asociarla a la interfaz secundaria
resource "aws_eip" "elastic_ip" {

}

resource "aws_eip_association" "eip_assoc" {
  network_interface_id = aws_network_interface.secondary.id
  allocation_id        = aws_eip.elastic_ip.id
}
