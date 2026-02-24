#include <omp.h>
#include <stdio.h>

int main(void) {
    printf("max_threads=%d\n", omp_get_max_threads());
    printf("num_procs=%d\n", omp_get_num_procs());
    return omp_get_num_procs() < 1;
}
