repoversion=$(shell LANG=C aptitude show apache2-auth-redmine | grep Version: | awk '{print $$2}')
currentversion=$(shell dpkg-parsechangelog --show-field Version)
nextversion=$(shell echo $(repoversion) | perl -ne 'chomp; print join(".", splice(@{[split/\./,$$_]}, 0, -1), map {++$$_} pop @{[split/\./,$$_]}), "\n";')

all:
	

deb:
	debuild -i -us -uc -b


dimage:
	docker build -t vitexsoftware/multi-abraflexi-setup .

drun: dimage
	docker run  -dit --name MultiAbraFlexiSetup -p 8080:80 vitexsoftware/multi-abraflexi-setup
	firefox http://localhost:8080/multi-abraflexi-setup?login=demo\&password=demo

vagrant: deb
	vagrant destroy -f
	mkdir -p deb
	debuild -us -uc
	mv ../apache2-auth-redmine_$(currentversion)_all.deb deb
	cd deb ; dpkg-scanpackages . /dev/null | gzip -9c > Packages.gz; cd ..
	vagrant up
	sensible-browser http://localhost:9080/redmine

release:
	echo Release v$(nextversion)
	dch -v $(nextversion) `git log -1 --pretty=%B | head -n 1`
	debuild -i -us -uc -b
	git commit -a -m "Release v$(nextversion)"
	git tag -a $(nextversion) -m "version $(nextversion)"

