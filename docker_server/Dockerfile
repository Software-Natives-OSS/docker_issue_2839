FROM alpine:latest
MAINTAINER b3vis
#Install Borg & SSH
RUN apk upgrade --no-cache \
    && apk add --no-cache \
    openssh sshfs borgbackup supervisor \
    alpine-sdk \
    tzdata \
    sshfs \
    python3 \
    python3-dev \
    openssl-dev \
    lz4-dev \
    acl-dev \
    linux-headers && \
    pip3 install --upgrade pip \
    && pip3 install --upgrade borgbackup \
    && rm -rf /var/cache/apk/*
RUN adduser -D -u 1000 borg && \
    ssh-keygen -A && \
    mkdir /backups && \
    chown borg.borg /backups && \
    sed -i \
        -e 's/^#PasswordAuthentication yes$/PasswordAuthentication no/g' \
        -e 's/^PermitRootLogin without-password$/PermitRootLogin no/g' \
        /etc/ssh/sshd_config
COPY supervisord.conf /etc/supervisord.conf
COPY entry.sh /entry.sh
RUN chmod 755 /entry.sh
VOLUME /root/.ssh
RUN passwd -u borg
EXPOSE 22
CMD ["/entry.sh"]
