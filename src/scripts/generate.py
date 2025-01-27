import random

def generate_random_file(filename, num_lines, num_dimensions):
    with open(filename, 'w') as file:
        for _ in range(num_lines):
            line = '\t'.join(str(random.randint(-1000, 1000)) for _ in range(num_dimensions))  # generate random values
            file.write(line + '\n') 

filename = "../custom_tests/200D/input1.inp"
num_lines = 100  
num_dimensions = 200  
generate_random_file(filename, num_lines, num_dimensions)

filename = "../custom_tests/200D/input2.inp"
num_lines = 1000  
num_dimensions = 200  
generate_random_file(filename, num_lines, num_dimensions)

filename = "../custom_tests/200D/input3.inp"
num_lines = 5000  
num_dimensions = 200  
generate_random_file(filename, num_lines, num_dimensions)

filename = "../custom_tests/200D/input4.inp"
num_lines = 10000  
num_dimensions = 200  
generate_random_file(filename, num_lines, num_dimensions)

filename = "../custom_tests/200D/input5.inp"
num_lines = 50000  
num_dimensions = 200  
generate_random_file(filename, num_lines, num_dimensions)

filename = "../custom_tests/200D/input6.inp"
num_lines = 100000  
num_dimensions = 200  
generate_random_file(filename, num_lines, num_dimensions)