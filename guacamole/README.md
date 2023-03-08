## Apache Guacamole and XRDP for connecting to a Linux developemnt Environment


This is going to be built on Debian 11 (Stable). These commands should work on
Ubuntu LTS 22.04

Commands that can be copied and pasted will be displayed as
```code blocks
```
Please follow along, and read command output, and solve issues. Feel free to
submit pull requests to help me correct the guide.

## Preparation:

I assume you have a base install of Debian 11, with ssh. nothing else is
required.


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

Make sure to add the