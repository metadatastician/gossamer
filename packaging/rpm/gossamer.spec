# SPDX-License-Identifier: MPL-2.0
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# RPM spec file for the Gossamer webview shell framework.
# Build with: rpmbuild -bb packaging/rpm/gossamer.spec
# (run from the repository root after adjusting _sourcedir/_builddir if needed)

Name:           gossamer
Version:        0.3.0
Release:        1%{?dist}
Summary:        Linearly-typed webview shell framework with provable resource safety

License:        MPL-2.0
URL:            https://github.com/hyperpolymath/gossamer

# The source tree is the repository itself; rpmbuild is expected to be run
# from a checkout rather than a tarball-based workflow.
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  zig >= 0.14.0
BuildRequires:  webkit2gtk4-devel >= 2.40
BuildRequires:  gtk3-devel >= 3.22
BuildRequires:  just
BuildRequires:  pkg-config
# wasmtime C API >= v44.0.1 — packaged out-of-tree for now; install
# from https://github.com/bytecodealliance/wasmtime/releases under
# /usr/local before building (see cli/launcher/build.zig).
# ephapax — compiles cli/src/Main.eph → cli.wasm during the launcher
# build. Set EPHAPAX=/path/to/ephapax if not on PATH.

Requires:       webkit2gtk4 >= 2.40
Requires:       gtk3 >= 3.22
# wasmtime is dlopened by the launcher binary; same out-of-tree note
# applies — /usr/local/lib/libwasmtime.so must be present at runtime.

%description
Gossamer is a webview shell framework that uses linear types to guarantee
no resource leaks at compile time. It provides a C-ABI shared library
(libgossamer.so), a command-line tool, and a public C header for embedding
into any language with a C FFI.

The ABI layer is formally specified in Idris2 with dependent-type proofs,
and the implementation is in Zig for zero-overhead C compatibility.

Key guarantees:
- WebviewHandle, Channel, and Cap are linear resources
- Every resource creation has a paired destruction
- No double-free or use-after-free possible in correctly-typed code

%package devel
Summary:        Development headers for Gossamer
Requires:       %{name} = %{version}-%{release}

%description devel
Development headers (gossamer.h) and static library (libgossamer.a) for
building applications that embed the Gossamer webview shell framework.

%prep
%setup -q

%build
# Build the Zig FFI shared library in release mode.
just build-ffi-release

# Build the wasmtime-host launcher + cli.wasm in release mode.
just build-launcher-release

%install
# Clear any stale install root.
rm -rf %{buildroot}

# Install the shared library.
install -Dm755 src/interface/ffi/zig-out/lib/libgossamer.so \
    %{buildroot}%{_libdir}/libgossamer.so

# Install the static library (for static linking).
install -Dm644 src/interface/ffi/zig-out/lib/libgossamer.a \
    %{buildroot}%{_libdir}/libgossamer.a

# Install the launcher binary as `gossamer` (preserving the existing
# UX). The launcher discovers cli.wasm via the install-prefix-relative
# path <exe_dir>/../share/gossamer/cli.wasm at runtime.
install -Dm755 cli/launcher/zig-out/bin/gossamer-launcher \
    %{buildroot}%{_bindir}/gossamer

# Install the precompiled cli.wasm into the share/gossamer prefix.
install -Dm644 cli/launcher/zig-out/share/gossamer/cli.wasm \
    %{buildroot}%{_datadir}/gossamer/cli.wasm

# Install the public C header.
install -Dm644 generated/abi/gossamer.h \
    %{buildroot}%{_includedir}/gossamer/gossamer.h

%files
%license LICENSE
%doc README.adoc
%{_libdir}/libgossamer.so
%{_bindir}/gossamer
%{_datadir}/gossamer/cli.wasm

%files devel
%{_libdir}/libgossamer.a
%{_includedir}/gossamer/

%changelog
* Thu Apr 03 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk> - 0.3.0-1
- Initial RPM packaging for Gossamer v0.3.0
- Ships libgossamer.so, gossamer CLI, and gossamer.h
- Formal ABI layer specified in Idris2; Zig FFI implementation
