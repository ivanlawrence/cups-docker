#!/bin/bash -ex

# install the drivers for the printer
/usr/bin/wget -T 10 -nd --no-cache https://download.brother.com/pub/com/linux/linux/packages/hl3180cdwlpr-1.1.3-0.i386.deb
/usr/bin/wget -T 10 -nd --no-cache https://download.brother.com/pub/com/linux/linux/packages/hl3180cdwcupswrapper-1.1.4-0.i386.deb
/usr/bin/dpkg -i --force-all hl3180cdwlpr-1.1.3-0a.i386.deb
/usr/bin/dpkg -i --force-all hl3180cdwcupswrapper-1.1.4-0a.i386.deb

if [ $(grep -ci $CUPSADMIN /etc/shadow) -eq 0 ]; then
    useradd -r -G lpadmin -M $CUPSADMIN

    # add password
    echo $CUPSADMIN:$CUPSPASSWORD | chpasswd

    # add tzdata
    ln -fs /usr/share/zoneinfo/$TZ /etc/localtime
    dpkg-reconfigure --frontend noninteractive tzdata
fi

# restore default cups config in case user does not have any
if [ ! -f /etc/cups/cupsd.conf ]; then
    cp -rpn /etc/cups-bak/* /etc/cups/
fi

exec /usr/sbin/cupsd -f
