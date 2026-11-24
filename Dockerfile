FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PORT=8080 \
    HOST=0.0.0.0 \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# Install essential system dependencies for OpenCV, PyAV, FFmpeg, soundfile and healthcheck curl
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ffmpeg \
    libsm6 \
    libxext6 \
    libgl1 \
    libglib2.0-0 \
    curl \
    libsndfile1 \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies using CPU-optimized PyTorch
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY . .

# Ensure runtime directories exist
RUN mkdir -p /app/data/uploads /app/data/reports /app/data/models /app/corpus/verified_reference

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:${PORT:-8080}/health || exit 1

# Launch production server on platform $PORT (Railway, Google Cloud Run)
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8080} --workers 1"]
