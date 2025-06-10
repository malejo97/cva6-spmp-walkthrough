#!/bin/bash

set -e

ROOT="$(cd "$(dirname "$0")" && pwd)"

BAREMETAL_DIR="${ROOT}/bao-baremetal-guest"

BAO_DIR="${ROOT}/bao-hypervisor"
BAO_CONFIG="cva6-mmu-single"

UNK_TOOLCHAIN="riscv64-unknown-elf-"

OPENSBI_DIR="${ROOT}/opensbi"
CONFIG_DIR="${ROOT}/configs"

OUTPUT_DIR="${ROOT}/output"

## Remove outputs
mkdir -p ${OUTPUT_DIR}
rm -f -r ${OUTPUT_DIR}/*

## Build baremetal guest
make -C ${BAREMETAL_DIR} clean
make -C ${BAREMETAL_DIR} CROSS_COMPILE=${UNK_TOOLCHAIN} PLATFORM=cva6 ARCH_SUB=riscv64

if [ -e ${BAREMETAL_DIR}/build/cva6/baremetal.bin ]; then
    cp ${BAREMETAL_DIR}/build/cva6/baremetal.bin ${OUTPUT_DIR}
fi

## Build Bao
make -C ${BAO_DIR} clean
make -C ${BAO_DIR} CROSS_COMPILE=${UNK_TOOLCHAIN} PLATFORM=cva6-mmu ARCH_SUB=riscv64 CONFIG_REPO=${CONFIG_DIR} CONFIG=${BAO_CONFIG}

if [ -e ${BAO_DIR}/bin/cva6-mmu/${BAO_CONFIG}/bao.bin ]; then 
    cp ${BAO_DIR}/bin/cva6-mmu/${BAO_CONFIG}/bao.bin ${OUTPUT_DIR}
fi

## Build OpenSBI
make -C ${OPENSBI_DIR} clean
make -C ${OPENSBI_DIR} CROSS_COMPILE=${UNK_TOOLCHAIN} PLATFORM=fpga/ariane FW_PAYLOAD_PATH=${OUTPUT_DIR}/bao.bin

if [ -e ${OPENSBI_DIR}/build/platform/fpga/ariane/firmware/fw_payload.elf ]; then
    cp ${OPENSBI_DIR}/build/platform/fpga/ariane/firmware/fw_payload.elf ${OUTPUT_DIR}
    cp ${OPENSBI_DIR}/build/platform/fpga/ariane/firmware/fw_payload.bin ${OUTPUT_DIR}
fi
