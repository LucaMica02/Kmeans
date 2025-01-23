# take the argument
exe="$1" 
test="$2" 

# run both the sequential and parallel executable
echo "KMEANS_seq"
./KMEANS_seq $test 16 100 0.001 0.001 seq_result.txt 
echo -e "\n################################################\n$exe"
OMP_NUM_THREADS=2 mpiexec -n 4 ./$exe $test 16 100 0.001 0.001 result.txt
#mpiexec -n 4 ./$exe $test 16 100 0.001 0.001 result.txt
#./$exe test_files/$test 16 100 0.001 0.001 result.txt

# check for correctness
python3 check.py

# valgrind --tool=cachegrind --I1=32768,8,64 --D1=32768,8,64 --LL=8388608,16,64 --cache-sim=yes 