#include "lib/facil/http/http.h"

void on_request(http_s *request);
FIOBJ HTTP_HEADER_X_DATA;

int main(int argc, char const **argv) {
  HTTP_HEADER_X_DATA = fiobj_str_new("X-Data", 6);
  http_listen("3000", NULL, .on_request = on_request, .log = 1);
  fio_start(.threads = 1);
  fiobj_free(HTTP_HEADER_X_DATA);
  (void)argc; (void)argv;
}

void on_request(http_s *request) {
  char src[38], dest[40];
  strcpy(src, gen_uuid());
  strcpy(dest, "\r\n");
  strcat(dest, src);

  http_send_body(request, dest, 40);
}

char* gen_uuid() {
    char v[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
    static char buf[37] = {0};
    for(int i = 0; i < 36; ++i) {
        buf[i] = v[rand()%16];
    }
    buf[8] = '-';
    buf[13] = '-';
    buf[18] = '-';
    buf[23] = '-';
    buf[36] = '\0';
    return buf;
}