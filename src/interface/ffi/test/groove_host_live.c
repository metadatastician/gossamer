/* SPDX-License-Identifier: MPL-2.0
 * Actual GTK/Gossamer host lifecycle. No manual heartbeat or tick calls.
 * Runs protocol signaling against Burble; does NOT claim WebRTC media. */
#include <gtk/gtk.h>
#include <webkit2/webkit2.h>
#include <gossamer_voice.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

extern void *gossamer_create(const char *, uint32_t, uint32_t, uint8_t, uint8_t, uint8_t);
extern int gossamer_load_html(uint64_t, const char *);
extern void gossamer_run(uint64_t);
extern int gossamer_request_close(uint64_t);

static uint64_t window;
static GtkWindow *native_window;
static gint64 opened, started, activated;
static int phase, mode, ticks, test_case, host_started;
static unsigned lease_ttl;
static unsigned char offer[16384], answer[16384], ice[16384], peer_ice[16384], bad[16384];
static size_t offer_n, answer_n, ice_n, peer_ice_n, bad_n;

static void check(int ok, const char *message) {
    if (!ok) {
        fprintf(stderr, "FAIL GTK voice host: %s (case=%d ticks=%d elapsed_ms=%lld)\n",
            message, test_case, ticks, (long long)((g_get_monotonic_time() - started) / 1000));
        exit(1);
    }
}
static const char *required(const char *name) {
    const char *value = getenv(name);
    check(value != NULL && *value, "missing test environment");
    return value;
}
static size_t unhex(const char *name, unsigned char *out) {
    const char *text = required(name);
    size_t length = strlen(text);
    check(length % 2 == 0 && length / 2 <= 16384, "fixture length");
    for (size_t i = 0; i < length / 2; i++) {
        unsigned value;
        check(sscanf(text + i * 2, "%2x", &value) == 1, "fixture hex");
        out[i] = (unsigned char)value;
    }
    return length / 2;
}
static void native_close(void) {
    check(native_window != NULL && GTK_IS_WINDOW(native_window), "owned GTK window missing");
    gtk_window_close(native_window);
}
static void loaded(WebKitWebView *view, WebKitLoadEvent event, gpointer unused) {
    (void)view; (void)unused;
    if (event != WEBKIT_LOAD_FINISHED || host_started) return;
    const char *token = required("VOICE_ALICE_TOKEN"), *room = required("VOICE_ROOM");
    started = g_get_monotonic_time();
    printf("GTK initial document load_ms=%lld pre_host_ticks=%d\n",
        (long long)((started - opened) / 1000), ticks);
    check(gossamer_window_voice_start(window, mode, lease_ttl,
        (const unsigned char *)token, strlen(token), (const unsigned char *)room, strlen(room),
        (const unsigned char *)"alice", 5, (const unsigned char *)"bob", 3) == 0, "worker start failed");
    check(g_get_monotonic_time() - started < 200000, "worker start blocked the UI");
    host_started = 1;
    ticks = 0;
}
static gboolean tick(gpointer unused) {
    (void)unused;
    ticks++;
    gint64 now = g_get_monotonic_time();
    check(now - opened < 12000000, "window acceptance timed out");
    if (!host_started) return G_SOURCE_CONTINUE;
    int status = gossamer_window_voice_status(window);
    if (test_case == 2) {
        /* A real local TCP provider intentionally withholds its response. */
        if (now - started < 250000) return G_SOURCE_CONTINUE;
        check(status == 1, "stall control did not reach pending connect");
        check(ticks >= 10, "GTK timer starved while worker waited for HTTP");
        native_close();
        return G_SOURCE_REMOVE;
    }
    if (test_case == 3) {
        check(status != 3, "provider failure reported as clean soft expiry");
        if (status == 4) {
            check(now - started < 3000000, "provider failure waited for soft expiry");
            check(gossamer_request_close(window) == 0, "rupture close failed");
            return G_SOURCE_REMOVE;
        }
        check(status == 1 || status == 2, "unexpected rupture status");
        return G_SOURCE_CONTINUE;
    }
    if (test_case == 1) {
        if (status == 3) {
            check(ticks >= 20, "soft-expiry GUI did not stay responsive");
            check(gossamer_request_close(window) == 0, "soft close failed");
            return G_SOURCE_REMOVE;
        }
        check(status == 1 || status == 2, "soft host failed before expiry");
        return G_SOURCE_CONTINUE;
    }
    check(status == 1 || status == 2, "live worker failed");
    if (status != 2) return G_SOURCE_CONTINUE;
    if (phase == 0) {
        activated = now;
        check(gossamer_window_voice_send(window, bad, bad_n) != 0, "wrong-room enqueue accepted");
        check(gossamer_window_voice_send(window, offer, offer_n) == 0, "offer enqueue failed");
        phase = 1;
    }
    if (phase == 1 || phase == 2) {
        unsigned char out[16384];
        int32_t n = gossamer_window_voice_recv(window, out, sizeof out);
        check(n >= 0, "window receive failed");
        if (n > 0) {
            const unsigned char *expected = phase == 1 ? answer : peer_ice;
            size_t expected_n = phase == 1 ? answer_n : peer_ice_n;
            check((size_t)n == expected_n && memcmp(out, expected, expected_n) == 0,
                "worker/native decoder response differs from Burble encoder");
            if (phase == 1) check(gossamer_window_voice_send(window, ice, ice_n) == 0, "ICE enqueue failed");
            phase++;
        }
    }
    if (phase == 3 && (mode == 1 || now - activated >= 3600000)) {
        check(gossamer_window_voice_sent(window) == 2, "provider accepted-send counter differs");
        if (mode == 0) {
            check(ticks > 100, "GUI starved during automatic hard renewal");
            native_close(); /* real native close, not just explicit teardown */
        } else {
            check(gossamer_request_close(window) == 0, "soft explicit close failed");
        }
        return G_SOURCE_REMOVE;
    }
    return G_SOURCE_CONTINUE;
}
static void run_window(int which, int posture, unsigned ttl) {
    test_case = which; mode = posture; phase = 0; ticks = 0; activated = 0;
    lease_ttl = ttl; host_started = 0;
    char title[96];
    snprintf(title, sizeof title, "Gossamer voice-worker acceptance case=%d posture=%d", which, posture);
    window = (uint64_t)(uintptr_t)gossamer_create(title, 440, 160, 1, 1, 0);
    check(window != 0, "real GTK/Gossamer create failed");
    GList *windows = gtk_window_list_toplevels();
    native_window = NULL;
    for (GList *item = windows; item != NULL; item = item->next) {
        GtkWindow *candidate = GTK_WINDOW(item->data);
        if (g_strcmp0(gtk_window_get_title(candidate), title) != 0) continue;
        check(native_window == NULL, "ambiguous owned GTK window");
        native_window = candidate;
    }
    check(native_window != NULL, "owned GTK window missing before document load");
    GtkWidget *view = gtk_bin_get_child(GTK_BIN(native_window));
    check(WEBKIT_IS_WEB_VIEW(view), "expected actual WebKit view");
    g_signal_connect(view, "load-changed", G_CALLBACK(loaded), NULL);
    g_list_free(windows);
    opened = started = g_get_monotonic_time();
    check(gossamer_load_html(window, "<!doctype html><title>Voice worker acceptance</title><p>Native worker / GTK lifecycle test. No microphone or camera capture.</p>") == 0, "HTML load failed");
    g_timeout_add(10, tick, NULL);
    gossamer_run(window); /* closes and joins the actual owned worker */
    window = 0; native_window = NULL;
    check(gossamer_voice_worker_count() == 0, "window teardown left a live worker");
    if (which == 2) check(g_get_monotonic_time() - started < 1500000, "cancellation did not interrupt the five-second HTTP wait");
    printf("PASS GTK window case=%d posture=%d responsive_ticks=%d; owned worker joined\n", which, posture, ticks);
}
int main(int argc, char **argv) {
    if (argc > 1) {
        if (strcmp(argv[1], "stall") == 0) run_window(2, 0, 1);
        else if (strcmp(argv[1], "rupture") == 0) run_window(3, 1, 4);
        else check(0, "unknown fault case");
        return 0;
    }
    offer_n = unhex("VOICE_OFFER", offer); answer_n = unhex("VOICE_ANSWER", answer);
    ice_n = unhex("VOICE_ICE", ice); peer_ice_n = unhex("VOICE_PEER_ICE", peer_ice);
    bad_n = unhex("VOICE_BAD_ROOM", bad);
    run_window(0, 0, 1);
    run_window(0, 1, 4);
    run_window(1, 1, 1);
    puts("PASS window-owned signaling, automatic hard renewal, soft expiry and native close");
    return 0;
}
