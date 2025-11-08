# ==============================
# 1️⃣ Use a stable, small Python image
# ==============================
FROM python:3.11-slim

# Prevent Python from writing .pyc files and buffering logs
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# ==============================
# 2️⃣ Set working directory
# ==============================
WORKDIR /app

# ==============================
# 3️⃣ Copy project files
# ==============================
COPY . /app/

# ==============================
# 4️⃣ Install system dependencies
# ==============================
RUN apt-get update && apt-get install -y \
    build-essential \
    libpoppler-cpp-dev \
    tesseract-ocr \
    libtesseract-dev \
    && rm -rf /var/lib/apt/lists/*

# ==============================
# 5️⃣ Install Python dependencies
# ==============================
RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

# ==============================
# 6️⃣ Expose port and set environment
# ==============================
EXPOSE 10000
ENV PORT 10000

# ==============================
# 7️⃣ Run your Django app via Gunicorn
# ==============================
CMD ["gunicorn", "ai_companion.wsgi:application", "--bind", "0.0.0.0:10000"]
