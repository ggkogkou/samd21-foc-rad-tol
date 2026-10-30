# Field-Oriented Control Firmware (SAMD21)

This repository contains the firmware used to control the radiation-tolerant Permanent Magnet Synchronous Motor (PMSM) controller board, hosted [here](https://github.com/ggkogkou/rad-tol-bldc-motor-driver).

The PMSM controller is built with discrete COTS components, individually tested under irradiation and characterized at the system level. The control unit is a Microchip Cortex-M0+ SAMD21 microcontroller executing this Field-Oriented Control (FOC) firmware.

---

## Development Setup

### 1. Installing the Dependencies

#### Linux (Debian / Ubuntu)
Install the build system, ARM toolchain, and debugging utilities via `apt`:

```bash
sudo apt update
sudo apt install build-essential cmake ninja-build gcc-arm-none-eabi g++-arm-none-eabi openocd git
```

#### Windows (`winget`)
Install all required tools in PowerShell or Command Prompt (run as Administrator):

```cmd
winget install Kitware.CMake Ninja-build.Ninja Arm.ArmGnuToolchain xpack-dev-tools.openocd-xpack MinGW.w64
```
---

### 2. Cloning the Repository & Submodules

Recursively clone the repository to pull all required submodules automatically:

```bash
git clone --recursive https://github.com/ggkogkou/motor-controller-samd.git
cd motor-controller-samd
```

---

## Building the ELF Target

The project uses CMake Presets configured for the target SAMD21 microcontroller variants (`g18a` or `j18a`) to load the appropriate DFP. Configure and build for either `g18a` or `j18a`:

```bash
cmake --preset g18a
cmake --build build/g18a --parallel
```

The ELF is generated at `build/g18a/motor-controller-samd21.elf`. Replace `g18a` with `j18a` for the alternative target.
