#include <stdio.h>
#include <unistd.h>

int main(int argc, char **argv) {
    if (argc != 3) {
        printf("Usage: %s <un> <gn>\n", argv[0]);
        return(1);
    }
    char* un = argv[1]; char* gn = argv[2];
    char* spec = \
        "chown %s:%s /var/run/docker.sock;" \
        "/usr/sbin/usermod -aG docker %s;";
    char cmd[255];
    sprintf(cmd, spec, un, gn, un);
    setuid(0);
    return(execle("/bin/bash", "bash", "-c", cmd, (char*)NULL, (char*)NULL));
}
