target remote localhost:3333
load opensbi/build/platform/fpga/ariane/firmware/fw_payload.elf

add-symbol-file opensbi/build/platform/fpga/ariane/firmware/fw_payload.elf
add-symbol-file bao-hypervisor/bin/cva6-spmp/cva6-spmp-single/bao.elf 
add-symbol-file bao-baremetal-guest/build/cva6/baremetal.elf
add-symbol-file bao-baremetal-guest2/build/cva6/baremetal.elf