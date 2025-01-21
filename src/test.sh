exe="$1" 
output_file="test_output.txt"
test1="custom_tests/2D/input6.inp" 
test2="custom_tests/10D/input6.inp" 
test3="custom_tests/20D/input6.inp" 
test4="custom_tests/50D/input6.inp" 
test5="custom_tests/100D/input6.inp" 
test6="custom_tests/200D/input6.inp" 

N=1

# truncate the output file
> $output_file

for ((i=0; i<N; i++))
do
    # execute the tests
    echo $test1 >> $output_file
    ./run.sh $exe $test1 | grep "Computation" >> $output_file
    echo >> $output_file

    echo $test2 >> $output_file
    ./run.sh $exe $test2 | grep "Computation" >> $output_file
    echo >> $output_file

    echo $test3 >> $output_file
    ./run.sh $exe $test3 | grep "Computation" >> $output_file
    echo >> $output_file

    echo $test4 >> $output_file
    ./run.sh $exe $test4 | grep "Computation" >> $output_file
    echo >> $output_file

    echo $test5 >> $output_file
    ./run.sh $exe $test5 | grep "Computation" >> $output_file
    echo >> $output_file

    echo $test6 >> $output_file
    ./run.sh $exe $test6 | grep "Computation" >> $output_file
    echo >> $output_file

done
# plot the results
python3 plot.py