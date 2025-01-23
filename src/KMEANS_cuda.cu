/*
 * k-Means clustering algorithm
 *
 * CUDA version
 *
 * Parallel computing (Degree in Computer Engineering)
 * 2022/2023
 *
 * Version: 1.0
 *
 * (c) 2022 Diego García-Álvarez, Arturo Gonzalez-Escribano
 * Grupo Trasgo, Universidad de Valladolid (Spain)
 *
 * This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License.
 * https://creativecommons.org/licenses/by-sa/4.0/
 */
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <math.h>
#include <time.h>
#include <string.h>
#include <float.h>
#include <cuda.h>

#define MAXLINE 2000
#define MAXCAD 200

// Macros
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#define MAX(a, b) ((a) > (b) ? (a) : (b))

/*
 * Macros to show errors when calling a CUDA library function,
 * or after launching a kernel
 */
#define CHECK_CUDA_CALL(a)                                                                            \
	{                                                                                                 \
		cudaError_t ok = a;                                                                           \
		if (ok != cudaSuccess)                                                                        \
			fprintf(stderr, "-- Error CUDA call in line %d: %s\n", __LINE__, cudaGetErrorString(ok)); \
	}
#define CHECK_CUDA_LAST()                                                                             \
	{                                                                                                 \
		cudaError_t ok = cudaGetLastError();                                                          \
		if (ok != cudaSuccess)                                                                        \
			fprintf(stderr, "-- Error CUDA last in line %d: %s\n", __LINE__, cudaGetErrorString(ok)); \
	}

/*
Function showFileError: It displays the corresponding error during file reading.
*/
void showFileError(int error, char *filename)
{
	printf("Error\n");
	switch (error)
	{
	case -1:
		fprintf(stderr, "\tFile %s has too many columns.\n", filename);
		fprintf(stderr, "\tThe maximum number of columns has been exceeded. MAXLINE: %d.\n", MAXLINE);
		break;
	case -2:
		fprintf(stderr, "Error reading file: %s.\n", filename);
		break;
	case -3:
		fprintf(stderr, "Error writing file: %s.\n", filename);
		break;
	}
	fflush(stderr);
}

/*
Function readInput: It reads the file to determine the number of rows and columns.
*/
int readInput(char *filename, int *lines, int *samples)
{
	FILE *fp;
	char line[MAXLINE] = "";
	char *ptr;
	const char *delim = "\t";
	int contlines, contsamples = 0;

	contlines = 0;

	if ((fp = fopen(filename, "r")) != NULL)
	{
		while (fgets(line, MAXLINE, fp) != NULL)
		{
			if (strchr(line, '\n') == NULL)
			{
				return -1;
			}
			contlines++;
			ptr = strtok(line, delim);
			contsamples = 0;
			while (ptr != NULL)
			{
				contsamples++;
				ptr = strtok(NULL, delim);
			}
		}
		fclose(fp);
		*lines = contlines;
		*samples = contsamples;
		return 0;
	}
	else
	{
		return -2;
	}
}

/*
Function readInput2: It loads data from file.
*/
int readInput2(char *filename, float *data)
{
	FILE *fp;
	char line[MAXLINE] = "";
	char *ptr;
	const char *delim = "\t";
	int i = 0;

	if ((fp = fopen(filename, "rt")) != NULL)
	{
		while (fgets(line, MAXLINE, fp) != NULL)
		{
			ptr = strtok(line, delim);
			while (ptr != NULL)
			{
				data[i] = atof(ptr);
				i++;
				ptr = strtok(NULL, delim);
			}
		}
		fclose(fp);
		return 0;
	}
	else
	{
		return -2; // No file found
	}
}

/*
Function writeResult: It writes in the output file the cluster of each sample (point).
*/
int writeResult(int *classMap, int lines, const char *filename)
{
	FILE *fp;

	if ((fp = fopen(filename, "wt")) != NULL)
	{
		for (int i = 0; i < lines; i++)
		{
			fprintf(fp, "%d\n", classMap[i]);
		}
		fclose(fp);

		return 0;
	}
	else
	{
		return -3; // No file found
	}
}

/*

Function initCentroids: This function copies the values of the initial centroids, using their
position in the input data structure as a reference map.
*/
void initCentroids(const float *data, float *centroids, int *centroidPos, int samples, int K)
{
	int i;
	int idx;
	for (i = 0; i < K; i++)
	{
		idx = centroidPos[i];
		memcpy(&centroids[i * samples], &data[idx * samples], (samples * sizeof(float)));
	}
}

