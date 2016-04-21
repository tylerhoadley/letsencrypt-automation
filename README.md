# letsencrypt-automation

This project was created to help support automating lets encrypt certificate automation.

The run.sh script runs the renewal process over http and as a standalone service. This 
gets proxied through haproxy acl rules directly to the letsencrypt system (vm/docker)
So that any port 80 traffic set on any IP (resolving external DNS) can find it way back
for the challenge and validate the certificate generation.

The script supports

Apache
Haproxy
Webmin
PFSense

PfSense has a sed script file template for replace the existing letsencrypt certificate.
Put that file in the same directory as the run.sh and modified the variable parameters.


This script rely on ssh passwordless logins (as root). A quick google will show you how 
to generate keys and use ssh-copy-id.
