/* SPDX-License-Identifier: MPL-2.0
 * Real native ABI driver. Test inputs are emitted by Burble's OWN encoder.
 * JWTs travel only in the environment and native HTTP headers, never stdout.
 */
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <errno.h>
#include <gossamer_voice.h>

static void check(int ok, const char *what) {
    if (!ok) { fprintf(stderr, "FAIL voice: %s\n", what); exit(1); }
}
static const char *required(const char *name) {
    const char *value = getenv(name);
    check(value != NULL && *value, "missing test environment");
    return value;
}
static size_t unhex(const char *name, unsigned char *out) {
    const char *hex = required(name);
    size_t n = strlen(hex);
    check(n % 2 == 0 && n / 2 <= 16384, "invalid frame fixture length");
    for (size_t i = 0; i < n / 2; i++) {
        unsigned v;
        check(sscanf(hex + i * 2, "%2x", &v) == 1, "invalid fixture hex");
        out[i] = (unsigned char)v;
    }
    return n / 2;
}
static void pause_ms(long ms) {
    struct timespec t = { .tv_sec = ms / 1000, .tv_nsec = (ms % 1000) * 1000000 };
    while (nanosleep(&t, &t) != 0) check(errno == EINTR, "sleep failed");
}
static uint64_t connect_voice(int mode, unsigned ttl, const char *token) {
    const char *room = required("VOICE_ROOM");
    return gossamer_groove_voice_connect(0, mode, ttl,
        (const unsigned char *)token, strlen(token),
        (const unsigned char *)room, strlen(room),
        (const unsigned char *)"alice", 5, (const unsigned char *)"bob", 3);
}
static void receive_expected(uint64_t h, const unsigned char *expected, size_t expected_len, const char *label) {
    unsigned char out[16384];
    int32_t n = 0;
    for (int attempt = 0; attempt < 60 && n == 0; attempt++) {
        n = gossamer_groove_voice_recv(h, out, sizeof out);
        check(n >= 0, "native receive rejected");
        if (n == 0) pause_ms(20);
    }
    check(n > 0 && (size_t)n == expected_len && memcmp(out, expected, expected_len) == 0,
          "native decoder/output did not match Burble's encoded peer response");
    printf("%s=", label);
    for (int32_t i = 0; i < n; i++) printf("%02x", out[i]);
    putchar('\n');
}
int main(void) {
    unsigned char offer[16384], answer[16384], ice[16384], peer_ice[16384], bad[16384];
    size_t offer_n = unhex("VOICE_OFFER", offer), answer_n = unhex("VOICE_ANSWER", answer);
    size_t ice_n = unhex("VOICE_ICE", ice), peer_ice_n = unhex("VOICE_PEER_ICE", peer_ice);
    size_t bad_n = unhex("VOICE_BAD_ROOM", bad);
    const char *token = required("VOICE_ALICE_TOKEN");
    check(connect_voice(0, 4, "invalid.token") == 0, "invalid identity accepted");
    check(connect_voice(0, 4, required("VOICE_REFRESH_TOKEN")) == 0, "refresh token accepted");
    for (int mode = 0; mode <= 1; mode++) {
        uint64_t h = connect_voice(mode, 4, token);
        check(h != 0, "valid scoped connect failed");
        check(gossamer_groove_voice_send(h, bad, bad_n) != 0, "cross-room frame accepted");
        check(gossamer_groove_voice_send(h, offer, offer_n - 1) != 0, "truncated frame accepted");
        check(gossamer_groove_voice_send(h ^ (UINT64_C(1) << 60), offer, offer_n) != 0, "forged handle accepted");
        check(gossamer_groove_voice_send(h, offer, offer_n) == 0, "valid SDP send failed");
        receive_expected(h, answer, answer_n, mode == 0 ? "hard_answer" : "soft_answer");
        check(gossamer_groove_voice_send(h, ice, ice_n) == 0, "valid ICE send failed");
        receive_expected(h, peer_ice, peer_ice_n, mode == 0 ? "hard_ice" : "soft_ice");
        check((gossamer_groove_heartbeat(h) == 0) == (mode == 0), "posture renewal rule failed");
        check(gossamer_groove_disconnect_session(h) == 0, "disconnect failed");
        check(gossamer_groove_voice_recv(h, answer, sizeof answer) < 0, "consumed handle received data");
    }
    uint64_t soft = connect_voice(1, 1, token);
    check(soft != 0, "expiry control connect failed");
    pause_ms(1100);
    gossamer_groove_voice_tick();
    check(gossamer_groove_disconnect_session(soft) == 5, "tick did not consume expired local lease");
    uint64_t hard = connect_voice(0, 1, token);
    check(hard != 0, "hard timer control connect failed");
    for (int i = 0; i < 6; i++) { pause_ms(600); gossamer_groove_voice_tick(); }
    check(gossamer_groove_heartbeat(hard) == 0, "host tick did not keep hard lease live beyond 3 TTLs");
    check(gossamer_groove_disconnect_session(hard) == 0, "timer control cleanup failed");
    puts("PASS native scoped voice + real WebSocket peer");
    return 0;
}
