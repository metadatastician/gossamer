// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

package io.gossamer;

import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * GossamerActivity — Hosts a WebView and bridges to the native Gossamer library.
 *
 * This Activity creates a full-screen WebView and passes global JNI references
 * to the native layer via nativeInit(). The native library (libgossamer.so) is
 * loaded via System.loadLibrary in a static block.
 *
 * Subclass this and override getInitialUrl() or getInitialHtml() to provide
 * your application content.
 */
public class GossamerActivity extends Activity {

    private WebView webView;

    static {
        System.loadLibrary("gossamer");
    }

    // Native methods implemented in webview_android.zig
    private static native void nativeInit(Activity activity, WebView webview);
    private static native void nativeDestroy();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        webView = new WebView(this);
        setContentView(webView);

        // Configure WebView for Gossamer IPC
        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(false);  // Security: no file:// access
        settings.setAllowContentAccess(false);

        // Prevent WebView from opening external browser
        webView.setWebViewClient(new WebViewClient());

        // Register the GossamerBridge JavaScript interface
        GossamerBridge bridge = new GossamerBridge();
        webView.addJavascriptInterface(bridge, "GossamerBridge");

        // Pass global references to the native layer
        nativeInit(this, webView);

        // Load initial content
        String html = getInitialHtml();
        if (html != null) {
            webView.loadData(html, "text/html", "UTF-8");
        } else {
            String url = getInitialUrl();
            if (url != null) {
                webView.loadUrl(url);
            }
        }
    }

    @Override
    protected void onDestroy() {
        nativeDestroy();
        if (webView != null) {
            webView.removeJavascriptInterface("GossamerBridge");
            webView.destroy();
            webView = null;
        }
        super.onDestroy();
    }

    /**
     * Override to provide an initial URL to load.
     * Return null to use getInitialHtml() instead.
     */
    protected String getInitialUrl() {
        return null;
    }

    /**
     * Override to provide initial HTML content.
     * Return null if using getInitialUrl().
     */
    protected String getInitialHtml() {
        return "<html><body><h1>Gossamer</h1><p>Override getInitialHtml() or getInitialUrl().</p></body></html>";
    }
}
