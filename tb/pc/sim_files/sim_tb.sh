# Somehow define the root directory not sure now gotta continue another day :)

xvlog --sv pkg/nes_cpu_pkg.sv src/pc.sv tb/pc/tb.sv
xelab -debug typical tb -s tb
xsim tb -gui
