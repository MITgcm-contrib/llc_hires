module load python
pip install --upgrade pip
pip install numpy
pip install matplotlib

--------------------------

e.g. 
python visualize_2d.py crood_llc8640_Salt --nx 8640 --vmin 0 --vmax  15 --cmap Blues --endian '>' --output Theta_surface.png --level 20