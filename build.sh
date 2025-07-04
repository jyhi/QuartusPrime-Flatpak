#!/bin/sh

# Script for building all com.intel.quartusprime Flatpak packages.
#
# An external package definition file is required to work. It contains external
# dependency information. The script will make a symbolic link before building
# the package. It should look like the following:
#
#     tld.package.name:source1,source2,source3
#
# SPDX-FileCopyrightText: 2025 Junde Yhi <junde@yhi.moe>
# SPDX-License-Identifier: CC0-1.0

set -e

# posixly-correct echo alternative
println()
{
    printf '%s\n' "$*"
}

# print the first field of all function arguments separated by colon
get_pkg_name()
{
    printf '%s' "$*" | cut -f 1 -d ':' -s
}

# print the second field of all function arguments separated by colon,
# then split by comma, producing a list
get_pkg_reqs()
{
    printf '%s' "$*" | cut -f 2 -d ':' -s | sed -e 's/,/ /g' | xargs
}

# print pkg name, then replace dots with slashes, forming a path
get_pkg_dir()
{
    printf '%s' "$*" | cut -f 1 -d ':' -s | sed -e 's,\.,/,g'
}

# match and negative-match supplied regular expressions against function
# arguments
match_pkg_name()
(
    if test -n "${PKGMAT}"
    then
        STRMAT="$(printf '%s' $* | grep -E ${PKGMAT})"
    fi

    if test -n "${PKGNMT}"
    then
        STRNMT="$(printf '%s' $* | grep -E ${PKGNMT})"
    fi

    ( test -z "${PKGMAT}" || test -n "${STRMAT}" ) && \
    ( test -z "${PKGNMT}" || test -z "${STRNMT}" )
)

# read file containing all package information
read_pkginfo()
{
    if test -n "${PKGINFO_READ}"
    then
        return 0
    fi

    PKGINFO_READ=1

    if test -z "${PKGFIL}"
    then
        println 'Use option -f to specify a package definition file (or -f -' \
                'for stdin)'
        return 1
    fi

    PKGINFO="$(cat ${PKGFIL})"

    if test -z "${PKGINFO}"
    then
        println 'Nothing to do - make sure the package description file is' \
                'valid!'
        return 2
    fi
}

help()
{
    println "\
Usage: $(basename ${0}) [OPTION...] ACTION [ACTION...]

OPTION:

    -f FILE   Specify package description file (omit or -f - for stdin)
    -m REGEX  Select only packages matching the given regular expression
    -M REGEX  Like -m but negate matches
    -s DIR    Specify path where downloaded files are found

ACTION:

    -b        Build all
    -c        Clean all
    -h        Display this help message and exit
    -l        List all
"
}

build()
{
    for PKG in ${PKGINFO}
    do
    (
        PKGNAME="$(get_pkg_name ${PKG})"
        PKGREQS="$(get_pkg_reqs ${PKG})"
        PKGDIR="$(get_pkg_dir ${PKG})"

        if ! match_pkg_name "${PKGNAME}"
        then
            continue
        fi

        println "* Building ${PKGNAME}..."
        cd "${PKGDIR}"

        for REQ in ${PKGREQS}
        do
            rm -frv "${REQ}"
            ln -sv "${SRCDIA}/${REQ}"

        done

        make bundle
    )
    done
}

clean()
{
    for PKG in ${PKGINFO}
    do
    (
        PKGNAME="$(get_pkg_name ${PKG})"
        PKGREQS="$(get_pkg_reqs ${PKG})"
        PKGDIR="$(get_pkg_dir ${PKG})"

        if ! match_pkg_name "${PKGNAME}"
        then
            continue
        fi

        println "* Cleaning ${PKGNAME}..."
        cd "${PKGDIR}"

        make distclean
        for REQ in ${PKGREQS}
        do
            rm -frv "${REQ}"
        done
    )
    done
}

list()
{
    for PKG in ${PKGINFO}
    do
    (
        PKGNAME="$(get_pkg_name ${PKG})"
        PKGREQS="$(get_pkg_reqs ${PKG})"

        if ! match_pkg_name "${PKGNAME}"
        then
            continue
        fi

        println "Package: ${PKGNAME}"
        println 'Requires:'

        for REQ in ${PKGREQS}
        do
            if test -f "${SRCDIA}/${REQ}"
            then
                EXIST='exists'
            else
                EXIST='missing'
            fi

            println "* ${REQ} (${EXIST})"
        done

        println
    )
    done
}

while getopts 'bcf:hlm:M:s:' OPT
do
    case "${OPT}" in
        ('b') ACTOPT="${ACTOPT},${OPT}" ;;
        ('c') ACTOPT="${ACTOPT},${OPT}" ;;
        ('f') PKGFIL="${OPTARG}" ;;
        ('h') ACTOPT="${ACTOPT},${OPT}" ;;
        ('l') ACTOPT="${ACTOPT},${OPT}" ;;
        ('m') PKGMAT="${OPTARG}" ;;
        ('M') PKGNMT="${OPTARG}" ;;
        ('s') SRCDIR="${OPTARG}" ;;
    esac
done

# if srcdir is not an absolute path, prepend present working directory
SRCDIA="$(printf '%s' ${SRCDIR} | sed -e 's,^[^/],'${PWD}'/&,')"

# split action arguments into lists
ACTLST="$(printf '%s' ${ACTOPT} | sed -e 's/,/ /g' | xargs)"

if test -z "${ACTLST}"
then
    help
    exit 0
fi

for ACT in ${ACTLST}
do
    case "${ACT}" in
        ('h') help; exit 0;;
        ('l') read_pkginfo && list ;;
        ('b') read_pkginfo && build ;;
        ('c') read_pkginfo && clean ;;
        (*) help; exit 1;;
    esac
done
