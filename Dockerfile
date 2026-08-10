# ── Stage 1: Builder (Biên dịch & cài thư viện) ──
FROM python:3.11-slim AS builder

WORKDIR /app

# Copy requirements.txt và cài thư viện vào /install trước (Tận dụng Docker Cache)
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt


# ── Stage 2: Runtime (Chạy ứng dụng gọn nhẹ) ──
FROM python:3.11-slim AS runtime

WORKDIR /app

# Copy các thư viện đã cài ở Stage 1 sang Runtime
COPY --from=builder /install /usr/local

# Copy mã nguồn ứng dụng (COPY sau để tối ưu cache)
COPY app ./app
COPY utils ./utils

# Bảo mật: Tạo và chuyển sang user thường (không dùng root)
RUN useradd --create-home --uid 10001 appuser
USER appuser

EXPOSE 8000

# Cấu hình kiểm tra sức khỏe container
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
    CMD python -c "import urllib.request, os; port = os.getenv('PORT', '8000'); urllib.request.urlopen(f'http://127.0.0.1:{port}/healthz').read()" || exit 1

# Lệnh chạy ứng dụng linh hoạt theo cổng $PORT
CMD ["python", "-m", "app.main"]

