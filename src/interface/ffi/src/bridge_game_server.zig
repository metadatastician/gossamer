// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>
//
// Gossamer — Game Server Admin Bridge FFI
//
// Exports C-ABI symbols consumed by the Ephapax __ffi() intrinsic.
// Each function matches a bridge_* or utility symbol referenced in
// gossamer/examples/game-server-admin/bridge.eph.
//
// These symbols are linked into libgossamer.so and resolved at runtime
// via Ephapax's dlopen/dlsym mechanism (ephapax-interp load_ffi_library).
//
// All functions take i64 args (Ephapax FFI convention: up to 6 i64 params)
// and return i64. String arguments are passed as pointers to null-terminated
// C strings; string returns are allocated via c_allocator and must be freed
// by the caller (or, in practice, the Ephapax GC handles it).
//
// SPDX-License-Identifier: PMPL-1.0-or-later
// Copyright (c) 2026 Jonathan D.A. Jewell (hyperpolymath) <j.d.a.jewell@open.ac.uk>

const std = @import("std");

//==============================================================================
// Server Registry
//==============================================================================

/// Server entry in the registry.
const Server = struct {
    id: []const u8,
    name: []const u8,
    container: []const u8,
    port: u16,
    config: []const u8,
    format: []const u8,
};

/// Static server registry. Matches bridge.eph.
const servers = [_]Server{
    .{ .id = "barotrauma", .name = "Barotrauma", .container = "barotrauma", .port = 27015, .config = "/opt/barotrauma-game/serversettings.xml", .format = "xml" },
    .{ .id = "dst", .name = "Don't Starve Together", .container = "dst-server", .port = 10999, .config = "/opt/dst-server/DoNotStarveTogether/Cluster_1/cluster.ini", .format = "ini" },
    .{ .id = "ass", .name = "Airborne Submarine Squadron", .container = "ass-server", .port = 8081, .config = "", .format = "none" },
    .{ .id = "idaptik", .name = "IDApTIK Sync", .container = "idaptik-sync", .port = 4030, .config = "", .format = "env" },
    .{ .id = "burble", .name = "Burble", .container = "burble", .port = 4001, .config = "", .format = "env" },
    .{ .id = "voidexpanse", .name = "Void Expanse", .container = "voidexpanse", .port = 6100, .config = "/opt/voidexpanse/SettingsServer.xml", .format = "xml" },
};

const VPS_HOST = "root@209.42.26.106";

//==============================================================================
// SSH Execution
//==============================================================================

/// Execute a command on the VPS via SSH.
/// Args: host (i64 ptr to cstr), command (i64 ptr to cstr)
/// Returns: i64 ptr to allocated result string.
export fn ssh_exec(host_ptr: i64, cmd_ptr: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    const host = ptrToSlice(host_ptr) orelse return allocToI64(allocator, "error: null host");
    const cmd = ptrToSlice(cmd_ptr) orelse return allocToI64(allocator, "error: null command");

    // Build: ssh <host> '<cmd>'
    const argv = [_][]const u8{ "ssh", "-o", "ConnectTimeout=5", "-o", "StrictHostKeyChecking=no", host, cmd };
    const result = std.process.Child.run(.{
        .allocator = allocator,
        .argv = &argv,
    }) catch |e| {
        const err_msg = std.fmt.allocPrint(allocator, "error: ssh exec failed: {}", .{e}) catch return 0;
        return allocToI64(allocator, err_msg);
    };
    defer allocator.free(result.stderr);

    // Return stdout (already allocated by run())
    const out_z = allocator.dupeZ(u8, result.stdout) catch return 0;
    allocator.free(result.stdout);
    return @intCast(@intFromPtr(out_z.ptr));
}

//==============================================================================
// JSON Field Extraction
//==============================================================================

