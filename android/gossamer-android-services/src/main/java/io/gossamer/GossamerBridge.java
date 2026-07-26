// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// gossamer-android-services: subclass-based shim base classes (issue #71).
//
package io.gossamer;

import android.webkit.JavascriptInterface;

/**
 * GossamerBridge — JavaScript interface exposed to the WebView.
 *
 * <p>{@code window.GossamerBridge.postMessage(json)} forwards the IPC message to
 * the native layer via {@link #nativePostMessage}, which dispatches to the bound
 * handler and replies through {@code window.__gossamer_callbacks} via
 * {@code evaluateJavascript()}.
 *
 * <p>{@code nativePostMessage} is an INSTANCE native method to match
 * {@code Java_io_gossamer_GossamerBridge_nativePostMessage} on the Zig side.
 */
public final class GossamerBridge {

    public native void nativePostMessage(String message);

    /**
     * Message shape: {@code {"id":"abc","name":"command","payload":"{...}"}}.
     * Null/empty messages are dropped before crossing the JNI boundary.
     */
    @JavascriptInterface
    public void postMessage(String message) {
        if (message == null || message.isEmpty()) {
            return;
        }
        nativePostMessage(message);
    }
}
