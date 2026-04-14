This is Bron Nelson's compress/shrink routine modified slightly by DBW

ssh afe
module purge
module load gcc/13.2

g++ -O2 -std=c++17 -Wall -Wextra -o compress compress.cxx async_io.cxx -lrt
ln -sf compress shrink
ln -sf compress bloat

# usage
./bloat /path/to/mask_input /path/to/shrunk_input /path/to/bloat_output
./shrink /path/to/mask_input /path/to/bloat_input /path/to/shrunk_output