/// Extract a string field from a JSON object.
/// Args: json_ptr (cstr), field_ptr (cstr)
/// Returns: i64 ptr to extracted value string.
export fn json_field(json_ptr: i64, field_ptr: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    const json = ptrToSlice(json_ptr) orelse return allocToI64(allocator, "");
    const field = ptrToSlice(field_ptr) orelse return allocToI64(allocator, "");

    // Search for "field":"value" pattern
    const search = std.fmt.allocPrint(allocator, "\"{s}\":\"", .{field}) catch return 0;
    defer allocator.free(search);

    const start_idx = std.mem.indexOf(u8, json, search) orelse return allocToI64(allocator, "");
    const value_start = start_idx + search.len;

    // Find closing quote
    var i: usize = value_start;
    while (i < json.len) : (i += 1) {
        if (json[i] == '"' and (i == 0 or json[i - 1] != '\\')) {
            const value = json[value_start..i];
            const result = allocator.dupeZ(u8, value) catch return 0;
            return @intCast(@intFromPtr(result.ptr));
        }
    }
    return allocToI64(allocator, "");
}

//==============================================================================
// Bridge Functions
//==============================================================================

/// List all registered servers as JSON.
export fn bridge_list_servers(_: i64, _: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    var json = std.ArrayListUnmanaged(u8){};
    json.appendSlice(allocator,"[") catch return 0;

    for (servers, 0..) |s, idx| {
        if (idx > 0) json.appendSlice(allocator,",") catch return 0;
        const entry = std.fmt.allocPrint(
            allocator,
            "{{\"id\":\"{s}\",\"name\":\"{s}\",\"container\":\"{s}\",\"port\":{d},\"config\":\"{s}\",\"format\":\"{s}\"}}",
            .{ s.id, s.name, s.container, s.port, s.config, s.format },
        ) catch return 0;
        defer allocator.free(entry);
        json.appendSlice(allocator,entry) catch return 0;
    }

    json.appendSlice(allocator,"]") catch return 0;
    const result = allocator.dupeZ(u8, json.items) catch return 0;
    json.deinit(allocator);
    return @intCast(@intFromPtr(result.ptr));
}

/// Resolve a server ID to its config file path.
export fn bridge_resolve_config_path(server_id_ptr: i64, _: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;
    const server_id = ptrToSlice(server_id_ptr) orelse return allocToI64(allocator, "");

    for (servers) |s| {
        if (std.mem.eql(u8, s.id, server_id)) {
            return allocToI64(allocator, s.config);
        }
    }
    return allocToI64(allocator, "");
}

/// Resolve a server ID to its config format.
export fn bridge_resolve_config_format(server_id_ptr: i64, _: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;
    const server_id = ptrToSlice(server_id_ptr) orelse return allocToI64(allocator, "");

    for (servers) |s| {
        if (std.mem.eql(u8, s.id, server_id)) {
            return allocToI64(allocator, s.format);
        }
    }
    return allocToI64(allocator, "none");
}

/// Resolve a server ID to its container name.
export fn bridge_resolve_container(server_id_ptr: i64, _: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;
    const server_id = ptrToSlice(server_id_ptr) orelse return allocToI64(allocator, "");

    for (servers) |s| {
        if (std.mem.eql(u8, s.id, server_id)) {
            return allocToI64(allocator, s.container);
        }
    }
    return allocToI64(allocator, "");
}

/// Build a sed command for the given config format.
/// Args: format, key, value, config_path (all cstr ptrs)
export fn bridge_build_sed(fmt_ptr: i64, key_ptr: i64, val_ptr: i64, path_ptr: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    const format = ptrToSlice(fmt_ptr) orelse return 0;
    const key = ptrToSlice(key_ptr) orelse return 0;
    const value = ptrToSlice(val_ptr) orelse return 0;
    const path = ptrToSlice(path_ptr) orelse return 0;

    const cmd = if (std.mem.eql(u8, format, "xml"))
        // XML: sed -i 's/Key="[^"]*"/Key="NewValue"/' file
        std.fmt.allocPrint(allocator, "sed -i 's/{s}=\"[^\"]*\"/{s}=\"{s}\"/' {s}", .{ key, key, value, path })
    else if (std.mem.eql(u8, format, "ini"))
        // INI: sed -i 's/^key *=.*/key = newvalue/' file
        std.fmt.allocPrint(allocator, "sed -i 's/^{s} *=.*/{s} = {s}/' {s}", .{ key, key, value, path })
    else
        std.fmt.allocPrint(allocator, "echo 'unsupported format: {s}'", .{format});

    const result_str = cmd catch return 0;
    const result_z = allocator.dupeZ(u8, result_str) catch return 0;
    allocator.free(result_str);
    return @intCast(@intFromPtr(result_z.ptr));
}

