# K-means Project

Project for the Parallel and Multicore Programming course, part of the Bachelor's degree in Computer Science at Sapienza University of Rome. This project focuses on optimizing the K-means clustering algorithm to improve performance and scalability.

## K-means overview
- Input: points with variable dimensions, number of clusters **K**, and thresholds.  
- Algorithm:  
  1. Randomly select K centroids.  
  2. Assign each point to the nearest centroid (Euclidean distance).  
  3. Update centroids as the mean of assigned points.  
  4. Repeat until convergence criteria (thresholds or max iterations).

The main loop has data dependencies between iterations, but parallelism is applied within each iteration across points and clusters.

## MPI + OpenMP Implementation

- Hybrid approach: master process handles I/O and distributes data; each process uses OpenMP threads for parallel loops.  
- MPI collectives (`scatterv`, `gatherv`, `allgatherv`, `allreduce`) manage data distribution and aggregation, handling uneven splits.  
- Optimizations include avoiding false sharing, binding processes properly (`--bind-to none`), and disabling nested parallelism.  
- Loop scheduling kept static after testing for simplicity and performance.  
- Timing measured by master with MPI barrier for synchronization.  
- Scalability: near-linear speedup up to 3-4 process/thread groups; weak scalability with problem size increase.

## CUDA Implementation

- Steps: allocate memory, copy data host→device, run kernels, copy results back.  
- Uses shared memory to cache centroids and reduce global memory access.  
- Atomic operations optimized by performing reductions in shared memory first.  
- Implements custom parallel reduction for max distance (atomicMax unsupported for floats).  
- Optimal block size found: 32 threads per block.  
- Disabled fused multiply-add (fmaf) on GPU to match CPU results.

## Testing & Performance

- Tested varying points and dimensions (e.g., points: 0.1k to 100k, dimensions: 2 to 200).  
- Each test averaged over ~100 runs.  
- MPI+OpenMP run on cluster with 16 processes × 4 threads; CUDA tested via batch jobs.  
- Results:  
  - MPI+OpenMP: ~27x speedup vs sequential.  
  - CUDA: ~77x speedup vs sequential.

*Note:* Custom test data not included due to size; can be generated via `generate.py`.

## Contact

For questions or details, reach me out at [https://www.linkedin.com/in/luca-micarelli-81877a19b/].
