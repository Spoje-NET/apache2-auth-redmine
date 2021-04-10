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


Tested on Debian 9 & 10

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
<Directory "/var/www/html/usersonly">
        AuthType Basic
        AuthName "Only for Redmine Users" 
        AuthBasicProvider external
        AuthExternal redmineuser
        Require valid-user
</Directory>

```

Group membership based auth
---------------------------

```apache
<Directory "/var/www/html/adminsonly">
        AuthType Basic
        AuthName "Only for Redmine Admins" 
        AuthBasicProvider external
        AuthExternal redmineuser
        GroupExternal redminegroup
        Require external-group admins
</Directory>
```

**Please look into [Vagrantfile](Vagrantfile) for details how to install on real system.**

Testing
-------

We provide example [Vagrant](https://www.vagrantup.com/).with whole setup in the box.

In this cloned repository simply run 

```shell
vagrant up
```

And wait to things be done.
After image download, package installation and additional provisioning web iside virtual machine become reachable at

[http://localhost:8090](http://localhost:8090)

Then you can try to open Apache's locations only for redmine users and group members

[For Users](http://localhost:8090/user/)
[Only for Admins](http://localhost:8090/admin/)

Testing users:


  | login	| password	| member of group |
  |-------------|---------------|-----------------
  | admin	| Cli@queel3	|
  | john	| dydCag9knag	| admin
  | doe		| steevCor2ov	| users

Auth tool read login and password from stdin in simple format

```
login
password

```

So You can test basic functionality from commandline:

```shell
echo -e "admin\nCli@queel3\n" | /usr/lib/apache2/redmine-mysql-auth.pl 
```

Gives you error message to stderr:

```
[Sat Apr 10 17:59:56 2021] /usr/lib/apache2/redmine-mysql-auth.pl: invalid characters used in login/password - Rejected
```

The credentials was rejected cause the '@' character in admin's password. Then script ends with **1** code as you can check using "$?" macro:

```shell
echo $?
1
```

Successfull attempt ends with zero return code.




See Also:
---------

 * https://github.com/haegar/mod-auth-external/blob/master/mod_authnz_external/INSTALL
 * http://anders.fix.no/software/#unix
 * https://spojenet.cz/

![Apache](apache.svg?raw=true)
![Redmin](redmine.svg?raw=true)

![Spoje.Net](logo-spojenet.png?raw=true)
