#!/bin/sh
#SBATCH --partition=ludicrous,super,batch
#SBATCH --job-name=SmS-x2c
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --exclusive
#SBATCH --output=SmS-x2c.o%j
#SBATCH --error=err.o%j
#SBATCH --mail-user=munkhw@umich.edu
#SBATCH --mail-type=END

### Print Node info
echo "My job run on"
echo $SLURM_NODELIST
echo "Start Date"
date

### Load Module
echo "Module list"
module purge
module load BuildEnv/gcc-12.2.0
module li

### Set environment variables
export ScriptDir="/home/munkhw/lib/green/python"
export StrucDir="/pauli-storage/munkhw/SmS"
export OMP_NUM_THREADS=64
export PYSCF_MAX_MEMORY=100000
export HDF5_USE_FILE_LOCKING=FALSE

# Keep OpenMP at allocated cores
export OMP_NUM_THREADS=${SLURM_CPUS_PER_TASK:-1}
export OMP_PROC_BIND=spread
export OMP_PLACES=cores

# Prevent nested parallelism from BLAS/numexpr
export MKL_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export BLIS_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

# ---- Heap / crash diagnostics (important for free(): invalid pointer) ----
# Make glibc abort closer to the point of corruption and add fill patterns.
export MALLOC_CHECK_=3
export MALLOC_PERTURB_=165
# Ensure glibc malloc/free messages go to stderr (your err.o%j).
export LIBC_FATAL_STDERR_=1
# Make Python print tracebacks on fatal signals where possible.
export PYTHONFAULTHANDLER=1
# Use system malloc (often improves usefulness of gdb/valgrind/asan-style debugging).
export PYTHONMALLOC=malloc

### Job Script
srun --cpu-bind=cores python -X faulthandler $ScriptDir/init_data_df.py \
            --a prim-5.97.dat \
            --atom coord-5.97.dat \
            --xc PBE \
            --job init \
            --nk 2 \
            --basis x2csvpall.dat \
            --x2c 2 \
            --max_iter 10 \
            --damping 0.2

echo "End Date"
date


