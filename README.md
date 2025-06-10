# CVA6-SPMP Walkthrough

This tutorial guides you on how to run the Bao Hypervisor on top two different versions of the CVA6 core with the RISC-V Hypervisor extension (hereinafter refered to as CVA6-H):

- CVA6-H with MMU
- CVA6-H with SPMP for Hypervisor (MCU-style)

## Prerequisites

1. RISC-V GCC toolchain required by the CVA6. Install the prerequisites as specified [here](https://github.com/openhwgroup/cva6/blob/master/util/toolchain-builder/README.md#Prerequisites). Then, install the [toolchain itself](https://github.com/openhwgroup/cva6/blob/master/util/toolchain-builder/README.md#Getting-started).\
:information_source: The CVA6 repo **strongly recommends** to use the toolchain built with the provided scripts.

2. `riscv64-unknown-elf-` toolchain. You can find it [here](https://static.dev.sifive.com/dev-tools/freedom-tools/v2020.08/riscv64-unknown-elf-gcc-10.1.0-2020.08.2-x86_64-linux-ubuntu14.tar.gz).

3. Vivado (with license to synthesize Xilinx parts).

4. OpenOCD with RISC-V support. You can find it [here](https://github.com/riscv-collab/riscv-openocd).

## Clone repository and update submodules
```shell
git clone https://github.com/malejo97/cva6-spmp-walkthrough.git

git submodule update --init --recursive
```

## Generate CVA6 bitstream

### 1. Define the target CVA6 configuration

Change the target configuration in **cva6/Makefile** (lines [104](https://github.com/malejo97/cva6/blob/ec5ab88684cef215a2b43759a7a92be1461cd931/Makefile#L104) and [105](https://github.com/malejo97/cva6/blob/ec5ab88684cef215a2b43759a7a92be1461cd931/Makefile#L105)) according to the intended CVA6 version:

| CVA6 version | `target` |
| --- | --- |
| CVA6-H with MMU | `cv64a6_imafdch_sv39` |
| CVA6-H with SPMP for Hypervisor | `cv64a6_imafdch_spmp` |

### 2. Start synthesis

Set the `$RISCV` environment variable to the path where you installed the RISC-V GCC toolchain

```shell
export RISCV=<path/to/toolchain>
```

Then, start the synthesis

:warning: The CVA6-based SoC integrates some Xilinx parts that require a Vivado license to be synthesized. This license is usually provided with the Genesys2 board. **If you don't have the license, the synthesis will fail**
```shell
make fpga
```

After ~1h the bitstream will be located in **cva6/corev_apu/fpga/work-fpga/ariane_xilinx.bit**

## Build Bao+OpenSBI

Run the corresponding script to build Bao and OpenSBI depending on the CVA6 version where you intend to run the binary.

| CVA6 version | `target` |
| --- | --- |
| CVA6-H with MMU | `build-bao-mmu.sh` |
| CVA6-H with SPMP for Hypervisor | `build-bao-spmp.sh` |

The output binary will be located in **output/fw_payload.bin**

## Run the binary on top of the CVA6

1. Connect two micro-USB cables to the Genesys2 board. One to the port with the `JTAG` label, and another to the port with the `UART` label.

2. Plug and turn on the board.

3. Open Vivado and start the Vivado Hardware manager. Connect to the Genesys2 board with the **Open target -> Auto Connect** option.\
:warning: In order to use the Vivado Auto Connect funcion, you need to have the cable drivers for the Genesys2 installed in your PC.

4. Program the device with the generated bitstream

5. Open a console with 115200/8N1 and connect to the board's UART. E.g. something like `screen /dev/ttyUSB0 115200` or `sudo minicom -D /dev/ttyUSB2`.

6. Open two terminals

    5.1 In **terminal 1**, start an OpenOCD server with the CVA6 configuration
    ```shell
    riscv-openocd -f cva6/corev_apu/fpga/ariane.cfg
    ```

    5.2 In terminal 2, start GDB using the command file provided
    ```shell
    riscv64-unknown-elf-gdb -x cmd.gdb
    ```

7. In the GDB console, type `continue` after the binary is loaded to the board. You should see Bao executing and printing in the UART.