/// Build a podman action command.
/// Args: action (cstr), container (cstr)
export fn bridge_build_action_cmd(action_ptr: i64, container_ptr: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    const action = ptrToSlice(action_ptr) orelse return 0;
    const container = ptrToSlice(container_ptr) orelse return 0;

    const cmd = if (std.mem.eql(u8, action, "start"))
        std.fmt.allocPrint(allocator, "podman start {s}", .{container})
    else if (std.mem.eql(u8, action, "stop"))
        std.fmt.allocPrint(allocator, "podman stop {s}", .{container})
    else if (std.mem.eql(u8, action, "restart"))
        std.fmt.allocPrint(allocator, "podman restart {s}", .{container})
    else if (std.mem.eql(u8, action, "status"))
        std.fmt.allocPrint(allocator, "podman ps -a -f name=^{s}$ --format '{{{{.Status}}}}'", .{container})
    else if (std.mem.eql(u8, action, "logs"))
        std.fmt.allocPrint(allocator, "podman logs --tail 50 {s}", .{container})
    else
        std.fmt.allocPrint(allocator, "echo 'unknown action: {s}'", .{action});

    const result_str = cmd catch return 0;
    const result_z = allocator.dupeZ(u8, result_str) catch return 0;
    allocator.free(result_str);
    return @intCast(@intFromPtr(result_z.ptr));
}

/// Parse a config file into JSON key-value pairs.
/// Detects XML attributes or INI lines.
export fn bridge_parse_config(fmt_ptr: i64, content_ptr: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;

    const format = ptrToSlice(fmt_ptr) orelse return allocToI64(allocator, "[]");
    const content = ptrToSlice(content_ptr) orelse return allocToI64(allocator, "[]");

    if (std.mem.eql(u8, format, "xml")) {
        return parseXmlAttributes(allocator, content);
    } else if (std.mem.eql(u8, format, "ini")) {
        return parseIniLines(allocator, content);
    }
    return allocToI64(allocator, "[]");
}

/// Infer types for parsed key-value pairs.
/// Input: JSON array of {"key":"...","value":"..."} objects.
/// Output: same array with "type" field added.
export fn bridge_infer_types(pairs_ptr: i64, _: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    // For now, pass through — type inference is done in the overlay step
    // where we have game-specific knowledge.
    return pairs_ptr;
}

/// Overlay game-specific schema metadata.
/// Adds labels, types, ranges, and enum options based on known game schemas.
export fn bridge_overlay_schema(server_id_ptr: i64, pairs_ptr: i64, _: i64, _: i64, _: i64, _: i64) callconv(.c) i64 {
    const allocator = std.heap.c_allocator;
    const server_id = ptrToSlice(server_id_ptr) orelse return pairs_ptr;
    const pairs_json = ptrToSlice(pairs_ptr) orelse return pairs_ptr;

    // For Barotrauma, enrich with known field metadata
    if (std.mem.eql(u8, server_id, "barotrauma")) {
        return overlayBarotraumaSchema(allocator, pairs_json);
    }

    // For unknown games, auto-infer types from values
    return autoInferSchema(allocator, pairs_json);
}

//==============================================================================
// Config Parsers
//==============================================================================

