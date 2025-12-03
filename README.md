PROYECTO FPT Y MYSQL EN SERVIDORES DISTINTOS
----------------------------------------------

**los dos servidores están en equipos distintos**

Aquí iría toda la documentación de vuestro proyecto.

**git config --global credential.helper** store copiar el token de github cuando en el siguiente push pida la contraseña y ya se queda almacenado enel elkey ring

Cuestiones a tener en cuenta
============================

1. Las credenciales del LAB cambian. Fichero *$HOME/.aws/credentials*
2. Si queréis poderos conectar a la instancia por ssh una vez levantada acordaros de usar el *key_name* en terraform con un *.pem/.ppk* que ya tengáis descargado.
3. Si queréis asociar una interfaz y una IP elástica hay que crear tambien un Internet Gateway.

    ```python
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

    ```
    

4. Acordaros del security group para permitir el tráfico necesario (ssh, ftp con los puertos pasivos)
5.- El servicio mysql no será publico, solo se podrá acceder desde la ip del servidor FTP, por lo que usaréis la ip privada en la configuración.