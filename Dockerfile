FROM debian:stable-slim

# ENV variables
ENV DEBIAN_FRONTEND noninteractive
ENV TZ "America/Los_Angeles"
ENV CUPSADMIN admin
ENV CUPSPASSWORD password


LABEL org.opencontainers.image.source="https://github.com/anujdatar/cups-docker"
LABEL org.opencontainers.image.description="CUPS Printer Server"
LABEL org.opencontainers.image.author="Anuj Datar <anuj.datar@gmail.com>"
LABEL org.opencontainers.image.url="https://github.com/anujdatar/cups-docker/blob/main/README.md"
LABEL org.opencontainers.image.licenses=MIT


# Install dependencies
RUN apt-get update -qq  && apt-get upgrade -qqy \
    && apt-get install -qqy \
    apt-utils \
    usbutils \
    cups \
    cups-filters \
    printer-driver-all \
    printer-driver-cups-pdf \
    printer-driver-foo2zjs \
    foomatic-db-compressed-ppds \
    openprinting-ppds \
    hpijs-ppds \
    hp-ppd \
    hplip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
RUN wget -T 10 -nd --no-cache https://download.brother.com/pub/com/linux/linux/packages/hl3180cdwlpr-1.1.3-0.i386.deb
RUN wget -T 10 -nd --no-cache https://download.brother.com/pub/com/linux/linux/packages/hl3180cdwcupswrapper-1.1.4-0.i386.deb
RUN dpkg -i --force-all hl3180cdwlpr-1.1.3-0a.i386.deb
RUN dpkg -i --force-all hl3180cdwcupswrapper-1.1.4-0a.i386.deb

EXPOSE 631

# Baked-in config file changes
RUN sed -i 's/Listen localhost:631/Listen 0.0.0.0:631/' /etc/cups/cupsd.conf && \
    sed -i 's/Browsing Off/Browsing On/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/>/<Location \/>\n  Allow All/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin>/<Location \/admin>\n  Allow All\n  Require user @SYSTEM/' /etc/cups/cupsd.conf && \
    sed -i 's/<Location \/admin\/conf>/<Location \/admin\/conf>\n  Allow All/' /etc/cups/cupsd.conf && \
    echo "ServerAlias *" >> /etc/cups/cupsd.conf && \
    echo "DefaultEncryption Never" >> /etc/cups/cupsd.conf

# back up cups configs in case used does not add their own
RUN cp -rp /etc/cups /etc/cups-bak
VOLUME [ "/etc/cups" ]

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