/*
Function euclideanDistance: Euclidean distance
This function could be modified
*/
__device__ float euclideanDistance(float *point, float *center, int samples)
{
	float dist = 0.0;
	for (int i = 0; i < samples; i++)
	{
		dist += (point[i] - center[i]) * (point[i] - center[i]);
	}
	dist = sqrt(dist);
	return (dist);
}

/*
Function zeroFloatMatriz: Set matrix elements to 0
This function could be modified
*/
void zeroFloatMatriz(float *matrix, int rows, int columns)
{
	int i, j;
	for (i = 0; i < rows; i++)
		for (j = 0; j < columns; j++)
			matrix[i * columns + j] = 0.0;
}

/*
Function zeroIntArray: Set array elements to 0
This function could be modified
*/
void zeroIntArray(int *array, int size)
{
	int i;
	for (i = 0; i < size; i++)
		array[i] = 0;
}

// KERNEL FUNCTION
__global__ void assignPointsToCentroids(float *data, float *centroids, int *classMap, float *auxCentroids, int *pointsPerClass, int lines, int samples, int K, int *changes)
{
	extern __shared__ float sharedMemory[]; // Shared memory declaration

	// Pointers for shared memory
	float *sharedCentroids = sharedMemory;

	int tid = threadIdx.x;
	int idx = blockIdx.x * blockDim.x + threadIdx.x;

	// Load centroids into shared memory
	for (int i = tid; i < K * samples; i += blockDim.x)
	{
		sharedCentroids[i] = centroids[i];
	}
	__syncthreads(); // Ensure all threads have loaded centroids

	if (idx < lines)
	{

		// Calculate the closest centroid
		int cluster = 1;
		float minDist = FLT_MAX;

		for (int j = 0; j < K; j++)
		{
			float dist = euclideanDistance(&data[idx * samples], &sharedCentroids[j * samples], samples);
			if (dist < minDist)
			{
				minDist = dist;
				cluster = j + 1;
			}
		}

		if (classMap[idx] != cluster)
		{
			atomicAdd(changes, 1);
		}

		classMap[idx] = cluster;
		cluster--;
		atomicAdd(&pointsPerClass[cluster], 1);
		for (int j = 0; j < samples; j++)
		{
			atomicAdd(&auxCentroids[cluster * samples + j], data[idx * samples + j]);
		}
	}
}

__global__ void normalizeCentroids(float *centroids, float *auxCentroids, float *distCentroids, int *pointsPerClass, int samples, int K)
{
	int idx = blockIdx.x * blockDim.x + threadIdx.x;

	if (idx < K * samples)
	{
		int cluster = idx / samples;
		auxCentroids[idx] /= pointsPerClass[cluster];
	}

	if (idx < K)
	{
		distCentroids[idx] = euclideanDistance(&centroids[idx * samples], &auxCentroids[idx * samples], samples);
	}
}

