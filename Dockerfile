FROM python:3.10-bookworm
RUN apt-get update && apt-get install -y xvfb libgtk-3-0 libgl1 \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY requirements.txt .
RUN pip install "wxPython==4.2.1" \
    && pip install -r requirements.txt
COPY . .
CMD ["bash", "scripts/ci_test_gui.sh"]
