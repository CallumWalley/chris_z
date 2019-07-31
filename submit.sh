#!/bin/bash -e
#===========================================================#
root_dir="/nesi/project/nesi99999/Callum/chris_z/"
stock_name="${1}" 
#===========================================================#
#                                                           #
#===========================================================#
debug="false"                # If true, will not submit job.

#Include trailing slash if missing.
[[ "${root_dir}" != */ ]] && root_dir="${root_dir}/"

root_stock_dir="${root_dir}${stock_name}/"      # Where  array script will be written here.
cd ${root_stock_dir}                            # 
root_log_dir="${root_stock_dir}${root_dir}"     # Where logs go
root_output_dir="${root_stock_dir}${root_dir}"  # Where outputs go

main_input_mat="${root_stock_dir}${stock_name}.mat"

ls ${main_input_mat}

echo "version 1.1"

#Validate directories
mkdir -pv ${root_stock_dir} ${root_log_dir} ${root_output_dir} 

# Move to working directory


# Message
echo "Submitting array job size ${input_count} using input ${main_input_mat}"

bash_file="${stock_name}_1-${input_count}"

cat <<mainEOF > ${bash_file}
#!/bin/bash -e
#=================================================#
#SBATCH --time                      01:00:00
#SBATCH --array                     1-${input_count}
#SBATCH --job-name                  ${stock_name}_%a
#SBATCH --output                    ${root_log_dir}${stock_name}_%a.log
#SBATCH --cpus-per-task             2
#SBATCH --mem                       1500
#=================================================#
# Avoid possible future version issues
module load MATLAB/2018b

# If going for individual file.
matlab -nojvm -r "addpath('${root_dir}'); AutomateRun(${mat_file},${SLURM_ARRAY_TASK_ID})"
mainEOF


if [ ${debug} != "false" ]; then
    echo "NOTE: This is a debug run."
else
    sbatch ${bash_file}
fi
