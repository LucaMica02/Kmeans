#!/bin/bash

# take the argument
exe="$1" 
test="$2" 

# check if arguments are passed
if [ -z "$exe" ]; then
  echo "The execute file must be specified"
  exit 1
fi

if [ -z "$test" ]; then
  echo "The test file must be specified"
  exit 1
fi

# run the sequential executable
echo "KMEANS_seq"
./KMEANS_seq $test 32 100 0.001 0.001 seq_result.txt 
echo -e "\n################################################\n$exe"

# run the parallel executable
case "$1" in
  "KMEANS_mpi+omp")
    OMP_NUM_THREADS=2 mpirun --bind-to none -n 4 ./KMEANS_mpi+omp $test 32 100 0.001 0.001 result.txt
    ;;
  "KMEANS_mpi")
    mpirun -n 4 ./KMEANS_mpi $test 32 100 0.001 0.001 result.txt
    ;;
  "KMEANS_omp")
    OMP_NUM_THREADS=8 ./KMEANS_omp $test 32 100 0.001 0.001 result.txt
    ;;
  "KMEANS_cuda")
    ./KMEANS_cuda $test 32 100 0.001 0.001 result.txt
    ;;
  *)
    echo "Invalid execute file"
    ;;
esac

# check for correctness
python3 scripts/check.py

# valgrind --tool=cachegrind --I1=32768,8,64 --D1=32768,8,64 --LL=8388608,16,64 --cache-sim=yes 