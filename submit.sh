#!/bin/bash
set -e
#===========================================================#
root_dir="/nesi/project/nesi99999/Callum/chris_z/"      # Your project directory
stock_name="FBUTESTING"                                 # Stock to proccess
debug="false"                                            # If this is equal to "true", the job won't be submitted.

# Include trailing slash if missing.
[[ "${root_dir}" != */ ]] && root_dir="${root_dir}/"

# Set Paths
#===========================================================#
root_stock_dir="${root_dir}${stock_name}/"              # Array slurm-script will be written here.
root_log_dir="${root_stock_dir}logs/"                   # Where logs go
root_output_dir="${root_stock_dir}outputs/"             # Where outputs go
main_input_mat="${root_stock_dir}${stock_name}.mat"     # Input file


# Validate
#============================================================#
echo ${root_stock_dir}
cd ${root_stock_dir}                # Move to requred diretory. Will fail if it doesn't exist. 
ls ${main_input_mat} > /dev/null    # Check input file exists
                                    # "> /dev/null" re-directs the standard output to null.
                                    # This is just saying "Don't print the outcome (unless an error)"

echo "version 1.3"                  # This is a good way to keep track of edits

# If these directories don't exist, make them.
mkdir -pv ${root_stock_dir} ${root_log_dir} ${root_output_dir} 

# Get length of input (a bit hackey. Don't bother trying to understand this bit)
echo "Reading number of rows..."
set +e
matlab -nodisplay -nojvm -r "step1=whos(matfile('FBUTESTING/FBUTESTING.mat')); exit(step1.size(2));" > /dev/null
input_count=${?}
set -e
echo "Done!"

# Echo message, good for last common sense check
echo "Submitting array job size ${input_count} using input ${main_input_mat}"

# Name of the slurm-script we are creating.
bash_file="${stock_name}_1-${input_count}"

# Everyting from here to the bottom 'mainEOF' will be written into the slurm script.
# All variables will be replaced with values.
cat <<mainEOF > ${bash_file}
#!/bin/bash -e
#=================================================#
#SBATCH --time                      01:00:00
#SBATCH --array                     1-${input_count}
#SBATCH --job-name                  ${stock_name}
#SBATCH --output                    ${root_log_dir}${stock_name}_%a.log
#SBATCH --cpus-per-task             2
#SBATCH --mem                       1500
#SBATCH --partition		    large 	#long
#=================================================#
# Avoid possible future version issues
module load MATLAB/2018b

# Add root to path, run function with index then save output 
matlab -nojvm -r "addpath('${root_dir}'); output_mat=AutomateRun('${main_input_mat}',\${SLURM_ARRAY_TASK_ID}); save('${stock_name}_row-\${SLURM_ARRAY_TASK_ID}.mat', 'output_mat', '-v7.3'); exit;"
mainEOF


if [ ${debug} != "false" ]; then
    echo "NOTE: This is a debug run. Job not submitted."
else

    # Submit the file we just created to the SLURM queue.
    sbatch ${bash_file}
fi
