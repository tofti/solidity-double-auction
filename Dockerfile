FROM ubuntu:latest

RUN \
    apt-get update && \
    apt-get install -y \
    git \
    vim \
    curl \
    tmux \
    htop \
    zsh && \
    # add nodejs
    curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update && \
    apt-get install -y nodejs && \
    corepack enable

# RUN chsh /usr/bin/zsh

# Set the working directory inside the container
WORKDIR /app

# the hardhat local network port
EXPOSE 8545

# Define the command to run when the container starts
CMD [ "zsh" ]