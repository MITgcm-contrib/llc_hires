parent_dir="/scratch/dmenemen/MITgcm/run_8640/"
nx="8640"
level="1"
vmin="0"
vmax="0.5"

for ufile in "${parent_dir}"/U.*.data; do
  fname=$(basename "${ufile}")
  num=${fname#U.}
  num=${num%.data}
  echo "Processing sequence $num..."
  python llc_vis.py "${parent_dir}" --num "$num" --nx "$nx" --level "$level" --vmin "$vmin" --vmax "$vmax"
done
