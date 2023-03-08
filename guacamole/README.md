## Apache Guacamole and XRDP for connecting to a Linux developemnt Environment


This is going to be built on Debian 11 (Stable). These commands should work on
Ubuntu LTS 22.04

Commands that can be copied and pasted will be displayed as
```
code blocks
```
Please follow along, and read command output, and solve issues. Feel free to
submit pull requests to help me correct the guide.

## Preparation:

I assume you have a base install of Debian 11, with ssh. nothing else is
required.

SSH to the server, su to root and lets begin:

Always good practice before beginning an install is to verify the repositories
and update the system.
```
editor /etc/apt/sources.list
```
should look something like this:
```
deb http://deb.debian.org/debian/ bullseye main contrib non-free
deb-src http://deb.debian.org/debian/ bullseye main contrib non-free

deb http://security.debian.org/debian-security bullseye-security main contrib non-free
deb-src http://security.debian.org/debian-security bullseye-security main contrib non-free

deb http://deb.debian.org/debian/ bullseye-updates main contrib non-free
deb-src http://deb.debian.org/debian/ bullseye-updates main contrib non-free
```
If your file has some lines that begin with # those are comments and will be
ignored by the apt system

Make sure to add the `contrib non-free` to gain access to the necessary
packages.

```
apt update && apt upgrade -y
```
This should get us a freshly updated system to begin.

## Dependancies

This should install all the dependancies to have a basic cinnamon desktop
accessable over guacamole+rdp when we finish building/configuring the applications.

```
apt install tomcat9 apache2 xrdp cinnamon chromium build-essential libcairo2-dev libjpeg62-turbo-dev libpng-dev libtool-bin uuid-dev libossp-uuid-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev freerdp2-dev libpango1.0-dev libssh2-1-dev libtelnet-dev libvncserver-dev libwebsockets-dev libpulse-dev libssl-dev libvorbis-dev libwebp-dev -y
```

## Application Install

Apache Guacamole runs on Apache Tomcat, it was installed in the previous command.
Tomcat does not get enabled by default. Execute this command to enable and start
Apache Tomcat9.

```
systemctl enable --now Tomcat9
```

At the time of this writing the latest version of guacamole is 1.5, this will
download the source. You can do the build from anywhere, I like to use the
`/opt/` directory for that as it is the current "standard".

```
cd /opt
wget https://dlcdn.apache.org/guacamole/1.5.0/source/guacamole-server-1.5.0.tar.gz
```
Now we need to extract the source code and begin the build process.

```
tar -zxf guacamole-server-1.5.0.tar.gz
cd guacamole-server-1.5.0/
```
Configure the application setting the system directory and track dependancies.
```
./configure --with-systemd-dir=/etc/systemd/system/ --disable-dependency-tracking
```
Because we are not building on Windows you can ignore the single missing library wsock32.
If any other libraries are missing in the dependancy check please resolve them,
and submit an issue so I can correct the dependancies.
```
make
```
Check for errors. This should complete without issues. Any hard stops
should be corrected, and issues submitted so I can update the guide.
```
make install
```
This will produce a couple warnings about relinking, but should install and be
functional.

Some system libraries are added and need to have their links updated and guacd
was added to systemd. systemd needs to be reloaded after the libraries are synced.

```
ldconfig
systemctl daemon-reload
```
Now we tell systemd to automatically start guacd on reboots, and start it now.
```
systemctl enable --now guacd
```

## Configuration, and Integration

Tomcat is designed to be application agnostic. It really doesn't care what
java application it serves. Four our application we need to tell it where to find
Guacamole.
```
echo GUACAMOLE_HOME=/etc/guacamole >> /etc/default/tomcat9
```

Create the Applcation directories and setup config files for Guacamole.
```
mkdir -p /etc/guacamole/{extensions,lib}
touch /etc/guacamole/{guacamole.properties,guacd.conf}
```

Now we get the Guacamole client, also served by Tomcat,
We will set this up to be served by apache2 using local proxy

```
cd /opt
wget https://dlcdn.apache.org/guacamole/1.5.0/binary/guacamole-1.5.0.war -o /var/lib/tomcat9/webapps/guacamole.war
```
