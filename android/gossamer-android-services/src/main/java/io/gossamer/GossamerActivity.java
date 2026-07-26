// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// gossamer-android-services: subclass-based shim base classes (issue #71).
// Apps EXTEND this class with a handful of lines; the lifecycle is final and
// native delegation goes through JNI static native methods. Hand-authored on
// purpose (not generated): this is the carve-out "services" surface.
//
package io.gossamer;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.webkit.WebSettings;
import android.webkit.WebView;
import android.webkit.WebViewClient;

/**
 * GossamerActivity — full-screen WebView host that bridges to libgossamer.so.
 *
 * <p>Creates a full-screen {@link WebView} (JavaScript + DOM storage on, file
 * and content access off), registers a single {@link GossamerBridge} as the
 * {@code GossamerBridge} JavaScript interface, hands the Activity, WebView and
 * screen size to the native layer via {@link #nativeInit}, then loads
 * {@link #getInitialHtml()} or {@link #getInitialUrl()}.
 *
 * <p>Subclass and override {@link #getInitialUrl()}/{@link #getInitialHtml()} to
 * supply app content, and optionally {@link #onIntentReceived(Intent)} to react
 * to new intents. Lifecycle methods are deliberately {@code final}.
 *
 * <p>The JNI signatures match the Zig host exactly:
 * <ul>
 *   <li>{@code Java_io_gossamer_GossamerActivity_nativeInit}
 *   <li>{@code Java_io_gossamer_GossamerActivity_nativeDestroy}
 *   <li>{@code Java_io_gossamer_GossamerActivity_nativeIntentReceived}
 * </ul>
 */
public class GossamerActivity extends Activity {

    private WebView webView;

    static {
        System.loadLibrary("gossamer");
    }

    private static native void nativeInit(Activity activity, WebView webview, int screenWidth, int screenHeight);
    private static native void nativeDestroy();
    private static native void nativeIntentReceived(Intent intent);

    @Override
    protected final void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        webView = new WebView(this);
        setContentView(webView);

        WebSettings settings = webView.getSettings();
        settings.setJavaScriptEnabled(true);
        settings.setDomStorageEnabled(true);
        settings.setAllowFileAccess(false);
        settings.setAllowContentAccess(false);

        webView.setWebViewClient(new WebViewClient());
        webView.addJavascriptInterface(new GossamerBridge(), "GossamerBridge");

        DisplayMetrics dm = getResources().getDisplayMetrics();
        nativeInit(this, webView, dm.widthPixels, dm.heightPixels);

        String html = getInitialHtml();
        if (html != null) {
            webView.loadDataWithBaseURL(null, html, "text/html", "UTF-8", null);
        } else {
            String url = getInitialUrl();
            if (url != null) {
                webView.loadUrl(url);
            }
        }
    }

    @Override
    protected final void onNewIntent(Intent intent) {
        super.onNewIntent(intent);
        setIntent(intent);
        onIntentReceived(intent);
    }

    @Override
    protected final void onDestroy() {
        nativeDestroy();
        if (webView != null) {
            webView.removeJavascriptInterface("GossamerBridge");
            webView.destroy();
            webView = null;
        }
        super.onDestroy();
    }

    /**
     * Hook invoked when the Activity is re-delivered an Intent. The default
     * forwards it to the native layer; override to pre-process (call super to
     * keep native delivery).
     */
    protected void onIntentReceived(Intent intent) {
        nativeIntentReceived(intent);
    }

    /** Override to load an initial URL. Return null to use getInitialHtml(). */
    protected String getInitialUrl() {
        return null;
    }

    /** Override to provide initial HTML. Return null if using getInitialUrl(). */
    protected String getInitialHtml() {
        return "<html><body><h1>Gossamer</h1><p>Override getInitialHtml() or getInitialUrl().</p></body></html>";
    }
}
