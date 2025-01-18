import random

def generate_random_file(filename, num_lines, num_dimensions):
    with open(filename, 'w') as file:
        for _ in range(num_lines):
            line = '\t'.join(str(random.randint(-1000, 1000)) for _ in range(num_dimensions))  # generate random values
            file.write(line + '\n')  # write the line to the file

filename = "test_files/custom6.inp"  # You can specify any filename you want
num_lines = 1000  # Set the number of lines you want in the file
num_dimensions = 200  # Set the number of values per line (dimension)
generate_random_file(filename, num_lines, num_dimensions)