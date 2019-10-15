#!/bin/bash
set -e
#===========================================================#
root_dir="/nesi/nobackup/aut02787/"      # Your project directory

stock_suffix="LOB"
stock_name="CSL"                                 # Stock to proccess
time="04:00:00"
mem="5000"

debug="true"                                            # If this is equal to "true", the job won't be submitted.

# Include trailing slash if missing.
[[ "${root_dir}" != */ ]] && root_dir="${root_dir}/"

# Set Paths
#===========================================================#
root_stock_dir="${root_dir}${stock_name}/"              # Array slurm-script will be written here.
#root_log_dir="${root_stock_dir}AskSideVariable/"              # Where logs go
root_output_dir="/nesi/project/aut02787/${stock_name}/"             # Where outputs go
main_input_mat="/nesi/project/aut02787/${stock_name}.mat"     # Input file


mkdir -pv ${root_stock_dir} ${root_log_dir} ${root_output_dir}

# Validate
#============================================================#
ls ${main_input_mat} > /dev/null    # Check input file exists
                                    # "> /dev/null" re-directs the standard output to null.
                                    # This is just saying "Don't print the outcome (unless an error)"

echo "version 1.4"                  # This is a good way to keep track of edits

# If these directories don't exist, make them.
module load Python
input_count=$(python -c "import sys,h5py;print(h5py.File(sys.argv[1])['DATA']['DATE'].shape[0])" ${main_input_mat})
echo "$input_count rows found."

#ls $root_output_dir

for (( i=1; i<=$input_count; i++ )); do
    if ls ${root_output_dir}*${i}.mat 1> /dev/null 2>&1; then
        printf "Run ${i} already exists, skipping.\r"
    else
        input_array="${input_array}${i},"
    fi
done

# Echo message, good for last common sense check
echo "Submitting array job size ${input_count}, using input ${main_input_mat}"

# Name of the slurm-script we are creating.
bash_file="${stock_name}_1-${input_count}"

# Everyting from here to the bottom 'mainEOF' will be written into the slurm script.
# All variables will be replaced with valuSes.
cat <<mainEOF > ${bash_file}
#!/bin/bash -e
#=================================================#
#SBATCH --time                      ${time}
#SBATCH --array                     ${input_array}
#SBATCH --job-name                  ${stock_name}_${stock_suffix}
#SBATCH --output                    ${root_log_dir}${stock_name}%a.log
#SBATCH --cpus-per-task             2
#SBATCH --mem                       ${mem}
#SBATCH --partition		            large
#SBATCH --mail-type                 TIME_LIMIT_80,ARRAY_TASKS
#SBATCH --mail-user                 chris.hengbin.zhang@aut.ac.nz
#=================================================#
# Avoid possible future version issues
module load MATLAB/2018b

# Add root to path, run function with index then save output 
matlab -nojvm -r "addpath('${root_dir}'); output_mat_\${SLURM_ARRAY_TASK_ID}=AskSideVariables('${main_input_mat}',\${SLURM_ARRAY_TASK_ID}); save('${root_output_dir}${stock_name}_ASKSIDE\${SLURM_ARRAY_TASK_ID}.mat', 'output_mat_\${SLURM_ARRAY_TASK_ID}', '-v7.3'); exit;"
mainEOF


if [ ${debug} != "false" ]; then
    echo "NOTE: This is a debug run. Job not submitted. Set debug=\"false\" to disable this."
else

    # Submit the file we just created to the SLURM queue.
    sbatch ${bash_file}
fi
