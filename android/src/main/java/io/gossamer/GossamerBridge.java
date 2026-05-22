// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

package io.gossamer;

import android.webkit.JavascriptInterface;

/**
 * GossamerBridge — JavaScript interface exposed to the WebView.
 *
 * When JavaScript calls `window.GossamerBridge.postMessage(msg)`,
 * the message is forwarded to the native Gossamer library via JNI.
 * The native side parses the JSON message, dispatches to the bound
 * callback, and sends the response back via evaluateJavascript().
 *
 * This class is registered via WebView.addJavascriptInterface() in
 * GossamerActivity.onCreate().
 */
public class GossamerBridge {

    // Native method implemented in webview_android.zig
    private static native void nativePostMessage(String message);

    /**
     * Called from JavaScript via the Gossamer IPC bridge.
     *
     * The message is a JSON string with the following structure:
     * {"id":"abc123","name":"command_name","payload":"{...}"}
     *
     * @param message JSON-encoded IPC message
     */
    @JavascriptInterface
    public void postMessage(String message) {
        if (message == null || message.isEmpty()) {
            return;
        }
        nativePostMessage(message);
    }
}
