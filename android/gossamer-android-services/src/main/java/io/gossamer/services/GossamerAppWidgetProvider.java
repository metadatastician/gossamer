// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// gossamer-android-services: subclass-based shim base classes (issue #71).
//
package io.gossamer.services;

import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;

import androidx.annotation.LayoutRes;

/**
 * GossamerAppWidgetProvider — abstract base for a home-screen widget backed by
 * libgossamer.so.
 *
 * <p>{@link RemoteViews} can only be built JVM-side, so widget state is fetched
 * from native as a JSON string ({@link #nativeFetchWidgetState}) and the
 * subclass renders it into a {@link RemoteViews} ({@link #renderWidget}). Custom
 * taps (intents whose action starts with {@link #getActionPrefix()}) are routed
 * to native ({@link #nativeHandleWidgetAction}) and then every instance is
 * re-rendered. Subclasses supply the layout, action prefix and render logic.
 *
 * <p>JNI symbols (must match the Zig host exactly):
 * <ul>
 *   <li>{@code Java_io_gossamer_services_GossamerAppWidgetProvider_nativeFetchWidgetState}
 *   <li>{@code Java_io_gossamer_services_GossamerAppWidgetProvider_nativeHandleWidgetAction}
 * </ul>
 */
public abstract class GossamerAppWidgetProvider extends AppWidgetProvider {

    static {
        System.loadLibrary("gossamer");
    }

    private static native String nativeFetchWidgetState(Context context);
    private static native void nativeHandleWidgetAction(Context context, String action, int widgetId);

    /** Layout resource ({@code R.layout.*}) inflated for each widget instance. */
    @LayoutRes
    protected abstract int getWidgetLayout();

    /** Intent-action prefix that marks a tap as belonging to this widget. */
    protected abstract String getActionPrefix();

    /**
     * Render the native state JSON into the given RemoteViews for one instance.
     *
     * @param views           the RemoteViews to populate
     * @param nativeStateJson state fetched from the native layer
     * @param widgetId        the AppWidget id being rendered
     */
    protected abstract void renderWidget(RemoteViews views, String nativeStateJson, int widgetId);

    @Override
    public final void onUpdate(Context context, AppWidgetManager manager, int[] ids) {
        String state = nativeFetchWidgetState(context);
        for (int id : ids) {
            RemoteViews views = new RemoteViews(context.getPackageName(), getWidgetLayout());
            renderWidget(views, state, id);
            manager.updateAppWidget(id, views);
        }
    }

    @Override
    public final void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        String action = (intent != null) ? intent.getAction() : null;
        if (action != null && action.startsWith(getActionPrefix())) {
            int widgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, -1);
            nativeHandleWidgetAction(context, action, widgetId);

            AppWidgetManager manager = AppWidgetManager.getInstance(context);
            int[] ids = manager.getAppWidgetIds(new ComponentName(context, getClass()));
            onUpdate(context, manager, ids);
        }
    }
}
