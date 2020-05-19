FROM ubuntu:20.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
 && apt-get install -y \
    curl \
    wget \
    dumb-init \
    htop \
    locales \
    man \
    nano \
    git \
    procps \
    ssh \
    sudo \
    vim \
    openssl \
    zip \
    unzip \
    iputils-ping \
  && rm -rf /var/lib/apt/lists/*

RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen && locale-gen
ENV LANG=en_US.UTF-8

RUN chsh -s /bin/bash
ENV SHELL=/bin/bash

RUN adduser --gecos '' --disabled-password coder && \
  echo "coder ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd

RUN curl -SsL https://github.com/boxboat/fixuid/releases/download/v0.4/fixuid-0.4-linux-amd64.tar.gz | tar -C /usr/local/bin -xzf - && \
    chown root:root /usr/local/bin/fixuid && \
    chmod 4755 /usr/local/bin/fixuid && \
    mkdir -p /etc/fixuid && \
    printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml

RUN wget https://github.com/cdr/code-server/releases/download/3.3.0/code-server-3.3.0-linux-x86_64.tar.gz && \
	tar -zxvf code-server-3.3.0-linux-x86_64.tar.gz && \
	mv code-server-3.3.0-linux-x86_64 code-server && \
	rm code-server-3.3.0-linux-x86_64.tar.gz && \
	mv code-server /usr/local/lib/code-server && \
	ln -s /usr/local/lib/code-server/code-server /usr/local/bin/code-server

RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -
RUN apt install -y nodejs
RUN npm install -g firebase-tools

RUN apt install -y php-cgi php-mbstring php-gd php-xml php-cli php-curl php-mysql php-imagick php-pgsql php-zip php-redis && \
	curl -sS https://getcomposer.org/installer -o composer-setup.php && \
	php composer-setup.php --install-dir=/usr/local/bin --filename=composer

RUN apt install -y python3

EXPOSE 8080
EXPOSE 8000
EXPOSE 3000
USER coder
WORKDIR /home/coder

ENTRYPOINT ["dumb-init", "fixuid", "-q", "/usr/local/bin/code-server", "--bind-addr", "0.0.0.0:8080",  "."]
