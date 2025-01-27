#!/bin/bash

# take the argument
input="$1" 
test="$2" 

# check if arguments are passed
if [ -z "$input" ]; then
  echo "The execute file must be specified"
  exit 1
fi

if [ -z "$test" ]; then
  echo "The test file must be specified"
  exit 1
fi

# execute the relative file
case "$1" in
  "KMEANS_seq")
    ./KMEANS_seq $test 32 100 0.001 0.001 seq_result.txt
    ;;
  "KMEANS_mpi+omp")
    OMP_NUM_THREADS=2 mpirun --bind-to none -n 4 ./KMEANS_mpi+omp $test 32 100 0.001 0.001 result.txt
    ;;
  "KMEANS_cuda")
    ./KMEANS_cuda $test 32 100 0.001 0.001 result.txt
    ;;
  *)
    echo "Invalid execute file"
    ;;
esac