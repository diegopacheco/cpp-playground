#include <iostream>
#include <sys/epoll.h>
#include <unistd.h>

int main() {
    int epoll_fd = epoll_create1(0);
    if (epoll_fd == -1) {
        std::cerr << "Failed to create epoll file descriptor" << std::endl;
        return 1;
    }

    int fd = 0;
    struct epoll_event event;
    event.events = EPOLLIN; // Monitor for input events
    event.data.fd = fd;

    if (epoll_ctl(epoll_fd, EPOLL_CTL_ADD, fd, &event) == -1) {
        std::cerr << "Failed to add file descriptor to epoll" << std::endl;
        close(epoll_fd);
        return 1;
    }
    std::cout << "Waiting for input on stdin (press Enter to trigger event)..." << std::endl;

    struct epoll_event events[1];
    int num_events = epoll_wait(epoll_fd, events, 1, -1);
    if (num_events == -1) {
        std::cerr << "Error during epoll_wait" << std::endl;
        close(epoll_fd);
        return 1;
    }

    std::cout << "Event triggered on file descriptor: " << events[0].data.fd << std::endl;
    close(epoll_fd);
    return 0;
}