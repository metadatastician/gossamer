/* SPDX-License-Identifier: MPL-2.0 */
#ifndef GOSSAMER_VOICE_H
#define GOSSAMER_VOICE_H
#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

/* Session operations are internally serialized. These synchronous APIs still
 * perform network I/O; use the window-owned APIs below on a UI thread.
 * Buffer pointers must
 * address the stated lengths; connect copies credentials before returning.
 * mode: 0 hard, 1 soft; ttl_seconds: 1..3600. Existing JWT/room membership only.
 * Returns 0 on failure, otherwise an opaque generation-checked local handle.
 * The wire lease bearer is never exposed by this API. */
uint64_t gossamer_groove_voice_connect(uint32_t target_index, int mode,
    uint32_t ttl_seconds, const unsigned char *token, size_t token_len,
    const unsigned char *room, size_t room_len,
    const unsigned char *subject, size_t subject_len,
    const unsigned char *peer, size_t peer_len);

/* Full Bebop VoiceSignal, tags 9/10/11 only, <= 16384 bytes. No posture/rank
 * fields are introduced into this data plane. Returns Result (0 success). */
int gossamer_groove_voice_send(uint64_t handle,
    const unsigned char *bytes, size_t length);

/* Positive complete-frame length, 0 empty, -1 failure. A successful frame has
 * passed the production decoder and bound room/sender check. Caller owns out. */
int32_t gossamer_groove_voice_recv(uint64_t handle,
    unsigned char *out, size_t capacity);

/* Call at least twice per shortest TTL on the same serialized worker thread.
 * Renews hard leases and consumes expired soft/hard leases. This is not a
 * background scheduler. Each exchange may block for up to five seconds. */
void gossamer_groove_voice_tick(void);

/* Shared session operations accept voice handles too. Disconnect consumes the
 * local handle and owned children even if remote release fails; credentials
 * are wiped. Result 5 means already consumed. Only hard leases can renew. */
int gossamer_groove_disconnect_session(uint64_t handle);
int gossamer_groove_heartbeat(uint64_t handle);

/* WINDOW-OWNED API: invoke these only on the window's main thread, with a live
 * Gossamer window handle. One worker per window, 32 live workers process-wide.
 * No caller tick is needed. gossamer_run / gossamer_destroy cancel and join the
 * worker and consume its private lease. Do not use a window pointer after it
 * has been destroyed (same lifetime contract as the rest of the window API). */
int gossamer_window_voice_start(uint64_t window, int mode, uint32_t ttl_seconds,
    const unsigned char *token, size_t token_len,
    const unsigned char *room, size_t room_len,
    const unsigned char *subject, size_t subject_len,
    const unsigned char *peer, size_t peer_len);
/* 1 connecting, 2 active, 3 local soft expiry, 4 failed, 5 reserved/stopping, 6 stopped;
 * -1 means no attached worker. Transport failure is fail-closed; no reconnect. */
int gossamer_window_voice_status(uint64_t window);
/* send success means QUEUED, not delivered. The sent counter only advances
 * after provider acceptance. Four 16-KiB frames per direction. */
int gossamer_window_voice_send(uint64_t window, const unsigned char *bytes, size_t length);
uint64_t gossamer_window_voice_sent(uint64_t window);
int32_t gossamer_window_voice_recv(uint64_t window, unsigned char *out, size_t capacity);
/* Nonblocking cancellation request; final window cleanup joins the worker. */
int gossamer_window_voice_stop(uint64_t window);
uint32_t gossamer_voice_worker_count(void);

#ifdef __cplusplus
}
#endif
#endif
