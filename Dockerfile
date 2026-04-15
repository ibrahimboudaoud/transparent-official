FROM --platform=linux/amd64 python:3.10-slim

# 1. Install system dependencies
RUN apt-get update && apt-get install -y \
    git cmake build-essential libgl1-mesa-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev \
    libsdl2-gfx-dev libboost-all-dev libboost-python-dev \
    libst-dev mesa-utils xvfb python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Force-link the Boost Python libraries
RUN ln -s /usr/lib/x86_64-linux-gnu/libboost_python310.so /usr/lib/x86_64-linux-gnu/libboost_python3.so && \
    ln -s /usr/lib/x86_64-linux-gnu/libboost_python310.a /usr/lib/x86_64-linux-gnu/libboost_python3.a

# 3. Install specific compatible versions of AI tools
RUN pip install --no-cache-dir --upgrade pip setuptools==65.5.0 wheel
RUN pip install --no-cache-dir torch torchvision captum streamlit opencv-python-headless
RUN pip install --no-cache-dir gym==0.21.0

# 4. Manually build the Google Research Football Engine
WORKDIR /opt
RUN git clone https://github.com/google-research/football.git
WORKDIR /opt/football
# We use --no-deps so it doesn't try to re-install the broken gym version
RUN pip install --no-deps .
RUN pip install pygame psutil

# 5. Set up project workspace
WORKDIR /app
COPY . /app

CMD ["tail", "-f", "/dev/null"]
