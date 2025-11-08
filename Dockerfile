# ==============================
# 🐍 1️⃣ Base image — stable, small, and fast
# ==============================
FROM python:3.11-slim

# Prevent .pyc files and enable clean logging
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Set working directory inside container
WORKDIR /app

# Copy project files into the container
COPY . /app/

# ==============================
# ⚙️ 2️⃣ Install required system packages
# ==============================
# Includes build tools and libraries needed by PyMuPDF, tesseract, etc.
RUN apt-get update && apt-get install -y \
    build-essential \
    libpoppler-cpp-dev \
    tesseract-ocr \
    libtesseract-dev \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# ==============================
# 📦 3️⃣ Install Python dependencies
# ==============================
# Upgrade pip & install all dependencies
RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

# ==============================
# 🌍 4️⃣ Expose port and environment
# ==============================
EXPOSE 10000
ENV PORT=10000

# ==============================
# 🚀 5️⃣ Start the Django app using Gunicorn
# ==============================
CMD ["gunicorn", "ai_companion.wsgi:application", "--bind", "0.0.0.0:10000"]
