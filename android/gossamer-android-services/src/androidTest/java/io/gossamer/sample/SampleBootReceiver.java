// SPDX-License-Identifier: MPL-2.0
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Synthetic subclass proving GossamerBootReceiver's override surface compiles.
// Not shipped.
//
package io.gossamer.sample;

import io.gossamer.services.GossamerBootReceiver;

/** Minimal boot receiver that restarts {@link SampleService}. */
public final class SampleBootReceiver extends GossamerBootReceiver {

    @Override
    protected Class<?> getServiceClass() {
        return SampleService.class;
    }
}
