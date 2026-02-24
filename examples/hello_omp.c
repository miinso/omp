#include <omp.h>
#include <stdio.h>

int main(void) {
    int n = 0;
    #pragma omp parallel
    {
        #pragma omp atomic
        n++;
    }
    printf("threads=%d\n", n);
    return n < 1;
}
