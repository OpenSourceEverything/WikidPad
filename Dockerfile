FROM python:3.10-bookworm
WORKDIR /app

# Copy only the OS deps script first to leverage layer cache
COPY scripts/os_deps.sh scripts/os_deps.sh
RUN bash scripts/os_deps.sh && rm -rf /var/lib/apt/lists/*

# Bring in the rest of the project
COPY . .

# Prefer system wx inside the container
ENV USE_SYSTEM_WX=1

# Run the full CI flow inside the container
CMD ["bash", "-lc", "make ci"]
