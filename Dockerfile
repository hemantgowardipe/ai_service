# ==============================
# 1️⃣ Use Python image
# ==============================
FROM python:3.11-slim

WORKDIR /app
COPY . /app/

# ==============================
# 2️⃣ Install dependencies
# ==============================
RUN pip install --upgrade pip setuptools wheel
RUN pip install --no-cache-dir -r requirements.txt

# ==============================
# 3️⃣ Run Django app
# ==============================
EXPOSE 10000
CMD ["gunicorn", "ai_companion.wsgi:application", "--bind", "0.0.0.0:10000"]
