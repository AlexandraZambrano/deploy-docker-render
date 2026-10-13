FROM python:3.11-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py .

# Render inyecta $PORT (10000 por defecto); en local usamos 8501
ENV PORT=8501
EXPOSE 8501

# Forma shell para que se expanda $PORT
CMD streamlit run app.py --server.address=0.0.0.0 --server.port=$PORT --server.headless=true
