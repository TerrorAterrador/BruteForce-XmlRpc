# BruteForce-XmlRpc
Herramienta creada en **bash** que nos permite realizar un ataque de fuerza bruta a una página web que este alojada en un WordPress y tenga expuesto el archivo **xmlrpc.php**.<br>

Las opciones son las siguientes:

- d) Especificar la dirección IP.
- u) Especificar el nombre del usuario.
- w) Especificar la ruta al diccionario con el que aplicar fuerza bruta.
- i) Mostrar una barra de progreso informativa. (El tiempo de ejecución podría verse afectado).

---

## Uso

```shell
wget https://raw.githubusercontent.com/TerrorAterrador/BruteForce-XmlRpc/main/brute-force-xmlrpc.sh
```

```shell
chmod +x brute-force-xmlrpc.sh
```

---

## Ejemplo Práctico

```shell
./brute-force-xmlrpc.sh -d http://127.0.0.1:31337 -w /usr/share/wordlists/rockyou.txt -u TerrorAterrador -i
```

![image](https://github.com/user-attachments/assets/0a854469-11c9-407a-8fdd-28cb2d7861ed)

---

## WpScan

Para sacar los posibles nombres de usuarios podríamos usar la herramienta **WpScan**:

```shell
wpscan --url http://127.0.0.1:31337 -e u
```

![image](https://github.com/user-attachments/assets/4dec1901-cf21-4b89-a566-4cd2dfba06aa)

---

### Practicar

##### En el caso de que queramos probar el script de fuerza bruta podríamos usar el recurso [DVWP](https://github.com/vavkamil/dvwp) el cual nos monta unos contenedores con un WordPress para realizar pruebas.

##### También podríamos usar el laboratorio **WalkingCMS** de [DockerLabs](https://dockerlabs.es) creado por el [El Pinguino De Mario](https://github.com/Maalfer)

---

### Advertencia legal

Este software está destinado solo para uso personal y debe utilizarse únicamente en entornos controlados y con autorización previa. El empleo de esta herramienta en sistemas o redes sin la debida autorización puede ser ilegal y contravenir políticas de seguridad. El desarrollador no se hace responsable de daños, pérdidas o consecuencias resultantes de su uso inapropiado o no autorizado. Antes de utilizar esta herramienta, asegúrate de cumplir con todas las leyes y regulaciones locales pertinentes.