/// Parse XML attributes: key="value" patterns.
/// Returns JSON: [{"key":"...","value":"..."}]
fn parseXmlAttributes(allocator: std.mem.Allocator, content: []const u8) i64 {
    var result = std.ArrayListUnmanaged(u8){};
    result.appendSlice(allocator,"[") catch return 0;

    var first = true;
    var i: usize = 0;
    while (i < content.len) {
        // Find pattern: identifier="value"
        // Skip whitespace
        while (i < content.len and (content[i] == ' ' or content[i] == '\n' or content[i] == '\r' or content[i] == '\t')) : (i += 1) {}

        // Look for key="
        const key_start = i;
        while (i < content.len and content[i] != '=' and content[i] != ' ' and content[i] != '\n' and content[i] != '<' and content[i] != '>') : (i += 1) {}

        if (i >= content.len or content[i] != '=') {
            i += 1;
            continue;
        }

        const key = content[key_start..i];
        i += 1; // skip '='

        // Expect opening quote
        if (i >= content.len or content[i] != '"') {
            continue;
        }
        i += 1; // skip '"'

        const val_start = i;
        while (i < content.len and content[i] != '"') : (i += 1) {}

        if (i >= content.len) break;

        const value = content[val_start..i];
        i += 1; // skip closing '"'

        // Skip XML-internal attributes (xmlns, version, encoding, etc.)
        if (key.len == 0) continue;
        if (std.mem.startsWith(u8, key, "<?")) continue;
        if (std.mem.eql(u8, key, "version")) continue;
        if (std.mem.eql(u8, key, "encoding")) continue;

        if (!first) result.appendSlice(allocator,",") catch return 0;
        first = false;

        const entry = std.fmt.allocPrint(allocator, "{{\"key\":\"{s}\",\"value\":\"{s}\"}}", .{ key, value }) catch return 0;
        defer allocator.free(entry);
        result.appendSlice(allocator,entry) catch return 0;
    }

    result.appendSlice(allocator,"]") catch return 0;
    const out = allocator.dupeZ(u8, result.items) catch return 0;
    result.deinit(allocator);
    return @intCast(@intFromPtr(out.ptr));
}

/// Parse INI lines: key = value patterns.
fn parseIniLines(allocator: std.mem.Allocator, content: []const u8) i64 {
    var result = std.ArrayListUnmanaged(u8){};
    result.appendSlice(allocator,"[") catch return 0;

    var first = true;
    var lines = std.mem.splitScalar(u8, content, '\n');
    var current_section: []const u8 = "General";

    while (lines.next()) |line| {
        const trimmed = std.mem.trim(u8, line, " \t\r");
        if (trimmed.len == 0) continue;
        if (trimmed[0] == '#' or trimmed[0] == ';') continue;

        // Section header [SECTION]
        if (trimmed[0] == '[' and trimmed[trimmed.len - 1] == ']') {
            current_section = trimmed[1 .. trimmed.len - 1];
            continue;
        }

        // Key = Value
        if (std.mem.indexOf(u8, trimmed, "=")) |eq_idx| {
            const key = std.mem.trim(u8, trimmed[0..eq_idx], " \t");
            const value = std.mem.trim(u8, trimmed[eq_idx + 1 ..], " \t");

            if (!first) result.appendSlice(allocator,",") catch return 0;
            first = false;

            const entry = std.fmt.allocPrint(allocator, "{{\"key\":\"{s}\",\"value\":\"{s}\",\"group\":\"{s}\"}}", .{ key, value, current_section }) catch return 0;
            defer allocator.free(entry);
            result.appendSlice(allocator,entry) catch return 0;
        }
    }

    result.appendSlice(allocator,"]") catch return 0;
    const out = allocator.dupeZ(u8, result.items) catch return 0;
    result.deinit(allocator);
    return @intCast(@intFromPtr(out.ptr));
}

//==============================================================================
// Game-Specific Schema Overlays
//==============================================================================

/// Known Barotrauma field metadata.
const BaroFieldMeta = struct {
    key: []const u8,
    label: []const u8,
    field_type: []const u8,
    group: []const u8,
    min: ?i32 = null,
    max: ?i32 = null,
    options: ?[]const []const u8 = null,
};

const baro_gamemode_options = [_][]const u8{ "mission", "sandbox", "multiplayercampaign", "pvp" };
const baro_respawn_options = [_][]const u8{ "MidRound", "BetweenRounds" };
const baro_playstyle_options = [_][]const u8{ "Serious", "Casual", "Roleplay", "Rampage", "SomethingDifferent" };
const baro_losmode_options = [_][]const u8{ "None", "Transparent", "Opaque" };
const baro_botspawn_options = [_][]const u8{ "Normal", "Fill" };

