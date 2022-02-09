.PHONY: build-env build install uninstall clean

DESTDIR = /usr/local
bindir = /bin
mkinstalldirs = mkdir -p
INSTALL = install
UNINSTALL = \rm

build:
	docker build \
		--build-arg USER=${USER} \
		--build-arg GROUP=${USER} \
		--build-arg UID=$(shell id -u ${USER}) \
		--build-arg GID=$(shell id -g ${USER}) \
		-t fwbackups-docker .

build-env:
	apt install docker-ce-cli autotools-dev

install:
	$(mkinstalldirs) $(DESTDIR)$(bindir)
	$(INSTALL) -m 755 bin/fwbackups $(DESTDIR)$(bindir)/fwbackups
	$(INSTALL) -m 755 bin/fwbackups-run $(DESTDIR)$(bindir)/fwbackups-run
	$(INSTALL) -m 755 bin/fwbackups-runonce $(DESTDIR)$(bindir)/fwbackups-runonce
	$(mkinstalldirs) $(DESTDIR)/share/applications
	container_id=$(shell docker create fwbackups-docker) && \
		docker cp -a $${container_id}:/usr/local/share/applications/fwbackups.desktop ${DESTDIR}/share/applications/fwbackups.desktop && \
		docker cp -a $${container_id}:/usr/local/share/fwbackups ${DESTDIR}/share/fwbackups && \
		docker rm -v $${container_id} && \
		$(mkinstalldirs) $(DESTDIR)/share/pixmaps && \
		ln -s $(DESTDIR)/share/fwbackups/fwbackups.png $(DESTDIR)/share/pixmaps/

uninstall:
	$(UNINSTALL) $(DESTDIR)$(bindir)/fwbackups*
	$(UNINSTALL) $(DESTDIR)/share/applications/fwbackups.desktop
	$(UNINSTALL) -r $(DESTDIR)/share/fwbackups
	$(UNINSTALL) $(DESTDIR)/share/pixmaps/fwbackups.png
	$(UNINSTALL) -f /home/$(SUDO_USER)/.config/autostart/fwbackups-autostart.desktop

clean:
	docker image rm docker-fwbackups
