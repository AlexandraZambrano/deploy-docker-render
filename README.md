# Deploy con Docker en Render (sin Docker Hub)

App Streamlit de ejemplo (`hello_docker`) desplegada en [Render](https://render.com) a partir de un `Dockerfile`.
Render construye la imagen por nosotros desde el repo de GitHub, así que no hace falta Docker Hub.

## 1. Probar en local

```bash
docker build -t hello-docker .
docker run --rm -p 8501:8501 hello-docker
```

Abre http://localhost:8501

## 2. Subir a GitHub

```bash
git init && git add . && git commit -m "Primer commit"
gh repo create deploy-docker-render --public --source=. --push
```

## 3. Desplegar en Render

1. Crea cuenta en render.com y conecta tu GitHub.
2. **New +** → **Web Service** → elige este repo.
3. Render detecta el `Dockerfile` y marca **Language: Docker**. Plan **Free**.
4. En *Advanced* pon **Health Check Path** = `/_stcore/health`.
5. **Deploy Web Service**. En unos minutos tendrás una URL `https://hello-docker-xxxx.onrender.com`.

Alternativa: **New +** → **Blueprint** y Render lee `render.yaml` y lo rellena todo.

## Notas

- Render pasa el puerto en la variable `$PORT`; el `Dockerfile` la usa. Si el puerto está fijo en el código, el deploy falla con "No open ports detected".
- Plan free: el servicio se duerme tras 15 min sin tráfico (el primer acceso tarda ~1 min) y el disco es efímero, así que `data/nombres.txt` se borra en cada redeploy o reinicio.
- Cada `git push` a `main` redespliega solo.