const baro_fields = [_]BaroFieldMeta{
    .{ .key = "ServerName", .label = "Server Name", .field_type = "string", .group = "Server" },
    .{ .key = "password", .label = "Password", .field_type = "string", .group = "Server" },
    .{ .key = "IsPublic", .label = "Public Server", .field_type = "bool", .group = "Server" },
    .{ .key = "MaxPlayers", .label = "Max Players", .field_type = "int", .group = "Server", .min = 1, .max = 16 },
    .{ .key = "TickRate", .label = "Tick Rate", .field_type = "int", .group = "Server", .min = 10, .max = 60 },
    .{ .key = "GameModeIdentifier", .label = "Game Mode", .field_type = "enum", .group = "Gameplay", .options = &baro_gamemode_options },
    .{ .key = "SelectedSubmarine", .label = "Submarine", .field_type = "string", .group = "Gameplay" },
    .{ .key = "SelectedShuttle", .label = "Shuttle", .field_type = "string", .group = "Gameplay" },
    .{ .key = "SelectedLevelDifficulty", .label = "Difficulty", .field_type = "int", .group = "Gameplay", .min = 0, .max = 100 },
    .{ .key = "BotCount", .label = "Bot Count", .field_type = "int", .group = "Gameplay", .min = 0, .max = 16 },
    .{ .key = "MaxBotCount", .label = "Max Bot Count", .field_type = "int", .group = "Gameplay", .min = 0, .max = 16 },
    .{ .key = "BotSpawnMode", .label = "Bot Spawn Mode", .field_type = "enum", .group = "Gameplay", .options = &baro_botspawn_options },
    .{ .key = "RespawnMode", .label = "Respawn Mode", .field_type = "enum", .group = "Gameplay", .options = &baro_respawn_options },
    .{ .key = "MinRespawnRatio", .label = "Min Respawn Ratio", .field_type = "float", .group = "Gameplay" },
    .{ .key = "RespawnInterval", .label = "Respawn Interval (s)", .field_type = "int", .group = "Gameplay", .min = 0, .max = 600 },
    .{ .key = "AllowFriendlyFire", .label = "Friendly Fire", .field_type = "bool", .group = "Rules" },
    .{ .key = "AllowRewiring", .label = "Allow Rewiring", .field_type = "bool", .group = "Rules" },
    .{ .key = "AllowDisguises", .label = "Allow Disguises", .field_type = "bool", .group = "Rules" },
    .{ .key = "VoiceChatEnabled", .label = "Voice Chat", .field_type = "bool", .group = "Communication" },
    .{ .key = "PlayStyle", .label = "Play Style", .field_type = "enum", .group = "Server", .options = &baro_playstyle_options },
    .{ .key = "LosMode", .label = "Line of Sight", .field_type = "enum", .group = "Gameplay", .options = &baro_losmode_options },
    .{ .key = "StartWhenClientsReady", .label = "Start When Ready", .field_type = "bool", .group = "Lobby" },
    .{ .key = "StartWhenClientsReadyRatio", .label = "Ready Ratio", .field_type = "float", .group = "Lobby" },
    .{ .key = "AllowSpectating", .label = "Allow Spectating", .field_type = "bool", .group = "Rules" },
    .{ .key = "KarmaEnabled", .label = "Karma System", .field_type = "bool", .group = "Rules" },
    .{ .key = "AllowVoteKick", .label = "Vote Kick", .field_type = "bool", .group = "Rules" },
    .{ .key = "enableupnp", .label = "UPnP", .field_type = "bool", .group = "Network" },
    .{ .key = "MaxLagCompensation", .label = "Max Lag Compensation (ms)", .field_type = "int", .group = "Network", .min = 0, .max = 500 },
};

