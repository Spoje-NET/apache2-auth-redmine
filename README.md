![apache_auth_redmine](apache_auth_redmine.svg?raw=true)

Authenticate Apache Users using Redmine's database
==================================================

authentificators read its configuration from default redmine's db config **/etc/redmine/default/database.yml**


Based on original script by Anders Nordby <anders@fix.no>


Installation:
-------------

```shell
sudo apt install lsb-release wget
echo "deb http://repo.vitexsoftware.cz $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/vitexsoftware.list
sudo wget -O /etc/apt/trusted.gpg.d/vitexsoftware.gpg http://repo.vitexsoftware.cz/keyring.gpg
sudo apt update
sudo apt install apache2-auth-redmine
```


Configuration
-------------

The package provide enabled /etc/apache2/confs-availble/auth_redmine.conf with default external Auth definitions

```apache
DefineExternalAuth  redmineuser pipe /usr/lib/apache2/redmine-mysql-auth.pl
DefineExternalGroup redminegroup pipe /usr/lib/apache2/redmine-group-mysql-auth.pl
```

The following examples use it:

Simple known user auth
----------------------

```apache
<Directory "/var/www/html/protected">
        AuthType Basic
        AuthName "Only for Redmine Users" 
        AuthBasicProvider external
        AuthExternal redmine
        Require valid-user
</Directory>

```

Group membership based auth
---------------------------

```apache
<Directory "/var/www/html/protected">
        AuthType Basic
        AuthName "Only for Redmine Users" 
        AuthBasicProvider external
        AuthExternal redmineuser
        GroupExternal redminegroup
        Require external-group admins
</Directory>
```

Testing
-------

Testing users:


  | login	| password	| member of group |
  |-------------|---------------|-----------------
  | admin	| Cli@queel3	|
  | john	| dydCag9knag	| admins
  | doe		| steevCor2ov	| users



See Also: 

 * https://github.com/haegar/mod-auth-external/blob/master/mod_authnz_external/INSTALL
 * http://anders.fix.no/software/#unix


![Apache](apache.svg?raw=true)
![Redmin](redmine.svg?raw=true)
