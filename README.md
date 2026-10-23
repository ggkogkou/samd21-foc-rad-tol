# Field-Oriented Control Firmware (SAMD21)

This repository contains the firmware used to control the radiation-tolerant Permanent Magnet Synchronous Motor (PMSM) controller board, hosted [here](https://github.com/ggkogkou/rad-tol-bldc-motor-driver).

The PMSM controller is built with discrete COTS components, individually tested under irradiation and characterized at the system level. The control unit is a Microchip Cortex-M0+ SAMD21 microcontroller executing this Field-Oriented Control (FOC) firmware.

---

## Development Setup

### 1. Prerequisites & Dependencies

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

> **Note:** After installation on Windows, close and reopen your terminal or VS Code so the updated `PATH` environment variables take effect.

---

### 2. Cloning the Repository & Submodules

This repository uses Git submodules. Choose one of the following methods:

#### Option A: Clone with submodules included (Recommended)
Recursively clone the repository to pull all required submodules automatically:

```bash
git clone --recursive https://github.com/ggkogkou/motor-controller-samd.git
cd motor-controller-samd
```

#### Option B: Pull submodules after cloning
If you have already cloned the repository without submodules, run:

```bash
cd motor-controller-samd
git submodule update --init --recursive
```

---

## Building the Firmware

The project uses CMake Presets configured for the target SAMD21 microcontroller variants (`g18a` or `j18a`) to load the appropriate Device Family Pack (DFP).

### Build Commands

1. **Configure the project for your target MCU:**

   ```bash
   # For SAMD21G18A
   cmake --preset g18a

   # For SAMD21J18A
   cmake --preset j18a
   ```

2. **Compile the firmware:**

   ```bash
   # Build SAMD21G18A target
   cmake --build --preset g18a

   # Build SAMD21J18A target
   cmake --build --preset j18a
   ```

3. **Clean build directory (Optional):**

   ```bash
   cmake --build --preset g18a --target clean
   ```