# Deploy de una app con Docker en Render

Vas a desplegar una app web en Python (Streamlit) en internet usando **solo un Dockerfile**.
No hace falta Docker Hub: Render construye la imagen por ti desde tu repositorio de GitHub.

## Objetivo

- Crear tu propio `Dockerfile`
- Probar la imagen en local
- Desplegarla en Render y tener una URL pública

## Requisitos

- Docker Desktop instalado y abierto
- Cuenta de GitHub
- Cuenta gratuita en [render.com](https://render.com) (puedes entrar con GitHub)

## Paso 1. Crea tu propio repositorio

Este repo es de solo lectura para ti: puedes descargarlo, pero no hacer `push` en él. Render necesita un repo **tuyo** en GitHub, así que vas a descargar este código y subirlo a un repo nuevo.

**1.1. Descarga este repo en tu ordenador**

```bash
git clone https://github.com/Factoria-F5-madrid/deploy-docker-render.git
cd deploy-docker-render
```

- `git clone <url>`: descarga una copia del repo en tu ordenador.
- `cd deploy-docker-render`: entra en la carpeta que se acaba de crear.

**1.2. Crea un repo vacío en tu cuenta de GitHub**

1. Entra en https://github.com/new
2. En *Repository name* pon, por ejemplo, `deploy-docker-render`.
3. Déjalo en **Public**.
4. **No marques** *Add a README*, *.gitignore* ni *license*. Tiene que estar vacío, porque ya vas a subir tus archivos.
5. Pulsa **Create repository**. GitHub te muestra la URL de tu repo, algo como `https://github.com/<tu-usuario>/deploy-docker-render.git`. Cópiala.

**1.3. Conecta tu carpeta con tu repo y sube el código**

```bash
git remote set-url origin https://github.com/<tu-usuario>/deploy-docker-render.git
git remote -v
git push -u origin main
```

- `git remote set-url origin <url>`: un *remote* es la dirección de un repo en internet, y `origin` es el nombre del principal. Ahora mismo `origin` apunta al repo de Factoría, y con este comando lo cambias para que apunte al tuyo.
- `git remote -v`: lista los remotes para que compruebes que `origin` muestra **tu** URL y no la de Factoría.
- `git push -u origin main`: sube la rama `main` a tu repo. `-u` recuerda esa conexión, así que desde ahora basta con escribir `git push`.

La primera vez, Git te pedirá autenticarte con tu cuenta de GitHub. Si usas HTTPS, la contraseña de la cuenta no vale, hace falta un *token*. Lo más fácil es instalar la CLI de GitHub y ejecutar `gh auth login`.

Recarga la página de tu repo en GitHub: deberías ver `app.py`, `requirements.txt` y `README.md`.

## Paso 2. Crea el Dockerfile

Crea un archivo llamado `Dockerfile` (sin extensión) en la raíz del proyecto y pega esto:

```dockerfile
# Imagen base de Python
FROM python:3.11-slim

# Directorio de trabajo dentro del contenedor
WORKDIR /app

# Copiamos primero las dependencias (así Docker cachea esta capa)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiamos el código de la app
COPY app.py .

# Render inyecta $PORT (10000 por defecto). En local usamos 8501
ENV PORT=8501
EXPOSE 8501

# Forma shell (sin corchetes) para que se expanda $PORT
CMD streamlit run app.py --server.address=0.0.0.0 --server.port=$PORT --server.headless=true
```

Qué hace cada parte:

- `FROM`: imagen base con Python ya instalado.
- `WORKDIR`: carpeta donde vivirá la app dentro del contenedor.
- `COPY` + `RUN pip install`: copia e instala las dependencias.
- `ENV PORT=8501`: valor por defecto para local. En Render se sobrescribe con el puerto que ellos asignan.
- `$PORT`: es una variable. Antes de ejecutar el comando, la shell la sustituye por su valor (a eso se le llama *expandir*): con `PORT=10000` el comando acaba siendo `--server.port=10000`. Por eso el mismo Dockerfile vale en local (usa 8501) y en Render (usa el que le asigna Render).
- `CMD`: comando que arranca la app. Escucha en `0.0.0.0` (para ser accesible desde fuera del contenedor) y en el puerto `$PORT`. Render decide el puerto (no lo eliges tú) y lo comunica con la variable `$PORT`. Si dejas un puerto fijo, a veces Render lo detecta y a veces falla con *No open ports detected*, así que usa siempre `$PORT`.

## Paso 3. Pruébalo en local

```bash
docker build -t hello-docker .
docker run --rm -p 8501:8501 hello-docker
```

Qué hace cada comando:

- `docker build`: construye una **imagen** (la "plantilla" de tu app, con Python, las dependencias y tu código) siguiendo las instrucciones del `Dockerfile`.
  - `-t hello-docker`: `-t` (*tag*) le pone nombre a la imagen para poder usarla después.
  - `.`: el punto significa "busca el `Dockerfile` en esta carpeta".
- `docker run`: crea y arranca un **contenedor**, que es una instancia en ejecución de la imagen.
  - `--rm`: borra el contenedor automáticamente cuando lo pares (Ctrl+C). Sin esta opción, cada vez que ejecutas la app queda un contenedor parado ocupando espacio y tendrías que borrarlo a mano con `docker rm`.
  - `-p 8501:8501`: conecta puertos con el formato `puerto-de-tu-ordenador:puerto-del-contenedor`. Así lo que la app sirve en el 8501 dentro del contenedor lo ves tú en `localhost:8501`.
  - `hello-docker`: el nombre de la imagen que construiste antes.

Abre http://localhost:8501. Si ves la app, ya casi has terminado. Para pararla, vuelve a la terminal y pulsa Ctrl+C.

## Paso 4. Sube los cambios

```bash
git add Dockerfile
git commit -m "Añade Dockerfile"
git push
```

- `git add Dockerfile`: marca el archivo para incluirlo en el próximo commit.
- `git commit -m "..."`: guarda una "foto" de los cambios en tu historial local; `-m` es el mensaje que lo describe.
- `git push`: envía tus commits a **tu** repo en GitHub (el que conectaste en el paso 1). Render lo leerá desde allí.

## Paso 5. Despliega en Render

1. En Render pulsa **New +** y luego **Web Service**.
2. Conecta tu GitHub y elige tu repo.
3. Render detecta el `Dockerfile` y marca el lenguaje como **Docker**.
4. Elige el plan **Free**.
5. En *Advanced*, pon **Health Check Path** = `/_stcore/health`.
6. Pulsa **Deploy Web Service** y espera unos minutos.

Cuando termine tendrás una URL tipo `https://hello-docker-xxxx.onrender.com`.

## Opcional. Automatiza el deploy con render.yaml

En vez de rellenar el formulario a mano (paso 5), puedes describir el servicio en un archivo y Render lo lee. Se llama **Blueprint**.

Crea `render.yaml` en la raíz y pega esto:

```yaml
services:
  - type: web                        # servicio web con URL pública
    name: hello-docker               # nombre del servicio (sale en la URL)
    runtime: docker                  # construye la imagen con tu Dockerfile
    plan: free                       # plan gratuito
    healthCheckPath: /_stcore/health # ruta que Render consulta para saber si la app está viva
```

Haz commit y push, y en Render pulsa **New +** y luego **Blueprint**, elige tu repo y **Apply**. Render crea el servicio con esos mismos ajustes.

## Notas

- En el plan free el servicio se duerme tras 15 minutos sin tráfico y el primer acceso tarda cerca de un minuto.
- El disco es efímero: los nombres que guarda la app en `data/nombres.txt` se borran en cada redeploy o reinicio.
- Cada `git push` a `main` de tu repo vuelve a desplegar la app automáticamente.

## ¿Atascado?

La rama `solucion` tiene el `Dockerfile` terminado y un `render.yaml` opcional (Blueprint de Render).
