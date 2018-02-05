# letsencrypt-automation


This project was created to help support automating lets encrypt certificate automation.

The run.sh script runs the renewal process over http and as a standalone service. This 
gets proxied through haproxy acl rules directly to the letsencrypt system (vm/docker)
So that any port 80 traffic set on any IP (resolving external DNS) can find it way back
for the challenge and validate the certificate generation.


-----------
This script supports


Apache/Nginx


Haproxy


Webmin


PFSense


* PfSense has an attached sed template file for replacing the existing letsencrypt certificate files.
You must have the certificate uploaded and configed to a name prior to use. Then you modify that file to regex your 
named "Certificate" in pfsense and this will update and force a reload of the webui.
Put that file (pattern.template) in the same directory as this run.sh.

Modify for your use!

I've been doing this for a couple years now.



-----------


This script relies on ssh passwordless logins (as root). A quick google will show you how 
to generate keys and use ssh-copy-id. Pfsense on the other hand requires additional 
configuration with the admin user for persistant upgrades otherwise these keys are lost 
and need to be manually added. This is done by appending the key inside the admin users 
configuration.


Login to your Webui, 

System > User Management > Admin

Paste Key inside "Authorized SSH Keys" textbox and save
