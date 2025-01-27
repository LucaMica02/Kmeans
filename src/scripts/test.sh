#!/bin/bash

exe="$1" 
output_file="result_tests/Sequential/2Dinput6.inp"
test="custom_tests/2D/input6.inp" 

N=5

for ((i=0; i<N; i++))
do
    ./scripts/run.sh $exe $test | grep "Computation" | sed 's/.*Computation: \(.*\) seconds/\1/' >> $output_file
done