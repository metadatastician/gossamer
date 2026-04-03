# SPDX-License-Identifier: PMPL-1.0-or-later
# Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
#
# RPM spec file for the Gossamer webview shell framework.
# Build with: rpmbuild -bb packaging/rpm/gossamer.spec
# (run from the repository root after adjusting _sourcedir/_builddir if needed)

Name:           gossamer
Version:        0.3.0
Release:        1%{?dist}
Summary:        Linearly-typed webview shell framework with provable resource safety

License:        PMPL-1.0-or-later
URL:            https://github.com/hyperpolymath/gossamer

# The source tree is the repository itself; rpmbuild is expected to be run
# from a checkout rather than a tarball-based workflow.
Source0:        %{name}-%{version}.tar.gz

BuildRequires:  zig >= 0.14.0
BuildRequires:  webkit2gtk4-devel >= 2.40
BuildRequires:  gtk3-devel >= 3.22
BuildRequires:  just
BuildRequires:  pkg-config

Requires:       webkit2gtk4 >= 2.40
Requires:       gtk3 >= 3.22

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

# Build the Gossamer CLI in release mode.
just build-cli-release

%install
# Clear any stale install root.
rm -rf %{buildroot}

# Install the shared library.
install -Dm755 src/interface/ffi/zig-out/lib/libgossamer.so \
    %{buildroot}%{_libdir}/libgossamer.so

# Install the static library (for static linking).
install -Dm644 src/interface/ffi/zig-out/lib/libgossamer.a \
    %{buildroot}%{_libdir}/libgossamer.a

# Install the CLI binary.
install -Dm755 cli/zig-out/bin/gossamer \
    %{buildroot}%{_bindir}/gossamer

# Install the public C header.
install -Dm644 generated/abi/gossamer.h \
    %{buildroot}%{_includedir}/gossamer/gossamer.h

%files
%license LICENSE
%doc README.adoc
%{_libdir}/libgossamer.so
%{_bindir}/gossamer

%files devel
%{_libdir}/libgossamer.a
%{_includedir}/gossamer/

%changelog
* Thu Apr 03 2026 Jonathan D.A. Jewell <j.d.a.jewell@open.ac.uk> - 0.3.0-1
- Initial RPM packaging for Gossamer v0.3.0
- Ships libgossamer.so, gossamer CLI, and gossamer.h
- Formal ABI layer specified in Idris2; Zig FFI implementation
