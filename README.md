## SLURM / MATLAB workflow


### Instructions

1. Open `submit.sh` with text editor.
2. Set `root_path` to the directory containing your functions.
3. Set `stock_name` this will look for file $stock_name/$stock_name.mat
4. Check values in SLURM header. ≈ line 50.
  * Time
  * Mem
  * Partition
5. Save file then `bash submit.sh

### Paths

`$root_dir/$stock_name/outputs`

`$root_dir/$stock_name/logs`
