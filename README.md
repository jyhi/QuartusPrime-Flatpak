<!--
    SPDX-FileCopyrightText: 2024-2025 Junde Yhi <junde@yhi.moe>
    SPDX-License-Identifier: CC0-1.0
-->

# Intel Quartus Prime Lite Edition Design Software for Linux (Flatpak)

This folder contains *some* necessary files to re-pack [Quartus Prime Lite Edition](https://www.intel.com/content/www/us/en/products/details/fpga/development-tools/quartus-prime.html) and its components (version 23.1.1/23.1std.1.993, released on 14 June 2024) into [Flatpak](https://en.wikipedia.org/wiki/Flatpak) packages.

**You must obtain the software installer programs and build the Flatpak(s) by yourself.** Under [Intel.com Website Terms of Use](https://www.intel.com/content/www/us/en/legal/terms-of-use.html), the building scripts are unable to automatically download the software installers required to build the packages. The built packages are not hosted in any repository either. See <https://www.intel.com/content/www/us/en/software-kit/825277/> for all the download options available from Intel.

## Known Issues

Some packages are known to be broken at this moment:

- Questa (`com.intel.quartusprime.lite.questa.starter`) won't start. The exact cause is unknown yet, but a peak into the `vsim` launching process reveals that something might be corrupted: `** Error: mountTrofs script: Invalid TCL archive content`.
- Help (`com.intel.quartusprime.lite.help`) documents may be misconfigured, as Quartus Prime Lite Edition cannot show any offline help materials.
- RiscFree (`com.intel.quartusprime.riscfree`) doesn't have a proper desktop icon. This is done to avoid distributing the company's logo, which is likely protected, in this folder.

## Build &amp; Install

Flatpak must be installed on the computer first. Then, install the Flatpak development toolkit from Flathub:

```sh
flatpak --user install org.flatpak.Builder
```

Package definitions (manifests, metadata, etc.) are placed under folders with paths (separated by forward slashes (`/`)) starting from this level mimicking their package names (separated by periods (`.`)). For example, `com.intel.quartusprime.lite` is at [com/intel/quartusprime/lite](./com/intel/quartusprime/lite/). A list of additionally required file(s) can be found in the `REQFILES =` line in `Makefile`. The file names are identical to those available from the Intel website. For example, `com.intel.quartusprime.lite` requires `QuartusLiteSetup-23.1std.1.993-linux.run`, which is its official installer executable. Place the additionally required file(s) to the package folder. Then, install the package using the build script:

```sh
make install
```

By default, the script installs the package to the current user. To install it system-wide:

```sh
make FLATPAKFLAGS=--system install
```

## Run

To run Quartus Prime Lite, Quartus Prime Programmer or RiscFree, find and click their corresponding icons in the application menu (under category "Development").

To run Quartus Prime Lite (GUI) from a terminal emulator:

```sh
flatpak run com.intel.quartusprime.lite
```

To run a shell, Quartus Prime Lite CLI (`quartus_sh`) or any other program that comes with it, change the entry point to `/bin/sh`, then source `/app/enable.sh` to populate `PATH` and set up the environment. For example:

```sh
flatpak run --command=/bin/sh com.intel.quartusprime.lite -c \
    '. /app/enable.sh; quartus_sh'
```

## Permission

By default, neither Quartus Prime Lite (`com.intel.quartusprime.lite`) nor RiscFree (`com.intel.quartusprime.riscfree`) has access to any file or device on the host computer. You must explicitly grant permissions to them. For example, to give Quartus Prime Lite access to all files (read and write) and devices on the host computer:

```sh
flatpak override --filesystem=host --device=all com.intel.quartusprime.lite
```

For a full range of options that you can specify with the `flatpak override` command, check [flatpak-override(1)](https://docs.flatpak.org/en/latest/flatpak-command-reference.html#flatpak-override). Alternatively, a GUI like [Flatseal](https://flathub.org/apps/com.github.tchx84.Flatseal) can be more intuitive.

The standalone Quartus Prime Programmer (`com.intel.quartusprime.programmer`) is by default allowed to access all files (read only) and devices on the host computer instead. This makes it useful out of the box.

## Software License

The RTL simulator (Questa - Intel FPGA Starter Edition) that comes with Quartus Prime Lite Edition requires a license, despite that it's free. You should obtain and set up the license file before starting it. Follow [this document](https://www.intel.com/content/www/us/en/docs/programmable/683472/24-3/and-software-license.html) for the steps required to generate and download a free license file.

Note: you *may* want to enable the network permission (`share=network`) for Quartus Prime Lite Edition, since it cannot read the MAC address(es) in the system without the network permission. It'll display `000000000000` (which is the MAC address on `lo`) in the License Setup dialog, but **an all-zero MAC address won't work in the Self-Service Licensing Center.** Although you'll be allowed to type in a string of zeros and download a `.dat` file, the actual certificate will be absent from the file and be replaced with `300 Disallowed hostid and/or server hostid.`

After obtaining the license file (with a `.dat` suffix), expose the file to the Flatpak and set the environment variable `LM_LICENSE_FILE`:

```sh
flatpak override --filesystem=/path/to/license.dat:ro \
    --env=LM_LICENSE_FILE=/path/to/license.dat \
    com.intel.quartusprime.lite
```

Quartus Prime Lite Edition should be able to pick up the license automatically and pass it to Questa.

## List of Packages

### Standalone Software

These packages have their desktop icons and can be found in the launcher after installation.

- Quartus Prime Lite Edition (including Nios II EDS): [`com.intel.quartusprime.lite`](./com/intel/quartusprime/lite)
- Quartus Prime Programmer and Tools: [`com.intel.quartusprime.programmer`](./com/intel/quartusprime/programmer)
- Ashling RiscFree IDE for Intel FPGAs: [`com.intel.quartusprime.riscfree`](./com/intel/quartusprime/riscfree)

### Extensions to Quartus Prime Lite

These packages are automatically loaded if they're installed when Quartus Prime Lite Edition is starting. They can't be launched individually as they contain no desktop icon.

- Intel Quartus Prime Help: [`com.intel.quartusprime.lite.help`](./com/intel/quartusprime/lite/help)
- Questa - Intel FPGA and Starter Editions: [`com.intel.quartusprime.lite.questa.starter`](./com/intel/quartusprime/lite/questa/starter)

### Quartus Prime Lite Device Support Packages

These are also extensions to Quartus Prime Lite Edition and are automatically loaded by Flatpak if they're installed when Quartus Prime Lite Edition is starting.

- Arria II device support: [`com.intel.quartusprime.lite.device.arrialite`](./com/intel/quartusprime/lite/device/arrialite)
- Cyclone IV device support: [`com.intel.quartusprime.lite.device.cyclone`](./com/intel/quartusprime/lite/device/cyclone)
- Cyclone 10 LP device support: [`com.intel.quartusprime.lite.device.cyclone10lp`](./com/intel/quartusprime/lite/device/cyclone10lp)
- Cyclone V device support: [`com.intel.quartusprime.lite.device.cyclonev`](./com/intel/quartusprime/lite/device/cyclonev)
- MAX II, MAX V device support: [`com.intel.quartusprime.lite.device.max`](./com/intel/quartusprime/lite/device/max)
- MAX 10 FPGA device support: [`com.intel.quartusprime.lite.device.max10`](./com/intel/quartusprime/lite/device/max10)

## License

All files included in this folder are public domain work under the CC0 1.0 license. See [LICENSE](./LICENSE) for a copy of the license text.

The Intel Quartus Prime software is a proprietary software licensed under the Quartus Prime and Intel FPGA IP License Agreement, along with a number of licenses that come with 3rd-party software used by Quartus Prime. These files are installed to `/app/opt/intelFPGA_lite/23.1std/licenses` in the Flatpak. Alternatively, a copy of all license texts can be extracted separately from the Quartus Prime installer:

```sh
./QuartusLiteSetup-23.1std.1.993-linux.run --install_lic ./intelFPGA_lite/23.1std
```

This will place all the license documents under `./intelFPGA_lite/23.1std/licenses`.
