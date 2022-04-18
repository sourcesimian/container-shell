ARG BASE=ubuntu:22.04
FROM $BASE as builder

# Install base packages
RUN apt-get update \
 && apt-get install -y \
        curl \
        docker.io \
        git \
        gcc \
        jq \
        locales \
        openssh-client \
        python3 \
        python3-distutils \
        python3-venv \
        shellcheck \
        zsh \
  && rm -rf /var/lib/apt/lists/* \
  && locale-gen en_US.UTF-8

# Python
RUN ln -s /usr/bin/python3 /usr/bin/python
RUN curl -kLo /get-pip.py https://bootstrap.pypa.io/get-pip.py \
 && python3 /get-pip.py \
 && rm /get-pip.py
COPY ./python3-requirements.txt /
RUN pip3 install -r /python3-requirements.txt --no-cache-dir \
 && rm /python3-requirements.txt

RUN mkdir /cosh

# User setup 
COPY ./setupuser.c /
RUN gcc -o /cosh/setupuser /setupuser.c \
 && rm /setupuser.c

# Docker socket access
COPY ./setupdocker.c /
RUN gcc -o /cosh/setupdocker /setupdocker.c \
 && rm /setupdocker.c

# Cleanup and compact the layers from above to reduce image size
RUN apt-get clean \
 && apt-get autoremove \
 && rm -rf /var/lib/apt/lists/*
# ----------------------------------------------------------------------------------
FROM scratch
COPY --from=builder / /

ARG COSH_IMAGE
ENV COSH_IMAGE=$COSH_IMAGE

# Set setuid flag
RUN chmod 4511 /cosh/setupuser \
 && chmod 4511 /cosh/setupdocker

# Mock sudo - dev tools that need sudo are bad
COPY ./sudo /usr/bin/sudo

# ZSH
COPY ./zshrc /etc/zsh/zshrc.cosh
RUN cat /etc/zsh/zshrc.cosh >> /etc/zsh/zshrc

# CoSH
COPY ./cosh/ /cosh/

# Launcher
ENTRYPOINT ["/cosh/install.sh"]
