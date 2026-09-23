/* SPDX-License-Identifier: MPL-2.0
 * Direct C ABI acceptance driver, Linux/POSIX host. Links the real shared
 * library. Burble's integration suite starts and observes the real endpoint.
 * No bearer values are printed or persisted.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <errno.h>
#include <string.h>

extern uint64_t gossamer_groove_connect_session(uint32_t, int, uint32_t);
extern int gossamer_groove_disconnect_session(uint64_t);
extern int gossamer_groove_heartbeat(uint64_t);
extern int gossamer_groove_session_adopt(uint64_t, uint64_t);
extern size_t gossamer_groove_audit_summary(unsigned char *, size_t);
extern const char *gossamer_last_error(void);

static void check(int ok, const char *message) {
    if (!ok) {
        const char *error = gossamer_last_error();
        fprintf(stderr, "%s: %s\n", message, error ? error : "no native error");
        exit(1);
    }
}
static uint64_t connect_session(int mode, unsigned ttl) {
    uint64_t handle = gossamer_groove_connect_session(0, mode, ttl);
    check(handle != 0, "connect returned no handle");
    return handle;
}
static void pause_ms(long ms) {
    struct timespec delay = { .tv_sec = ms / 1000, .tv_nsec = (ms % 1000) * 1000000 };
    while (nanosleep(&delay, &delay) != 0) check(errno == EINTR, "nanosleep failed");
}
int main(void) {
    uint64_t hard = connect_session(0, 1);
    check(gossamer_groove_heartbeat(hard) == 0, "hard heartbeat");
    check(gossamer_groove_heartbeat(hard ^ (UINT64_C(1) << 60)) != 0, "forged local handle accepted");
    check(gossamer_groove_heartbeat(hard) == 0, "forgery affected live session");
    check(gossamer_groove_disconnect_session(hard) == 0, "hard disconnect");
    check(gossamer_groove_disconnect_session(hard) == 5, "second disconnect not consumed");
    puts("hard: negotiated, renewed, forged local token rejected, consumed once");

    uint64_t soft = connect_session(1, 1);
    check(gossamer_groove_heartbeat(soft) != 0, "soft renewal accepted");
    pause_ms(1100);
    check(gossamer_groove_heartbeat(soft) != 0, "expired soft lease revived");
    check(gossamer_groove_disconnect_session(soft) == 0, "local soft cleanup");
    check(gossamer_groove_heartbeat(soft) == 5, "stale soft handle accepted");
    puts("soft: renewal refused, remote expiry, explicit local cleanup, stale token rejected");

    uint64_t lost = connect_session(0, 1);
    pause_ms(3100);
    check(gossamer_groove_heartbeat(lost) != 0, "expired hard lease revived");
    check(gossamer_groove_disconnect_session(lost) == 0, "local hard expiry cleanup");
    puts("hard loss: three TTLs elapsed, renewal rejected, explicit local cleanup");

    uint64_t parent = connect_session(0, 5);
    uint64_t child = connect_session(1, 5);
    check(gossamer_groove_session_adopt(parent, child) == 0, "adoption");
    check(gossamer_groove_session_adopt(child, parent) != 0, "ownership cycle accepted");
    check(gossamer_groove_disconnect_session(parent) == 0, "parent teardown");
    check(gossamer_groove_disconnect_session(child) == 5, "owned child not consumed");
    unsigned char audit[4096];
    size_t length = gossamer_groove_audit_summary(audit, sizeof audit - 1);
    check(length > 0 && length < sizeof audit, "audit missing");
    audit[length] = 0;
    char *child_release = strstr((char *)audit, "released slot 1 (parent slot 0)");
    check(child_release != NULL && strstr(child_release, "released slot 0 (root)") != NULL,
          "teardown not children-first");
    fwrite(audit, 1, length, stdout);
    puts("PASS native lifecycle pairing (not a live voice/Bebop capability capture)");
    return 0;
}
