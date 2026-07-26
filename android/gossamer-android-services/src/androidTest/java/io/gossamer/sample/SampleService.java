// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Synthetic subclass proving GossamerForegroundService's override surface
// compiles with a minimal (~5-20 line) app implementation. Not shipped.
//
package io.gossamer.sample;

import android.app.Notification;
import android.hardware.Sensor;

import io.gossamer.services.GossamerForegroundService;

/** Minimal foreground service that subscribes to the accelerometer. */
public final class SampleService extends GossamerForegroundService {

    private static final String CHANNEL_ID = "sample_channel";
    private static final int NOTIFICATION_ID = 0x5301;

    @Override
    protected Notification createForegroundNotification() {
        return new Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("Sample")
            .setContentText("Running")
            .setSmallIcon(android.R.drawable.stat_notify_sync)
            .setOngoing(true)
            .build();
    }

    @Override
    protected String getChannelId() {
        return CHANNEL_ID;
    }

    @Override
    protected int getNotificationId() {
        return NOTIFICATION_ID;
    }

    @Override
    protected int[] getSubscribedSensors() {
        return new int[] { Sensor.TYPE_ACCELEROMETER };
    }
}
