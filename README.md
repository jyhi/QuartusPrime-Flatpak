<!--
    SPDX-FileCopyrightText: 2024-2025 Junde Yhi <junde@yhi.moe>
    SPDX-License-Identifier: CC0-1.0
-->

# Quartus Prime Lite Edition Design Software for Linux (Flatpak)

This folder contains necessary files to re-pack [Quartus Prime Lite Edition](https://www.intel.com/content/www/us/en/products/details/fpga/development-tools/quartus-prime.html) and its components into [Flatpak](https://en.wikipedia.org/wiki/Flatpak) containers/packages.

The current supported version is 24.1 (24.1std.0.1077), released on 17 March 2025. Supports for past versions are placed under different branches of the Git repository:

* `v23.x`: 23.1 (23.1std.0.991), 23.1.1 (23.1std.1.993)

> [!NOTE]
>
> **You must obtain the software installer programs and build the Flatpak(s) by yourself.**
>
> Under [Intel.com Website Terms of Use](https://www.intel.com/content/www/us/en/legal/terms-of-use.html), the building scripts are unable to automatically download the software installers required to build the packages. The built packages are not hosted in any repository either.
>
> See <https://www.intel.com/content/www/us/en/software-kit/849769> for all download options available.

## Known Issues

Some packages are known to be broken at this moment:

* **Questa won't start.**
    * Cause: unknown. Running `vsim` gives the following error: `** Error: mountTrofs script: Invalid TCL archive content`.
    * Mitigation: none.
* **Help topics won't appear if installed.**
    * Cause: unknown.
    * Mitigation: do not install `com.intel.quartusprime.lite.help`. Help topics will be redirected to online contents and opened in the browser instead.

## List of Packages

### Standalone Applications

These packages have their own desktop icons and can be found in the launcher of desktop after installation.

- Quartus Prime (including Nios II EDS): [`com.intel.quartusprime.lite`](./com/intel/quartusprime/lite)
- Quartus Prime Programmer and Tools: [`com.intel.quartusprime.programmer`](./com/intel/quartusprime/programmer)
- Ashling RiscFree IDE for Altera: [`com.intel.quartusprime.riscfree`](./com/intel/quartusprime/riscfree)

### Extensions to Quartus Prime Lite

These packages are automatically loaded if they're installed when Quartus Prime is starting. They can't be launched individually as they don't have their own desktop icon.

- Quartus Prime Help: [`com.intel.quartusprime.lite.help`](./com/intel/quartusprime/lite/help)
- Questa - Altera FPGA and Starter Editions: [`com.intel.quartusprime.lite.questa.starter`](./com/intel/quartusprime/lite/questa/starter)

### Quartus Prime Lite Device Support Packages

These are also extensions to Quartus Prime and are automatically loaded by Flatpak if they're installed when Quartus Prime is starting.

- Arria II device support: [`com.intel.quartusprime.lite.device.arrialite`](./com/intel/quartusprime/lite/device/arrialite)
- Cyclone IV device support: [`com.intel.quartusprime.lite.device.cyclone`](./com/intel/quartusprime/lite/device/cyclone)
- Cyclone 10 LP device support: [`com.intel.quartusprime.lite.device.cyclone10lp`](./com/intel/quartusprime/lite/device/cyclone10lp)
- Cyclone V device support: [`com.intel.quartusprime.lite.device.cyclonev`](./com/intel/quartusprime/lite/device/cyclonev)
- MAX II, MAX V device support: [`com.intel.quartusprime.lite.device.max`](./com/intel/quartusprime/lite/device/max)
- MAX 10 FPGA device support: [`com.intel.quartusprime.lite.device.max10`](./com/intel/quartusprime/lite/device/max10)

## Build &amp; Install

Flatpak must be installed on the computer first. Then, install the Flatpak development toolkit from Flathub:

```sh
flatpak --user install org.flatpak.Builder
```

Package definitions (manifests, metadata, etc.) are placed under paths with hierarchies following their package IDs. For example, `com.intel.quartusprime.lite` is at [com/intel/quartusprime/lite](./com/intel/quartusprime/lite/). Place the corresponding installer / extension pack file under the folder. Enter the folder and run:

```sh
make install
```

This builds and installs the package to the current user.

## Run

To launch Quartus Prime Lite Edition, Quartus Prime Programmer or RiscFree, find and choose their corresponding icons in the application menu under category "Development".

To launch from a terminal emulator instead, run:

```sh
flatpak run com.intel.quartusprime.lite
```

To run a shell inside the container, Quartus Prime Shell (`quartus_sh`) or any other program that comes with it, change the entry point to `/bin/sh`, then source (`.`) `/app/enable.sh` to populate `PATH` and set up the environment. As an example, to run Quartus Prime Shell in one line:

```sh
flatpak run --command=/bin/sh com.intel.quartusprime.lite -c '. /app/enable.sh; quartus_sh'
```

## Permission

All applications have the following permissions preset:

- x86 (32-bit) support (`--allow=multiarch`)
- Access to all devices on the computer (`--device=all`; allows device programming)
- Share IPC namespace (`--share=ipc`; improves X.org performance)
- Display on X.org (`--socket=x11`)
- Display on Wayland (`--socket=wayland`)
- XWayland fallback (`--socket=fallback-x11`)

Quartus Prime Lite Edition has the following additional permissions preset:

- Read-write access to all files under the home directory (`--filesystem=home`)
- Persist `~/.altera.quartus` across application startups (`--persist=.altera.quartus`)

Quartus Prime Programmer (standalone) has the following additional permissions preset:

- Read-only access to all files on the computer (`--filesystem=host:ro`)

RiscFree has the following additional permissions preset:

- Read-write access to all files under the home directory (`--filesystem=home`)

Users are encouraged to review the permissions before launching the applications. To manage application permissions, use command [flatpak-override(1)](https://docs.flatpak.org/en/latest/flatpak-command-reference.html#flatpak-override). For example, to grant Quartus Prime read-write access to all files and devices on the computer, run:

```sh
flatpak override --filesystem=host --device=all com.intel.quartusprime.lite
```

Alternatively, install [Flatseal](https://flathub.org/apps/com.github.tchx84.Flatseal), which has a GUI.

## Software License

> [!NOTE]
>
> Before licensing the software, grant networking permission to Quartus Prime. This is required for Quartus Prime to:
>
> * Obtain the license file automatically (for method 1 below).
> * Read the host machine's MAC address.
> * Register the current computer with the license online.
>
> By default, networking permission is not granted. If the software displays `000000000000` in the "License Setup" dialog, networking permission is not granted. **Do not use this all-zero MAC address; it won't work.** Although you can still obtain a `.dat` file (with either method below), the actual signature will be absent from the file and be replaced with `300 Disallowed hostid and/or server hostid.`

The RTL simulator (Questa - Intel FPGA Starter Edition) that comes with Quartus Prime Lite Edition requires a license, despite that it's free. There are two ways to obtain a license:

1. Click the "Get no-cost licenses" button under menu \[Tools\] \> \[License Setup...\]: [follow steps in this document](https://www.intel.com/content/www/us/en/docs/programmable/683472/25-1/acquiring-free-no-cost-licenses.html#uex1716819435805__section_lz4_4jt_nbc) (Method 2).
2. Obtain a license on Self-Service Licensing Center (SSLC): [follow steps in this document](https://www.intel.com/content/www/us/en/docs/programmable/683472/25-1/and-software-license.html) (Generating the License).

With method 1, the license file is automatically placed at `~/.altera.quartus/license.dat`. With method 2, the file needs to be made visible to the software. To make the license file visible inside container, expose the file (can be at any location), then set environment variable `LM_LICENSE_FILE` with the path to the license file:

```sh
flatpak override --filesystem=/path/to/license.dat:ro \
    --env=LM_LICENSE_FILE=/path/to/license.dat com.intel.quartusprime.lite
```

If the license is automatically obtained with method 1 above, just set the environment variable:

```sh
flatpak override --env=LM_LICENSE_FILE=~/.altera.quartus/license.dat com.intel.quartusprime.lite
```

Quartus Prime should be able to pick up the license automatically and pass it to Questa.

## License

All files included in this folder are public domain work under the CC0 1.0 license. See [LICENSE](./LICENSE) for a copy of the license text.

Intel Quartus Prime is a proprietary software licensed under the Quartus Prime and Intel FPGA IP License Agreement, along with a number of licenses that come with 3rd-party software used by Quartus Prime. These files can be retrieved from [here](https://downloadmirror.intel.com/849094/license-quartus-24.1std.zip) or from the installer by running:

```sh
./QuartusLiteSetup-24.1std.0.1077-linux.run --install_lic ./altera_lite/24.1std
```

This will place all license documents under `./altera_lite/24.1std/licenses`.

The same copy of license documents can also be found under `/app/opt/altera_lite/24.1std/licenses` in package `com.intel.quartusprime.lite`.
