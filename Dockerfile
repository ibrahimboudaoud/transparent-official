FROM --platform=linux/amd64 python:3.10-slim

# 1. System dependencies
RUN apt-get update && apt-get install -y \
    git cmake build-essential libgl1-mesa-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev \
    libsdl2-gfx-dev libboost-all-dev libboost-python-dev \
    libst-dev mesa-utils xvfb python3-dev freeglut3-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Fix Boost links
RUN ln -s /usr/lib/x86_64-linux-gnu/libboost_python310.so /usr/lib/x86_64-linux-gnu/libboost_python3.so && \
    ln -s /usr/lib/x86_64-linux-gnu/libboost_python310.a /usr/lib/x86_64-linux-gnu/libboost_python3.a

# 3. Pre-install ALL requirements (Build + App)
RUN pip install --no-cache-dir --upgrade pip setuptools wheel psutil
RUN pip install --no-cache-dir torch torchvision captum streamlit opencv-python-headless pygame

# 4. Manual Gym Injection (Bypasses metadata errors)
WORKDIR /opt
RUN git clone https://github.com/openai/gym.git && \
    cd gym && \
    git checkout v0.21.0 && \
    cp -r gym /usr/local/lib/python3.10/site-packages/

# 5. Build Football Engine - CRITICAL: Added --no-build-isolation
RUN git clone https://github.com/google-research/football.git
WORKDIR /opt/football
RUN pip install --no-deps --no-build-isolation .

# 6. Final App Setup
WORKDIR /app
COPY . /app

CMD ["tail", "-f", "/dev/null"]
