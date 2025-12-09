#include <stdio.h>
#include <stdlib.h>
#include <signal.h>
#include <unistd.h>

static volatile sig_atomic_t ready_to_crash = 0;

static void handle_usr1(int sig) {
    (void)sig;  // unused
    ready_to_crash = 1;
}

int main(void) {
    struct sigaction sa;

    sa.sa_handler = handle_usr1;
    sigemptyset(&sa.sa_mask);
    sa.sa_flags = 0;

    if (sigaction(SIGUSR1, &sa, NULL) == -1) {
        perror("sigaction");
        return EXIT_FAILURE;
    }

    printf("crashme waiting for SIGUSR1, pid=%d\n", getpid());
    fflush(stdout);

    while (!ready_to_crash) {
        pause();
    }

    int *p = NULL;
    printf("About to segfault\n");
    fflush(stdout);

    *p = 42;  // deliberate segfault

    return 0;
}
