# This is a 3-deg test for temp_EvPrRn
# initially based on a combination of llc_hires/trillium/3deg

# ========
# 1. Get code
 git clone https://github.com/MITgcm-contrib/llc_hires.git
 git clone https://github.com/MITgcm/MITgcm.git
 cd MITgcm
 git checkout checkpoint69f
 mkdir build run

# ================
# 2. Build executable
 cd build
 ../tools/genmake2 -mo ../../llc_hires/3deg/69f/code
 make depend
 make -j

# ======================
# 3. Run verification setup
 cd ../run
 ln -sf ../build/mitgcmuv .
 cp ../../llc_hires/3deg/v4r5/input/*.0005184000 .
 cp ../../llc_hires/3deg/v4r5/input/EIG_* .
 cp ../../llc_hires/3deg/v4r5/input/*.bin .
 cp ../../llc_hires/3deg/69f/input/* .
 ./mitgcmuv > output.txt
