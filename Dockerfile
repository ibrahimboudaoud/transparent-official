FROM --platform=linux/amd64 python:3.10-slim

# 1. System dependencies
RUN apt-get update && apt-get install -y \
    git cmake build-essential libgl1-mesa-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev \
    libsdl2-gfx-dev libboost-all-dev libboost-python-dev \
    libst-dev mesa-utils xvfb python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Boost links
RUN ln -s /usr/lib/x86_64-linux-gnu/libboost_python310.so /usr/lib/x86_64-linux-gnu/libboost_python3.so && \
    ln -s /usr/lib/x86_64-linux-gnu/libboost_python310.a /usr/lib/x86_64-linux-gnu/libboost_python3.a

# 3. Core AI tools
RUN pip install --no-cache-dir --upgrade pip setuptools==65.5.0 wheel
RUN pip install --no-cache-dir torch torchvision captum streamlit opencv-python-headless

# 4. SURGERY: Fix the broken gym metadata
WORKDIR /opt
RUN git clone https://github.com/openai/gym.git && \
    cd gym && \
    git checkout 0.21.0 && \
    # This sed command finds the broken 'opencv-python' line and removes it to prevent the crash
    sed -i "s/'opencv-python[^']*'//g" setup.py && \
    pip install -e .

# 5. Build the Football Engine
RUN git clone https://github.com/google-research/football.git
WORKDIR /opt/football
RUN pip install --no-deps .
RUN pip install pygame psutil

WORKDIR /app
COPY . /app

CMD ["tail", "-f", "/dev/null"]
