# dl
Make a file named mapping.txt base on that format:  
<4 alphanum chars> <space> <filename>  
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
