-- SPDX-License-Identifier: MPL-2.0
-- Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
--
||| GENERATED FILE — DO NOT EDIT BY HAND.
||| Regenerate with `just abi-gen` (scripts/gen-abi-foreign.py); CI fails if this
||| file is stale (scripts/check-abi-ffi-cleave.sh --check-generated).
|||
||| Complete raw %foreign mirror of the libgossamer C ABI: EVERY `export fn
||| gossamer_*` in src/interface/ffi/src/*.zig has a matching declaration here,
||| so the Idris ABI describes the *real, whole* FFI surface (gossamer#82) and is
||| generated FROM it — it cannot drift or go phantom. Curated safe wrappers over
||| the core subset live in `Gossamer.ABI.Foreign`; these are the raw bindings.

module Gossamer.ABI.ForeignGen

%default total

export
%foreign "C:gossamer_activity_get, libgossamer"
prim__gossamer_activity_get : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_activity_set, libgossamer"
prim__gossamer_activity_set : Bits64 -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_android_register_boot_callback, libgossamer"
prim__gossamer_android_register_boot_callback : Bits64 -> PrimIO ()

export
%foreign "C:gossamer_android_register_intent_callback, libgossamer"
prim__gossamer_android_register_intent_callback : Bits64 -> PrimIO ()

export
%foreign "C:gossamer_android_register_service_callbacks, libgossamer"
prim__gossamer_android_register_service_callbacks : Bits64 -> Bits64 -> Bits64 -> Bits64 -> PrimIO ()

export
%foreign "C:gossamer_android_register_widget_callbacks, libgossamer"
prim__gossamer_android_register_widget_callbacks : Bits64 -> Bits64 -> PrimIO ()

export
%foreign "C:gossamer_arch, libgossamer"
prim__gossamer_arch : PrimIO Bits64

export
%foreign "C:gossamer_arrange, libgossamer"
prim__gossamer_arrange : Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_async_inflight_count, libgossamer"
prim__gossamer_async_inflight_count : PrimIO Bits32

export
%foreign "C:gossamer_broadcast, libgossamer"
prim__gossamer_broadcast : String -> String -> PrimIO Bits32

export
%foreign "C:gossamer_build_info, libgossamer"
prim__gossamer_build_info : PrimIO Bits64

export
%foreign "C:gossamer_cap_check, libgossamer"
prim__gossamer_cap_check : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_cap_get_max, libgossamer"
prim__gossamer_cap_get_max : PrimIO Bits32

export
%foreign "C:gossamer_cap_grant, libgossamer"
prim__gossamer_cap_grant : Bits32 -> PrimIO Bits64

export
%foreign "C:gossamer_cap_resource_kind, libgossamer"
prim__gossamer_cap_resource_kind : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_cap_revoke, libgossamer"
prim__gossamer_cap_revoke : Bits64 -> PrimIO ()

export
%foreign "C:gossamer_cap_set_max, libgossamer"
prim__gossamer_cap_set_max : Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_channel_bind, libgossamer"
prim__gossamer_channel_bind : Bits64 -> String -> Bits64 -> Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_channel_bind_async, libgossamer"
prim__gossamer_channel_bind_async : Bits64 -> String -> Bits64 -> Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_channel_close, libgossamer"
prim__gossamer_channel_close : Bits64 -> PrimIO ()

export
%foreign "C:gossamer_channel_open, libgossamer"
prim__gossamer_channel_open : Bits64 -> PrimIO Bits64

export
%foreign "C:gossamer_channel_register_defaults, libgossamer"
prim__gossamer_channel_register_defaults : Bits64 -> Bits64 -> PrimIO ()

export
%foreign "C:gossamer_clipboard_read, libgossamer"
prim__gossamer_clipboard_read : Bits64 -> Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_clipboard_write, libgossamer"
prim__gossamer_clipboard_write : String -> PrimIO Bits32

export
%foreign "C:gossamer_conf_free, libgossamer"
prim__gossamer_conf_free : Bits64 -> PrimIO ()

export
%foreign "C:gossamer_conf_get_bool, libgossamer"
prim__gossamer_conf_get_bool : Bits64 -> String -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_conf_get_int, libgossamer"
prim__gossamer_conf_get_int : Bits64 -> String -> Bits64 -> PrimIO Bits64

export
%foreign "C:gossamer_conf_get_string, libgossamer"
prim__gossamer_conf_get_string : Bits64 -> String -> PrimIO Bits64

export
%foreign "C:gossamer_conf_has, libgossamer"
prim__gossamer_conf_has : Bits64 -> String -> PrimIO Bits32

export
%foreign "C:gossamer_conf_load, libgossamer"
prim__gossamer_conf_load : String -> Bits64 -> PrimIO Bits64

export
%foreign "C:gossamer_create, libgossamer"
prim__gossamer_create : String -> Bits32 -> Bits32 -> Bits8 -> Bits8 -> Bits8 -> PrimIO Bits64

export
%foreign "C:gossamer_create_ex, libgossamer"
prim__gossamer_create_ex : String -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bits32 -> Bits8 -> Bits8 -> Bits8 -> Bits8 -> PrimIO Bits64

export
%foreign "C:gossamer_debug_close, libgossamer"
prim__gossamer_debug_close : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_debug_open, libgossamer"
prim__gossamer_debug_open : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_debug_toggle, libgossamer"
prim__gossamer_debug_toggle : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_destroy, libgossamer"
prim__gossamer_destroy : Bits64 -> PrimIO ()

export
%foreign "C:gossamer_dialog_free_path, libgossamer"
prim__gossamer_dialog_free_path : Bits64 -> PrimIO ()

export
%foreign "C:gossamer_dialog_open, libgossamer"
prim__gossamer_dialog_open : String -> String -> PrimIO Bits64

export
%foreign "C:gossamer_dialog_open_directory, libgossamer"
prim__gossamer_dialog_open_directory : String -> PrimIO Bits64

export
%foreign "C:gossamer_dialog_open_multiple, libgossamer"
prim__gossamer_dialog_open_multiple : String -> String -> PrimIO Bits64

export
%foreign "C:gossamer_dialog_save, libgossamer"
prim__gossamer_dialog_save : String -> String -> PrimIO Bits64

export
%foreign "C:gossamer_emit, libgossamer"
prim__gossamer_emit : Bits64 -> String -> String -> PrimIO Bits32

export
%foreign "C:gossamer_emit_binary, libgossamer"
prim__gossamer_emit_binary : Bits64 -> String -> Bits64 -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_eval, libgossamer"
prim__gossamer_eval : Bits64 -> String -> PrimIO Bits32

export
%foreign "C:gossamer_fs_copy_file, libgossamer"
prim__gossamer_fs_copy_file : String -> String -> Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_fs_exists, libgossamer"
prim__gossamer_fs_exists : String -> Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_fs_list_dir, libgossamer"
prim__gossamer_fs_list_dir : String -> Bits64 -> PrimIO Bits64

export
%foreign "C:gossamer_fs_mkdir_p, libgossamer"
prim__gossamer_fs_mkdir_p : String -> Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_fs_read_text, libgossamer"
prim__gossamer_fs_read_text : String -> Bits64 -> PrimIO Bits64

export
%foreign "C:gossamer_fs_remove, libgossamer"
prim__gossamer_fs_remove : String -> Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_fs_write_text, libgossamer"
prim__gossamer_fs_write_text : String -> String -> Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_get_max_inflight, libgossamer"
prim__gossamer_get_max_inflight : PrimIO Bits32

export
%foreign "C:gossamer_groove_check_compat, libgossamer"
prim__gossamer_groove_check_compat : Bits32 -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_groove_connect_typed, libgossamer"
prim__gossamer_groove_connect_typed : Bits32 -> Bits32 -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_groove_disconnect, libgossamer"
prim__gossamer_groove_disconnect : Bits32 -> PrimIO ()

export
%foreign "C:gossamer_groove_disconnect_all, libgossamer"
prim__gossamer_groove_disconnect_all : PrimIO ()

export
%foreign "C:gossamer_groove_disconnect_typed, libgossamer"
prim__gossamer_groove_disconnect_typed : Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_groove_discover, libgossamer"
prim__gossamer_groove_discover : PrimIO Bits32

export
%foreign "C:gossamer_groove_dock, libgossamer"
prim__gossamer_groove_dock : Bits64 -> String -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_groove_find_capability, libgossamer"
prim__gossamer_groove_find_capability : String -> PrimIO Bits32

export
%foreign "C:gossamer_groove_manifest, libgossamer"
prim__gossamer_groove_manifest : Bits32 -> PrimIO Bits64

export
%foreign "C:gossamer_groove_query_type, libgossamer"
prim__gossamer_groove_query_type : Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_groove_recv, libgossamer"
prim__gossamer_groove_recv : Bits32 -> PrimIO Bits64

export
%foreign "C:gossamer_groove_send, libgossamer"
prim__gossamer_groove_send : Bits32 -> String -> PrimIO Bits32

export
%foreign "C:gossamer_groove_signing_active, libgossamer"
prim__gossamer_groove_signing_active : PrimIO Bits32

export
%foreign "C:gossamer_groove_status, libgossamer"
prim__gossamer_groove_status : Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_groove_summary, libgossamer"
prim__gossamer_groove_summary : PrimIO Bits64

export
%foreign "C:gossamer_groove_tls_enabled, libgossamer"
prim__gossamer_groove_tls_enabled : PrimIO Bits32

export
%foreign "C:gossamer_groove_undock, libgossamer"
prim__gossamer_groove_undock : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_group_add, libgossamer"
prim__gossamer_group_add : Bits32 -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_group_apply, libgossamer"
prim__gossamer_group_apply : Bits32 -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_group_create, libgossamer"
prim__gossamer_group_create : String -> PrimIO Bits32

export
%foreign "C:gossamer_group_destroy, libgossamer"
prim__gossamer_group_destroy : Bits32 -> PrimIO ()

export
%foreign "C:gossamer_group_remove, libgossamer"
prim__gossamer_group_remove : Bits32 -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_guard_get, libgossamer"
prim__gossamer_guard_get : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_guard_set, libgossamer"
prim__gossamer_guard_set : Bits64 -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_hide, libgossamer"
prim__gossamer_hide : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_is_desktop, libgossamer"
prim__gossamer_is_desktop : PrimIO Bits8

export
%foreign "C:gossamer_last_error, libgossamer"
prim__gossamer_last_error : PrimIO Bits64

export
%foreign "C:gossamer_load_html, libgossamer"
prim__gossamer_load_html : Bits64 -> String -> PrimIO Bits32

export
%foreign "C:gossamer_lower, libgossamer"
prim__gossamer_lower : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_maximize, libgossamer"
prim__gossamer_maximize : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_minimize, libgossamer"
prim__gossamer_minimize : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_navigate, libgossamer"
prim__gossamer_navigate : Bits64 -> String -> PrimIO Bits32

export
%foreign "C:gossamer_notify, libgossamer"
prim__gossamer_notify : String -> String -> PrimIO Bits32

export
%foreign "C:gossamer_platform, libgossamer"
prim__gossamer_platform : PrimIO Bits64

export
%foreign "C:gossamer_platform_json, libgossamer"
prim__gossamer_platform_json : PrimIO Bits64

export
%foreign "C:gossamer_plugin_list, libgossamer"
prim__gossamer_plugin_list : PrimIO Bits64

export
%foreign "C:gossamer_plugin_load, libgossamer"
prim__gossamer_plugin_load : Bits64 -> String -> PrimIO Bits32

export
%foreign "C:gossamer_plugin_unload, libgossamer"
prim__gossamer_plugin_unload : Bits32 -> PrimIO ()

export
%foreign "C:gossamer_raise, libgossamer"
prim__gossamer_raise : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_registry_add, libgossamer"
prim__gossamer_registry_add : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_registry_count, libgossamer"
prim__gossamer_registry_count : PrimIO Bits32

export
%foreign "C:gossamer_registry_remove, libgossamer"
prim__gossamer_registry_remove : Bits64 -> PrimIO ()

export
%foreign "C:gossamer_request_close, libgossamer"
prim__gossamer_request_close : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_resize, libgossamer"
prim__gossamer_resize : Bits64 -> Bits32 -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_restore, libgossamer"
prim__gossamer_restore : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_run, libgossamer"
prim__gossamer_run : Bits64 -> PrimIO ()

export
%foreign "C:gossamer_send_to, libgossamer"
prim__gossamer_send_to : Bits32 -> String -> String -> PrimIO Bits32

export
%foreign "C:gossamer_set_csp, libgossamer"
prim__gossamer_set_csp : Bits64 -> String -> PrimIO Bits32

export
%foreign "C:gossamer_set_max_inflight, libgossamer"
prim__gossamer_set_max_inflight : Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_set_title, libgossamer"
prim__gossamer_set_title : Bits64 -> String -> PrimIO Bits32

export
%foreign "C:gossamer_shell_kill, libgossamer"
prim__gossamer_shell_kill : Bits64 -> Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_shell_spawn, libgossamer"
prim__gossamer_shell_spawn : String -> Bits64 -> PrimIO Bits64

export
%foreign "C:gossamer_show, libgossamer"
prim__gossamer_show : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_ssg_build_site, libgossamer"
prim__gossamer_ssg_build_site : String -> String -> String -> PrimIO Bits32

export
%foreign "C:gossamer_ssg_list_files, libgossamer"
prim__gossamer_ssg_list_files : String -> String -> PrimIO Bits64

export
%foreign "C:gossamer_ssg_md_to_html, libgossamer"
prim__gossamer_ssg_md_to_html : String -> PrimIO Bits64

export
%foreign "C:gossamer_ssg_parse_body, libgossamer"
prim__gossamer_ssg_parse_body : String -> PrimIO Bits64

export
%foreign "C:gossamer_ssg_parse_front_matter, libgossamer"
prim__gossamer_ssg_parse_front_matter : String -> PrimIO Bits64

export
%foreign "C:gossamer_ssg_read_file, libgossamer"
prim__gossamer_ssg_read_file : String -> PrimIO Bits64

export
%foreign "C:gossamer_ssg_template_substitute, libgossamer"
prim__gossamer_ssg_template_substitute : String -> String -> PrimIO Bits64

export
%foreign "C:gossamer_ssg_write_file, libgossamer"
prim__gossamer_ssg_write_file : String -> String -> PrimIO Bits32

export
%foreign "C:gossamer_transmute, libgossamer"
prim__gossamer_transmute : Bits64 -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_transmute_get, libgossamer"
prim__gossamer_transmute_get : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_tray_add_item, libgossamer"
prim__gossamer_tray_add_item : Bits64 -> String -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_tray_add_separator, libgossamer"
prim__gossamer_tray_add_separator : Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_tray_clear_window, libgossamer"
prim__gossamer_tray_clear_window : PrimIO ()

export
%foreign "C:gossamer_tray_create, libgossamer"
prim__gossamer_tray_create : String -> PrimIO Bits64

export
%foreign "C:gossamer_tray_destroy, libgossamer"
prim__gossamer_tray_destroy : Bits64 -> PrimIO ()

export
%foreign "C:gossamer_tray_set_callback, libgossamer"
prim__gossamer_tray_set_callback : Bits64 -> Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_tray_set_icon, libgossamer"
prim__gossamer_tray_set_icon : Bits64 -> String -> PrimIO Bits32

export
%foreign "C:gossamer_tray_set_icon_from_file, libgossamer"
prim__gossamer_tray_set_icon_from_file : Bits64 -> String -> PrimIO Bits32

export
%foreign "C:gossamer_tray_set_tooltip, libgossamer"
prim__gossamer_tray_set_tooltip : Bits64 -> String -> PrimIO Bits32

export
%foreign "C:gossamer_tray_set_visible, libgossamer"
prim__gossamer_tray_set_visible : Bits64 -> Bits32 -> PrimIO Bits32

export
%foreign "C:gossamer_tray_set_window, libgossamer"
prim__gossamer_tray_set_window : Bits64 -> Bits64 -> PrimIO Bits32

export
%foreign "C:gossamer_version, libgossamer"
prim__gossamer_version : PrimIO Bits64

export
%foreign "C:gossamer_watcher_start, libgossamer"
prim__gossamer_watcher_start : Bits64 -> String -> String -> PrimIO Bits64

export
%foreign "C:gossamer_watcher_stop, libgossamer"
prim__gossamer_watcher_stop : Bits64 -> PrimIO ()

export
%foreign "C:gossamer_webview_engine, libgossamer"
prim__gossamer_webview_engine : PrimIO Bits64
