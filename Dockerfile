FROM php:8.1-fpm

# Add Bullseye backports repository and install system dependencies including GCC 12
RUN apt-get update && apt-get install -y \
    software-properties-common \
    && echo "deb http://deb.debian.org/debian bullseye-backports main" >> /etc/apt/sources.list \
    && apt-get update && apt-get install -y \
    # nginx \
    git \
    unzip \
    wget \
    build-essential \
    libpcre3-dev \
    zlib1g-dev \
    autoconf \
    automake \
    libtool \
    libcurl4-openssl-dev \
    libzip-dev \
    pkg-config \
    libusb-1.0-0-dev \
    libssl-dev \
    gcc-12 \
    g++-12 \
    && rm -rf /var/lib/apt/lists/*

# Set GCC 12 as default
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-12 100 \
    && update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-12 100

# Install PHP extensions
RUN docker-php-ext-install pdo_mysql

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Compile and install libplist (version >= 2.3.0)
RUN git clone https://github.com/libimobiledevice/libplist.git /tmp/libplist \
    && cd /tmp/libplist \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && rm -rf /tmp/libplist

# Compile and install libgeneral (dependency for libfragmentzip)
RUN git clone https://github.com/tihmstar/libgeneral.git /tmp/libgeneral \
    && cd /tmp/libgeneral \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && rm -rf /tmp/libgeneral

# Compile and install libfragmentzip (dependency for tsschecker)
RUN git clone https://github.com/tihmstar/libfragmentzip.git /tmp/libfragmentzip \
    && cd /tmp/libfragmentzip \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && rm -rf /tmp/libfragmentzip

# Compile and install libimobiledevice-glue (dependency for libirecovery)
RUN git clone https://github.com/libimobiledevice/libimobiledevice-glue.git /tmp/libimobiledevice-glue \
    && cd /tmp/libimobiledevice-glue \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && rm -rf /tmp/libimobiledevice-glue

# Compile and install libirecovery (dependency for tsschecker)
RUN git clone https://github.com/libimobiledevice/libirecovery.git /tmp/libirecovery \
    && cd /tmp/libirecovery \
    && ./autogen.sh \
    && ./configure \
    && make \
    && make install \
    && rm -rf /tmp/libirecovery

# Compile and install tsschecker from source with submodules, patching TSSException.cpp
RUN git clone --recurse-submodules https://github.com/tihmstar/tsschecker.git /tmp/tsschecker \
    && cd /tmp/tsschecker \
    && sed -i 's/: TSSException(commit_count_str,commit_sha_str,line,filename, "Key '\''%s'\'' missing in dict. %s",keyname,err), _keyname(keyname ? keyname : "")/: TSSException(commit_count_str,commit_sha_str,line,filename, "Key missing in dict."), _keyname(keyname ? keyname : "")/' tsschecker/TSSException.cpp \
    && ./autogen.sh \
    && ./configure \
    && make \
    && mv tsschecker /usr/local/bin/ \
    && rm -rf /tmp/tsschecker \
    && chmod +x /usr/local/bin/tsschecker

# Install img4tool from release 212
RUN wget -O /tmp/buildroot_ubuntu-latest.zip https://github.com/tihmstar/img4tool/releases/download/212/buildroot_ubuntu-latest.zip \
    && unzip /tmp/buildroot_ubuntu-latest.zip -d /tmp/img4tool \
    && find /tmp/img4tool -type f -name "img4tool" -exec mv {} /usr/local/bin/img4tool \; \
    && chmod +x /usr/local/bin/img4tool \
    && rm -rf /tmp/buildroot_ubuntu-latest.zip /tmp/img4tool

# Install Nginx with fancyindex module
RUN wget http://nginx.org/download/nginx-1.22.1.tar.gz \
    && tar -xzvf nginx-1.22.1.tar.gz \
    && git clone https://github.com/aperezdc/ngx-fancyindex.git \
    && cd nginx-1.22.1 \
    && ./configure --with-http_stub_status_module --add-module=../ngx-fancyindex \
    && make && make install \
    && cd .. && rm -rf nginx-1.22.1.tar.gz nginx-1.22.1 ngx-fancyindex

# Set working directory
WORKDIR /var/www

# Clone the TSSSaver repository
RUN git clone https://github.com/TSSSaver/TSSSaver.git tssaver

# Install Composer dependencies
WORKDIR /var/www/tssaver
RUN composer install --no-dev --optimize-autoloader || true

# Copy custom config.php
COPY inc/config.php /var/www/tssaver/inc/config.php

# Copy Nginx configuration
COPY nginx.conf /usr/local/nginx/conf/nginx.conf
# RUN ln -sf /etc/nginx/sites-available/default /etc/nginx/sites-enabled/default

# Ensure shsh directory exists and is writable
RUN mkdir -p /var/www/tssaver/shsh && chmod 777 /var/www/tssaver/shsh

# Expose port
EXPOSE 80

# Start PHP-FPM and Nginx with full path
CMD /usr/local/sbin/php-fpm -F & /usr/local/nginx/sbin/nginx -g "daemon off;"