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

## Paso 1. Haz tu copia del repo

Pulsa **Fork** (o **Use this template**) para tener el repo en tu cuenta de GitHub y clónalo:

```bash
git clone https://github.com/<tu-usuario>/deploy-docker-render.git
cd deploy-docker-render
```

## Paso 2. Crea el Dockerfile

Crea un archivo llamado `Dockerfile` (sin extensión) en la raíz. Tiene que:

1. Partir de la imagen `python:3.11-slim`
2. Usar `/app` como directorio de trabajo
3. Copiar `requirements.txt` e instalar las dependencias con `pip install --no-cache-dir -r requirements.txt`
4. Copiar `app.py`
5. Arrancar con: `streamlit run app.py --server.address=0.0.0.0 --server.port=$PORT --server.headless=true`

Dos pistas importantes:

- Render le dice a tu app en qué puerto escuchar con la variable de entorno `$PORT`. Si el puerto está fijo en el código, el deploy falla con *No open ports detected*.
- Para que `$PORT` se expanda, el `CMD` debe ir en **forma shell** (texto normal, sin corchetes).
- Para probar en local, define un valor por defecto en el Dockerfile con `ENV PORT=8501`.

## Paso 3. Pruébalo en local

```bash
docker build -t hello-docker .
docker run --rm -p 8501:8501 hello-docker
```

Abre http://localhost:8501. Si ves la app, ya casi has terminado.

## Paso 4. Sube los cambios

```bash
git add Dockerfile
git commit -m "Añade Dockerfile"
git push
```

## Paso 5. Despliega en Render

1. En Render pulsa **New +** y luego **Web Service**.
2. Conecta tu GitHub y elige tu repo.
3. Render detecta el `Dockerfile` y marca el lenguaje como **Docker**.
4. Elige el plan **Free**.
5. En *Advanced*, pon **Health Check Path** = `/_stcore/health`.
6. Pulsa **Deploy Web Service** y espera unos minutos.

Cuando termine tendrás una URL tipo `https://hello-docker-xxxx.onrender.com`.

## Notas

- En el plan free el servicio se duerme tras 15 minutos sin tráfico y el primer acceso tarda cerca de un minuto.
- El disco es efímero: los nombres que guarda la app en `data/nombres.txt` se borran en cada redeploy o reinicio.
- Cada `git push` a `main` vuelve a desplegar la app automáticamente.

## ¿Atascado?

La rama `solucion` tiene el `Dockerfile` terminado y un `render.yaml` opcional (Blueprint de Render).
