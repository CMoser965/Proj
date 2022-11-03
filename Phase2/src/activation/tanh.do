onbreak {resume}

if [file exists work] {
    vdel -all
}
vlib work

vlog tanh.v tanh_tb.v

vsim -voptargs=+acc work.stimulus

view wave

-- display input and output signals as hexidecimal values
# Diplays All Signals recursively

add wave -hex -r /stimulus/*

-- Set Wave Output Items ---
TreeUpdate [SetDefaultTree]
WaveRestoreZoom {0 ps} {75 ns}
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2

run -all