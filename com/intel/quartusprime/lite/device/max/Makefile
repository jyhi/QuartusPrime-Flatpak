# SPDX-FileCopyrightText: 2024 Junde Yhi <junde@yhi.moe>
# SPDX-License-Identifier: CC0-1.0

PKGNAME  = com.intel.quartusprime.lite.device.max
REQFILES = max-23.1std.1.993.qdz

SHELL   = /bin/sh
FLATPAK = flatpak

FLATPAKFLAGS = --user

srcdir   ?= .
STATEDIR ?= ./.flatpak-builder
BUILDDIR ?= ./build
REPODIR  ?= ./repo

SRCFILES = $(srcdir)/$(PKGNAME).metainfo.xml $(srcdir)/$(PKGNAME).yml $(srcdir)/$(REQFILES)

.SUFFIXES:
.PHONY: all install uninstall clean distclean dist check check-metadata check-manifest check-builddir check-repo

all: $(BUILDDIR)
install: $(REPODIR)
	$(FLATPAK) $(FLATPAKFLAGS) install --sideload-repo=$(REPODIR) $(REPODIR) $(PKGNAME)

uninstall:
	$(FLATPAK) $(FLATPAKFLAGS) uninstall $(PKGNAME)

clean:
	rm -fr $(BUILDDIR) $(REPODIR)

distclean: clean
	rm -fr $(STATEDIR)

dist: $(REPODIR)
check: check-metadata check-manifest check-builddir check-repo
check-metadata: $(PKGNAME).metainfo.xml
	-$(FLATPAK) run --command=flatpak-builder-lint org.flatpak.Builder appstream $<

check-manifest: $(PKGNAME).yml
	-$(FLATPAK) run --command=flatpak-builder-lint org.flatpak.Builder manifest $<

check-builddir: $(BUILDDIR)
	-$(FLATPAK) run --command=flatpak-builder-lint org.flatpak.Builder builddir $<

check-repo: $(REPODIR)
	-$(FLATPAK) run --command=flatpak-builder-lint org.flatpak.Builder repo $<

$(BUILDDIR): $(SRCFILES)
	$(FLATPAK) $(FLATPAKFLAGS) run org.flatpak.Builder --sandbox --state-dir=$(STATEDIR) --force-clean $(BUILDDIR) $(PKGNAME).yml

$(REPODIR): $(BUILDDIR)
	$(FLATPAK) $(FLATPAKFLAGS) run org.flatpak.Builder --sandbox --state-dir=$(STATEDIR) --repo=$(REPODIR) --export-only $(BUILDDIR) $(PKGNAME).yml
