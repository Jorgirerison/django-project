# USAMOS A IMAGEM OFICIAL DO PYTHON
FROM python:3.12-slim

# 1. Trazemos o binário do uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# 2. Variáveis de Ambiente
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy

WORKDIR /app

# 3. Instalação do Cron e dependências do sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    cron \
    nano \
    && rm -rf /var/lib/apt/lists/*

# 4. Dependências (Lógica Híbrida: pyproject.toml OU requirements.txt)
# O truque do asterisco (*) faz o COPY não falhar se um dos arquivos não existir
COPY pyproject.tom* uv.loc* requirements.tx* ./

# Usamos o mount de cache do uv para acelerar
RUN --mount=type=cache,target=/root/.cache/uv \
    # Se existir pyproject.toml...
    if [ -f pyproject.toml ]; then \
        # ...instala as dependências definidas nele no sistema
        uv pip install --system .; \
    # Caso contrário, se existir requirements.txt...
    elif [ -f requirements.txt ]; then \
        # ...instala via requirements
        uv pip install --system -r requirements.txt; \
    fi

# 5. Cópia do Código (o restante do projeto)
COPY . .

# 6. Configuração do Cron
COPY ./cron /etc/cron.d/cron
RUN chmod 0644 /etc/cron.d/cron
RUN crontab /etc/cron.d/cron

EXPOSE 8000

# Mantemos seu comando de entrada original
CMD cron && python manage.py migrate && python manage.py runserver 0.0.0.0:8000
