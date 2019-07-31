#!/bin/bash
#===========================================================#
root_dir="/nesi/project/nesi99999/Callum/chris_z/"
stock_name="TST" 
num_jobs="5"       # Number of jobs this script will submit.
project_code="nesi99999"
mail_address="@"
#===========================================================#
#           No need to change anything below here           #
#===========================================================#
debug="false"               # If true, will not run matlab
interactive="false"          # If true will not use slurm.

#Include trailing slash if missing.
[[ "${root_dir}" != */ ]] && root_dir="${root_dir}/"

# Check root dir exists
ls ${root_dir} > /dev/null

root_stock_dir="${root_dir}${stock_name}/"      # Where  array script will be written here.
root_input_dir="${root_stock_dir}${root_dir}"   # Where inputs go
root_log_dir="${root_stock_dir}${root_dir}"     # Where logs go
root_output_dir="${root_stock_dir}${root_dir}"  # Where outputs go

#script_name=${prefix}${operation}${suffix}

echo "version 1.1"

#Validate directories
mkdir -pv ${root_stock_dir} ${root_input_dir} ${root_log_dir} ${root_output_dir} 


if [ ${debug} != "false" ]; then
    echo "NOTE: This is a debug run, no slurm jobs will be submitted. To fix this change 'debug=false'"
fi

# List on all files in directory
input_list=$(ls ${root_stock_dir}*)

# Count all files in directory
input_count=${#input_list[@]}

# Move to working directory
cd ${root_stock_dir}

# Message
echo "Submitting array job size ${input_count}..."

bash_file=".${stock_name}_1-${input_count}"

cat <<mainEOF > ${bash_file}
#!/bin/bash -e
#=================================================#
#SBATCH --time                      ${time}
#SBATCH --account                   ${project_code}
#SBATCH --array                     1-${input_count}
#SBATCH --job-name                  ${job_name}
#SBATCH --output                    %x.output
#SBATCH --cpus-per-task             ${cpus}
#SBATCH --mem                       ${mem}
#SBATCH --output                    ${log_dir}%x.log
#SBATCH --mail-type                 TIME_LIMIT_90
#SBATCH --mail-user                 ${mail_address}
#=================================================#
# Avoid possible future version issues
module load MATLAB/2018b
module load MATLAB
matlab -nojvm -r "downsampleRate=${downsample_rate}; \\
input_path='${input_path}'; \\
filename='${filename}'; \\
output_path='${output_path}'; \\
script_name='${script_name}'; \\
launch; exit;"
mainEOF



for line in ${!input_list[@]}; do 
    
    if [ ! ${num_jobs} -lt 1 ]; then
        input_path=${line}
        filename=$(basename $line)
        filename="${filename%.*}"
        job_name="${operation}_${filename}"
        output_path="${root_output_dir}linux_$(date +%Y%m%d)_${filename}_${operation}.xlsx"
        #ls ${root_output_dir}*_${filename}_${operation}.xlsx
        
        if ! ls ${root_output_dir}*_${filename}_${operation}.xlsx 1> /dev/null 2>&1;  then 

            echo "Using input '${line}'..." 
            echo "Operation will write to path '$output_path'"
            touch ${output_path}           
            num_jobs=$((${num_jobs} - 1))
            cd ${working_dir}
        
            if [ ${debug} != "true" ]; then        
                bash_file="${log_dir}${operation}_${filename}.sl"

# Create script for this run 


                if [ ${interactive} != "true" ]; then
                    echo "Submitting job"
                    sbatch ${bash_file}
                    sleep ${wait_time}                   
                else
                    echo "Running job interactively"
                    bash ${bash_file}
                    sleep ${wait_time}               
                fi 
                
            else    
                echo "Pretend Submitting job"
            fi

        else

            echo "File '$output_path' already exists. Skipping....."

        fi
    else
        echo "Specified number of jobs submitted."
        exit 0
    fi
    
done

