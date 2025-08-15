# This is a 3-deg test for the ECCO v4r5 c68y configuration
# initially based on a combination of MITgcm-contrib/ecco_darwin/v05/3deg
# and MITgcm-contrib/llc_hires/llc_90/ecco_v4r5/readme_v4r5_68y.txt

# ========
# 1. Get code
 git clone https://github.com/MITgcm-contrib/llc_hires.git
 git clone https://github.com/MITgcm/MITgcm.git
 cd MITgcm
 git checkout checkpoint68y
 mkdir build run

# ================
# 2. Build executable
 cd build
 ../tools/genmake2 -mo ../../llc_hires/3deg/v4r5/code
 make depend
 make -j

# ======================
# 3. Run verification setup
 cd ../run
 ln -sf ../build/mitgcmuv .
 cp ../../llc_hires/3deg/v4r5/input/* .
 ./mitgcmuv > output.txt
