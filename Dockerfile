FROM python:3.11-slim-bookworm

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    fonts-dejavu \
    libffi-dev \
    libjpeg62-turbo-dev \
    libldap2-dev \
    liblcms2-dev \
    libpq-dev \
    libsasl2-dev \
    libssl-dev \
    libwebp-dev \
    libxml2-dev \
    libxslt1-dev \
    postgresql-client \
    wkhtmltopdf \
    zlib1g-dev \
    npm \
    && npm install -g rtlcss \
    && rm -rf /var/lib/apt/lists/*

RUN groupadd -g 1000 odoo && useradd -m -u 1000 -g odoo -s /bin/bash odoo

WORKDIR /opt/odoo/odoo-17

COPY requirements.txt /tmp/requirements.txt
RUN pip install --upgrade pip "setuptools<81" wheel && pip install -r /tmp/requirements.txt

# Add ddtrace library to instrumenting application with datadog
RUN pip install ddtrace

COPY . /opt/odoo/odoo-17
COPY docker/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh \
    && mkdir -p /var/lib/odoo /var/log/odoo \
    && chown -R odoo:odoo /opt/odoo /var/lib/odoo /var/log/odoo /entrypoint.sh

USER odoo

EXPOSE 8069 8072

ENTRYPOINT ["/entrypoint.sh"]
CMD ["ddtrace-run", "python", "odoo-bin"]
