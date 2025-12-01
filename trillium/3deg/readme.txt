# This is a 3-deg test for KPP_VARY_RICR
# initially based on a combination of llc_hires/3deg
# and llc_hires/trillium/llc_1080

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
 ../tools/genmake2 -mo ../../llc_hires/trillium/3deg/code
 make depend
 make -j

# ======================
# 3. Run verification setup
 cd ../run
 ln -sf ../build/mitgcmuv .
 cp ../../trillium/3deg/input/* .
 ./mitgcmuv > output.txt
