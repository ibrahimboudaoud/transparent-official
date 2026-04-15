FROM --platform=linux/amd64 python:3.10-slim

# 1. Install every possible dependency for the engine
RUN apt-get update && apt-get install -y \
    git cmake build-essential libgl1-mesa-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev \
    libsdl2-gfx-dev libboost-all-dev libboost-python-dev \
    libst-dev mesa-utils xvfb python3-dev \
    && rm -rf /var/lib/apt/lists/*

# 2. Force-link the Boost Python libraries where the engine expects them
RUN ln -s /usr/lib/x86_64-linux-gnu/libboost_python310.so /usr/lib/x86_64-linux-gnu/libboost_python3.so && \
    ln -s /usr/lib/x86_64-linux-gnu/libboost_python310.a /usr/lib/x86_64-linux-gnu/libboost_python3.a

# 3. Pre-install the Python requirements
RUN pip install --no-cache-dir --upgrade pip setuptools wheel
RUN pip install --no-cache-dir torch torchvision captum streamlit opencv-python-headless gym==0.26.2

# 4. MANUALLY build the Google Research Football Engine
WORKDIR /opt
RUN git clone https://github.com/google-research/football.git
WORKDIR /opt/football
RUN pip install .

# 5. Set up your project workspace
WORKDIR /app
COPY . /app

CMD ["tail", "-f", "/dev/null"]
