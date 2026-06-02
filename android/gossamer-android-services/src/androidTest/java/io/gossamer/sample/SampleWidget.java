// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Synthetic subclass proving GossamerAppWidgetProvider's override surface
// compiles. Not shipped.
//
package io.gossamer.sample;

import android.widget.RemoteViews;

import io.gossamer.services.GossamerAppWidgetProvider;

/** Minimal widget provider that renders a text field from the native state. */
public final class SampleWidget extends GossamerAppWidgetProvider {

    @Override
    protected int getWidgetLayout() {
        return 0; // placeholder; a real app returns R.layout.sample_widget
    }

    @Override
    protected String getActionPrefix() {
        return "io.gossamer.sample.";
    }

    @Override
    protected void renderWidget(RemoteViews views, String nativeStateJson, int widgetId) {
        // Minimal parse: pull a "label" string field out of the flat JSON state.
        String label = extractLabel(nativeStateJson);
        views.setTextViewText(android.R.id.text1, label);
    }

    private static String extractLabel(String json) {
        if (json == null) {
            return "";
        }
        final String key = "\"label\":\"";
        int start = json.indexOf(key);
        if (start < 0) {
            return "";
        }
        start += key.length();
        int end = json.indexOf('"', start);
        if (end < 0) {
            return "";
        }
        return json.substring(start, end);
    }
}
