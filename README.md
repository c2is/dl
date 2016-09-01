# dl
Web application which permit to download files by shortened url.
It automatically zip folders.

The main feature come from the file named mapping.txt based on that format:  
[4 letters] [space] [filename]  
Example:  
```txt
abcd somefile.txt
bcde otherfile.jpg
```
Call in your browser http://dl.mydomain/abcd
And the file somefile.txt will be downloaded

# VHOST
Options -Indexes FollowSymLinks MultiViews
AllowOverride All
Order allow,deny
Allow from All

Authtype Basic
AuthName "Zone privée"
AuthUserFile /some/path/.htpasswd
Require valid-user

RewriteEngine On
RewriteRule ^.*$ index.php [L]
# SCRIPT CALLED BY INCRON

# AUTOMATION
The file download-area-listener.sh show you how to automate : 
- mapping.txt file filling
- email alert sending
