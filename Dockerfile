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