/// Overlay Barotrauma-specific metadata onto parsed fields.
fn overlayBarotraumaSchema(allocator: std.mem.Allocator, pairs_json: []const u8) i64 {
    _ = pairs_json;
    // Build the enriched schema directly from the known fields + current server values.
    // We SSH to get current values and merge with metadata.
    var result = std.ArrayListUnmanaged(u8){};
    result.appendSlice(allocator,"[") catch return 0;

    // Get current config from VPS
    const ssh_argv = [_][]const u8{ "ssh", "-o", "ConnectTimeout=5", "-o", "StrictHostKeyChecking=no", VPS_HOST, "cat /opt/barotrauma-game/serversettings.xml" };
    const ssh_result = std.process.Child.run(.{ .allocator = allocator, .argv = &ssh_argv }) catch {
        result.deinit(allocator);
        return allocToI64(allocator, "[]");
    };
    defer allocator.free(ssh_result.stdout);
    defer allocator.free(ssh_result.stderr);

    var first = true;
    for (baro_fields) |field| {
        // Extract current value from XML
        const current_value = extractXmlAttribute(allocator, ssh_result.stdout, field.key) orelse "";

        if (!first) result.appendSlice(allocator,",") catch return 0;
        first = false;

        // Build JSON entry with metadata
        var entry = std.ArrayListUnmanaged(u8){};
        const base = std.fmt.allocPrint(allocator, "{{\"key\":\"{s}\",\"label\":\"{s}\",\"type\":\"{s}\",\"group\":\"{s}\",\"value\":\"{s}\"", .{ field.key, field.label, field.field_type, field.group, current_value }) catch return 0;
        defer allocator.free(base);
        entry.appendSlice(allocator,base) catch return 0;

        if (field.min) |min| {
            const min_str = std.fmt.allocPrint(allocator, ",\"min\":{d}", .{min}) catch return 0;
            defer allocator.free(min_str);
            entry.appendSlice(allocator,min_str) catch return 0;
        }
        if (field.max) |max| {
            const max_str = std.fmt.allocPrint(allocator, ",\"max\":{d}", .{max}) catch return 0;
            defer allocator.free(max_str);
            entry.appendSlice(allocator,max_str) catch return 0;
        }
        if (field.options) |options| {
            entry.appendSlice(allocator,",\"options\":[") catch return 0;
            for (options, 0..) |opt, oi| {
                if (oi > 0) entry.appendSlice(allocator,",") catch return 0;
                const opt_str = std.fmt.allocPrint(allocator, "\"{s}\"", .{opt}) catch return 0;
                defer allocator.free(opt_str);
                entry.appendSlice(allocator,opt_str) catch return 0;
            }
            entry.appendSlice(allocator,"]") catch return 0;
        }

        entry.appendSlice(allocator,"}") catch return 0;
        result.appendSlice(allocator,entry.items) catch return 0;
        entry.deinit(allocator);
    }

    result.appendSlice(allocator,"]") catch return 0;
    const out = allocator.dupeZ(u8, result.items) catch return 0;
    result.deinit(allocator);
    return @intCast(@intFromPtr(out.ptr));
}

/// Auto-infer schema from raw key-value pairs (for unknown games).
fn autoInferSchema(allocator: std.mem.Allocator, pairs_json: []const u8) i64 {
    // Simple pass-through with type inference based on value patterns.
    // "True"/"False" -> bool, digits -> int, digits with '.' -> float, else string.
    _ = allocator;
    // TODO: implement generic type inference
    return @intCast(@intFromPtr(pairs_json.ptr));
}

//==============================================================================
// Helpers
//==============================================================================

/// Extract an XML attribute value by key from raw XML content.
fn extractXmlAttribute(allocator: std.mem.Allocator, xml: []const u8, key: []const u8) ?[]const u8 {
    const search = std.fmt.allocPrint(allocator, "{s}=\"", .{key}) catch return null;
    defer allocator.free(search);

    const start_idx = std.mem.indexOf(u8, xml, search) orelse return null;
    const value_start = start_idx + search.len;

    var i: usize = value_start;
    while (i < xml.len and xml[i] != '"') : (i += 1) {}
    if (i >= xml.len) return null;

    return xml[value_start..i];
}

/// Convert a i64 (Ephapax FFI convention) to a slice by treating it as a C string pointer.
fn ptrToSlice(val: i64) ?[]const u8 {
    if (val == 0) return null;
    const ptr: [*:0]const u8 = @ptrFromInt(@as(usize, @intCast(val)));
    return std.mem.span(ptr);
}

/// Allocate a null-terminated copy of a string and return as i64 pointer.
fn allocToI64(allocator: std.mem.Allocator, str: []const u8) i64 {
    const z = allocator.dupeZ(u8, str) catch return 0;
    return @intCast(@intFromPtr(z.ptr));
}
