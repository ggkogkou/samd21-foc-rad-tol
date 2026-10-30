cmake_minimum_required(VERSION 3.20)

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)
set(CMAKE_C_COMPILER arm-none-eabi-gcc)
set(CMAKE_CXX_COMPILER arm-none-eabi-g++)
set(CMAKE_ASM_COMPILER arm-none-eabi-gcc)
set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

project(motor-controller-samd21 LANGUAGES C CXX ASM)

# MCU configuration
set(MCU_ARCH "cortex-m0plus")
set(DEVICE_DEFINE "__SAMD21${MCU}__")
set(LD_SCRIPT "${CMAKE_CURRENT_SOURCE_DIR}/device_startup/SAMD21x18A.ld")

# External libraries
set(ETL_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib/etl/include")
set(GCEM_INCLUDE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/lib/gcem/include")

if (NOT EXISTS "${ETL_INCLUDE_DIR}/etl/expected.h" OR
        NOT EXISTS "${GCEM_INCLUDE_DIR}/gcem.hpp")
    message(FATAL_ERROR
            "Missing Git submodules (ETL or GCEM).\n"
            "Run: git submodule update --init --recursive"
    )
endif ()

# Sources
set(SOURCES
        # Application
        src/main.cpp
        src/svpwm.cpp
        src/pid.cpp
        src/pmsm_controller.cpp
        src/spi_buffer.cpp
        src/USART_TxStream.cpp
        src/SAMD21_FOC.cpp
        src/Telemetry.cpp
        src/CriticalVariables.cpp
        src/StartupCalibration.cpp
        src/HardwareDiagnosticsLogger.cpp
        src/HealthMonitor.cpp
        src/ResetBreadcrumb.cpp

        # Startup and initialization
        src/config/sam_d21_xpro/initialization.c
        device_startup/InterruptHandlers.cpp
        device_startup/DeviceStartup.cpp
        device_startup/libc_syscalls.cpp

        # Peripheral libraries
        src/config/sam_d21_xpro/peripheral/adc/plib_adc.c
        src/config/sam_d21_xpro/peripheral/clock/plib_clock.c
        src/config/sam_d21_xpro/peripheral/dmac/plib_dmac.c
        src/config/sam_d21_xpro/peripheral/eic/plib_eic.c
        src/config/sam_d21_xpro/peripheral/evsys/plib_evsys.c
        src/config/sam_d21_xpro/peripheral/nvic/plib_nvic.c
        src/config/sam_d21_xpro/peripheral/nvmctrl/plib_nvmctrl.c
        src/config/sam_d21_xpro/peripheral/port/plib_port.c
        src/config/sam_d21_xpro/peripheral/systick/plib_systick.c
        src/config/sam_d21_xpro/peripheral/sercom/usart/plib_sercom3_usart.c
        src/config/sam_d21_xpro/peripheral/sercom/usart/plib_sercom4_usart.c
        src/config/sam_d21_xpro/peripheral/sercom/spi_master/plib_sercom5_spi_master.c
        src/config/sam_d21_xpro/peripheral/tc/plib_tc3.c
        src/config/sam_d21_xpro/peripheral/tc/plib_tc4.c
        src/config/sam_d21_xpro/peripheral/tcc/plib_tcc0.c

        # Drivers
        drivers/as5047p.cpp
        drivers/drv8316.cpp
        drivers/samd21_peripherals/GenericClockController.cpp
        drivers/samd21_peripherals/ADC.cpp
)

# Firmware target
add_executable(${PROJECT_NAME}.elf ${SOURCES})

set_target_properties(${PROJECT_NAME}.elf PROPERTIES
        C_STANDARD 99
        C_STANDARD_REQUIRED ON
        C_EXTENSIONS ON
        CXX_STANDARD 20
        CXX_STANDARD_REQUIRED ON
        CXX_EXTENSIONS OFF
)

# Include directories
target_include_directories(${PROJECT_NAME}.elf PRIVATE
        src
        src/config/sam_d21_xpro
        src/config/sam_d21_xpro/peripheral/adc
        src/config/sam_d21_xpro/peripheral/clock
        src/config/sam_d21_xpro/peripheral/dmac
        src/config/sam_d21_xpro/peripheral/eic
        src/config/sam_d21_xpro/peripheral/evsys
        src/config/sam_d21_xpro/peripheral/nvic
        src/config/sam_d21_xpro/peripheral/nvmctrl
        src/config/sam_d21_xpro/peripheral/port
        src/config/sam_d21_xpro/peripheral/sercom/usart
        src/config/sam_d21_xpro/peripheral/sercom/spi_master
        src/config/sam_d21_xpro/peripheral/systick
        src/config/sam_d21_xpro/peripheral/tc
        src/config/sam_d21_xpro/peripheral/tcc

        src/packs/ATSAMD21_DFP
        src/packs/ATSAMD21_DFP/component
        src/packs/ATSAMD21_DFP/instance
        src/packs/ATSAMD21_DFP/pio
        src/packs/CMSIS/CMSIS/Core/Include

        device_startup
        drivers
        drivers/samd21_peripherals

        ${ETL_INCLUDE_DIR}
        ${GCEM_INCLUDE_DIR}
)

# Preprocessor definitions
target_compile_definitions(${PROJECT_NAME}.elf PRIVATE
        ${DEVICE_DEFINE}
        DONT_USE_PREDEFINED_CORE_HANDLERS
        DONT_USE_PREDEFINED_PERIPHERALS_HANDLERS

        ETL_NO_STL
        ETL_TARGET_DEVICE_ARM
        ETL_COMPILER_GCC
        ETL_CPP20_SUPPORTED
)

# Compiler options
target_compile_options(${PROJECT_NAME}.elf PRIVATE
        -mcpu=${MCU_ARCH}
        -mthumb
        -mfloat-abi=soft

        -O3
        -flto
        -g3

        -ffunction-sections
        -fdata-sections
        -Wall
        -Wextra

        $<$<COMPILE_LANGUAGE:CXX>:-fno-exceptions>
        $<$<COMPILE_LANGUAGE:CXX>:-fno-rtti>
        $<$<COMPILE_LANGUAGE:CXX>:-fno-threadsafe-statics>
        $<$<COMPILE_LANGUAGE:CXX>:-fno-unwind-tables>
        $<$<COMPILE_LANGUAGE:CXX>:-fno-asynchronous-unwind-tables>
)

# Linker options
target_link_options(${PROJECT_NAME}.elf PRIVATE
        -mcpu=${MCU_ARCH}
        -mthumb
        -mfloat-abi=soft

        -specs=nano.specs
        -specs=nosys.specs
        -T${LD_SCRIPT}

        -flto
        -Wl,--gc-sections
        -Wl,-Map=${CMAKE_CURRENT_BINARY_DIR}/${PROJECT_NAME}.map,--cref
        -Wl,--no-warn-mismatch
)

set_property(TARGET ${PROJECT_NAME}.elf APPEND PROPERTY
        LINK_DEPENDS "${LD_SCRIPT}"
)

# Memory usage
find_program(SIZE arm-none-eabi-size REQUIRED)

add_custom_command(TARGET ${PROJECT_NAME}.elf POST_BUILD
        COMMAND ${SIZE} --format=berkeley $<TARGET_FILE:${PROJECT_NAME}.elf>
        COMMENT "Firmware memory usage"
        VERBATIM
)

# Build information
message(STATUS "Target MCU: ATSAMD21${MCU}")
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "Linker script: ${LD_SCRIPT}")
