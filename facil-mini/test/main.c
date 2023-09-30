#include <stdio.h>
#include <stdlib.h>

void gen_uuid(char buf[]);

int main(){
    char uuid[37] = {0};
    gen_uuid(uuid);

    printf("UUID generated:\n[");
    for (int i = 0; i < 36; i++){
        printf("%c", uuid[i]);
    }
    printf("]\n");
    return 0;
}

void gen_uuid(char buf[37]){
    char v[] = {'0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f'};
    for (int i = 0; i < 36; i++){
        buf[i] = v[rand() % 16];
    }
    buf[8] = '-';
    buf[13] = '-';
    buf[18] = '-';
    buf[23] = '-';
    buf[36] = '\0';
}