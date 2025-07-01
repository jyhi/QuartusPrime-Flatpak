# SPDX-FileCopyrightText: 2024-2025 Junde Yhi <junde@yhi.moe>
# SPDX-License-Identifier: CC0-1.0

PKGNAME  = com.intel.quartusprime.lite.questa.starter
REQFILES = QuestaSetup-24.1std.0.1077-linux.run

SHELL   = /bin/sh
FLATPAK = flatpak

FLATPAKINSTALLFLAGS   = --user --reinstall --noninteractive
FLATPAKUNINSTALLFLAGS = --user --noninteractive

STATEDIR ?= .flatpak-builder
BUILDDIR ?= .build
REPODIR  ?= .repo

SRCFILES = $(PKGNAME).metainfo.xml $(PKGNAME).yml $(REQFILES)

.SUFFIXES:
.PHONY: all bundle install uninstall clean distclean check check-metadata check-manifest check-builddir check-repo

all: $(BUILDDIR)
repo: $(REPODIR)
bundle: $(PKGNAME).flatpak
install: $(REPODIR)
	$(FLATPAK) install $(FLATPAKINSTALLFLAGS) --sideload-repo=$< $< $(PKGNAME)

uninstall:
	$(FLATPAK) uninstall $(FLATPAKUNINSTALLFLAGS) $(PKGNAME)

clean:
	$(RM) -r $(BUILDDIR) $(REPODIR) $(PKGNAME).flatpak

distclean: clean
	$(RM) -r $(STATEDIR)

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
	$(FLATPAK) run org.flatpak.Builder --sandbox --state-dir=$(STATEDIR) --force-clean $@ $(PKGNAME).yml

$(REPODIR): $(BUILDDIR)
	$(FLATPAK) run org.flatpak.Builder --sandbox --state-dir=$(STATEDIR) --repo=$@ --export-only $< $(PKGNAME).yml

$(PKGNAME).flatpak: $(REPODIR)
	$(FLATPAK) build-bundle $< $@ $(PKGNAME)
