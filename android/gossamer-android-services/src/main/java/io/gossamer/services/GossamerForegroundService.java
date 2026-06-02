// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// gossamer-android-services: subclass-based shim base classes (issue #71).
//
package io.gossamer.services;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.Service;
import android.content.Intent;
import android.content.pm.ServiceInfo;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Build;
import android.os.IBinder;
import android.os.PowerManager;

/**
 * GossamerForegroundService — abstract base for a long-running foreground
 * {@link Service} driven by libgossamer.so.
 *
 * <p>Lifecycle methods are {@code final}: the JVM owns the lifecycle and each
 * step is delegated to the native side through an independent service handle
 * (a {@code long} returned by {@link #nativeServiceCreate}). Subclasses supply
 * only the JVM-object work that cannot be done natively — building the
 * {@link Notification}, naming the channel — plus optional config and sensor
 * subscriptions. Roughly 5-20 lines of subclass code.
 *
 * <p>Config and state cross the boundary as JSON strings
 * ({@link #getNativeConfig()}). Sensors are subscribed via a primitive
 * {@code int[]} of {@code Sensor.TYPE_*} values ({@link #getSubscribedSensors()})
 * and each event is forwarded raw to {@link #nativeSensorEvent}.
 *
 * <p>JNI symbols (must match the Zig host exactly):
 * <ul>
 *   <li>{@code Java_io_gossamer_services_GossamerForegroundService_nativeServiceCreate}
 *   <li>{@code Java_io_gossamer_services_GossamerForegroundService_nativeServiceStartCommand}
 *   <li>{@code Java_io_gossamer_services_GossamerForegroundService_nativeServiceDestroy}
 *   <li>{@code Java_io_gossamer_services_GossamerForegroundService_nativeSensorEvent}
 * </ul>
 */
public abstract class GossamerForegroundService extends Service implements SensorEventListener {

    static {
        System.loadLibrary("gossamer");
    }

    private static native long nativeServiceCreate(Service self, String configJson);
    private static native int  nativeServiceStartCommand(long handle, Intent intent, int flags, int startId);
    private static native void nativeServiceDestroy(long handle);
    private static native void nativeSensorEvent(long handle, int sensorType, float[] values, long timestampNs, int accuracy);

    private long nativeHandle;
    private SensorManager sensorManager;
    private PowerManager.WakeLock wakeLock;

    // ---- abstract hooks the subclass MUST implement -----------------------

    /** Build the ongoing notification shown while the service runs in foreground. */
    protected abstract Notification createForegroundNotification();

    /** Notification channel id; the channel is created at IMPORTANCE_LOW if absent. */
    protected abstract String getChannelId();

    /** Stable notification id used by startForeground(). */
    protected abstract int getNotificationId();

    // ---- overridable hooks with sensible defaults -------------------------

    /** JSON config handed to the native service at creation. Defaults to "{}". */
    protected String getNativeConfig() {
        return "{}";
    }

    /** Sensor types ({@code Sensor.TYPE_*}) to subscribe to. Empty = none. */
    protected int[] getSubscribedSensors() {
        return new int[0];
    }

    /** Sampling rate for subscribed sensors. Defaults to SENSOR_DELAY_GAME. */
    protected int getSensorSamplingRate() {
        return SensorManager.SENSOR_DELAY_GAME;
    }

    /** Wake-lock tag; return null (default) to run without a wake lock. */
    protected String getWakeLockTag() {
        return null;
    }

    // ---- final lifecycle (delegates to native) ----------------------------

    @Override
    public final void onCreate() {
        super.onCreate();

        NotificationManager nm = getSystemService(NotificationManager.class);
        if (nm != null && nm.getNotificationChannel(getChannelId()) == null) {
            nm.createNotificationChannel(
                new NotificationChannel(getChannelId(), getChannelId(), NotificationManager.IMPORTANCE_LOW));
        }

        nativeHandle = nativeServiceCreate(this, getNativeConfig());

        String tag = getWakeLockTag();
        if (tag != null) {
            PowerManager pm = getSystemService(PowerManager.class);
            if (pm != null) {
                wakeLock = pm.newWakeLock(PowerManager.PARTIAL_WAKE_LOCK, tag);
                wakeLock.setReferenceCounted(false);
                wakeLock.acquire();
            }
        }

        sensorManager = getSystemService(SensorManager.class);
        if (sensorManager != null) {
            int rate = getSensorSamplingRate();
            for (int sensorType : getSubscribedSensors()) {
                Sensor sensor = sensorManager.getDefaultSensor(sensorType);
                if (sensor != null) {
                    sensorManager.registerListener(this, sensor, rate);
                }
            }
        }
    }

    @Override
    public final int onStartCommand(Intent intent, int flags, int startId) {
        Notification notification = createForegroundNotification();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.UPSIDE_DOWN_CAKE) {
            startForeground(getNotificationId(), notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC);
        } else {
            startForeground(getNotificationId(), notification);
        }
        return nativeServiceStartCommand(nativeHandle, intent, flags, startId);
    }

    @Override
    public final void onDestroy() {
        if (sensorManager != null) {
            sensorManager.unregisterListener(this);
            sensorManager = null;
        }
        if (wakeLock != null) {
            if (wakeLock.isHeld()) {
                wakeLock.release();
            }
            wakeLock = null;
        }
        nativeServiceDestroy(nativeHandle);
        super.onDestroy();
    }

    @Override
    public final IBinder onBind(Intent intent) {
        return null;
    }

    // ---- SensorEventListener ----------------------------------------------

    /**
     * Forwards each sensor sample to the native service. NOT final on purpose:
     * subclasses may pre-filter or down-sample, calling super to deliver.
     */
    @Override
    public void onSensorChanged(SensorEvent event) {
        nativeSensorEvent(nativeHandle, event.sensor.getType(), event.values, event.timestamp, event.accuracy);
    }

    @Override
    public final void onAccuracyChanged(Sensor sensor, int accuracy) {
        // no-op
    }
}
