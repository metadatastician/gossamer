// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// gossamer-android-services: subclass-based shim base classes (issue #71).
//
package io.gossamer.services;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;

/**
 * GossamerBootReceiver — abstract base for restarting a service on boot.
 *
 * <p>On {@code BOOT_COMPLETED} / {@code LOCKED_BOOT_COMPLETED} it asks the native
 * layer whether the service should be restarted ({@link #nativeShouldRestart},
 * keyed by the service class name) and, if so, starts it as a foreground
 * service. Subclasses provide only {@link #getServiceClass()}.
 *
 * <p>JNI symbol (must match the Zig host exactly):
 * {@code Java_io_gossamer_services_GossamerBootReceiver_nativeShouldRestart}.
 */
public abstract class GossamerBootReceiver extends BroadcastReceiver {

    static {
        System.loadLibrary("gossamer");
    }

    private static native boolean nativeShouldRestart(Context context, String serviceClassName);

    /** The foreground service class to (re)start on boot. */
    protected abstract Class<?> getServiceClass();

    @Override
    public final void onReceive(Context context, Intent intent) {
        String action = (intent != null) ? intent.getAction() : null;
        if (action == null) {
            return;
        }
        if (!Intent.ACTION_BOOT_COMPLETED.equals(action)
                && !Intent.ACTION_LOCKED_BOOT_COMPLETED.equals(action)) {
            return;
        }
        Class<?> serviceClass = getServiceClass();
        if (nativeShouldRestart(context, serviceClass.getName())) {
            context.startForegroundService(new Intent(context, serviceClass));
        }
    }
}
