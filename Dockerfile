FROM --platform=linux/amd64 python:3.10-slim

# 1. System dependencies - includes everything needed for C++ compilation
RUN apt-get update && apt-get install -y \
    git cmake build-essential libgl1-mesa-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev \
    libsdl2-gfx-dev libboost-all-dev libboost-python-dev \
    libst-dev mesa-utils xvfb python3-dev freeglut3-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Fix Boost links for Python 3.10
RUN ln -s /usr/lib/x86_64-linux-gnu/libboost_python310.so /usr/lib/x86_64-linux-gnu/libboost_python3.so && \
    ln -s /usr/lib/x86_64-linux-gnu/libboost_python310.a /usr/lib/x86_64-linux-gnu/libboost_python3.a

# 3. Install AI tools and build-time requirements (psutil must be here)
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
RUN pip install --no-cache-dir torch torchvision captum streamlit opencv-python-headless pygame psutil

# 4. SURGERY: Manually inject gym 0.21.0
# We copy the source directly to site-packages to avoid broken setup.py metadata
WORKDIR /opt
RUN git clone https://github.com/openai/gym.git && \
    cd gym && \
    git checkout v0.21.0 && \
    cp -r gym /usr/local/lib/python3.10/site-packages/

# 5. Build the Google Research Football Engine
RUN git clone https://github.com/google-research/football.git
WORKDIR /opt/football
RUN pip install --no-deps .

# 6. Final App Setup
WORKDIR /app
COPY . /app

CMD ["tail", "-f", "/dev/null"]
