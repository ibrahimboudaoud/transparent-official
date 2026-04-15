FROM --platform=linux/amd64 python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git cmake build-essential libgl1-mesa-dev \
    libsdl2-dev libsdl2-image-dev libsdl2-ttf-dev \
    libsdl2-gfx-dev libboost-all-dev libboost-python-dev \
    libst-dev mesa-utils xvfb python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Fix for "Boost Python not found"
# This creates a shortcut so the installer finds the library where it expects it
RUN ln -s /usr/lib/x86_64-linux-gnu/libboost_python310.so /usr/lib/x86_64-linux-gnu/libboost_python3.so

# Install AI stack
RUN pip install --upgrade pip
RUN pip install torch torchvision captum streamlit opencv-python-headless

# Install gfootball separately to catch errors early
RUN pip install gfootball

WORKDIR /app
COPY . /app

CMD ["tail", "-f", "/dev/null"]
