FROM python:3.10-bookworm
RUN apt-get update && apt-get install -y xvfb libgtk-3-0 libgl1 make \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY requirements.txt .
ARG WX_VERSION=4.2.1
RUN if [ "$WX_VERSION" = "latest" ]; then \
      pip install -U wxPython; \
    else \
      pip install "wxPython==${WX_VERSION}"; \
    fi \
    && pip install -r requirements.txt
COPY . .
CMD ["bash", "scripts/ci_test_gui.sh"]
