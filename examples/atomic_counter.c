#include <omp.h>
#include <stdio.h>
#include <stdlib.h>

int main(void) {
    int expected = omp_get_max_threads();
    int count = 0;
    #pragma omp parallel
    {
        #pragma omp atomic
        count++;
    }
    printf("expected=%d actual=%d\n", expected, count);
    return count != expected;
}
