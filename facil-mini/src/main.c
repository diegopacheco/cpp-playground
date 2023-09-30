#include "main.h"

int main(int argc, char const *argv[]) {
  initialize_cli(argc, argv);
  initialize_http_service();
  fio_start(.threads = fio_cli_get_i("-t"), .workers = fio_cli_get_i("-w"));
  free_cli();
  return 0;
}