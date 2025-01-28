#!/bin/bash

N=90

for ((i=0; i<N; i++))
do
    #sequential
    ./scripts/run.sh KMEANS_seq "custom_tests/20D/input6.inp" | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/Sequential/20Dinput6.inp"
    ./scripts/run.sh KMEANS_seq "custom_tests/50D/input6.inp" | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/Sequential/50Dinput6.inp"
    ./scripts/run.sh KMEANS_seq "custom_tests/100D/input6.inp" | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/Sequential/100Dinput6.inp"

    #mpi+omp parallel dimensioni
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/2D/input6.inp" 4 16 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/2Dinput6_4_16.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/10D/input6.inp" 4 16 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/10Dinput6_4_16.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/20D/input6.inp" 4 16 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/20Dinput6_4_16.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/50D/input6.inp" 4 16 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/50Dinput6_4_16.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/100D/input6.inp" 4 16 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/100Dinput6_4_16.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input6.inp" 4 16 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput6_4_16.inp"

    #mpi+omp parallel punti
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input1.inp" 4 16 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput1_4_16.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input2.inp" 4 16 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput2_4_16.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input3.inp" 4 16 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput3_4_16.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input4.inp" 4 16 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput4_4_16.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input5.inp" 4 16 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput5_4_16.inp"

    #mpi+omp parallel scaling
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input6.inp" 1 1 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput6_1_1.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input6.inp" 1 2 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput6_1_2.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input6.inp" 1 4 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput6_1_4.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input6.inp" 1 8 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput6_1_8.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input6.inp" 1 16 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput6_1_16.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input6.inp" 2 16 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput6_2_16.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input6.inp" 8 8 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput6_8_8.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input6.inp" 4 4 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput6_4_4.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input6.inp" 2 2 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput6_2_2.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input6.inp" 2 8 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput6_2_8.inp"
    ./scripts/run.sh KMEANS_mpi+omp "custom_tests/200D/input6.inp" 4 8 | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> "result_tests/MPI+OMP/200Dinput6_4_8.inp"

done
