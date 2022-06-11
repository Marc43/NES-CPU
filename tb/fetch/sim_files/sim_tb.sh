# Somehow define the root directory not sure now gotta continue another day :)

xvlog -i ${ROOT_DIR}/include --sv pkg/cpu_6502_ISA_pkg.sv pkg/nes_cpu_pkg.sv src/pc.sv src/fetch.sv src/mem.sv tb/fetch/tb.sv
xelab -debug typical tb -s tb
xsim tb -gui
