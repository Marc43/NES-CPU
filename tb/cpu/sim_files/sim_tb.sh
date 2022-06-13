# Somehow define the root directory not sure now gotta continue another day :)

xvlog -i ${ROOT_DIR}/include --sv pkg/*.sv src/*.sv tb/cpu/tb.sv
xelab -debug typical tb -s tb
xsim tb -gui
