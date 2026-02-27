#include <benchmark/benchmark.h>
#include <omp.h>
#include <vector>
#include <algorithm>

static int max_threads() {
    return std::max(1, (int)(omp_get_num_procs() * 0.75));
}

// thread scaling: fixed data size, vary thread count 1..max
static void BM_ThreadScaling(benchmark::State& state) {
    const int N = 1000000;
    std::vector<double> data(N, 1.5);
    omp_set_num_threads(state.range(0));

    for (auto _ : state) {
        double sum = 0.0;
        #pragma omp parallel for reduction(+:sum)
        for (int i = 0; i < N; i++) sum += data[i] * data[i];
        benchmark::DoNotOptimize(sum);
    }
    state.SetLabel(std::to_string(state.range(0)) + "t");
}

// data scaling: fixed thread count (max), vary data size
static void BM_DataScaling(benchmark::State& state) {
    const int N = state.range(0);
    std::vector<double> data(N, 1.5);
    omp_set_num_threads(max_threads());

    for (auto _ : state) {
        double sum = 0.0;
        #pragma omp parallel for reduction(+:sum)
        for (int i = 0; i < N; i++) sum += data[i] * data[i];
        benchmark::DoNotOptimize(sum);
    }
}

// linear 1..8, then power-of-2 above
static void thread_args(benchmark::internal::Benchmark* b) {
    int mt = omp_get_num_procs();
    for (int t = 1; t <= std::min(mt, 8); t++) b->Arg(t);
    for (int t = 16; t <= mt; t *= 2) b->Arg(t);
    if (mt > 8 && (mt & (mt - 1)) != 0) b->Arg(mt);
}

BENCHMARK(BM_ThreadScaling)->Apply(thread_args);

BENCHMARK(BM_DataScaling)
    ->Arg(10000)
    ->Arg(100000)
    ->Arg(1000000)
    ->Arg(10000000);

BENCHMARK_MAIN();