int main(int argc, char *argv[])
{

	// START CLOCK***************************************
	clock_t start, end;
	start = clock();
	//**************************************************
	/*
	 * PARAMETERS
	 *
	 * argv[1]: Input data file
	 * argv[2]: Number of clusters
	 * argv[3]: Maximum number of iterations of the method. Algorithm termination condition.
	 * argv[4]: Minimum percentage of class changes. Algorithm termination condition.
	 *          If between one iteration and the next, the percentage of class changes is less than
	 *          this percentage, the algorithm stops.
	 * argv[5]: Precision in the centroid distance after the update.
	 *          It is an algorithm termination condition. If between one iteration of the algorithm
	 *          and the next, the maximum distance between centroids is less than this precision, the
	 *          algorithm stops.
	 * argv[6]: Output file. Class assigned to each point of the input file.
	 * */
	if (argc != 7)
	{
		fprintf(stderr, "EXECUTION ERROR K-MEANS: Parameters are not correct.\n");
		fprintf(stderr, "./KMEANS [Input Filename] [Number of clusters] [Number of iterations] [Number of changes] [Threshold] [Output data file]\n");
		fflush(stderr);
		exit(-1);
	}

	// Reading the input data
	// lines = number of points; samples = number of dimensions per point
	int lines = 0, samples = 0;

	int error = readInput(argv[1], &lines, &samples);
	if (error != 0)
	{
		showFileError(error, argv[1]);
		exit(error);
	}

	float *data = (float *)calloc(lines * samples, sizeof(float));
	if (data == NULL)
	{
		fprintf(stderr, "Memory allocation error.\n");
		exit(-4);
	}
	error = readInput2(argv[1], data);
	if (error != 0)
	{
		showFileError(error, argv[1]);
		exit(error);
	}

	// Parameters
	int K = atoi(argv[2]);
	int maxIterations = atoi(argv[3]);
	int minChanges = (int)(lines * atof(argv[4]) / 100.0);
	float maxThreshold = atof(argv[5]);

	int *centroidPos = (int *)calloc(K, sizeof(int));
	float *centroids = (float *)calloc(K * samples, sizeof(float));
	int *classMap = (int *)calloc(lines, sizeof(int));

	if (centroidPos == NULL || centroids == NULL || classMap == NULL)
	{
		fprintf(stderr, "Memory allocation error.\n");
		exit(-4);
	}

	// Initial centrodis
	srand(0);
	int i;
	for (i = 0; i < K; i++)
		centroidPos[i] = rand() % lines;

	// Loading the array of initial centroids with the data from the array data
	// The centroids are points stored in the data array.
	initCentroids(data, centroids, centroidPos, samples, K);

	printf("\n\tData file: %s \n\tPoints: %d\n\tDimensions: %d\n", argv[1], lines, samples);
	printf("\tNumber of clusters: %d\n", K);
	printf("\tMaximum number of iterations: %d\n", maxIterations);
	printf("\tMinimum number of changes: %d [%g%% of %d points]\n", minChanges, atof(argv[4]), lines);
	printf("\tMaximum centroid precision: %f\n", maxThreshold);

	// END CLOCK*****************************************
	end = clock();
	double elapsed = (double)(end - start) / CLOCKS_PER_SEC;
	printf("\nMemory allocation: %f seconds\n", elapsed);
	fflush(stdout);

	CHECK_CUDA_CALL(cudaSetDevice(0));
	CHECK_CUDA_CALL(cudaDeviceSynchronize());
	//**************************************************
	// START CLOCK***************************************
	start = clock();
	//**************************************************
	char *outputMsg = (char *)calloc(10000, sizeof(char));
	char line[100];

	int it = 0;
	int changes = 0;
	float maxDist;

	// pointPerClass: number of points classified in each class
	// auxCentroids: mean of the points in each class
	int *pointsPerClass = (int *)malloc(K * sizeof(int));
	float *auxCentroids = (float *)malloc(K * samples * sizeof(float));
	float *distCentroids = (float *)malloc(K * sizeof(float));
	if (pointsPerClass == NULL || auxCentroids == NULL || distCentroids == NULL)
	{
		fprintf(stderr, "Memory allocation error.\n");
		exit(-4);
	}

	/*
	 *
	 * START HERE: DO NOT CHANGE THE CODE ABOVE THIS POINT
	 *
	 */

	int *changes_d;
	float *data_d, *centroids_d, *auxCentroids_d, *distCentroids_d;
	int *classMap_d, *pointsPerClass_d;

	// Allocate device memory
	CHECK_CUDA_CALL(cudaMalloc((void **)&data_d, lines * samples * sizeof(float)));
	CHECK_CUDA_CALL(cudaMalloc((void **)&centroids_d, K * samples * sizeof(float)));
	CHECK_CUDA_CALL(cudaMalloc((void **)&classMap_d, lines * sizeof(int)));
	CHECK_CUDA_CALL(cudaMalloc((void **)&pointsPerClass_d, K * sizeof(int)));
	CHECK_CUDA_CALL(cudaMalloc((void **)&auxCentroids_d, K * samples * sizeof(float)));
	CHECK_CUDA_CALL(cudaMalloc((void **)&distCentroids_d, K * sizeof(float)));
	CHECK_CUDA_CALL(cudaMalloc((void **)&changes_d, sizeof(int)));

	// Copy memory from host to device
	CHECK_CUDA_CALL(cudaMemcpy(data_d, data, lines * samples * sizeof(float), cudaMemcpyHostToDevice));
	CHECK_CUDA_CALL(cudaMemcpy(centroids_d, centroids, K * samples * sizeof(float), cudaMemcpyHostToDevice));
	CHECK_CUDA_CALL(cudaMemcpy(classMap_d, classMap, lines * sizeof(int), cudaMemcpyHostToDevice));
	CHECK_CUDA_CALL(cudaMemcpy(pointsPerClass_d, pointsPerClass, K * sizeof(int), cudaMemcpyHostToDevice));
	CHECK_CUDA_CALL(cudaMemcpy(auxCentroids_d, auxCentroids, K * samples * sizeof(float), cudaMemcpyHostToDevice));
	CHECK_CUDA_CALL(cudaMemcpy(distCentroids_d, distCentroids, K * sizeof(float), cudaMemcpyHostToDevice));

	do
	{
		it++;

		// Reset changes on device
		cudaMemset(changes_d, 0, sizeof(int));
		cudaMemset(pointsPerClass_d, 0, K * sizeof(int));
		cudaMemset(auxCentroids_d, 0, K * samples * sizeof(float));

		// 1. Calculate the distance from each point to the centroid and assign to nearest centroid
		int blockSize = 32;
		int gridSize = (lines + blockSize - 1) / blockSize;
		int sharedMemorySize = (K * samples) * sizeof(float);
		assignPointsToCentroids<<<gridSize, blockSize, sharedMemorySize>>>(data_d, centroids_d, classMap_d, auxCentroids_d, pointsPerClass_d, lines, samples, K, changes_d);

		// Copy the number of changes back to host
		cudaMemcpy(&changes, changes_d, sizeof(int), cudaMemcpyDeviceToHost);

		// Normalize centroids
		gridSize = (K * samples + blockSize - 1) / blockSize;
		normalizeCentroids<<<gridSize, blockSize, 2>>>(centroids_d, auxCentroids_d, distCentroids_d, pointsPerClass_d, samples, K);

		// 3. Calculate maximum distance moved by centroids
		// gridSize = (K + blockSize - 1) / blockSize;
		// computeCentroidMovement<<<gridSize, blockSize, 2>>>(centroids_d, auxCentroids_d, distCentroids_d, samples, K);

		// Copy maxDist to host
		CHECK_CUDA_CALL(cudaMemcpy(distCentroids, distCentroids_d, K * sizeof(float), cudaMemcpyDeviceToHost));
		maxDist = distCentroids[0];
		for (int i = 1; i < K; i++)
		{
			maxDist = MAX(maxDist, distCentroids[i]);
		}

		// Update centroids for next iteration
		CHECK_CUDA_CALL(cudaMemcpy(centroids_d, auxCentroids_d, K * samples * sizeof(float), cudaMemcpyDeviceToDevice));

		sprintf(line, "\n[%d] Cluster changes: %d\tMax. centroid distance: %f", it, changes, maxDist);
		outputMsg = strcat(outputMsg, line);

	} while ((changes > minChanges) && (it < maxIterations) && (maxDist > maxThreshold));

	/*
	 *
	 * STOP HERE: DO NOT CHANGE THE CODE BELOW THIS POINT
	 *
	 */
	// Output and termination conditions
	printf("%s", outputMsg);

	CHECK_CUDA_CALL(cudaDeviceSynchronize());

	// END CLOCK*****************************************
	end = clock();
	elapsed = (double)(end - start) / CLOCKS_PER_SEC;
	printf("\nComputation: %f seconds", elapsed);
	fflush(stdout);
	//**************************************************
	// START CLOCK***************************************
	start = clock();
	//**************************************************

	if (changes <= minChanges)
	{
		printf("\n\nTermination condition:\nMinimum number of changes reached: %d [%d]", changes, minChanges);
	}
	else if (it >= maxIterations)
	{
		printf("\n\nTermination condition:\nMaximum number of iterations reached: %d [%d]", it, maxIterations);
	}
	else
	{
		printf("\n\nTermination condition:\nCentroid update precision reached: %g [%g]", maxDist, maxThreshold);
	}

	// Writing the classification of each point to the output file.
	error = writeResult(classMap, lines, argv[6]);
	if (error != 0)
	{
		showFileError(error, argv[6]);
		exit(error);
	}

	// Free device memory
	CHECK_CUDA_CALL(cudaFree(data_d));
	CHECK_CUDA_CALL(cudaFree(centroids_d));
	CHECK_CUDA_CALL(cudaFree(classMap_d));
	CHECK_CUDA_CALL(cudaFree(pointsPerClass_d));
	CHECK_CUDA_CALL(cudaFree(auxCentroids_d));
	CHECK_CUDA_CALL(cudaFree(distCentroids_d));
	CHECK_CUDA_CALL(cudaFree(changes_d));

	// Free host memory
	free(data);
	free(classMap);
	free(centroidPos);
	free(centroids);
	free(distCentroids);
	free(pointsPerClass);
	free(auxCentroids);

	// END CLOCK*****************************************
	end = clock();
	elapsed = (double)(end - start) / CLOCKS_PER_SEC;
	printf("\n\nMemory deallocation: %f seconds\n", elapsed);
	fflush(stdout);
	//***************************************************/
	return 0;
}
