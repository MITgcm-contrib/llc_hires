import re
from pathlib import Path

# ---- configuration ----
path='/nobackup/hplombat/llc_1080/MITgcm/run/run_18x18x30051/'
meta_template_file =path+"meta_template"
dt = 3.6e3  # seconds
# -----------------------

# Read template once
with open(meta_template_file, "r") as f:
    template = f.read()

# Find all Eta.*.data files
data_files = sorted(Path(path).glob("Eta.*.data"))

for i, data_file in enumerate(data_files, start=1):
    # Extract timestep number from filename
    m = re.search(r"Eta\.(\d+)\.data", data_file.name)
    if not m:
        continue

    timestep = int(m.group(1))
    time_interval = i * dt

    # Replace fields in template
    meta_content = template
    meta_content = re.sub(
        r"timeStepNumber\s*=\s*\[\s*\d+\s*\];",
        f"timeStepNumber = [ {timestep} ];",
        meta_content,
    )
    meta_content = re.sub(
        r"timeInterval\s*=\s*\[\s*.*?\s*\];",
        f"timeInterval=[ {time_interval:.13E} ];",
        meta_content,
    )

    # Write meta file
    meta_file = data_file.with_suffix(".meta")
    with open(meta_file, "w") as f:
        f.write(meta_content)

    print(f"Written {meta_file}")
