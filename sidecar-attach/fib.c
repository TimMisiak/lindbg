#include <stdio.h>
#include <unistd.h>

long long fibonacci(int n) {
    if (n <= 1) {
        usleep(100000);  // sleep 100 ms
        return n;
    }
    return fibonacci(n - 1) + fibonacci(n - 2);
}

int main() {
    int n;
    printf("Enter n: ");
    scanf("%d", &n);

    while (1) {
        long long result = fibonacci(n);
        printf("Fibonacci(%d) = %lld\n", n, result);
    }

    return 0;
}
