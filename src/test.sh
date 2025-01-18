exe="$1" 
output_file="test_output.txt"
test1="input2D.inp" 
test2="input2D2.inp" 
test3="input10D.inp" 
test4="input20D.inp" 
test5="input100D.inp" 
test6="input100D2.inp" 

ctest1="custom.inp" 
ctest2="custom2.inp" 
ctest3="custom3.inp" 
ctest4="custom4.inp" 
ctest5="custom5.inp"
ctest6="custom6.inp" 

N=10

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

    #echo $test6 >> $output_file
    #./run.sh $exe $test6 | grep "Computation" >> $output_file
    #echo >> $output_file

    echo $ctest1 >> $output_file
    ./run.sh $exe $ctest1 | grep "Computation" >> $output_file
    echo >> $output_file

    echo $ctest2 >> $output_file
    ./run.sh $exe $ctest2 | grep "Computation" >> $output_file
    echo >> $output_file

    echo $ctest3 >> $output_file
    ./run.sh $exe $ctest3 | grep "Computation" >> $output_file
    echo >> $output_file

    echo $ctest4 >> $output_file
    ./run.sh $exe $ctest4 | grep "Computation" >> $output_file
    echo >> $output_file

    echo $ctest5 >> $output_file
    ./run.sh $exe $ctest5 | grep "Computation" >> $output_file
    echo >> $output_file

    echo $ctest6 >> $output_file
    ./run.sh $exe $ctest6 | grep "Computation" >> $output_file
    echo >> $output_file
done
# plot the results
python3 plot.py