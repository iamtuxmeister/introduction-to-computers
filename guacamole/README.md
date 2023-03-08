## Apache Guacamole and XRDP for connecting to a Linux developemnt Environment


First acknowledgements, I straight ripped off [this guy](https://adamtheautomator.com/apache-guacamole/)'s tutorial for the most part.
Without it I probably would not have been able to complete this in the time I did.
I have created this repo to help others, and to inshrine his excellent work.
Thanks Adam.

Let's get to work

This is going to be built on Debian 11 (Stable). These commands should work on
Ubuntu LTS 22.04

Commands that can be copied and pasted will be displayed as
```
code block
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

Some system libraries are added and need to have their linuser updated and guacd
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
wget https://dlcdn.apache.org/guacamole/1.5.0/binary/guacamole-1.5.0.war
mv guacamole-1.5.0.war guacamole.war
cp guacamole.war /var/lib/tomcat9/webapps
```

We will be utilizing Let's Encrypt for the ssl certificate for Apache2.
This is optional, but you should supply an ssl certificate, an will need to adjust
the apache configs to reflect your certificate location. The following commands
will install certbot and create the cert, please follow the prompts to create the cert.
```
apt install certbot python3-certbot-apache
certbot certonly --apache
```

Test to make sure that the certificate renewall process will succeed by running
this command.
```
certbot renew --dry-run
```

Apache2 is next to be configured, lets enable the modules that will be necessary
```
a2enmod proxy proxy_wstunnel proxy_http ssl rewrite
```
Copy and paste this config into the new file `/etc/apache2/sites-available/guacamole.conf`
Be sure to replace example.io with your fqdn.

```
editor /etc/apache2/sites-available/guacamole.conf
```

```
<VirtualHost *:80>
    ServerName example.io
    ServerAlias www.example.io
    DocumentRoot /var/www/html

    Redirect permanent / https://example.io/
</VirtualHost>

<VirtualHost *:443>
    ServerName example.io
    ServerAlias www.example.io
    DocumentRoot /var/www/html

    <If "%{HTTP_HOST} == 'www.example.io'">
    Redirect permanent / https://example.io/
    </If>

    ErrorLog /var/log/apache2/example.io-error.log
    CustomLog /var/log/apache2/example.io-access.log combined

    SSLEngine On
    SSLCertificateFile /etc/letsencrypt/live/example.io/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/example.io/privkey.pem

    <Location /guacamole/>
        Order allow,deny
        Allow from all
        ProxyPass http://127.0.0.1:8080/guacamole/ flushpackets=on
        ProxyPassReverse http://127.0.0.1:8080/guacamole/
    </Location>

    <Location /guacamole/websocket-tunnel>
        Order allow,deny
        Allow from all
        ProxyPass ws://127.0.0.1:8080/guacamole/websocket-tunnel
        ProxyPassReverse ws://127.0.0.1:8080/guacamole/websocket-tunnel
    </Location>

</VirtualHost>
```
Now enable the guacamole apache config file, and restart apache.
```
a2ensite guacamole.conf
systemctl restart apache2
```

We need to get apache tomcat to be able to see the real ip of the client to make
guacamole work correctly. Edit the `/etc/tomcat9/server.xml` file and add this
code block after the `<Host ...>` tag

```
editor /etc/tomcat9/server.xml
```
```
<Valve className="org.apache.catalina.valves.RemoteIpValve"
            internalProxies="127.0.0.1"
            remoteIpHeader="x-forwarded-for"
            remoteIpProxiesHeader="x-forwarded-by"
            protocolHeader="x-forwarded-proto" />
```
Now we need to configure the Guacamole application to allow our connections
and setup users/resources

Make the following changes to the configuration files for guacamole

```
editor /etc/guacamole/guacd.conf
```
```
[server]
bind_host = 0.0.0.0
bind_port = 4822
```
```
editor /etc/guacamole/guacamole.properties
```
```
guacd-hostname: localhost
guacd-port: 4822
```
That will get Guacamole talking to apache and allowing the connections,

Now create this file and setup the users for access
```
editor /etc/guacamole/user-mapping.xml
```
```
<user-mapping>
    <!-- Create a User, repeat this stanza per user -->
    <authorize
            username="user"
            password="password">

        <!-- First authorized connection -->
        <connection name="rdp">
            <protocol>rdp</protocol>
            <param name="hostname">localhost</param>
            <param name="port">3389</param>
	    <param name="username">user</param>
            <param name="password">password</param>
        </connection>

        <!-- Second authorized connection -->
        <connection name="ssh">
            <protocol>ssh</protocol>
            <param name="hostname">localhost</param>
            <param name="port">22</param>
	    <param name="username">user</param>
            <param name="password">password</param>
        </connection>

    </authorize>
    <!-- End User -->
</user-mapping>
```
This you can remove the username and password paramaers from the connection
stanzas to have the system request authentication.
these user/password combos need to match the system user used to connect to the
rdp and ssh respectively.

There are tons more configuration options and connections that can be used,
please see the [Apache Guacamole Documentation](https://guacamole.apache.org/doc/gug/) for more configuration options
and a complete description of what we are doing here.

## Wrapping up

Last thing should be to restart all the services to take the new configurations
and you should have working rdp/ssh in a webpage.

```
systemctl restart xrdp
systemctl restart apache2
systemctl restart tomcat9
systemctl restart guacd
```


