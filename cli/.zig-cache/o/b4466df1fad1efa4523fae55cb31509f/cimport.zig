pub const __builtin_bswap16 = @import("std").zig.c_builtins.__builtin_bswap16;
pub const __builtin_bswap32 = @import("std").zig.c_builtins.__builtin_bswap32;
pub const __builtin_bswap64 = @import("std").zig.c_builtins.__builtin_bswap64;
pub const __builtin_signbit = @import("std").zig.c_builtins.__builtin_signbit;
pub const __builtin_signbitf = @import("std").zig.c_builtins.__builtin_signbitf;
pub const __builtin_popcount = @import("std").zig.c_builtins.__builtin_popcount;
pub const __builtin_ctz = @import("std").zig.c_builtins.__builtin_ctz;
pub const __builtin_clz = @import("std").zig.c_builtins.__builtin_clz;
pub const __builtin_sqrt = @import("std").zig.c_builtins.__builtin_sqrt;
pub const __builtin_sqrtf = @import("std").zig.c_builtins.__builtin_sqrtf;
pub const __builtin_sin = @import("std").zig.c_builtins.__builtin_sin;
pub const __builtin_sinf = @import("std").zig.c_builtins.__builtin_sinf;
pub const __builtin_cos = @import("std").zig.c_builtins.__builtin_cos;
pub const __builtin_cosf = @import("std").zig.c_builtins.__builtin_cosf;
pub const __builtin_exp = @import("std").zig.c_builtins.__builtin_exp;
pub const __builtin_expf = @import("std").zig.c_builtins.__builtin_expf;
pub const __builtin_exp2 = @import("std").zig.c_builtins.__builtin_exp2;
pub const __builtin_exp2f = @import("std").zig.c_builtins.__builtin_exp2f;
pub const __builtin_log = @import("std").zig.c_builtins.__builtin_log;
pub const __builtin_logf = @import("std").zig.c_builtins.__builtin_logf;
pub const __builtin_log2 = @import("std").zig.c_builtins.__builtin_log2;
pub const __builtin_log2f = @import("std").zig.c_builtins.__builtin_log2f;
pub const __builtin_log10 = @import("std").zig.c_builtins.__builtin_log10;
pub const __builtin_log10f = @import("std").zig.c_builtins.__builtin_log10f;
pub const __builtin_abs = @import("std").zig.c_builtins.__builtin_abs;
pub const __builtin_labs = @import("std").zig.c_builtins.__builtin_labs;
pub const __builtin_llabs = @import("std").zig.c_builtins.__builtin_llabs;
pub const __builtin_fabs = @import("std").zig.c_builtins.__builtin_fabs;
pub const __builtin_fabsf = @import("std").zig.c_builtins.__builtin_fabsf;
pub const __builtin_floor = @import("std").zig.c_builtins.__builtin_floor;
pub const __builtin_floorf = @import("std").zig.c_builtins.__builtin_floorf;
pub const __builtin_ceil = @import("std").zig.c_builtins.__builtin_ceil;
pub const __builtin_ceilf = @import("std").zig.c_builtins.__builtin_ceilf;
pub const __builtin_trunc = @import("std").zig.c_builtins.__builtin_trunc;
pub const __builtin_truncf = @import("std").zig.c_builtins.__builtin_truncf;
pub const __builtin_round = @import("std").zig.c_builtins.__builtin_round;
pub const __builtin_roundf = @import("std").zig.c_builtins.__builtin_roundf;
pub const __builtin_strlen = @import("std").zig.c_builtins.__builtin_strlen;
pub const __builtin_strcmp = @import("std").zig.c_builtins.__builtin_strcmp;
pub const __builtin_object_size = @import("std").zig.c_builtins.__builtin_object_size;
pub const __builtin___memset_chk = @import("std").zig.c_builtins.__builtin___memset_chk;
pub const __builtin_memset = @import("std").zig.c_builtins.__builtin_memset;
pub const __builtin___memcpy_chk = @import("std").zig.c_builtins.__builtin___memcpy_chk;
pub const __builtin_memcpy = @import("std").zig.c_builtins.__builtin_memcpy;
pub const __builtin_expect = @import("std").zig.c_builtins.__builtin_expect;
pub const __builtin_nanf = @import("std").zig.c_builtins.__builtin_nanf;
pub const __builtin_huge_valf = @import("std").zig.c_builtins.__builtin_huge_valf;
pub const __builtin_inff = @import("std").zig.c_builtins.__builtin_inff;
pub const __builtin_isnan = @import("std").zig.c_builtins.__builtin_isnan;
pub const __builtin_isinf = @import("std").zig.c_builtins.__builtin_isinf;
pub const __builtin_isinf_sign = @import("std").zig.c_builtins.__builtin_isinf_sign;
pub const __has_builtin = @import("std").zig.c_builtins.__has_builtin;
pub const __builtin_assume = @import("std").zig.c_builtins.__builtin_assume;
pub const __builtin_unreachable = @import("std").zig.c_builtins.__builtin_unreachable;
pub const __builtin_constant_p = @import("std").zig.c_builtins.__builtin_constant_p;
pub const __builtin_mul_overflow = @import("std").zig.c_builtins.__builtin_mul_overflow;
pub const ptrdiff_t = c_long;
pub const wchar_t = c_int;
pub const max_align_t = extern struct {
    __clang_max_align_nonce1: c_longlong align(8) = @import("std").mem.zeroes(c_longlong),
    __clang_max_align_nonce2: c_longdouble align(16) = @import("std").mem.zeroes(c_longdouble),
};
pub const gint8 = i8;
pub const guint8 = u8;
pub const gint16 = c_short;
pub const guint16 = c_ushort;
pub const gint32 = c_int;
pub const guint32 = c_uint;
pub const gint64 = c_long;
pub const guint64 = c_ulong;
pub const gssize = c_long;
pub const gsize = c_ulong;
pub const goffset = gint64;
pub const gintptr = c_long;
pub const guintptr = c_ulong;
pub const GPid = c_int;
pub const __u_char = u8;
pub const __u_short = c_ushort;
pub const __u_int = c_uint;
pub const __u_long = c_ulong;
pub const __int8_t = i8;
pub const __uint8_t = u8;
pub const __int16_t = c_short;
pub const __uint16_t = c_ushort;
pub const __int32_t = c_int;
pub const __uint32_t = c_uint;
pub const __int64_t = c_long;
pub const __uint64_t = c_ulong;
pub const __int_least8_t = __int8_t;
pub const __uint_least8_t = __uint8_t;
pub const __int_least16_t = __int16_t;
pub const __uint_least16_t = __uint16_t;
pub const __int_least32_t = __int32_t;
pub const __uint_least32_t = __uint32_t;
pub const __int_least64_t = __int64_t;
pub const __uint_least64_t = __uint64_t;
pub const __quad_t = c_long;
pub const __u_quad_t = c_ulong;
pub const __intmax_t = c_long;
pub const __uintmax_t = c_ulong;
pub const __dev_t = c_ulong;
pub const __uid_t = c_uint;
pub const __gid_t = c_uint;
pub const __ino_t = c_ulong;
pub const __ino64_t = c_ulong;
pub const __mode_t = c_uint;
pub const __nlink_t = c_ulong;
pub const __off_t = c_long;
pub const __off64_t = c_long;
pub const __pid_t = c_int;
pub const __fsid_t = extern struct {
    __val: [2]c_int = @import("std").mem.zeroes([2]c_int),
};
pub const __clock_t = c_long;
pub const __rlim_t = c_ulong;
pub const __rlim64_t = c_ulong;
pub const __id_t = c_uint;
pub const __time_t = c_long;
pub const __useconds_t = c_uint;
pub const __suseconds_t = c_long;
pub const __suseconds64_t = c_long;
pub const __daddr_t = c_int;
pub const __key_t = c_int;
pub const __clockid_t = c_int;
pub const __timer_t = ?*anyopaque;
pub const __blksize_t = c_long;
pub const __blkcnt_t = c_long;
pub const __blkcnt64_t = c_long;
pub const __fsblkcnt_t = c_ulong;
pub const __fsblkcnt64_t = c_ulong;
pub const __fsfilcnt_t = c_ulong;
pub const __fsfilcnt64_t = c_ulong;
pub const __fsword_t = c_long;
pub const __ssize_t = c_long;
pub const __syscall_slong_t = c_long;
pub const __syscall_ulong_t = c_ulong;
pub const __loff_t = __off64_t;
pub const __caddr_t = [*c]u8;
pub const __intptr_t = c_long;
pub const __socklen_t = c_uint;
pub const __sig_atomic_t = c_int;
pub const clock_t = __clock_t;
pub const time_t = __time_t;
pub const struct_tm = extern struct {
    tm_sec: c_int = @import("std").mem.zeroes(c_int),
    tm_min: c_int = @import("std").mem.zeroes(c_int),
    tm_hour: c_int = @import("std").mem.zeroes(c_int),
    tm_mday: c_int = @import("std").mem.zeroes(c_int),
    tm_mon: c_int = @import("std").mem.zeroes(c_int),
    tm_year: c_int = @import("std").mem.zeroes(c_int),
    tm_wday: c_int = @import("std").mem.zeroes(c_int),
    tm_yday: c_int = @import("std").mem.zeroes(c_int),
    tm_isdst: c_int = @import("std").mem.zeroes(c_int),
    tm_gmtoff: c_long = @import("std").mem.zeroes(c_long),
    tm_zone: [*c]const u8 = @import("std").mem.zeroes([*c]const u8),
};
pub const struct_timespec = extern struct {
    tv_sec: __time_t = @import("std").mem.zeroes(__time_t),
    tv_nsec: __syscall_slong_t = @import("std").mem.zeroes(__syscall_slong_t),
};
pub const clockid_t = __clockid_t;
pub const timer_t = __timer_t;
pub const struct_itimerspec = extern struct {
    it_interval: struct_timespec = @import("std").mem.zeroes(struct_timespec),
    it_value: struct_timespec = @import("std").mem.zeroes(struct_timespec),
};
pub const union_sigval = extern union {
    sival_int: c_int,
    sival_ptr: ?*anyopaque,
};
pub const __sigval_t = union_sigval;
pub const union_pthread_attr_t = extern union {
    __size: [56]u8,
    __align: c_long,
};
pub const pthread_attr_t = union_pthread_attr_t;
const struct_unnamed_2 = extern struct {
    _function: ?*const fn (__sigval_t) callconv(.c) void = @import("std").mem.zeroes(?*const fn (__sigval_t) callconv(.c) void),
    _attribute: [*c]pthread_attr_t = @import("std").mem.zeroes([*c]pthread_attr_t),
};
const union_unnamed_1 = extern union {
    _pad: [12]c_int,
    _tid: __pid_t,
    _sigev_thread: struct_unnamed_2,
};
pub const struct_sigevent = extern struct {
    sigev_value: __sigval_t = @import("std").mem.zeroes(__sigval_t),
    sigev_signo: c_int = @import("std").mem.zeroes(c_int),
    sigev_notify: c_int = @import("std").mem.zeroes(c_int),
    _sigev_un: union_unnamed_1 = @import("std").mem.zeroes(union_unnamed_1),
};
pub const pid_t = __pid_t;
pub const struct___locale_data_3 = opaque {};
pub const struct___locale_struct = extern struct {
    __locales: [13]?*struct___locale_data_3 = @import("std").mem.zeroes([13]?*struct___locale_data_3),
    __ctype_b: [*c]const c_ushort = @import("std").mem.zeroes([*c]const c_ushort),
    __ctype_tolower: [*c]const c_int = @import("std").mem.zeroes([*c]const c_int),
    __ctype_toupper: [*c]const c_int = @import("std").mem.zeroes([*c]const c_int),
    __names: [13][*c]const u8 = @import("std").mem.zeroes([13][*c]const u8),
};
pub const __locale_t = [*c]struct___locale_struct;
pub const locale_t = __locale_t;
pub extern fn clock() clock_t;
pub extern fn time(__timer: [*c]time_t) time_t;
pub extern fn difftime(__time1: time_t, __time0: time_t) f64;
pub extern fn mktime(__tp: [*c]struct_tm) time_t;
pub extern fn strftime(noalias __s: [*c]u8, __maxsize: usize, noalias __format: [*c]const u8, noalias __tp: [*c]const struct_tm) usize;
pub extern fn strftime_l(noalias __s: [*c]u8, __maxsize: usize, noalias __format: [*c]const u8, noalias __tp: [*c]const struct_tm, __loc: locale_t) usize;
pub extern fn gmtime(__timer: [*c]const time_t) [*c]struct_tm;
pub extern fn localtime(__timer: [*c]const time_t) [*c]struct_tm;
pub extern fn gmtime_r(noalias __timer: [*c]const time_t, noalias __tp: [*c]struct_tm) [*c]struct_tm;
pub extern fn localtime_r(noalias __timer: [*c]const time_t, noalias __tp: [*c]struct_tm) [*c]struct_tm;
pub extern fn asctime(__tp: [*c]const struct_tm) [*c]u8;
pub extern fn ctime(__timer: [*c]const time_t) [*c]u8;
pub extern fn asctime_r(noalias __tp: [*c]const struct_tm, noalias __buf: [*c]u8) [*c]u8;
pub extern fn ctime_r(noalias __timer: [*c]const time_t, noalias __buf: [*c]u8) [*c]u8;
pub extern var __tzname: [2][*c]u8;
pub extern var __daylight: c_int;
pub extern var __timezone: c_long;
pub extern var tzname: [2][*c]u8;
pub extern fn tzset() void;
pub extern var daylight: c_int;
pub extern var timezone: c_long;
pub extern fn timegm(__tp: [*c]struct_tm) time_t;
pub extern fn timelocal(__tp: [*c]struct_tm) time_t;
pub extern fn dysize(__year: c_int) c_int;
pub extern fn nanosleep(__requested_time: [*c]const struct_timespec, __remaining: [*c]struct_timespec) c_int;
pub extern fn clock_getres(__clock_id: clockid_t, __res: [*c]struct_timespec) c_int;
pub extern fn clock_gettime(__clock_id: clockid_t, __tp: [*c]struct_timespec) c_int;
pub extern fn clock_settime(__clock_id: clockid_t, __tp: [*c]const struct_timespec) c_int;
pub extern fn clock_nanosleep(__clock_id: clockid_t, __flags: c_int, __req: [*c]const struct_timespec, __rem: [*c]struct_timespec) c_int;
pub extern fn clock_getcpuclockid(__pid: pid_t, __clock_id: [*c]clockid_t) c_int;
pub extern fn timer_create(__clock_id: clockid_t, noalias __evp: [*c]struct_sigevent, noalias __timerid: [*c]timer_t) c_int;
pub extern fn timer_delete(__timerid: timer_t) c_int;
pub extern fn timer_settime(__timerid: timer_t, __flags: c_int, noalias __value: [*c]const struct_itimerspec, noalias __ovalue: [*c]struct_itimerspec) c_int;
pub extern fn timer_gettime(__timerid: timer_t, __value: [*c]struct_itimerspec) c_int;
pub extern fn timer_getoverrun(__timerid: timer_t) c_int;
pub extern fn timespec_get(__ts: [*c]struct_timespec, __base: c_int) c_int;
pub const gchar = u8;
pub const gshort = c_short;
pub const glong = c_long;
pub const gint = c_int;
pub const gboolean = gint;
pub const guchar = u8;
pub const gushort = c_ushort;
pub const gulong = c_ulong;
pub const guint = c_uint;
pub const gfloat = f32;
pub const gdouble = f64;
pub const gpointer = ?*anyopaque;
pub const gconstpointer = ?*const anyopaque;
pub const GCompareFunc = ?*const fn (gconstpointer, gconstpointer) callconv(.c) gint;
pub const GCompareDataFunc = ?*const fn (gconstpointer, gconstpointer, gpointer) callconv(.c) gint;
pub const GEqualFunc = ?*const fn (gconstpointer, gconstpointer) callconv(.c) gboolean;
pub const GEqualFuncFull = ?*const fn (gconstpointer, gconstpointer, gpointer) callconv(.c) gboolean;
pub const GDestroyNotify = ?*const fn (gpointer) callconv(.c) void;
pub const GFunc = ?*const fn (gpointer, gpointer) callconv(.c) void;
pub const GHashFunc = ?*const fn (gconstpointer) callconv(.c) guint;
pub const GHFunc = ?*const fn (gpointer, gpointer, gpointer) callconv(.c) void;
pub const GCopyFunc = ?*const fn (gconstpointer, gpointer) callconv(.c) gpointer;
pub const GFreeFunc = ?*const fn (gpointer) callconv(.c) void;
pub const GTranslateFunc = ?*const fn ([*c]const gchar, gpointer) callconv(.c) [*c]const gchar;
// /usr/include/glib-2.0/glib/gtypes.h:548:11: warning: struct demoted to opaque type - has bitfield
const struct_unnamed_4 = opaque {};
pub const union__GDoubleIEEE754 = extern union {
    v_double: gdouble,
    mpn: struct_unnamed_4,
};
pub const GDoubleIEEE754 = union__GDoubleIEEE754;
// /usr/include/glib-2.0/glib/gtypes.h:539:11: warning: struct demoted to opaque type - has bitfield
const struct_unnamed_5 = opaque {};
pub const union__GFloatIEEE754 = extern union {
    v_float: gfloat,
    mpn: struct_unnamed_5,
};
pub const GFloatIEEE754 = union__GFloatIEEE754;
pub const struct__GTimeVal = extern struct {
    tv_sec: glong = @import("std").mem.zeroes(glong),
    tv_usec: glong = @import("std").mem.zeroes(glong),
};
pub const GTimeVal = struct__GTimeVal;
pub const grefcount = gint;
pub const gatomicrefcount = gint;
pub extern fn memcpy(__dest: ?*anyopaque, __src: ?*const anyopaque, __n: c_ulong) ?*anyopaque;
pub extern fn memmove(__dest: ?*anyopaque, __src: ?*const anyopaque, __n: c_ulong) ?*anyopaque;
pub extern fn memccpy(__dest: ?*anyopaque, __src: ?*const anyopaque, __c: c_int, __n: c_ulong) ?*anyopaque;
pub extern fn memset(__s: ?*anyopaque, __c: c_int, __n: c_ulong) ?*anyopaque;
pub extern fn memcmp(__s1: ?*const anyopaque, __s2: ?*const anyopaque, __n: c_ulong) c_int;
pub extern fn __memcmpeq(__s1: ?*const anyopaque, __s2: ?*const anyopaque, __n: usize) c_int;
pub extern fn memchr(__s: ?*const anyopaque, __c: c_int, __n: c_ulong) ?*anyopaque;
pub extern fn strcpy(__dest: [*c]u8, __src: [*c]const u8) [*c]u8;
pub extern fn strncpy(__dest: [*c]u8, __src: [*c]const u8, __n: c_ulong) [*c]u8;
pub extern fn strcat(__dest: [*c]u8, __src: [*c]const u8) [*c]u8;
pub extern fn strncat(__dest: [*c]u8, __src: [*c]const u8, __n: c_ulong) [*c]u8;
pub extern fn strcmp(__s1: [*c]const u8, __s2: [*c]const u8) c_int;
pub extern fn strncmp(__s1: [*c]const u8, __s2: [*c]const u8, __n: c_ulong) c_int;
pub extern fn strcoll(__s1: [*c]const u8, __s2: [*c]const u8) c_int;
pub extern fn strxfrm(__dest: [*c]u8, __src: [*c]const u8, __n: c_ulong) c_ulong;
pub extern fn strcoll_l(__s1: [*c]const u8, __s2: [*c]const u8, __l: locale_t) c_int;
pub extern fn strxfrm_l(__dest: [*c]u8, __src: [*c]const u8, __n: usize, __l: locale_t) usize;
pub extern fn strdup(__s: [*c]const u8) [*c]u8;
pub extern fn strndup(__string: [*c]const u8, __n: c_ulong) [*c]u8;
pub extern fn strchr(__s: [*c]const u8, __c: c_int) [*c]u8;
pub extern fn strrchr(__s: [*c]const u8, __c: c_int) [*c]u8;
pub extern fn strchrnul(__s: [*c]const u8, __c: c_int) [*c]u8;
pub extern fn strcspn(__s: [*c]const u8, __reject: [*c]const u8) c_ulong;
pub extern fn strspn(__s: [*c]const u8, __accept: [*c]const u8) c_ulong;
pub extern fn strpbrk(__s: [*c]const u8, __accept: [*c]const u8) [*c]u8;
pub extern fn strstr(__haystack: [*c]const u8, __needle: [*c]const u8) [*c]u8;
pub extern fn strtok(__s: [*c]u8, __delim: [*c]const u8) [*c]u8;
pub extern fn __strtok_r(noalias __s: [*c]u8, noalias __delim: [*c]const u8, noalias __save_ptr: [*c][*c]u8) [*c]u8;
pub extern fn strtok_r(noalias __s: [*c]u8, noalias __delim: [*c]const u8, noalias __save_ptr: [*c][*c]u8) [*c]u8;
pub extern fn strcasestr(__haystack: [*c]const u8, __needle: [*c]const u8) [*c]u8;
pub extern fn memmem(__haystack: ?*const anyopaque, __haystacklen: usize, __needle: ?*const anyopaque, __needlelen: usize) ?*anyopaque;
pub extern fn __mempcpy(noalias __dest: ?*anyopaque, noalias __src: ?*const anyopaque, __n: usize) ?*anyopaque;
pub extern fn mempcpy(__dest: ?*anyopaque, __src: ?*const anyopaque, __n: c_ulong) ?*anyopaque;
pub extern fn strlen(__s: [*c]const u8) c_ulong;
pub extern fn strnlen(__string: [*c]const u8, __maxlen: usize) usize;
pub extern fn strerror(__errnum: c_int) [*c]u8;
pub extern fn strerror_r(__errnum: c_int, __buf: [*c]u8, __buflen: usize) c_int;
pub extern fn strerror_l(__errnum: c_int, __l: locale_t) [*c]u8;
pub extern fn bcmp(__s1: ?*const anyopaque, __s2: ?*const anyopaque, __n: c_ulong) c_int;
pub extern fn bcopy(__src: ?*const anyopaque, __dest: ?*anyopaque, __n: c_ulong) void;
pub extern fn bzero(__s: ?*anyopaque, __n: c_ulong) void;
pub extern fn index(__s: [*c]const u8, __c: c_int) [*c]u8;
pub extern fn rindex(__s: [*c]const u8, __c: c_int) [*c]u8;
pub extern fn ffs(__i: c_int) c_int;
pub extern fn ffsl(__l: c_long) c_int;
pub extern fn ffsll(__ll: c_longlong) c_int;
pub extern fn strcasecmp(__s1: [*c]const u8, __s2: [*c]const u8) c_int;
pub extern fn strncasecmp(__s1: [*c]const u8, __s2: [*c]const u8, __n: c_ulong) c_int;
pub extern fn strcasecmp_l(__s1: [*c]const u8, __s2: [*c]const u8, __loc: locale_t) c_int;
pub extern fn strncasecmp_l(__s1: [*c]const u8, __s2: [*c]const u8, __n: usize, __loc: locale_t) c_int;
pub extern fn explicit_bzero(__s: ?*anyopaque, __n: usize) void;
pub extern fn strsep(noalias __stringp: [*c][*c]u8, noalias __delim: [*c]const u8) [*c]u8;
pub extern fn strsignal(__sig: c_int) [*c]u8;
pub extern fn __stpcpy(noalias __dest: [*c]u8, noalias __src: [*c]const u8) [*c]u8;
pub extern fn stpcpy(__dest: [*c]u8, __src: [*c]const u8) [*c]u8;
pub extern fn __stpncpy(noalias __dest: [*c]u8, noalias __src: [*c]const u8, __n: usize) [*c]u8;
pub extern fn stpncpy(__dest: [*c]u8, __src: [*c]const u8, __n: c_ulong) [*c]u8;
pub extern fn strlcpy(__dest: [*c]u8, __src: [*c]const u8, __n: c_ulong) c_ulong;
pub extern fn strlcat(__dest: [*c]u8, __src: [*c]const u8, __n: c_ulong) c_ulong;
pub const struct__GBytes = opaque {};
pub const GBytes = struct__GBytes;
pub const struct__GArray = extern struct {
    data: [*c]gchar = @import("std").mem.zeroes([*c]gchar),
    len: guint = @import("std").mem.zeroes(guint),
};
pub const GArray = struct__GArray;
pub const struct__GByteArray = extern struct {
    data: [*c]guint8 = @import("std").mem.zeroes([*c]guint8),
    len: guint = @import("std").mem.zeroes(guint),
};
pub const GByteArray = struct__GByteArray;
pub const struct__GPtrArray = extern struct {
    pdata: [*c]gpointer = @import("std").mem.zeroes([*c]gpointer),
    len: guint = @import("std").mem.zeroes(guint),
};
pub const GPtrArray = struct__GPtrArray;
pub extern fn g_array_new(zero_terminated: gboolean, clear_: gboolean, element_size: guint) [*c]GArray;
pub extern fn g_array_new_take(data: gpointer, len: gsize, clear: gboolean, element_size: gsize) [*c]GArray;
pub extern fn g_array_new_take_zero_terminated(data: gpointer, clear: gboolean, element_size: gsize) [*c]GArray;
pub extern fn g_array_steal(array: [*c]GArray, len: [*c]gsize) gpointer;
pub extern fn g_array_sized_new(zero_terminated: gboolean, clear_: gboolean, element_size: guint, reserved_size: guint) [*c]GArray;
pub extern fn g_array_copy(array: [*c]GArray) [*c]GArray;
pub extern fn g_array_free(array: [*c]GArray, free_segment: gboolean) [*c]gchar;
pub extern fn g_array_ref(array: [*c]GArray) [*c]GArray;
pub extern fn g_array_unref(array: [*c]GArray) void;
pub extern fn g_array_get_element_size(array: [*c]GArray) guint;
pub extern fn g_array_append_vals(array: [*c]GArray, data: gconstpointer, len: guint) [*c]GArray;
pub extern fn g_array_prepend_vals(array: [*c]GArray, data: gconstpointer, len: guint) [*c]GArray;
pub extern fn g_array_insert_vals(array: [*c]GArray, index_: guint, data: gconstpointer, len: guint) [*c]GArray;
pub extern fn g_array_set_size(array: [*c]GArray, length: guint) [*c]GArray;
pub extern fn g_array_remove_index(array: [*c]GArray, index_: guint) [*c]GArray;
pub extern fn g_array_remove_index_fast(array: [*c]GArray, index_: guint) [*c]GArray;
pub extern fn g_array_remove_range(array: [*c]GArray, index_: guint, length: guint) [*c]GArray;
pub extern fn g_array_sort(array: [*c]GArray, compare_func: GCompareFunc) void;
pub extern fn g_array_sort_with_data(array: [*c]GArray, compare_func: GCompareDataFunc, user_data: gpointer) void;
pub extern fn g_array_binary_search(array: [*c]GArray, target: gconstpointer, compare_func: GCompareFunc, out_match_index: [*c]guint) gboolean;
pub extern fn g_array_set_clear_func(array: [*c]GArray, clear_func: GDestroyNotify) void;
pub extern fn g_ptr_array_new() [*c]GPtrArray;
pub extern fn g_ptr_array_new_with_free_func(element_free_func: GDestroyNotify) [*c]GPtrArray;
pub extern fn g_ptr_array_new_take(data: [*c]gpointer, len: gsize, element_free_func: GDestroyNotify) [*c]GPtrArray;
pub extern fn g_ptr_array_new_from_array(data: [*c]gpointer, len: gsize, copy_func: GCopyFunc, copy_func_user_data: gpointer, element_free_func: GDestroyNotify) [*c]GPtrArray;
pub extern fn g_ptr_array_steal(array: [*c]GPtrArray, len: [*c]gsize) [*c]gpointer;
pub extern fn g_ptr_array_copy(array: [*c]GPtrArray, func: GCopyFunc, user_data: gpointer) [*c]GPtrArray;
pub extern fn g_ptr_array_sized_new(reserved_size: guint) [*c]GPtrArray;
pub extern fn g_ptr_array_new_full(reserved_size: guint, element_free_func: GDestroyNotify) [*c]GPtrArray;
pub extern fn g_ptr_array_new_null_terminated(reserved_size: guint, element_free_func: GDestroyNotify, null_terminated: gboolean) [*c]GPtrArray;
pub extern fn g_ptr_array_new_take_null_terminated(data: [*c]gpointer, element_free_func: GDestroyNotify) [*c]GPtrArray;
pub extern fn g_ptr_array_new_from_null_terminated_array(data: [*c]gpointer, copy_func: GCopyFunc, copy_func_user_data: gpointer, element_free_func: GDestroyNotify) [*c]GPtrArray;
pub extern fn g_ptr_array_free(array: [*c]GPtrArray, free_segment: gboolean) [*c]gpointer;
pub extern fn g_ptr_array_ref(array: [*c]GPtrArray) [*c]GPtrArray;
pub extern fn g_ptr_array_unref(array: [*c]GPtrArray) void;
pub extern fn g_ptr_array_set_free_func(array: [*c]GPtrArray, element_free_func: GDestroyNotify) void;
pub extern fn g_ptr_array_set_size(array: [*c]GPtrArray, length: gint) void;
pub extern fn g_ptr_array_remove_index(array: [*c]GPtrArray, index_: guint) gpointer;
pub extern fn g_ptr_array_remove_index_fast(array: [*c]GPtrArray, index_: guint) gpointer;
pub extern fn g_ptr_array_steal_index(array: [*c]GPtrArray, index_: guint) gpointer;
pub extern fn g_ptr_array_steal_index_fast(array: [*c]GPtrArray, index_: guint) gpointer;
pub extern fn g_ptr_array_remove(array: [*c]GPtrArray, data: gpointer) gboolean;
pub extern fn g_ptr_array_remove_fast(array: [*c]GPtrArray, data: gpointer) gboolean;
pub extern fn g_ptr_array_remove_range(array: [*c]GPtrArray, index_: guint, length: guint) [*c]GPtrArray;
pub extern fn g_ptr_array_add(array: [*c]GPtrArray, data: gpointer) void;
pub extern fn g_ptr_array_extend(array_to_extend: [*c]GPtrArray, array: [*c]GPtrArray, func: GCopyFunc, user_data: gpointer) void;
pub extern fn g_ptr_array_extend_and_steal(array_to_extend: [*c]GPtrArray, array: [*c]GPtrArray) void;
pub extern fn g_ptr_array_insert(array: [*c]GPtrArray, index_: gint, data: gpointer) void;
pub extern fn g_ptr_array_sort(array: [*c]GPtrArray, compare_func: GCompareFunc) void;
pub extern fn g_ptr_array_sort_with_data(array: [*c]GPtrArray, compare_func: GCompareDataFunc, user_data: gpointer) void;
pub extern fn g_ptr_array_sort_values(array: [*c]GPtrArray, compare_func: GCompareFunc) void;
pub extern fn g_ptr_array_sort_values_with_data(array: [*c]GPtrArray, compare_func: GCompareDataFunc, user_data: gpointer) void;
pub extern fn g_ptr_array_foreach(array: [*c]GPtrArray, func: GFunc, user_data: gpointer) void;
pub extern fn g_ptr_array_find(haystack: [*c]GPtrArray, needle: gconstpointer, index_: [*c]guint) gboolean;
pub extern fn g_ptr_array_find_with_equal_func(haystack: [*c]GPtrArray, needle: gconstpointer, equal_func: GEqualFunc, index_: [*c]guint) gboolean;
pub extern fn g_ptr_array_is_null_terminated(array: [*c]GPtrArray) gboolean;
pub extern fn g_byte_array_new() [*c]GByteArray;
pub extern fn g_byte_array_new_take(data: [*c]guint8, len: gsize) [*c]GByteArray;
pub extern fn g_byte_array_steal(array: [*c]GByteArray, len: [*c]gsize) [*c]guint8;
pub extern fn g_byte_array_sized_new(reserved_size: guint) [*c]GByteArray;
pub extern fn g_byte_array_free(array: [*c]GByteArray, free_segment: gboolean) [*c]guint8;
pub extern fn g_byte_array_free_to_bytes(array: [*c]GByteArray) ?*GBytes;
pub extern fn g_byte_array_ref(array: [*c]GByteArray) [*c]GByteArray;
pub extern fn g_byte_array_unref(array: [*c]GByteArray) void;
pub extern fn g_byte_array_append(array: [*c]GByteArray, data: [*c]const guint8, len: guint) [*c]GByteArray;
pub extern fn g_byte_array_prepend(array: [*c]GByteArray, data: [*c]const guint8, len: guint) [*c]GByteArray;
pub extern fn g_byte_array_set_size(array: [*c]GByteArray, length: guint) [*c]GByteArray;
pub extern fn g_byte_array_remove_index(array: [*c]GByteArray, index_: guint) [*c]GByteArray;
pub extern fn g_byte_array_remove_index_fast(array: [*c]GByteArray, index_: guint) [*c]GByteArray;
pub extern fn g_byte_array_remove_range(array: [*c]GByteArray, index_: guint, length: guint) [*c]GByteArray;
pub extern fn g_byte_array_sort(array: [*c]GByteArray, compare_func: GCompareFunc) void;
pub extern fn g_byte_array_sort_with_data(array: [*c]GByteArray, compare_func: GCompareDataFunc, user_data: gpointer) void;
pub extern fn g_atomic_int_get(atomic: [*c]const volatile gint) gint;
pub extern fn g_atomic_int_set(atomic: [*c]volatile gint, newval: gint) void;
pub extern fn g_atomic_int_inc(atomic: [*c]volatile gint) void;
pub extern fn g_atomic_int_dec_and_test(atomic: [*c]volatile gint) gboolean;
pub extern fn g_atomic_int_compare_and_exchange(atomic: [*c]volatile gint, oldval: gint, newval: gint) gboolean;
pub extern fn g_atomic_int_compare_and_exchange_full(atomic: [*c]gint, oldval: gint, newval: gint, preval: [*c]gint) gboolean;
pub extern fn g_atomic_int_exchange(atomic: [*c]gint, newval: gint) gint;
pub extern fn g_atomic_int_add(atomic: [*c]volatile gint, val: gint) gint;
pub extern fn g_atomic_int_and(atomic: [*c]volatile guint, val: guint) guint;
pub extern fn g_atomic_int_or(atomic: [*c]volatile guint, val: guint) guint;
pub extern fn g_atomic_int_xor(atomic: [*c]volatile guint, val: guint) guint;
pub extern fn g_atomic_pointer_get(atomic: ?*const volatile anyopaque) gpointer;
pub extern fn g_atomic_pointer_set(atomic: ?*volatile anyopaque, newval: gpointer) void;
pub extern fn g_atomic_pointer_compare_and_exchange(atomic: ?*volatile anyopaque, oldval: gpointer, newval: gpointer) gboolean;
pub extern fn g_atomic_pointer_compare_and_exchange_full(atomic: ?*anyopaque, oldval: gpointer, newval: gpointer, preval: ?*anyopaque) gboolean;
pub extern fn g_atomic_pointer_exchange(atomic: ?*anyopaque, newval: gpointer) gpointer;
pub extern fn g_atomic_pointer_add(atomic: ?*volatile anyopaque, val: gssize) gintptr;
pub extern fn g_atomic_pointer_and(atomic: ?*volatile anyopaque, val: gsize) guintptr;
pub extern fn g_atomic_pointer_or(atomic: ?*volatile anyopaque, val: gsize) guintptr;
pub extern fn g_atomic_pointer_xor(atomic: ?*volatile anyopaque, val: gsize) guintptr;
pub extern fn g_atomic_int_exchange_and_add(atomic: [*c]volatile gint, val: gint) gint;
pub const struct___va_list_tag_6 = extern struct {
    gp_offset: c_uint = @import("std").mem.zeroes(c_uint),
    fp_offset: c_uint = @import("std").mem.zeroes(c_uint),
    overflow_arg_area: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    reg_save_area: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
};
pub const __builtin_va_list = [1]struct___va_list_tag_6;
pub const __gnuc_va_list = __builtin_va_list;
pub const va_list = __builtin_va_list;
pub const GQuark = guint32;
pub extern fn g_quark_try_string(string: [*c]const gchar) GQuark;
pub extern fn g_quark_from_static_string(string: [*c]const gchar) GQuark;
pub extern fn g_quark_from_string(string: [*c]const gchar) GQuark;
pub extern fn g_quark_to_string(quark: GQuark) [*c]const gchar;
pub extern fn g_intern_string(string: [*c]const gchar) [*c]const gchar;
pub extern fn g_intern_static_string(string: [*c]const gchar) [*c]const gchar;
pub const struct__GError = extern struct {
    domain: GQuark = @import("std").mem.zeroes(GQuark),
    code: gint = @import("std").mem.zeroes(gint),
    message: [*c]gchar = @import("std").mem.zeroes([*c]gchar),
};
pub const GError = struct__GError;
pub const GErrorInitFunc = ?*const fn ([*c]GError) callconv(.c) void;
pub const GErrorCopyFunc = ?*const fn ([*c]const GError, [*c]GError) callconv(.c) void;
pub const GErrorClearFunc = ?*const fn ([*c]GError) callconv(.c) void;
pub extern fn g_error_domain_register_static(error_type_name: [*c]const u8, error_type_private_size: gsize, error_type_init: GErrorInitFunc, error_type_copy: GErrorCopyFunc, error_type_clear: GErrorClearFunc) GQuark;
pub extern fn g_error_domain_register(error_type_name: [*c]const u8, error_type_private_size: gsize, error_type_init: GErrorInitFunc, error_type_copy: GErrorCopyFunc, error_type_clear: GErrorClearFunc) GQuark;
pub extern fn g_error_new(domain: GQuark, code: gint, format: [*c]const gchar, ...) [*c]GError;
pub extern fn g_error_new_literal(domain: GQuark, code: gint, message: [*c]const gchar) [*c]GError;
pub extern fn g_error_new_valist(domain: GQuark, code: gint, format: [*c]const gchar, args: [*c]struct___va_list_tag_6) [*c]GError;
pub extern fn g_error_free(@"error": [*c]GError) void;
pub extern fn g_error_copy(@"error": [*c]const GError) [*c]GError;
pub extern fn g_error_matches(@"error": [*c]const GError, domain: GQuark, code: gint) gboolean;
pub extern fn g_set_error(err: [*c][*c]GError, domain: GQuark, code: gint, format: [*c]const gchar, ...) void;
pub extern fn g_set_error_literal(err: [*c][*c]GError, domain: GQuark, code: gint, message: [*c]const gchar) void;
pub extern fn g_propagate_error(dest: [*c][*c]GError, src: [*c]GError) void;
pub extern fn g_clear_error(err: [*c][*c]GError) void;
pub extern fn g_prefix_error(err: [*c][*c]GError, format: [*c]const gchar, ...) void;
pub extern fn g_prefix_error_literal(err: [*c][*c]GError, prefix: [*c]const gchar) void;
pub extern fn g_propagate_prefixed_error(dest: [*c][*c]GError, src: [*c]GError, format: [*c]const gchar, ...) void;
pub extern fn g_get_user_name() [*c]const gchar;
pub extern fn g_get_real_name() [*c]const gchar;
pub extern fn g_get_home_dir() [*c]const gchar;
pub extern fn g_get_tmp_dir() [*c]const gchar;
pub extern fn g_get_host_name() [*c]const gchar;
pub extern fn g_get_prgname() [*c]const gchar;
pub extern fn g_set_prgname(prgname: [*c]const gchar) void;
pub extern fn g_get_application_name() [*c]const gchar;
pub extern fn g_set_application_name(application_name: [*c]const gchar) void;
pub extern fn g_get_os_info(key_name: [*c]const gchar) [*c]gchar;
pub extern fn g_reload_user_special_dirs_cache() void;
pub extern fn g_get_user_data_dir() [*c]const gchar;
pub extern fn g_get_user_config_dir() [*c]const gchar;
pub extern fn g_get_user_cache_dir() [*c]const gchar;
pub extern fn g_get_user_state_dir() [*c]const gchar;
pub extern fn g_get_system_data_dirs() [*c]const [*c]const gchar;
pub extern fn g_get_system_config_dirs() [*c]const [*c]const gchar;
pub extern fn g_get_user_runtime_dir() [*c]const gchar;
pub const G_USER_DIRECTORY_DESKTOP: c_int = 0;
pub const G_USER_DIRECTORY_DOCUMENTS: c_int = 1;
pub const G_USER_DIRECTORY_DOWNLOAD: c_int = 2;
pub const G_USER_DIRECTORY_MUSIC: c_int = 3;
pub const G_USER_DIRECTORY_PICTURES: c_int = 4;
pub const G_USER_DIRECTORY_PUBLIC_SHARE: c_int = 5;
pub const G_USER_DIRECTORY_TEMPLATES: c_int = 6;
pub const G_USER_DIRECTORY_VIDEOS: c_int = 7;
pub const G_USER_N_DIRECTORIES: c_int = 8;
pub const GUserDirectory = c_uint;
pub extern fn g_get_user_special_dir(directory: GUserDirectory) [*c]const gchar;
pub const struct__GDebugKey = extern struct {
    key: [*c]const gchar = @import("std").mem.zeroes([*c]const gchar),
    value: guint = @import("std").mem.zeroes(guint),
};
pub const GDebugKey = struct__GDebugKey;
pub extern fn g_parse_debug_string(string: [*c]const gchar, keys: [*c]const GDebugKey, nkeys: guint) guint;
pub extern fn g_snprintf(string: [*c]gchar, n: gulong, format: [*c]const gchar, ...) gint;
pub extern fn g_vsnprintf(string: [*c]gchar, n: gulong, format: [*c]const gchar, args: [*c]struct___va_list_tag_6) gint;
pub extern fn g_nullify_pointer(nullify_location: [*c]gpointer) void;
pub const G_FORMAT_SIZE_DEFAULT: c_int = 0;
pub const G_FORMAT_SIZE_LONG_FORMAT: c_int = 1;
pub const G_FORMAT_SIZE_IEC_UNITS: c_int = 2;
pub const G_FORMAT_SIZE_BITS: c_int = 4;
pub const G_FORMAT_SIZE_ONLY_VALUE: c_int = 8;
pub const G_FORMAT_SIZE_ONLY_UNIT: c_int = 16;
pub const GFormatSizeFlags = c_uint;
pub extern fn g_format_size_full(size: guint64, flags: GFormatSizeFlags) [*c]gchar;
pub extern fn g_format_size(size: guint64) [*c]gchar;
pub extern fn g_format_size_for_display(size: goffset) [*c]gchar;
pub const GVoidFunc = ?*const fn () callconv(.c) void;
pub extern fn g_atexit(func: GVoidFunc) void;
pub extern fn g_find_program_in_path(program: [*c]const gchar) [*c]gchar;
pub extern fn g_bit_nth_lsf(mask: gulong, nth_bit: gint) gint;
pub extern fn g_bit_nth_msf(mask: gulong, nth_bit: gint) gint;
pub extern fn g_bit_storage(number: gulong) guint;
pub fn g_bit_nth_lsf_impl(arg_mask: gulong, arg_nth_bit: gint) callconv(.c) gint {
    var mask = arg_mask;
    _ = &mask;
    var nth_bit = arg_nth_bit;
    _ = &nth_bit;
    if (nth_bit < -@as(c_int, 1)) {
        nth_bit = -@as(c_int, 1);
    }
    while (nth_bit < ((@as(c_int, 8) * @as(c_int, 8)) - @as(c_int, 1))) {
        nth_bit += 1;
        if ((mask & (@as(c_ulong, 1) << @intCast(nth_bit))) != 0) return nth_bit;
    }
    return -@as(c_int, 1);
}
pub fn g_bit_nth_msf_impl(arg_mask: gulong, arg_nth_bit: gint) callconv(.c) gint {
    var mask = arg_mask;
    _ = &mask;
    var nth_bit = arg_nth_bit;
    _ = &nth_bit;
    if ((nth_bit < @as(c_int, 0)) or (nth_bit > (@as(c_int, 8) * @as(c_int, 8)))) {
        nth_bit = @as(c_int, 8) * @as(c_int, 8);
    }
    while (nth_bit > @as(c_int, 0)) {
        nth_bit -= 1;
        if ((mask & (@as(c_ulong, 1) << @intCast(nth_bit))) != 0) return nth_bit;
    }
    return -@as(c_int, 1);
}
pub fn g_bit_storage_impl(arg_number: gulong) callconv(.c) guint {
    var number = arg_number;
    _ = &number;
    var n_bits: guint = 0;
    _ = &n_bits;
    while (true) {
        n_bits +%= 1;
        number >>= @intCast(@as(c_int, 1));
        if (!(number != 0)) break;
    }
    return n_bits;
}
// /usr/include/bits/floatn.h:83:24: warning: unsupported type: 'Complex'
pub const __cfloat128 = @compileError("unable to resolve typedef child type");
// /usr/include/bits/floatn.h:83:24
pub const _Float128 = f128;
pub const _Float32 = f32;
pub const _Float64 = f64;
pub const _Float32x = f64;
pub const _Float64x = c_longdouble;
pub const div_t = extern struct {
    quot: c_int = @import("std").mem.zeroes(c_int),
    rem: c_int = @import("std").mem.zeroes(c_int),
};
pub const ldiv_t = extern struct {
    quot: c_long = @import("std").mem.zeroes(c_long),
    rem: c_long = @import("std").mem.zeroes(c_long),
};
pub const lldiv_t = extern struct {
    quot: c_longlong = @import("std").mem.zeroes(c_longlong),
    rem: c_longlong = @import("std").mem.zeroes(c_longlong),
};
pub extern fn __ctype_get_mb_cur_max() usize;
pub extern fn atof(__nptr: [*c]const u8) f64;
pub extern fn atoi(__nptr: [*c]const u8) c_int;
pub extern fn atol(__nptr: [*c]const u8) c_long;
pub extern fn atoll(__nptr: [*c]const u8) c_longlong;
pub extern fn strtod(__nptr: [*c]const u8, __endptr: [*c][*c]u8) f64;
pub extern fn strtof(__nptr: [*c]const u8, __endptr: [*c][*c]u8) f32;
pub extern fn strtold(__nptr: [*c]const u8, __endptr: [*c][*c]u8) c_longdouble;
pub extern fn strtol(__nptr: [*c]const u8, __endptr: [*c][*c]u8, __base: c_int) c_long;
pub extern fn strtoul(__nptr: [*c]const u8, __endptr: [*c][*c]u8, __base: c_int) c_ulong;
pub extern fn strtoq(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) c_longlong;
pub extern fn strtouq(noalias __nptr: [*c]const u8, noalias __endptr: [*c][*c]u8, __base: c_int) c_ulonglong;
pub extern fn strtoll(__nptr: [*c]const u8, __endptr: [*c][*c]u8, __base: c_int) c_longlong;
pub extern fn strtoull(__nptr: [*c]const u8, __endptr: [*c][*c]u8, __base: c_int) c_ulonglong;
pub extern fn l64a(__n: c_long) [*c]u8;
pub extern fn a64l(__s: [*c]const u8) c_long;
pub const u_char = __u_char;
pub const u_short = __u_short;
pub const u_int = __u_int;
pub const u_long = __u_long;
pub const quad_t = __quad_t;
pub const u_quad_t = __u_quad_t;
pub const fsid_t = __fsid_t;
pub const loff_t = __loff_t;
pub const ino_t = __ino_t;
pub const dev_t = __dev_t;
pub const gid_t = __gid_t;
pub const mode_t = __mode_t;
pub const nlink_t = __nlink_t;
pub const uid_t = __uid_t;
pub const off_t = __off_t;
pub const id_t = __id_t;
pub const daddr_t = __daddr_t;
pub const caddr_t = __caddr_t;
pub const key_t = __key_t;
pub const ulong = c_ulong;
pub const ushort = c_ushort;
pub const uint = c_uint;
pub const u_int8_t = __uint8_t;
pub const u_int16_t = __uint16_t;
pub const u_int32_t = __uint32_t;
pub const u_int64_t = __uint64_t;
pub const register_t = c_long;
pub fn __bswap_16(arg___bsx: __uint16_t) callconv(.c) __uint16_t {
    var __bsx = arg___bsx;
    _ = &__bsx;
    return @as(__uint16_t, @bitCast(@as(c_short, @truncate(((@as(c_int, @bitCast(@as(c_uint, __bsx))) >> @intCast(8)) & @as(c_int, 255)) | ((@as(c_int, @bitCast(@as(c_uint, __bsx))) & @as(c_int, 255)) << @intCast(8))))));
}
pub fn __bswap_32(arg___bsx: __uint32_t) callconv(.c) __uint32_t {
    var __bsx = arg___bsx;
    _ = &__bsx;
    return ((((__bsx & @as(c_uint, 4278190080)) >> @intCast(24)) | ((__bsx & @as(c_uint, 16711680)) >> @intCast(8))) | ((__bsx & @as(c_uint, 65280)) << @intCast(8))) | ((__bsx & @as(c_uint, 255)) << @intCast(24));
}
pub fn __bswap_64(arg___bsx: __uint64_t) callconv(.c) __uint64_t {
    var __bsx = arg___bsx;
    _ = &__bsx;
    return @as(__uint64_t, @bitCast(@as(c_ulong, @truncate(((((((((@as(c_ulonglong, @bitCast(@as(c_ulonglong, __bsx))) & @as(c_ulonglong, 18374686479671623680)) >> @intCast(56)) | ((@as(c_ulonglong, @bitCast(@as(c_ulonglong, __bsx))) & @as(c_ulonglong, 71776119061217280)) >> @intCast(40))) | ((@as(c_ulonglong, @bitCast(@as(c_ulonglong, __bsx))) & @as(c_ulonglong, 280375465082880)) >> @intCast(24))) | ((@as(c_ulonglong, @bitCast(@as(c_ulonglong, __bsx))) & @as(c_ulonglong, 1095216660480)) >> @intCast(8))) | ((@as(c_ulonglong, @bitCast(@as(c_ulonglong, __bsx))) & @as(c_ulonglong, 4278190080)) << @intCast(8))) | ((@as(c_ulonglong, @bitCast(@as(c_ulonglong, __bsx))) & @as(c_ulonglong, 16711680)) << @intCast(24))) | ((@as(c_ulonglong, @bitCast(@as(c_ulonglong, __bsx))) & @as(c_ulonglong, 65280)) << @intCast(40))) | ((@as(c_ulonglong, @bitCast(@as(c_ulonglong, __bsx))) & @as(c_ulonglong, 255)) << @intCast(56))))));
}
pub fn __uint16_identity(arg___x: __uint16_t) callconv(.c) __uint16_t {
    var __x = arg___x;
    _ = &__x;
    return __x;
}
pub fn __uint32_identity(arg___x: __uint32_t) callconv(.c) __uint32_t {
    var __x = arg___x;
    _ = &__x;
    return __x;
}
pub fn __uint64_identity(arg___x: __uint64_t) callconv(.c) __uint64_t {
    var __x = arg___x;
    _ = &__x;
    return __x;
}
pub const __sigset_t = extern struct {
    __val: [16]c_ulong = @import("std").mem.zeroes([16]c_ulong),
};
pub const sigset_t = __sigset_t;
pub const struct_timeval = extern struct {
    tv_sec: __time_t = @import("std").mem.zeroes(__time_t),
    tv_usec: __suseconds_t = @import("std").mem.zeroes(__suseconds_t),
};
pub const suseconds_t = __suseconds_t;
pub const __fd_mask = c_long;
pub const fd_set = extern struct {
    __fds_bits: [16]__fd_mask = @import("std").mem.zeroes([16]__fd_mask),
};
pub const fd_mask = __fd_mask;
pub extern fn select(__nfds: c_int, noalias __readfds: [*c]fd_set, noalias __writefds: [*c]fd_set, noalias __exceptfds: [*c]fd_set, noalias __timeout: [*c]struct_timeval) c_int;
pub extern fn pselect(__nfds: c_int, noalias __readfds: [*c]fd_set, noalias __writefds: [*c]fd_set, noalias __exceptfds: [*c]fd_set, noalias __timeout: [*c]const struct_timespec, noalias __sigmask: [*c]const __sigset_t) c_int;
pub const blksize_t = __blksize_t;
pub const blkcnt_t = __blkcnt_t;
pub const fsblkcnt_t = __fsblkcnt_t;
pub const fsfilcnt_t = __fsfilcnt_t;
const struct_unnamed_7 = extern struct {
    __low: c_uint = @import("std").mem.zeroes(c_uint),
    __high: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const __atomic_wide_counter = extern union {
    __value64: c_ulonglong,
    __value32: struct_unnamed_7,
};
pub const struct___pthread_internal_list = extern struct {
    __prev: [*c]struct___pthread_internal_list = @import("std").mem.zeroes([*c]struct___pthread_internal_list),
    __next: [*c]struct___pthread_internal_list = @import("std").mem.zeroes([*c]struct___pthread_internal_list),
};
pub const __pthread_list_t = struct___pthread_internal_list;
pub const struct___pthread_internal_slist = extern struct {
    __next: [*c]struct___pthread_internal_slist = @import("std").mem.zeroes([*c]struct___pthread_internal_slist),
};
pub const __pthread_slist_t = struct___pthread_internal_slist;
pub const struct___pthread_mutex_s = extern struct {
    __lock: c_int = @import("std").mem.zeroes(c_int),
    __count: c_uint = @import("std").mem.zeroes(c_uint),
    __owner: c_int = @import("std").mem.zeroes(c_int),
    __nusers: c_uint = @import("std").mem.zeroes(c_uint),
    __kind: c_int = @import("std").mem.zeroes(c_int),
    __spins: c_short = @import("std").mem.zeroes(c_short),
    __elision: c_short = @import("std").mem.zeroes(c_short),
    __list: __pthread_list_t = @import("std").mem.zeroes(__pthread_list_t),
};
pub const struct___pthread_rwlock_arch_t = extern struct {
    __readers: c_uint = @import("std").mem.zeroes(c_uint),
    __writers: c_uint = @import("std").mem.zeroes(c_uint),
    __wrphase_futex: c_uint = @import("std").mem.zeroes(c_uint),
    __writers_futex: c_uint = @import("std").mem.zeroes(c_uint),
    __pad3: c_uint = @import("std").mem.zeroes(c_uint),
    __pad4: c_uint = @import("std").mem.zeroes(c_uint),
    __cur_writer: c_int = @import("std").mem.zeroes(c_int),
    __shared: c_int = @import("std").mem.zeroes(c_int),
    __rwelision: i8 = @import("std").mem.zeroes(i8),
    __pad1: [7]u8 = @import("std").mem.zeroes([7]u8),
    __pad2: c_ulong = @import("std").mem.zeroes(c_ulong),
    __flags: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const struct___pthread_cond_s = extern struct {
    __wseq: __atomic_wide_counter = @import("std").mem.zeroes(__atomic_wide_counter),
    __g1_start: __atomic_wide_counter = @import("std").mem.zeroes(__atomic_wide_counter),
    __g_size: [2]c_uint = @import("std").mem.zeroes([2]c_uint),
    __g1_orig_size: c_uint = @import("std").mem.zeroes(c_uint),
    __wrefs: c_uint = @import("std").mem.zeroes(c_uint),
    __g_signals: [2]c_uint = @import("std").mem.zeroes([2]c_uint),
    __unused_initialized_1: c_uint = @import("std").mem.zeroes(c_uint),
    __unused_initialized_2: c_uint = @import("std").mem.zeroes(c_uint),
};
pub const __tss_t = c_uint;
pub const __thrd_t = c_ulong;
pub const __once_flag = extern struct {
    __data: c_int = @import("std").mem.zeroes(c_int),
};
pub const pthread_t = c_ulong;
pub const pthread_mutexattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const pthread_condattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub const pthread_key_t = c_uint;
pub const pthread_once_t = c_int;
pub const pthread_mutex_t = extern union {
    __data: struct___pthread_mutex_s,
    __size: [40]u8,
    __align: c_long,
};
pub const pthread_cond_t = extern union {
    __data: struct___pthread_cond_s,
    __size: [48]u8,
    __align: c_longlong,
};
pub const pthread_rwlock_t = extern union {
    __data: struct___pthread_rwlock_arch_t,
    __size: [56]u8,
    __align: c_long,
};
pub const pthread_rwlockattr_t = extern union {
    __size: [8]u8,
    __align: c_long,
};
pub const pthread_spinlock_t = c_int;
pub const pthread_barrier_t = extern union {
    __size: [32]u8,
    __align: c_long,
};
pub const pthread_barrierattr_t = extern union {
    __size: [4]u8,
    __align: c_int,
};
pub extern fn random() c_long;
pub extern fn srandom(__seed: c_uint) void;
pub extern fn initstate(__seed: c_uint, __statebuf: [*c]u8, __statelen: usize) [*c]u8;
pub extern fn setstate(__statebuf: [*c]u8) [*c]u8;
pub const struct_random_data = extern struct {
    fptr: [*c]i32 = @import("std").mem.zeroes([*c]i32),
    rptr: [*c]i32 = @import("std").mem.zeroes([*c]i32),
    state: [*c]i32 = @import("std").mem.zeroes([*c]i32),
    rand_type: c_int = @import("std").mem.zeroes(c_int),
    rand_deg: c_int = @import("std").mem.zeroes(c_int),
    rand_sep: c_int = @import("std").mem.zeroes(c_int),
    end_ptr: [*c]i32 = @import("std").mem.zeroes([*c]i32),
};
pub extern fn random_r(noalias __buf: [*c]struct_random_data, noalias __result: [*c]i32) c_int;
pub extern fn srandom_r(__seed: c_uint, __buf: [*c]struct_random_data) c_int;
pub extern fn initstate_r(__seed: c_uint, noalias __statebuf: [*c]u8, __statelen: usize, noalias __buf: [*c]struct_random_data) c_int;
pub extern fn setstate_r(noalias __statebuf: [*c]u8, noalias __buf: [*c]struct_random_data) c_int;
pub extern fn rand() c_int;
pub extern fn srand(__seed: c_uint) void;
pub extern fn rand_r(__seed: [*c]c_uint) c_int;
pub extern fn drand48() f64;
pub extern fn erand48(__xsubi: [*c]c_ushort) f64;
pub extern fn lrand48() c_long;
pub extern fn nrand48(__xsubi: [*c]c_ushort) c_long;
pub extern fn mrand48() c_long;
pub extern fn jrand48(__xsubi: [*c]c_ushort) c_long;
pub extern fn srand48(__seedval: c_long) void;
pub extern fn seed48(__seed16v: [*c]c_ushort) [*c]c_ushort;
pub extern fn lcong48(__param: [*c]c_ushort) void;
pub const struct_drand48_data = extern struct {
    __x: [3]c_ushort = @import("std").mem.zeroes([3]c_ushort),
    __old_x: [3]c_ushort = @import("std").mem.zeroes([3]c_ushort),
    __c: c_ushort = @import("std").mem.zeroes(c_ushort),
    __init: c_ushort = @import("std").mem.zeroes(c_ushort),
    __a: c_ulonglong = @import("std").mem.zeroes(c_ulonglong),
};
pub extern fn drand48_r(noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]f64) c_int;
pub extern fn erand48_r(__xsubi: [*c]c_ushort, noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]f64) c_int;
pub extern fn lrand48_r(noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn nrand48_r(__xsubi: [*c]c_ushort, noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn mrand48_r(noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn jrand48_r(__xsubi: [*c]c_ushort, noalias __buffer: [*c]struct_drand48_data, noalias __result: [*c]c_long) c_int;
pub extern fn srand48_r(__seedval: c_long, __buffer: [*c]struct_drand48_data) c_int;
pub extern fn seed48_r(__seed16v: [*c]c_ushort, __buffer: [*c]struct_drand48_data) c_int;
pub extern fn lcong48_r(__param: [*c]c_ushort, __buffer: [*c]struct_drand48_data) c_int;
pub extern fn arc4random() __uint32_t;
pub extern fn arc4random_buf(__buf: ?*anyopaque, __size: usize) void;
pub extern fn arc4random_uniform(__upper_bound: __uint32_t) __uint32_t;
pub extern fn malloc(__size: c_ulong) ?*anyopaque;
pub extern fn calloc(__nmemb: c_ulong, __size: c_ulong) ?*anyopaque;
pub extern fn realloc(__ptr: ?*anyopaque, __size: c_ulong) ?*anyopaque;
pub extern fn free(__ptr: ?*anyopaque) void;
pub extern fn reallocarray(__ptr: ?*anyopaque, __nmemb: usize, __size: usize) ?*anyopaque;
pub extern fn alloca(__size: c_ulong) ?*anyopaque;
pub extern fn valloc(__size: usize) ?*anyopaque;
pub extern fn posix_memalign(__memptr: [*c]?*anyopaque, __alignment: usize, __size: usize) c_int;
pub extern fn aligned_alloc(__alignment: c_ulong, __size: c_ulong) ?*anyopaque;
pub extern fn abort() noreturn;
pub extern fn atexit(__func: ?*const fn () callconv(.c) void) c_int;
pub extern fn at_quick_exit(__func: ?*const fn () callconv(.c) void) c_int;
pub extern fn on_exit(__func: ?*const fn (c_int, ?*anyopaque) callconv(.c) void, __arg: ?*anyopaque) c_int;
pub extern fn exit(__status: c_int) noreturn;
pub extern fn quick_exit(__status: c_int) noreturn;
pub extern fn _Exit(__status: c_int) noreturn;
pub extern fn getenv(__name: [*c]const u8) [*c]u8;
pub extern fn putenv(__string: [*c]u8) c_int;
pub extern fn setenv(__name: [*c]const u8, __value: [*c]const u8, __replace: c_int) c_int;
pub extern fn unsetenv(__name: [*c]const u8) c_int;
pub extern fn clearenv() c_int;
pub extern fn mktemp(__template: [*c]u8) [*c]u8;
pub extern fn mkstemp(__template: [*c]u8) c_int;
pub extern fn mkstemps(__template: [*c]u8, __suffixlen: c_int) c_int;
pub extern fn mkdtemp(__template: [*c]u8) [*c]u8;
pub extern fn system(__command: [*c]const u8) c_int;
pub extern fn realpath(noalias __name: [*c]const u8, noalias __resolved: [*c]u8) [*c]u8;
pub const __compar_fn_t = ?*const fn (?*const anyopaque, ?*const anyopaque) callconv(.c) c_int;
pub extern fn bsearch(__key: ?*const anyopaque, __base: ?*const anyopaque, __nmemb: usize, __size: usize, __compar: __compar_fn_t) ?*anyopaque;
pub extern fn qsort(__base: ?*anyopaque, __nmemb: usize, __size: usize, __compar: __compar_fn_t) void;
pub extern fn abs(__x: c_int) c_int;
pub extern fn labs(__x: c_long) c_long;
pub extern fn llabs(__x: c_longlong) c_longlong;
pub extern fn div(__numer: c_int, __denom: c_int) div_t;
pub extern fn ldiv(__numer: c_long, __denom: c_long) ldiv_t;
pub extern fn lldiv(__numer: c_longlong, __denom: c_longlong) lldiv_t;
pub extern fn ecvt(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn fcvt(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn gcvt(__value: f64, __ndigit: c_int, __buf: [*c]u8) [*c]u8;
pub extern fn qecvt(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn qfcvt(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int) [*c]u8;
pub extern fn qgcvt(__value: c_longdouble, __ndigit: c_int, __buf: [*c]u8) [*c]u8;
pub extern fn ecvt_r(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn fcvt_r(__value: f64, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn qecvt_r(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn qfcvt_r(__value: c_longdouble, __ndigit: c_int, noalias __decpt: [*c]c_int, noalias __sign: [*c]c_int, noalias __buf: [*c]u8, __len: usize) c_int;
pub extern fn mblen(__s: [*c]const u8, __n: usize) c_int;
pub extern fn mbtowc(noalias __pwc: [*c]wchar_t, noalias __s: [*c]const u8, __n: usize) c_int;
pub extern fn wctomb(__s: [*c]u8, __wchar: wchar_t) c_int;
pub extern fn mbstowcs(noalias __pwcs: [*c]wchar_t, noalias __s: [*c]const u8, __n: usize) usize;
pub extern fn wcstombs(noalias __s: [*c]u8, noalias __pwcs: [*c]const wchar_t, __n: usize) usize;
pub extern fn rpmatch(__response: [*c]const u8) c_int;
pub extern fn getsubopt(noalias __optionp: [*c][*c]u8, noalias __tokens: [*c]const [*c]u8, noalias __valuep: [*c][*c]u8) c_int;
pub extern fn getloadavg(__loadavg: [*c]f64, __nelem: c_int) c_int;
pub extern fn g_thread_error_quark() GQuark;
pub const G_THREAD_ERROR_AGAIN: c_int = 0;
pub const GThreadError = c_uint;
pub const GThreadFunc = ?*const fn (gpointer) callconv(.c) gpointer;
pub const struct__GThread = extern struct {
    func: GThreadFunc = @import("std").mem.zeroes(GThreadFunc),
    data: gpointer = @import("std").mem.zeroes(gpointer),
    joinable: gboolean = @import("std").mem.zeroes(gboolean),
    priority: GThreadPriority = @import("std").mem.zeroes(GThreadPriority),
};
pub const GThread = struct__GThread;
pub const union__GMutex = extern union {
    p: gpointer,
    i: [2]guint,
};
pub const GMutex = union__GMutex;
pub const struct__GRecMutex = extern struct {
    p: gpointer = @import("std").mem.zeroes(gpointer),
    i: [2]guint = @import("std").mem.zeroes([2]guint),
};
pub const GRecMutex = struct__GRecMutex;
pub const struct__GRWLock = extern struct {
    p: gpointer = @import("std").mem.zeroes(gpointer),
    i: [2]guint = @import("std").mem.zeroes([2]guint),
};
pub const GRWLock = struct__GRWLock;
pub const struct__GCond = extern struct {
    p: gpointer = @import("std").mem.zeroes(gpointer),
    i: [2]guint = @import("std").mem.zeroes([2]guint),
};
pub const GCond = struct__GCond;
pub const struct__GPrivate = extern struct {
    p: gpointer = @import("std").mem.zeroes(gpointer),
    notify: GDestroyNotify = @import("std").mem.zeroes(GDestroyNotify),
    future: [2]gpointer = @import("std").mem.zeroes([2]gpointer),
};
pub const GPrivate = struct__GPrivate;
pub const struct__GOnce = extern struct {
    status: GOnceStatus = @import("std").mem.zeroes(GOnceStatus),
    retval: gpointer = @import("std").mem.zeroes(gpointer),
};
pub const GOnce = struct__GOnce;
pub const G_ONCE_STATUS_NOTCALLED: c_int = 0;
pub const G_ONCE_STATUS_PROGRESS: c_int = 1;
pub const G_ONCE_STATUS_READY: c_int = 2;
pub const GOnceStatus = c_uint;
pub extern fn g_thread_ref(thread: [*c]GThread) [*c]GThread;
pub extern fn g_thread_unref(thread: [*c]GThread) void;
pub extern fn g_thread_new(name: [*c]const gchar, func: GThreadFunc, data: gpointer) [*c]GThread;
pub extern fn g_thread_try_new(name: [*c]const gchar, func: GThreadFunc, data: gpointer, @"error": [*c][*c]GError) [*c]GThread;
pub extern fn g_thread_self() [*c]GThread;
pub extern fn g_thread_exit(retval: gpointer) noreturn;
pub extern fn g_thread_join(thread: [*c]GThread) gpointer;
pub extern fn g_thread_yield() void;
pub extern fn g_thread_get_name(thread: [*c]GThread) [*c]const u8;
pub extern fn g_mutex_init(mutex: [*c]GMutex) void;
pub extern fn g_mutex_clear(mutex: [*c]GMutex) void;
pub extern fn g_mutex_lock(mutex: [*c]GMutex) void;
pub extern fn g_mutex_trylock(mutex: [*c]GMutex) gboolean;
pub extern fn g_mutex_unlock(mutex: [*c]GMutex) void;
pub extern fn g_rw_lock_init(rw_lock: [*c]GRWLock) void;
pub extern fn g_rw_lock_clear(rw_lock: [*c]GRWLock) void;
pub extern fn g_rw_lock_writer_lock(rw_lock: [*c]GRWLock) void;
pub extern fn g_rw_lock_writer_trylock(rw_lock: [*c]GRWLock) gboolean;
pub extern fn g_rw_lock_writer_unlock(rw_lock: [*c]GRWLock) void;
pub extern fn g_rw_lock_reader_lock(rw_lock: [*c]GRWLock) void;
pub extern fn g_rw_lock_reader_trylock(rw_lock: [*c]GRWLock) gboolean;
pub extern fn g_rw_lock_reader_unlock(rw_lock: [*c]GRWLock) void;
pub extern fn g_rec_mutex_init(rec_mutex: [*c]GRecMutex) void;
pub extern fn g_rec_mutex_clear(rec_mutex: [*c]GRecMutex) void;
pub extern fn g_rec_mutex_lock(rec_mutex: [*c]GRecMutex) void;
pub extern fn g_rec_mutex_trylock(rec_mutex: [*c]GRecMutex) gboolean;
pub extern fn g_rec_mutex_unlock(rec_mutex: [*c]GRecMutex) void;
pub extern fn g_cond_init(cond: [*c]GCond) void;
pub extern fn g_cond_clear(cond: [*c]GCond) void;
pub extern fn g_cond_wait(cond: [*c]GCond, mutex: [*c]GMutex) void;
pub extern fn g_cond_signal(cond: [*c]GCond) void;
pub extern fn g_cond_broadcast(cond: [*c]GCond) void;
pub extern fn g_cond_wait_until(cond: [*c]GCond, mutex: [*c]GMutex, end_time: gint64) gboolean;
pub extern fn g_private_get(key: [*c]GPrivate) gpointer;
pub extern fn g_private_set(key: [*c]GPrivate, value: gpointer) void;
pub extern fn g_private_replace(key: [*c]GPrivate, value: gpointer) void;
pub extern fn g_once_impl(once: [*c]GOnce, func: GThreadFunc, arg: gpointer) gpointer;
pub extern fn g_once_init_enter(location: ?*volatile anyopaque) gboolean;
pub extern fn g_once_init_leave(location: ?*volatile anyopaque, result: gsize) void;
pub extern fn g_once_init_enter_pointer(location: ?*anyopaque) gboolean;
pub extern fn g_once_init_leave_pointer(location: ?*anyopaque, result: gpointer) void;
pub extern fn g_get_num_processors() guint;
pub const GMutexLocker = anyopaque;
pub fn g_mutex_locker_new(arg_mutex: [*c]GMutex) callconv(.c) ?*GMutexLocker {
    var mutex = arg_mutex;
    _ = &mutex;
    g_mutex_lock(mutex);
    return @as(?*GMutexLocker, @ptrCast(mutex));
}
pub fn g_mutex_locker_free(arg_locker: ?*GMutexLocker) callconv(.c) void {
    var locker = arg_locker;
    _ = &locker;
    g_mutex_unlock(@as([*c]GMutex, @ptrCast(@alignCast(locker))));
}
pub const GRecMutexLocker = anyopaque;
pub fn g_rec_mutex_locker_new(arg_rec_mutex: [*c]GRecMutex) callconv(.c) ?*GRecMutexLocker {
    var rec_mutex = arg_rec_mutex;
    _ = &rec_mutex;
    g_rec_mutex_lock(rec_mutex);
    return @as(?*GRecMutexLocker, @ptrCast(rec_mutex));
}
pub fn g_rec_mutex_locker_free(arg_locker: ?*GRecMutexLocker) callconv(.c) void {
    var locker = arg_locker;
    _ = &locker;
    g_rec_mutex_unlock(@as([*c]GRecMutex, @ptrCast(@alignCast(locker))));
}
pub const GRWLockWriterLocker = anyopaque;
pub fn g_rw_lock_writer_locker_new(arg_rw_lock: [*c]GRWLock) callconv(.c) ?*GRWLockWriterLocker {
    var rw_lock = arg_rw_lock;
    _ = &rw_lock;
    g_rw_lock_writer_lock(rw_lock);
    return @as(?*GRWLockWriterLocker, @ptrCast(rw_lock));
}
pub fn g_rw_lock_writer_locker_free(arg_locker: ?*GRWLockWriterLocker) callconv(.c) void {
    var locker = arg_locker;
    _ = &locker;
    g_rw_lock_writer_unlock(@as([*c]GRWLock, @ptrCast(@alignCast(locker))));
}
pub const GRWLockReaderLocker = anyopaque;
pub fn g_rw_lock_reader_locker_new(arg_rw_lock: [*c]GRWLock) callconv(.c) ?*GRWLockReaderLocker {
    var rw_lock = arg_rw_lock;
    _ = &rw_lock;
    g_rw_lock_reader_lock(rw_lock);
    return @as(?*GRWLockReaderLocker, @ptrCast(rw_lock));
}
pub fn g_rw_lock_reader_locker_free(arg_locker: ?*GRWLockReaderLocker) callconv(.c) void {
    var locker = arg_locker;
    _ = &locker;
    g_rw_lock_reader_unlock(@as([*c]GRWLock, @ptrCast(@alignCast(locker))));
}
pub const struct__GAsyncQueue = opaque {};
pub const GAsyncQueue = struct__GAsyncQueue;
pub extern fn g_async_queue_new() ?*GAsyncQueue;
pub extern fn g_async_queue_new_full(item_free_func: GDestroyNotify) ?*GAsyncQueue;
pub extern fn g_async_queue_lock(queue: ?*GAsyncQueue) void;
pub extern fn g_async_queue_unlock(queue: ?*GAsyncQueue) void;
pub extern fn g_async_queue_ref(queue: ?*GAsyncQueue) ?*GAsyncQueue;
pub extern fn g_async_queue_unref(queue: ?*GAsyncQueue) void;
pub extern fn g_async_queue_ref_unlocked(queue: ?*GAsyncQueue) void;
pub extern fn g_async_queue_unref_and_unlock(queue: ?*GAsyncQueue) void;
pub extern fn g_async_queue_push(queue: ?*GAsyncQueue, data: gpointer) void;
pub extern fn g_async_queue_push_unlocked(queue: ?*GAsyncQueue, data: gpointer) void;
pub extern fn g_async_queue_push_sorted(queue: ?*GAsyncQueue, data: gpointer, func: GCompareDataFunc, user_data: gpointer) void;
pub extern fn g_async_queue_push_sorted_unlocked(queue: ?*GAsyncQueue, data: gpointer, func: GCompareDataFunc, user_data: gpointer) void;
pub extern fn g_async_queue_pop(queue: ?*GAsyncQueue) gpointer;
pub extern fn g_async_queue_pop_unlocked(queue: ?*GAsyncQueue) gpointer;
pub extern fn g_async_queue_try_pop(queue: ?*GAsyncQueue) gpointer;
pub extern fn g_async_queue_try_pop_unlocked(queue: ?*GAsyncQueue) gpointer;
pub extern fn g_async_queue_timeout_pop(queue: ?*GAsyncQueue, timeout: guint64) gpointer;
pub extern fn g_async_queue_timeout_pop_unlocked(queue: ?*GAsyncQueue, timeout: guint64) gpointer;
pub extern fn g_async_queue_length(queue: ?*GAsyncQueue) gint;
pub extern fn g_async_queue_length_unlocked(queue: ?*GAsyncQueue) gint;
pub extern fn g_async_queue_sort(queue: ?*GAsyncQueue, func: GCompareDataFunc, user_data: gpointer) void;
pub extern fn g_async_queue_sort_unlocked(queue: ?*GAsyncQueue, func: GCompareDataFunc, user_data: gpointer) void;
pub extern fn g_async_queue_remove(queue: ?*GAsyncQueue, item: gpointer) gboolean;
pub extern fn g_async_queue_remove_unlocked(queue: ?*GAsyncQueue, item: gpointer) gboolean;
pub extern fn g_async_queue_push_front(queue: ?*GAsyncQueue, item: gpointer) void;
pub extern fn g_async_queue_push_front_unlocked(queue: ?*GAsyncQueue, item: gpointer) void;
pub extern fn g_async_queue_timed_pop(queue: ?*GAsyncQueue, end_time: [*c]GTimeVal) gpointer;
pub extern fn g_async_queue_timed_pop_unlocked(queue: ?*GAsyncQueue, end_time: [*c]GTimeVal) gpointer;
pub const sig_atomic_t = __sig_atomic_t;
const struct_unnamed_9 = extern struct {
    si_pid: __pid_t = @import("std").mem.zeroes(__pid_t),
    si_uid: __uid_t = @import("std").mem.zeroes(__uid_t),
};
const struct_unnamed_10 = extern struct {
    si_tid: c_int = @import("std").mem.zeroes(c_int),
    si_overrun: c_int = @import("std").mem.zeroes(c_int),
    si_sigval: __sigval_t = @import("std").mem.zeroes(__sigval_t),
};
const struct_unnamed_11 = extern struct {
    si_pid: __pid_t = @import("std").mem.zeroes(__pid_t),
    si_uid: __uid_t = @import("std").mem.zeroes(__uid_t),
    si_sigval: __sigval_t = @import("std").mem.zeroes(__sigval_t),
};
const struct_unnamed_12 = extern struct {
    si_pid: __pid_t = @import("std").mem.zeroes(__pid_t),
    si_uid: __uid_t = @import("std").mem.zeroes(__uid_t),
    si_status: c_int = @import("std").mem.zeroes(c_int),
    si_utime: __clock_t = @import("std").mem.zeroes(__clock_t),
    si_stime: __clock_t = @import("std").mem.zeroes(__clock_t),
};
const struct_unnamed_15 = extern struct {
    _lower: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    _upper: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
};
const union_unnamed_14 = extern union {
    _addr_bnd: struct_unnamed_15,
    _pkey: __uint32_t,
};
const struct_unnamed_13 = extern struct {
    si_addr: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    si_addr_lsb: c_short = @import("std").mem.zeroes(c_short),
    _bounds: union_unnamed_14 = @import("std").mem.zeroes(union_unnamed_14),
};
const struct_unnamed_16 = extern struct {
    si_band: c_long = @import("std").mem.zeroes(c_long),
    si_fd: c_int = @import("std").mem.zeroes(c_int),
};
const struct_unnamed_17 = extern struct {
    _call_addr: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    _syscall: c_int = @import("std").mem.zeroes(c_int),
    _arch: c_uint = @import("std").mem.zeroes(c_uint),
};
const union_unnamed_8 = extern union {
    _pad: [28]c_int,
    _kill: struct_unnamed_9,
    _timer: struct_unnamed_10,
    _rt: struct_unnamed_11,
    _sigchld: struct_unnamed_12,
    _sigfault: struct_unnamed_13,
    _sigpoll: struct_unnamed_16,
    _sigsys: struct_unnamed_17,
};
pub const siginfo_t = extern struct {
    si_signo: c_int = @import("std").mem.zeroes(c_int),
    si_errno: c_int = @import("std").mem.zeroes(c_int),
    si_code: c_int = @import("std").mem.zeroes(c_int),
    __pad0: c_int = @import("std").mem.zeroes(c_int),
    _sifields: union_unnamed_8 = @import("std").mem.zeroes(union_unnamed_8),
};
pub const SI_ASYNCNL: c_int = -60;
pub const SI_DETHREAD: c_int = -7;
pub const SI_TKILL: c_int = -6;
pub const SI_SIGIO: c_int = -5;
pub const SI_ASYNCIO: c_int = -4;
pub const SI_MESGQ: c_int = -3;
pub const SI_TIMER: c_int = -2;
pub const SI_QUEUE: c_int = -1;
pub const SI_USER: c_int = 0;
pub const SI_KERNEL: c_int = 128;
const enum_unnamed_18 = c_int;
pub const ILL_ILLOPC: c_int = 1;
pub const ILL_ILLOPN: c_int = 2;
pub const ILL_ILLADR: c_int = 3;
pub const ILL_ILLTRP: c_int = 4;
pub const ILL_PRVOPC: c_int = 5;
pub const ILL_PRVREG: c_int = 6;
pub const ILL_COPROC: c_int = 7;
pub const ILL_BADSTK: c_int = 8;
pub const ILL_BADIADDR: c_int = 9;
const enum_unnamed_19 = c_uint;
pub const FPE_INTDIV: c_int = 1;
pub const FPE_INTOVF: c_int = 2;
pub const FPE_FLTDIV: c_int = 3;
pub const FPE_FLTOVF: c_int = 4;
pub const FPE_FLTUND: c_int = 5;
pub const FPE_FLTRES: c_int = 6;
pub const FPE_FLTINV: c_int = 7;
pub const FPE_FLTSUB: c_int = 8;
pub const FPE_FLTUNK: c_int = 14;
pub const FPE_CONDTRAP: c_int = 15;
const enum_unnamed_20 = c_uint;
pub const SEGV_MAPERR: c_int = 1;
pub const SEGV_ACCERR: c_int = 2;
pub const SEGV_BNDERR: c_int = 3;
pub const SEGV_PKUERR: c_int = 4;
pub const SEGV_ACCADI: c_int = 5;
pub const SEGV_ADIDERR: c_int = 6;
pub const SEGV_ADIPERR: c_int = 7;
pub const SEGV_MTEAERR: c_int = 8;
pub const SEGV_MTESERR: c_int = 9;
pub const SEGV_CPERR: c_int = 10;
const enum_unnamed_21 = c_uint;
pub const BUS_ADRALN: c_int = 1;
pub const BUS_ADRERR: c_int = 2;
pub const BUS_OBJERR: c_int = 3;
pub const BUS_MCEERR_AR: c_int = 4;
pub const BUS_MCEERR_AO: c_int = 5;
const enum_unnamed_22 = c_uint;
pub const CLD_EXITED: c_int = 1;
pub const CLD_KILLED: c_int = 2;
pub const CLD_DUMPED: c_int = 3;
pub const CLD_TRAPPED: c_int = 4;
pub const CLD_STOPPED: c_int = 5;
pub const CLD_CONTINUED: c_int = 6;
const enum_unnamed_23 = c_uint;
pub const POLL_IN: c_int = 1;
pub const POLL_OUT: c_int = 2;
pub const POLL_MSG: c_int = 3;
pub const POLL_ERR: c_int = 4;
pub const POLL_PRI: c_int = 5;
pub const POLL_HUP: c_int = 6;
const enum_unnamed_24 = c_uint;
pub const sigval_t = __sigval_t;
pub const sigevent_t = struct_sigevent;
pub const SIGEV_SIGNAL: c_int = 0;
pub const SIGEV_NONE: c_int = 1;
pub const SIGEV_THREAD: c_int = 2;
pub const SIGEV_THREAD_ID: c_int = 4;
const enum_unnamed_25 = c_uint;
pub const __sighandler_t = ?*const fn (c_int) callconv(.c) void;
pub extern fn __sysv_signal(__sig: c_int, __handler: __sighandler_t) __sighandler_t;
pub extern fn signal(__sig: c_int, __handler: __sighandler_t) __sighandler_t;
pub extern fn kill(__pid: __pid_t, __sig: c_int) c_int;
pub extern fn killpg(__pgrp: __pid_t, __sig: c_int) c_int;
pub extern fn raise(__sig: c_int) c_int;
pub extern fn ssignal(__sig: c_int, __handler: __sighandler_t) __sighandler_t;
pub extern fn gsignal(__sig: c_int) c_int;
pub extern fn psignal(__sig: c_int, __s: [*c]const u8) void;
pub extern fn psiginfo(__pinfo: [*c]const siginfo_t, __s: [*c]const u8) void;
pub extern fn sigblock(__mask: c_int) c_int;
pub extern fn sigsetmask(__mask: c_int) c_int;
pub extern fn siggetmask() c_int;
pub const sig_t = __sighandler_t;
pub extern fn sigemptyset(__set: [*c]sigset_t) c_int;
pub extern fn sigfillset(__set: [*c]sigset_t) c_int;
pub extern fn sigaddset(__set: [*c]sigset_t, __signo: c_int) c_int;
pub extern fn sigdelset(__set: [*c]sigset_t, __signo: c_int) c_int;
pub extern fn sigismember(__set: [*c]const sigset_t, __signo: c_int) c_int;
const union_unnamed_26 = extern union {
    sa_handler: __sighandler_t,
    sa_sigaction: ?*const fn (c_int, [*c]siginfo_t, ?*anyopaque) callconv(.c) void,
};
pub const struct_sigaction = extern struct {
    __sigaction_handler: union_unnamed_26 = @import("std").mem.zeroes(union_unnamed_26),
    sa_mask: __sigset_t = @import("std").mem.zeroes(__sigset_t),
    sa_flags: c_int = @import("std").mem.zeroes(c_int),
    sa_restorer: ?*const fn () callconv(.c) void = @import("std").mem.zeroes(?*const fn () callconv(.c) void),
};
pub extern fn sigprocmask(__how: c_int, noalias __set: [*c]const sigset_t, noalias __oset: [*c]sigset_t) c_int;
pub extern fn sigsuspend(__set: [*c]const sigset_t) c_int;
pub extern fn sigaction(__sig: c_int, noalias __act: [*c]const struct_sigaction, noalias __oact: [*c]struct_sigaction) c_int;
pub extern fn sigpending(__set: [*c]sigset_t) c_int;
pub extern fn sigwait(noalias __set: [*c]const sigset_t, noalias __sig: [*c]c_int) c_int;
pub extern fn sigwaitinfo(noalias __set: [*c]const sigset_t, noalias __info: [*c]siginfo_t) c_int;
pub extern fn sigtimedwait(noalias __set: [*c]const sigset_t, noalias __info: [*c]siginfo_t, noalias __timeout: [*c]const struct_timespec) c_int;
pub extern fn sigqueue(__pid: __pid_t, __sig: c_int, __val: union_sigval) c_int;
pub const struct__fpx_sw_bytes = extern struct {
    magic1: __uint32_t = @import("std").mem.zeroes(__uint32_t),
    extended_size: __uint32_t = @import("std").mem.zeroes(__uint32_t),
    xstate_bv: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    xstate_size: __uint32_t = @import("std").mem.zeroes(__uint32_t),
    __glibc_reserved1: [7]__uint32_t = @import("std").mem.zeroes([7]__uint32_t),
};
pub const struct__fpreg = extern struct {
    significand: [4]c_ushort = @import("std").mem.zeroes([4]c_ushort),
    exponent: c_ushort = @import("std").mem.zeroes(c_ushort),
};
pub const struct__fpxreg = extern struct {
    significand: [4]c_ushort = @import("std").mem.zeroes([4]c_ushort),
    exponent: c_ushort = @import("std").mem.zeroes(c_ushort),
    __glibc_reserved1: [3]c_ushort = @import("std").mem.zeroes([3]c_ushort),
};
pub const struct__xmmreg = extern struct {
    element: [4]__uint32_t = @import("std").mem.zeroes([4]__uint32_t),
};
pub const struct__fpstate = extern struct {
    cwd: __uint16_t = @import("std").mem.zeroes(__uint16_t),
    swd: __uint16_t = @import("std").mem.zeroes(__uint16_t),
    ftw: __uint16_t = @import("std").mem.zeroes(__uint16_t),
    fop: __uint16_t = @import("std").mem.zeroes(__uint16_t),
    rip: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    rdp: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    mxcsr: __uint32_t = @import("std").mem.zeroes(__uint32_t),
    mxcr_mask: __uint32_t = @import("std").mem.zeroes(__uint32_t),
    _st: [8]struct__fpxreg = @import("std").mem.zeroes([8]struct__fpxreg),
    _xmm: [16]struct__xmmreg = @import("std").mem.zeroes([16]struct__xmmreg),
    __glibc_reserved1: [24]__uint32_t = @import("std").mem.zeroes([24]__uint32_t),
};
const union_unnamed_27 = extern union {
    fpstate: [*c]struct__fpstate,
    __fpstate_word: __uint64_t,
};
pub const struct_sigcontext = extern struct {
    r8: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    r9: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    r10: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    r11: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    r12: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    r13: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    r14: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    r15: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    rdi: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    rsi: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    rbp: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    rbx: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    rdx: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    rax: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    rcx: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    rsp: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    rip: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    eflags: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    cs: c_ushort = @import("std").mem.zeroes(c_ushort),
    gs: c_ushort = @import("std").mem.zeroes(c_ushort),
    fs: c_ushort = @import("std").mem.zeroes(c_ushort),
    __pad0: c_ushort = @import("std").mem.zeroes(c_ushort),
    err: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    trapno: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    oldmask: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    cr2: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    unnamed_0: union_unnamed_27 = @import("std").mem.zeroes(union_unnamed_27),
    __reserved1: [8]__uint64_t = @import("std").mem.zeroes([8]__uint64_t),
};
pub const struct__xsave_hdr = extern struct {
    xstate_bv: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    __glibc_reserved1: [2]__uint64_t = @import("std").mem.zeroes([2]__uint64_t),
    __glibc_reserved2: [5]__uint64_t = @import("std").mem.zeroes([5]__uint64_t),
};
pub const struct__ymmh_state = extern struct {
    ymmh_space: [64]__uint32_t = @import("std").mem.zeroes([64]__uint32_t),
};
pub const struct__xstate = extern struct {
    fpstate: struct__fpstate = @import("std").mem.zeroes(struct__fpstate),
    xstate_hdr: struct__xsave_hdr = @import("std").mem.zeroes(struct__xsave_hdr),
    ymmh: struct__ymmh_state = @import("std").mem.zeroes(struct__ymmh_state),
};
pub extern fn sigreturn(__scp: [*c]struct_sigcontext) c_int;
pub const stack_t = extern struct {
    ss_sp: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    ss_flags: c_int = @import("std").mem.zeroes(c_int),
    ss_size: usize = @import("std").mem.zeroes(usize),
};
pub const greg_t = c_longlong;
pub const gregset_t = [23]greg_t;
pub const struct__libc_fpxreg = extern struct {
    significand: [4]c_ushort = @import("std").mem.zeroes([4]c_ushort),
    exponent: c_ushort = @import("std").mem.zeroes(c_ushort),
    __glibc_reserved1: [3]c_ushort = @import("std").mem.zeroes([3]c_ushort),
};
pub const struct__libc_xmmreg = extern struct {
    element: [4]__uint32_t = @import("std").mem.zeroes([4]__uint32_t),
};
pub const struct__libc_fpstate = extern struct {
    cwd: __uint16_t = @import("std").mem.zeroes(__uint16_t),
    swd: __uint16_t = @import("std").mem.zeroes(__uint16_t),
    ftw: __uint16_t = @import("std").mem.zeroes(__uint16_t),
    fop: __uint16_t = @import("std").mem.zeroes(__uint16_t),
    rip: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    rdp: __uint64_t = @import("std").mem.zeroes(__uint64_t),
    mxcsr: __uint32_t = @import("std").mem.zeroes(__uint32_t),
    mxcr_mask: __uint32_t = @import("std").mem.zeroes(__uint32_t),
    _st: [8]struct__libc_fpxreg = @import("std").mem.zeroes([8]struct__libc_fpxreg),
    _xmm: [16]struct__libc_xmmreg = @import("std").mem.zeroes([16]struct__libc_xmmreg),
    __glibc_reserved1: [24]__uint32_t = @import("std").mem.zeroes([24]__uint32_t),
};
pub const fpregset_t = [*c]struct__libc_fpstate;
pub const mcontext_t = extern struct {
    gregs: gregset_t = @import("std").mem.zeroes(gregset_t),
    fpregs: fpregset_t = @import("std").mem.zeroes(fpregset_t),
    __reserved1: [8]c_ulonglong = @import("std").mem.zeroes([8]c_ulonglong),
};
pub const struct_ucontext_t = extern struct {
    uc_flags: c_ulong = @import("std").mem.zeroes(c_ulong),
    uc_link: [*c]struct_ucontext_t = @import("std").mem.zeroes([*c]struct_ucontext_t),
    uc_stack: stack_t = @import("std").mem.zeroes(stack_t),
    uc_mcontext: mcontext_t = @import("std").mem.zeroes(mcontext_t),
    uc_sigmask: sigset_t = @import("std").mem.zeroes(sigset_t),
    __fpregs_mem: struct__libc_fpstate = @import("std").mem.zeroes(struct__libc_fpstate),
    __ssp: [4]c_ulonglong = @import("std").mem.zeroes([4]c_ulonglong),
};
pub const ucontext_t = struct_ucontext_t;
pub extern fn siginterrupt(__sig: c_int, __interrupt: c_int) c_int;
pub const SS_ONSTACK: c_int = 1;
pub const SS_DISABLE: c_int = 2;
const enum_unnamed_28 = c_uint;
pub extern fn sigaltstack(noalias __ss: [*c]const stack_t, noalias __oss: [*c]stack_t) c_int;
pub const struct_sigstack = extern struct {
    ss_sp: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    ss_onstack: c_int = @import("std").mem.zeroes(c_int),
};
pub extern fn sigstack(__ss: [*c]struct_sigstack, __oss: [*c]struct_sigstack) c_int;
pub extern fn pthread_sigmask(__how: c_int, noalias __newmask: [*c]const __sigset_t, noalias __oldmask: [*c]__sigset_t) c_int;
pub extern fn pthread_kill(__threadid: pthread_t, __signo: c_int) c_int;
pub extern fn __libc_current_sigrtmin() c_int;
pub extern fn __libc_current_sigrtmax() c_int;
pub extern fn g_on_error_query(prg_name: [*c]const gchar) void;
pub extern fn g_on_error_stack_trace(prg_name: [*c]const gchar) void;
pub extern fn g_base64_encode_step(in: [*c]const guchar, len: gsize, break_lines: gboolean, out: [*c]gchar, state: [*c]gint, save: [*c]gint) gsize;
pub extern fn g_base64_encode_close(break_lines: gboolean, out: [*c]gchar, state: [*c]gint, save: [*c]gint) gsize;
pub extern fn g_base64_encode(data: [*c]const guchar, len: gsize) [*c]gchar;
pub extern fn g_base64_decode_step(in: [*c]const gchar, len: gsize, out: [*c]guchar, state: [*c]gint, save: [*c]guint) gsize;
pub extern fn g_base64_decode(text: [*c]const gchar, out_len: [*c]gsize) [*c]guchar;
pub extern fn g_base64_decode_inplace(text: [*c]gchar, out_len: [*c]gsize) [*c]guchar;
pub extern fn g_bit_lock(address: [*c]volatile gint, lock_bit: gint) void;
pub extern fn g_bit_lock_and_get(address: [*c]gint, lock_bit: guint, out_val: [*c]gint) void;
pub extern fn g_bit_trylock(address: [*c]volatile gint, lock_bit: gint) gboolean;
pub extern fn g_bit_unlock(address: [*c]volatile gint, lock_bit: gint) void;
pub extern fn g_bit_unlock_and_set(address: [*c]gint, lock_bit: guint, new_val: gint, preserve_mask: gint) void;
pub extern fn g_pointer_bit_lock(address: ?*volatile anyopaque, lock_bit: gint) void;
pub extern fn g_pointer_bit_lock_and_get(address: gpointer, lock_bit: guint, out_ptr: [*c]guintptr) void;
pub extern fn g_pointer_bit_trylock(address: ?*volatile anyopaque, lock_bit: gint) gboolean;
pub extern fn g_pointer_bit_unlock(address: ?*volatile anyopaque, lock_bit: gint) void;
pub extern fn g_pointer_bit_lock_mask_ptr(ptr: gpointer, lock_bit: guint, set: gboolean, preserve_mask: guintptr, preserve_ptr: gpointer) gpointer;
pub extern fn g_pointer_bit_unlock_and_set(address: ?*anyopaque, lock_bit: guint, ptr: gpointer, preserve_mask: guintptr) void;
pub const struct__GTimeZone = opaque {};
pub const GTimeZone = struct__GTimeZone;
pub const G_TIME_TYPE_STANDARD: c_int = 0;
pub const G_TIME_TYPE_DAYLIGHT: c_int = 1;
pub const G_TIME_TYPE_UNIVERSAL: c_int = 2;
pub const GTimeType = c_uint;
pub extern fn g_time_zone_new(identifier: [*c]const gchar) ?*GTimeZone;
pub extern fn g_time_zone_new_identifier(identifier: [*c]const gchar) ?*GTimeZone;
pub extern fn g_time_zone_new_utc() ?*GTimeZone;
pub extern fn g_time_zone_new_local() ?*GTimeZone;
pub extern fn g_time_zone_new_offset(seconds: gint32) ?*GTimeZone;
pub extern fn g_time_zone_ref(tz: ?*GTimeZone) ?*GTimeZone;
pub extern fn g_time_zone_unref(tz: ?*GTimeZone) void;
pub extern fn g_time_zone_find_interval(tz: ?*GTimeZone, @"type": GTimeType, time_: gint64) gint;
pub extern fn g_time_zone_adjust_time(tz: ?*GTimeZone, @"type": GTimeType, time_: [*c]gint64) gint;
pub extern fn g_time_zone_get_abbreviation(tz: ?*GTimeZone, interval: gint) [*c]const gchar;
pub extern fn g_time_zone_get_offset(tz: ?*GTimeZone, interval: gint) gint32;
pub extern fn g_time_zone_is_dst(tz: ?*GTimeZone, interval: gint) gboolean;
pub extern fn g_time_zone_get_identifier(tz: ?*GTimeZone) [*c]const gchar;
pub const GTimeSpan = gint64;
pub const struct__GDateTime = opaque {};
pub const GDateTime = struct__GDateTime;
pub extern fn g_date_time_unref(datetime: ?*GDateTime) void;
pub extern fn g_date_time_ref(datetime: ?*GDateTime) ?*GDateTime;
pub extern fn g_date_time_new_now(tz: ?*GTimeZone) ?*GDateTime;
pub extern fn g_date_time_new_now_local() ?*GDateTime;
pub extern fn g_date_time_new_now_utc() ?*GDateTime;
pub extern fn g_date_time_new_from_unix_local(t: gint64) ?*GDateTime;
pub extern fn g_date_time_new_from_unix_utc(t: gint64) ?*GDateTime;
pub extern fn g_date_time_new_from_unix_local_usec(usecs: gint64) ?*GDateTime;
pub extern fn g_date_time_new_from_unix_utc_usec(usecs: gint64) ?*GDateTime;
pub extern fn g_date_time_new_from_timeval_local(tv: [*c]const GTimeVal) ?*GDateTime;
pub extern fn g_date_time_new_from_timeval_utc(tv: [*c]const GTimeVal) ?*GDateTime;
pub extern fn g_date_time_new_from_iso8601(text: [*c]const gchar, default_tz: ?*GTimeZone) ?*GDateTime;
pub extern fn g_date_time_new(tz: ?*GTimeZone, year: gint, month: gint, day: gint, hour: gint, minute: gint, seconds: gdouble) ?*GDateTime;
pub extern fn g_date_time_new_local(year: gint, month: gint, day: gint, hour: gint, minute: gint, seconds: gdouble) ?*GDateTime;
pub extern fn g_date_time_new_utc(year: gint, month: gint, day: gint, hour: gint, minute: gint, seconds: gdouble) ?*GDateTime;
pub extern fn g_date_time_add(datetime: ?*GDateTime, timespan: GTimeSpan) ?*GDateTime;
pub extern fn g_date_time_add_years(datetime: ?*GDateTime, years: gint) ?*GDateTime;
pub extern fn g_date_time_add_months(datetime: ?*GDateTime, months: gint) ?*GDateTime;
pub extern fn g_date_time_add_weeks(datetime: ?*GDateTime, weeks: gint) ?*GDateTime;
pub extern fn g_date_time_add_days(datetime: ?*GDateTime, days: gint) ?*GDateTime;
pub extern fn g_date_time_add_hours(datetime: ?*GDateTime, hours: gint) ?*GDateTime;
pub extern fn g_date_time_add_minutes(datetime: ?*GDateTime, minutes: gint) ?*GDateTime;
pub extern fn g_date_time_add_seconds(datetime: ?*GDateTime, seconds: gdouble) ?*GDateTime;
pub extern fn g_date_time_add_full(datetime: ?*GDateTime, years: gint, months: gint, days: gint, hours: gint, minutes: gint, seconds: gdouble) ?*GDateTime;
pub extern fn g_date_time_compare(dt1: gconstpointer, dt2: gconstpointer) gint;
pub extern fn g_date_time_difference(end: ?*GDateTime, begin: ?*GDateTime) GTimeSpan;
pub extern fn g_date_time_hash(datetime: gconstpointer) guint;
pub extern fn g_date_time_equal(dt1: gconstpointer, dt2: gconstpointer) gboolean;
pub extern fn g_date_time_get_ymd(datetime: ?*GDateTime, year: [*c]gint, month: [*c]gint, day: [*c]gint) void;
pub extern fn g_date_time_get_year(datetime: ?*GDateTime) gint;
pub extern fn g_date_time_get_month(datetime: ?*GDateTime) gint;
pub extern fn g_date_time_get_day_of_month(datetime: ?*GDateTime) gint;
pub extern fn g_date_time_get_week_numbering_year(datetime: ?*GDateTime) gint;
pub extern fn g_date_time_get_week_of_year(datetime: ?*GDateTime) gint;
pub extern fn g_date_time_get_day_of_week(datetime: ?*GDateTime) gint;
pub extern fn g_date_time_get_day_of_year(datetime: ?*GDateTime) gint;
pub extern fn g_date_time_get_hour(datetime: ?*GDateTime) gint;
pub extern fn g_date_time_get_minute(datetime: ?*GDateTime) gint;
pub extern fn g_date_time_get_second(datetime: ?*GDateTime) gint;
pub extern fn g_date_time_get_microsecond(datetime: ?*GDateTime) gint;
pub extern fn g_date_time_get_seconds(datetime: ?*GDateTime) gdouble;
pub extern fn g_date_time_to_unix(datetime: ?*GDateTime) gint64;
pub extern fn g_date_time_to_unix_usec(datetime: ?*GDateTime) gint64;
pub extern fn g_date_time_to_timeval(datetime: ?*GDateTime, tv: [*c]GTimeVal) gboolean;
pub extern fn g_date_time_get_utc_offset(datetime: ?*GDateTime) GTimeSpan;
pub extern fn g_date_time_get_timezone(datetime: ?*GDateTime) ?*GTimeZone;
pub extern fn g_date_time_get_timezone_abbreviation(datetime: ?*GDateTime) [*c]const gchar;
pub extern fn g_date_time_is_daylight_savings(datetime: ?*GDateTime) gboolean;
pub extern fn g_date_time_to_timezone(datetime: ?*GDateTime, tz: ?*GTimeZone) ?*GDateTime;
pub extern fn g_date_time_to_local(datetime: ?*GDateTime) ?*GDateTime;
pub extern fn g_date_time_to_utc(datetime: ?*GDateTime) ?*GDateTime;
pub extern fn g_date_time_format(datetime: ?*GDateTime, format: [*c]const gchar) [*c]gchar;
pub extern fn g_date_time_format_iso8601(datetime: ?*GDateTime) [*c]gchar;
pub const G_BOOKMARK_FILE_ERROR_INVALID_URI: c_int = 0;
pub const G_BOOKMARK_FILE_ERROR_INVALID_VALUE: c_int = 1;
pub const G_BOOKMARK_FILE_ERROR_APP_NOT_REGISTERED: c_int = 2;
pub const G_BOOKMARK_FILE_ERROR_URI_NOT_FOUND: c_int = 3;
pub const G_BOOKMARK_FILE_ERROR_READ: c_int = 4;
pub const G_BOOKMARK_FILE_ERROR_UNKNOWN_ENCODING: c_int = 5;
pub const G_BOOKMARK_FILE_ERROR_WRITE: c_int = 6;
pub const G_BOOKMARK_FILE_ERROR_FILE_NOT_FOUND: c_int = 7;
pub const GBookmarkFileError = c_uint;
pub extern fn g_bookmark_file_error_quark() GQuark;
pub const struct__GBookmarkFile = opaque {};
pub const GBookmarkFile = struct__GBookmarkFile;
pub extern fn g_bookmark_file_new() ?*GBookmarkFile;
pub extern fn g_bookmark_file_free(bookmark: ?*GBookmarkFile) void;
pub extern fn g_bookmark_file_copy(bookmark: ?*GBookmarkFile) ?*GBookmarkFile;
pub extern fn g_bookmark_file_load_from_file(bookmark: ?*GBookmarkFile, filename: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_load_from_data(bookmark: ?*GBookmarkFile, data: [*c]const gchar, length: gsize, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_load_from_data_dirs(bookmark: ?*GBookmarkFile, file: [*c]const gchar, full_path: [*c][*c]gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_to_data(bookmark: ?*GBookmarkFile, length: [*c]gsize, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_bookmark_file_to_file(bookmark: ?*GBookmarkFile, filename: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_set_title(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, title: [*c]const gchar) void;
pub extern fn g_bookmark_file_get_title(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_bookmark_file_set_description(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, description: [*c]const gchar) void;
pub extern fn g_bookmark_file_get_description(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_bookmark_file_set_mime_type(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, mime_type: [*c]const gchar) void;
pub extern fn g_bookmark_file_get_mime_type(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_bookmark_file_set_groups(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, groups: [*c][*c]const gchar, length: gsize) void;
pub extern fn g_bookmark_file_add_group(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, group: [*c]const gchar) void;
pub extern fn g_bookmark_file_has_group(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, group: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_get_groups(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, length: [*c]gsize, @"error": [*c][*c]GError) [*c][*c]gchar;
pub extern fn g_bookmark_file_add_application(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, name: [*c]const gchar, exec: [*c]const gchar) void;
pub extern fn g_bookmark_file_has_application(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, name: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_get_applications(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, length: [*c]gsize, @"error": [*c][*c]GError) [*c][*c]gchar;
pub extern fn g_bookmark_file_set_app_info(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, name: [*c]const gchar, exec: [*c]const gchar, count: gint, stamp: time_t, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_set_application_info(bookmark: ?*GBookmarkFile, uri: [*c]const u8, name: [*c]const u8, exec: [*c]const u8, count: c_int, stamp: ?*GDateTime, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_get_app_info(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, name: [*c]const gchar, exec: [*c][*c]gchar, count: [*c]guint, stamp: [*c]time_t, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_get_application_info(bookmark: ?*GBookmarkFile, uri: [*c]const u8, name: [*c]const u8, exec: [*c][*c]u8, count: [*c]c_uint, stamp: [*c]?*GDateTime, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_set_is_private(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, is_private: gboolean) void;
pub extern fn g_bookmark_file_get_is_private(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_set_icon(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, href: [*c]const gchar, mime_type: [*c]const gchar) void;
pub extern fn g_bookmark_file_get_icon(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, href: [*c][*c]gchar, mime_type: [*c][*c]gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_set_added(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, added: time_t) void;
pub extern fn g_bookmark_file_set_added_date_time(bookmark: ?*GBookmarkFile, uri: [*c]const u8, added: ?*GDateTime) void;
pub extern fn g_bookmark_file_get_added(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, @"error": [*c][*c]GError) time_t;
pub extern fn g_bookmark_file_get_added_date_time(bookmark: ?*GBookmarkFile, uri: [*c]const u8, @"error": [*c][*c]GError) ?*GDateTime;
pub extern fn g_bookmark_file_set_modified(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, modified: time_t) void;
pub extern fn g_bookmark_file_set_modified_date_time(bookmark: ?*GBookmarkFile, uri: [*c]const u8, modified: ?*GDateTime) void;
pub extern fn g_bookmark_file_get_modified(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, @"error": [*c][*c]GError) time_t;
pub extern fn g_bookmark_file_get_modified_date_time(bookmark: ?*GBookmarkFile, uri: [*c]const u8, @"error": [*c][*c]GError) ?*GDateTime;
pub extern fn g_bookmark_file_set_visited(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, visited: time_t) void;
pub extern fn g_bookmark_file_set_visited_date_time(bookmark: ?*GBookmarkFile, uri: [*c]const u8, visited: ?*GDateTime) void;
pub extern fn g_bookmark_file_get_visited(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, @"error": [*c][*c]GError) time_t;
pub extern fn g_bookmark_file_get_visited_date_time(bookmark: ?*GBookmarkFile, uri: [*c]const u8, @"error": [*c][*c]GError) ?*GDateTime;
pub extern fn g_bookmark_file_has_item(bookmark: ?*GBookmarkFile, uri: [*c]const gchar) gboolean;
pub extern fn g_bookmark_file_get_size(bookmark: ?*GBookmarkFile) gint;
pub extern fn g_bookmark_file_get_uris(bookmark: ?*GBookmarkFile, length: [*c]gsize) [*c][*c]gchar;
pub extern fn g_bookmark_file_remove_group(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, group: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_remove_application(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, name: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_remove_item(bookmark: ?*GBookmarkFile, uri: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bookmark_file_move_item(bookmark: ?*GBookmarkFile, old_uri: [*c]const gchar, new_uri: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_bytes_new(data: gconstpointer, size: gsize) ?*GBytes;
pub extern fn g_bytes_new_take(data: gpointer, size: gsize) ?*GBytes;
pub extern fn g_bytes_new_static(data: gconstpointer, size: gsize) ?*GBytes;
pub extern fn g_bytes_new_with_free_func(data: gconstpointer, size: gsize, free_func: GDestroyNotify, user_data: gpointer) ?*GBytes;
pub extern fn g_bytes_new_from_bytes(bytes: ?*GBytes, offset: gsize, length: gsize) ?*GBytes;
pub extern fn g_bytes_get_data(bytes: ?*GBytes, size: [*c]gsize) gconstpointer;
pub extern fn g_bytes_get_size(bytes: ?*GBytes) gsize;
pub extern fn g_bytes_ref(bytes: ?*GBytes) ?*GBytes;
pub extern fn g_bytes_unref(bytes: ?*GBytes) void;
pub extern fn g_bytes_unref_to_data(bytes: ?*GBytes, size: [*c]gsize) gpointer;
pub extern fn g_bytes_unref_to_array(bytes: ?*GBytes) [*c]GByteArray;
pub extern fn g_bytes_hash(bytes: gconstpointer) guint;
pub extern fn g_bytes_equal(bytes1: gconstpointer, bytes2: gconstpointer) gboolean;
pub extern fn g_bytes_compare(bytes1: gconstpointer, bytes2: gconstpointer) gint;
pub extern fn g_bytes_get_region(bytes: ?*GBytes, element_size: gsize, offset: gsize, n_elements: gsize) gconstpointer;
pub extern fn g_get_charset(charset: [*c][*c]const u8) gboolean;
pub extern fn g_get_codeset() [*c]gchar;
pub extern fn g_get_console_charset(charset: [*c][*c]const u8) gboolean;
pub extern fn g_get_language_names() [*c]const [*c]const gchar;
pub extern fn g_get_language_names_with_category(category_name: [*c]const gchar) [*c]const [*c]const gchar;
pub extern fn g_get_locale_variants(locale: [*c]const gchar) [*c][*c]gchar;
pub const G_CHECKSUM_MD5: c_int = 0;
pub const G_CHECKSUM_SHA1: c_int = 1;
pub const G_CHECKSUM_SHA256: c_int = 2;
pub const G_CHECKSUM_SHA512: c_int = 3;
pub const G_CHECKSUM_SHA384: c_int = 4;
pub const GChecksumType = c_uint;
pub const struct__GChecksum = opaque {};
pub const GChecksum = struct__GChecksum;
pub extern fn g_checksum_type_get_length(checksum_type: GChecksumType) gssize;
pub extern fn g_checksum_new(checksum_type: GChecksumType) ?*GChecksum;
pub extern fn g_checksum_reset(checksum: ?*GChecksum) void;
pub extern fn g_checksum_copy(checksum: ?*const GChecksum) ?*GChecksum;
pub extern fn g_checksum_free(checksum: ?*GChecksum) void;
pub extern fn g_checksum_update(checksum: ?*GChecksum, data: [*c]const guchar, length: gssize) void;
pub extern fn g_checksum_get_string(checksum: ?*GChecksum) [*c]const gchar;
pub extern fn g_checksum_get_digest(checksum: ?*GChecksum, buffer: [*c]guint8, digest_len: [*c]gsize) void;
pub extern fn g_compute_checksum_for_data(checksum_type: GChecksumType, data: [*c]const guchar, length: gsize) [*c]gchar;
pub extern fn g_compute_checksum_for_string(checksum_type: GChecksumType, str: [*c]const gchar, length: gssize) [*c]gchar;
pub extern fn g_compute_checksum_for_bytes(checksum_type: GChecksumType, data: ?*GBytes) [*c]gchar;
pub const G_CONVERT_ERROR_NO_CONVERSION: c_int = 0;
pub const G_CONVERT_ERROR_ILLEGAL_SEQUENCE: c_int = 1;
pub const G_CONVERT_ERROR_FAILED: c_int = 2;
pub const G_CONVERT_ERROR_PARTIAL_INPUT: c_int = 3;
pub const G_CONVERT_ERROR_BAD_URI: c_int = 4;
pub const G_CONVERT_ERROR_NOT_ABSOLUTE_PATH: c_int = 5;
pub const G_CONVERT_ERROR_NO_MEMORY: c_int = 6;
pub const G_CONVERT_ERROR_EMBEDDED_NUL: c_int = 7;
pub const GConvertError = c_uint;
pub extern fn g_convert_error_quark() GQuark;
pub const struct__GIConv = opaque {};
pub const GIConv = ?*struct__GIConv;
pub extern fn g_iconv_open(to_codeset: [*c]const gchar, from_codeset: [*c]const gchar) GIConv;
pub extern fn g_iconv(converter: GIConv, inbuf: [*c][*c]gchar, inbytes_left: [*c]gsize, outbuf: [*c][*c]gchar, outbytes_left: [*c]gsize) gsize;
pub extern fn g_iconv_close(converter: GIConv) gint;
pub extern fn g_convert(str: [*c]const gchar, len: gssize, to_codeset: [*c]const gchar, from_codeset: [*c]const gchar, bytes_read: [*c]gsize, bytes_written: [*c]gsize, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_convert_with_iconv(str: [*c]const gchar, len: gssize, converter: GIConv, bytes_read: [*c]gsize, bytes_written: [*c]gsize, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_convert_with_fallback(str: [*c]const gchar, len: gssize, to_codeset: [*c]const gchar, from_codeset: [*c]const gchar, fallback: [*c]const gchar, bytes_read: [*c]gsize, bytes_written: [*c]gsize, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_locale_to_utf8(opsysstring: [*c]const gchar, len: gssize, bytes_read: [*c]gsize, bytes_written: [*c]gsize, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_locale_from_utf8(utf8string: [*c]const gchar, len: gssize, bytes_read: [*c]gsize, bytes_written: [*c]gsize, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_filename_to_utf8(opsysstring: [*c]const gchar, len: gssize, bytes_read: [*c]gsize, bytes_written: [*c]gsize, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_filename_from_utf8(utf8string: [*c]const gchar, len: gssize, bytes_read: [*c]gsize, bytes_written: [*c]gsize, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_filename_from_uri(uri: [*c]const gchar, hostname: [*c][*c]gchar, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_filename_to_uri(filename: [*c]const gchar, hostname: [*c]const gchar, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_filename_display_name(filename: [*c]const gchar) [*c]gchar;
pub extern fn g_get_filename_charsets(filename_charsets: [*c][*c][*c]const gchar) gboolean;
pub extern fn g_filename_display_basename(filename: [*c]const gchar) [*c]gchar;
pub extern fn g_uri_list_extract_uris(uri_list: [*c]const gchar) [*c][*c]gchar;
pub const struct__GData = opaque {};
pub const GData = struct__GData;
pub const GDataForeachFunc = ?*const fn (GQuark, gpointer, gpointer) callconv(.c) void;
pub extern fn g_datalist_init(datalist: [*c]?*GData) void;
pub extern fn g_datalist_clear(datalist: [*c]?*GData) void;
pub extern fn g_datalist_id_get_data(datalist: [*c]?*GData, key_id: GQuark) gpointer;
pub extern fn g_datalist_id_set_data_full(datalist: [*c]?*GData, key_id: GQuark, data: gpointer, destroy_func: GDestroyNotify) void;
pub extern fn g_datalist_id_remove_multiple(datalist: [*c]?*GData, keys: [*c]GQuark, n_keys: gsize) void;
pub const GDuplicateFunc = ?*const fn (gpointer, gpointer) callconv(.c) gpointer;
pub extern fn g_datalist_id_dup_data(datalist: [*c]?*GData, key_id: GQuark, dup_func: GDuplicateFunc, user_data: gpointer) gpointer;
pub extern fn g_datalist_id_replace_data(datalist: [*c]?*GData, key_id: GQuark, oldval: gpointer, newval: gpointer, destroy: GDestroyNotify, old_destroy: [*c]GDestroyNotify) gboolean;
pub extern fn g_datalist_id_remove_no_notify(datalist: [*c]?*GData, key_id: GQuark) gpointer;
pub extern fn g_datalist_foreach(datalist: [*c]?*GData, func: GDataForeachFunc, user_data: gpointer) void;
pub extern fn g_datalist_set_flags(datalist: [*c]?*GData, flags: guint) void;
pub extern fn g_datalist_unset_flags(datalist: [*c]?*GData, flags: guint) void;
pub extern fn g_datalist_get_flags(datalist: [*c]?*GData) guint;
pub extern fn g_dataset_destroy(dataset_location: gconstpointer) void;
pub extern fn g_dataset_id_get_data(dataset_location: gconstpointer, key_id: GQuark) gpointer;
pub extern fn g_datalist_get_data(datalist: [*c]?*GData, key: [*c]const gchar) gpointer;
pub extern fn g_dataset_id_set_data_full(dataset_location: gconstpointer, key_id: GQuark, data: gpointer, destroy_func: GDestroyNotify) void;
pub extern fn g_dataset_id_remove_no_notify(dataset_location: gconstpointer, key_id: GQuark) gpointer;
pub extern fn g_dataset_foreach(dataset_location: gconstpointer, func: GDataForeachFunc, user_data: gpointer) void;
pub const GTime = gint32;
pub const GDateYear = guint16;
pub const GDateDay = guint8;
// /usr/include/glib-2.0/glib/gdate.h:94:9: warning: struct demoted to opaque type - has bitfield
pub const struct__GDate = opaque {};
pub const GDate = struct__GDate;
pub const G_DATE_DAY: c_int = 0;
pub const G_DATE_MONTH: c_int = 1;
pub const G_DATE_YEAR: c_int = 2;
pub const GDateDMY = c_uint;
pub const G_DATE_BAD_WEEKDAY: c_int = 0;
pub const G_DATE_MONDAY: c_int = 1;
pub const G_DATE_TUESDAY: c_int = 2;
pub const G_DATE_WEDNESDAY: c_int = 3;
pub const G_DATE_THURSDAY: c_int = 4;
pub const G_DATE_FRIDAY: c_int = 5;
pub const G_DATE_SATURDAY: c_int = 6;
pub const G_DATE_SUNDAY: c_int = 7;
pub const GDateWeekday = c_uint;
pub const G_DATE_BAD_MONTH: c_int = 0;
pub const G_DATE_JANUARY: c_int = 1;
pub const G_DATE_FEBRUARY: c_int = 2;
pub const G_DATE_MARCH: c_int = 3;
pub const G_DATE_APRIL: c_int = 4;
pub const G_DATE_MAY: c_int = 5;
pub const G_DATE_JUNE: c_int = 6;
pub const G_DATE_JULY: c_int = 7;
pub const G_DATE_AUGUST: c_int = 8;
pub const G_DATE_SEPTEMBER: c_int = 9;
pub const G_DATE_OCTOBER: c_int = 10;
pub const G_DATE_NOVEMBER: c_int = 11;
pub const G_DATE_DECEMBER: c_int = 12;
pub const GDateMonth = c_uint;
pub extern fn g_date_new() ?*GDate;
pub extern fn g_date_new_dmy(day: GDateDay, month: GDateMonth, year: GDateYear) ?*GDate;
pub extern fn g_date_new_julian(julian_day: guint32) ?*GDate;
pub extern fn g_date_free(date: ?*GDate) void;
pub extern fn g_date_copy(date: ?*const GDate) ?*GDate;
pub extern fn g_date_valid(date: ?*const GDate) gboolean;
pub extern fn g_date_valid_day(day: GDateDay) gboolean;
pub extern fn g_date_valid_month(month: GDateMonth) gboolean;
pub extern fn g_date_valid_year(year: GDateYear) gboolean;
pub extern fn g_date_valid_weekday(weekday: GDateWeekday) gboolean;
pub extern fn g_date_valid_julian(julian_date: guint32) gboolean;
pub extern fn g_date_valid_dmy(day: GDateDay, month: GDateMonth, year: GDateYear) gboolean;
pub extern fn g_date_get_weekday(date: ?*const GDate) GDateWeekday;
pub extern fn g_date_get_month(date: ?*const GDate) GDateMonth;
pub extern fn g_date_get_year(date: ?*const GDate) GDateYear;
pub extern fn g_date_get_day(date: ?*const GDate) GDateDay;
pub extern fn g_date_get_julian(date: ?*const GDate) guint32;
pub extern fn g_date_get_day_of_year(date: ?*const GDate) guint;
pub extern fn g_date_get_monday_week_of_year(date: ?*const GDate) guint;
pub extern fn g_date_get_sunday_week_of_year(date: ?*const GDate) guint;
pub extern fn g_date_get_week_of_year(date: ?*const GDate, first_day_of_week: GDateWeekday) guint;
pub extern fn g_date_get_iso8601_week_of_year(date: ?*const GDate) guint;
pub extern fn g_date_clear(date: ?*GDate, n_dates: guint) void;
pub extern fn g_date_set_parse(date: ?*GDate, str: [*c]const gchar) void;
pub extern fn g_date_set_time_t(date: ?*GDate, timet: time_t) void;
pub extern fn g_date_set_time_val(date: ?*GDate, timeval: [*c]GTimeVal) void;
pub extern fn g_date_set_time(date: ?*GDate, time_: GTime) void;
pub extern fn g_date_set_month(date: ?*GDate, month: GDateMonth) void;
pub extern fn g_date_set_day(date: ?*GDate, day: GDateDay) void;
pub extern fn g_date_set_year(date: ?*GDate, year: GDateYear) void;
pub extern fn g_date_set_dmy(date: ?*GDate, day: GDateDay, month: GDateMonth, y: GDateYear) void;
pub extern fn g_date_set_julian(date: ?*GDate, julian_date: guint32) void;
pub extern fn g_date_is_first_of_month(date: ?*const GDate) gboolean;
pub extern fn g_date_is_last_of_month(date: ?*const GDate) gboolean;
pub extern fn g_date_add_days(date: ?*GDate, n_days: guint) void;
pub extern fn g_date_subtract_days(date: ?*GDate, n_days: guint) void;
pub extern fn g_date_add_months(date: ?*GDate, n_months: guint) void;
pub extern fn g_date_subtract_months(date: ?*GDate, n_months: guint) void;
pub extern fn g_date_add_years(date: ?*GDate, n_years: guint) void;
pub extern fn g_date_subtract_years(date: ?*GDate, n_years: guint) void;
pub extern fn g_date_is_leap_year(year: GDateYear) gboolean;
pub extern fn g_date_get_days_in_month(month: GDateMonth, year: GDateYear) guint8;
pub extern fn g_date_get_monday_weeks_in_year(year: GDateYear) guint8;
pub extern fn g_date_get_sunday_weeks_in_year(year: GDateYear) guint8;
pub extern fn g_date_get_weeks_in_year(year: GDateYear, first_day_of_week: GDateWeekday) guint8;
pub extern fn g_date_days_between(date1: ?*const GDate, date2: ?*const GDate) gint;
pub extern fn g_date_compare(lhs: ?*const GDate, rhs: ?*const GDate) gint;
pub extern fn g_date_to_struct_tm(date: ?*const GDate, tm: [*c]struct_tm) void;
pub extern fn g_date_clamp(date: ?*GDate, min_date: ?*const GDate, max_date: ?*const GDate) void;
pub extern fn g_date_order(date1: ?*GDate, date2: ?*GDate) void;
pub extern fn g_date_strftime(s: [*c]gchar, slen: gsize, format: [*c]const gchar, date: ?*const GDate) gsize;
pub const struct_dirent = extern struct {
    d_ino: __ino_t = @import("std").mem.zeroes(__ino_t),
    d_off: __off_t = @import("std").mem.zeroes(__off_t),
    d_reclen: c_ushort = @import("std").mem.zeroes(c_ushort),
    d_type: u8 = @import("std").mem.zeroes(u8),
    d_name: [256]u8 = @import("std").mem.zeroes([256]u8),
};
pub const DT_UNKNOWN: c_int = 0;
pub const DT_FIFO: c_int = 1;
pub const DT_CHR: c_int = 2;
pub const DT_DIR: c_int = 4;
pub const DT_BLK: c_int = 6;
pub const DT_REG: c_int = 8;
pub const DT_LNK: c_int = 10;
pub const DT_SOCK: c_int = 12;
pub const DT_WHT: c_int = 14;
const enum_unnamed_29 = c_uint;
pub const struct___dirstream = opaque {};
pub const DIR = struct___dirstream;
pub extern fn closedir(__dirp: ?*DIR) c_int;
pub extern fn opendir(__name: [*c]const u8) ?*DIR;
pub extern fn fdopendir(__fd: c_int) ?*DIR;
pub extern fn readdir(__dirp: ?*DIR) [*c]struct_dirent;
pub extern fn readdir_r(noalias __dirp: ?*DIR, noalias __entry: [*c]struct_dirent, noalias __result: [*c][*c]struct_dirent) c_int;
pub extern fn rewinddir(__dirp: ?*DIR) void;
pub extern fn seekdir(__dirp: ?*DIR, __pos: c_long) void;
pub extern fn telldir(__dirp: ?*DIR) c_long;
pub extern fn dirfd(__dirp: ?*DIR) c_int;
pub extern fn scandir(noalias __dir: [*c]const u8, noalias __namelist: [*c][*c][*c]struct_dirent, __selector: ?*const fn ([*c]const struct_dirent) callconv(.c) c_int, __cmp: ?*const fn ([*c][*c]const struct_dirent, [*c][*c]const struct_dirent) callconv(.c) c_int) c_int;
pub extern fn alphasort(__e1: [*c][*c]const struct_dirent, __e2: [*c][*c]const struct_dirent) c_int;
pub extern fn getdirentries(__fd: c_int, noalias __buf: [*c]u8, __nbytes: usize, noalias __basep: [*c]__off_t) __ssize_t;
pub const struct__GDir = opaque {};
pub const GDir = struct__GDir;
pub extern fn g_dir_open(path: [*c]const gchar, flags: guint, @"error": [*c][*c]GError) ?*GDir;
pub extern fn g_dir_read_name(dir: ?*GDir) [*c]const gchar;
pub extern fn g_dir_rewind(dir: ?*GDir) void;
pub extern fn g_dir_close(dir: ?*GDir) void;
pub extern fn g_dir_ref(dir: ?*GDir) ?*GDir;
pub extern fn g_dir_unref(dir: ?*GDir) void;
pub extern fn g_getenv(variable: [*c]const gchar) [*c]const gchar;
pub extern fn g_setenv(variable: [*c]const gchar, value: [*c]const gchar, overwrite: gboolean) gboolean;
pub extern fn g_unsetenv(variable: [*c]const gchar) void;
pub extern fn g_listenv() [*c][*c]gchar;
pub extern fn g_get_environ() [*c][*c]gchar;
pub extern fn g_environ_getenv(envp: [*c][*c]gchar, variable: [*c]const gchar) [*c]const gchar;
pub extern fn g_environ_setenv(envp: [*c][*c]gchar, variable: [*c]const gchar, value: [*c]const gchar, overwrite: gboolean) [*c][*c]gchar;
pub extern fn g_environ_unsetenv(envp: [*c][*c]gchar, variable: [*c]const gchar) [*c][*c]gchar;
pub const G_FILE_ERROR_EXIST: c_int = 0;
pub const G_FILE_ERROR_ISDIR: c_int = 1;
pub const G_FILE_ERROR_ACCES: c_int = 2;
pub const G_FILE_ERROR_NAMETOOLONG: c_int = 3;
pub const G_FILE_ERROR_NOENT: c_int = 4;
pub const G_FILE_ERROR_NOTDIR: c_int = 5;
pub const G_FILE_ERROR_NXIO: c_int = 6;
pub const G_FILE_ERROR_NODEV: c_int = 7;
pub const G_FILE_ERROR_ROFS: c_int = 8;
pub const G_FILE_ERROR_TXTBSY: c_int = 9;
pub const G_FILE_ERROR_FAULT: c_int = 10;
pub const G_FILE_ERROR_LOOP: c_int = 11;
pub const G_FILE_ERROR_NOSPC: c_int = 12;
pub const G_FILE_ERROR_NOMEM: c_int = 13;
pub const G_FILE_ERROR_MFILE: c_int = 14;
pub const G_FILE_ERROR_NFILE: c_int = 15;
pub const G_FILE_ERROR_BADF: c_int = 16;
pub const G_FILE_ERROR_INVAL: c_int = 17;
pub const G_FILE_ERROR_PIPE: c_int = 18;
pub const G_FILE_ERROR_AGAIN: c_int = 19;
pub const G_FILE_ERROR_INTR: c_int = 20;
pub const G_FILE_ERROR_IO: c_int = 21;
pub const G_FILE_ERROR_PERM: c_int = 22;
pub const G_FILE_ERROR_NOSYS: c_int = 23;
pub const G_FILE_ERROR_FAILED: c_int = 24;
pub const GFileError = c_uint;
pub const G_FILE_TEST_IS_REGULAR: c_int = 1;
pub const G_FILE_TEST_IS_SYMLINK: c_int = 2;
pub const G_FILE_TEST_IS_DIR: c_int = 4;
pub const G_FILE_TEST_IS_EXECUTABLE: c_int = 8;
pub const G_FILE_TEST_EXISTS: c_int = 16;
pub const GFileTest = c_uint;
pub const G_FILE_SET_CONTENTS_NONE: c_int = 0;
pub const G_FILE_SET_CONTENTS_CONSISTENT: c_int = 1;
pub const G_FILE_SET_CONTENTS_DURABLE: c_int = 2;
pub const G_FILE_SET_CONTENTS_ONLY_EXISTING: c_int = 4;
pub const GFileSetContentsFlags = c_uint;
pub extern fn g_file_error_quark() GQuark;
pub extern fn g_file_error_from_errno(err_no: gint) GFileError;
pub extern fn g_file_test(filename: [*c]const gchar, @"test": GFileTest) gboolean;
pub extern fn g_file_get_contents(filename: [*c]const gchar, contents: [*c][*c]gchar, length: [*c]gsize, @"error": [*c][*c]GError) gboolean;
pub extern fn g_file_set_contents(filename: [*c]const gchar, contents: [*c]const gchar, length: gssize, @"error": [*c][*c]GError) gboolean;
pub extern fn g_file_set_contents_full(filename: [*c]const gchar, contents: [*c]const gchar, length: gssize, flags: GFileSetContentsFlags, mode: c_int, @"error": [*c][*c]GError) gboolean;
pub extern fn g_file_read_link(filename: [*c]const gchar, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_mkdtemp(tmpl: [*c]gchar) [*c]gchar;
pub extern fn g_mkdtemp_full(tmpl: [*c]gchar, mode: gint) [*c]gchar;
pub extern fn g_mkstemp(tmpl: [*c]gchar) gint;
pub extern fn g_mkstemp_full(tmpl: [*c]gchar, flags: gint, mode: gint) gint;
pub extern fn g_file_open_tmp(tmpl: [*c]const gchar, name_used: [*c][*c]gchar, @"error": [*c][*c]GError) gint;
pub extern fn g_dir_make_tmp(tmpl: [*c]const gchar, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_build_path(separator: [*c]const gchar, first_element: [*c]const gchar, ...) [*c]gchar;
pub extern fn g_build_pathv(separator: [*c]const gchar, args: [*c][*c]gchar) [*c]gchar;
pub extern fn g_build_filename(first_element: [*c]const gchar, ...) [*c]gchar;
pub extern fn g_build_filenamev(args: [*c][*c]gchar) [*c]gchar;
pub extern fn g_build_filename_valist(first_element: [*c]const gchar, args: [*c]va_list) [*c]gchar;
pub extern fn g_mkdir_with_parents(pathname: [*c]const gchar, mode: gint) gint;
pub extern fn g_path_is_absolute(file_name: [*c]const gchar) gboolean;
pub extern fn g_path_skip_root(file_name: [*c]const gchar) [*c]const gchar;
pub extern fn g_basename(file_name: [*c]const gchar) [*c]const gchar;
pub extern fn g_get_current_dir() [*c]gchar;
pub extern fn g_path_get_basename(file_name: [*c]const gchar) [*c]gchar;
pub extern fn g_path_get_dirname(file_name: [*c]const gchar) [*c]gchar;
pub extern fn g_canonicalize_filename(filename: [*c]const gchar, relative_to: [*c]const gchar) [*c]gchar;
pub extern fn g_strip_context(msgid: [*c]const gchar, msgval: [*c]const gchar) [*c]const gchar;
pub extern fn g_dgettext(domain: [*c]const gchar, msgid: [*c]const gchar) [*c]const gchar;
pub extern fn g_dcgettext(domain: [*c]const gchar, msgid: [*c]const gchar, category: gint) [*c]const gchar;
pub extern fn g_dngettext(domain: [*c]const gchar, msgid: [*c]const gchar, msgid_plural: [*c]const gchar, n: gulong) [*c]const gchar;
pub extern fn g_dpgettext(domain: [*c]const gchar, msgctxtid: [*c]const gchar, msgidoffset: gsize) [*c]const gchar;
pub extern fn g_dpgettext2(domain: [*c]const gchar, context: [*c]const gchar, msgid: [*c]const gchar) [*c]const gchar;
pub const struct__GMemVTable = extern struct {
    malloc: ?*const fn (gsize) callconv(.c) gpointer = @import("std").mem.zeroes(?*const fn (gsize) callconv(.c) gpointer),
    realloc: ?*const fn (gpointer, gsize) callconv(.c) gpointer = @import("std").mem.zeroes(?*const fn (gpointer, gsize) callconv(.c) gpointer),
    free: ?*const fn (gpointer) callconv(.c) void = @import("std").mem.zeroes(?*const fn (gpointer) callconv(.c) void),
    calloc: ?*const fn (gsize, gsize) callconv(.c) gpointer = @import("std").mem.zeroes(?*const fn (gsize, gsize) callconv(.c) gpointer),
    try_malloc: ?*const fn (gsize) callconv(.c) gpointer = @import("std").mem.zeroes(?*const fn (gsize) callconv(.c) gpointer),
    try_realloc: ?*const fn (gpointer, gsize) callconv(.c) gpointer = @import("std").mem.zeroes(?*const fn (gpointer, gsize) callconv(.c) gpointer),
};
pub const GMemVTable = struct__GMemVTable;
pub extern fn g_free(mem: gpointer) void;
pub extern fn g_free_sized(mem: gpointer, size: usize) void;
pub extern fn g_clear_pointer(pp: [*c]gpointer, destroy: GDestroyNotify) void;
pub extern fn g_malloc(n_bytes: gsize) gpointer;
pub extern fn g_malloc0(n_bytes: gsize) gpointer;
pub extern fn g_realloc(mem: gpointer, n_bytes: gsize) gpointer;
pub extern fn g_try_malloc(n_bytes: gsize) gpointer;
pub extern fn g_try_malloc0(n_bytes: gsize) gpointer;
pub extern fn g_try_realloc(mem: gpointer, n_bytes: gsize) gpointer;
pub extern fn g_malloc_n(n_blocks: gsize, n_block_bytes: gsize) gpointer;
pub extern fn g_malloc0_n(n_blocks: gsize, n_block_bytes: gsize) gpointer;
pub extern fn g_realloc_n(mem: gpointer, n_blocks: gsize, n_block_bytes: gsize) gpointer;
pub extern fn g_try_malloc_n(n_blocks: gsize, n_block_bytes: gsize) gpointer;
pub extern fn g_try_malloc0_n(n_blocks: gsize, n_block_bytes: gsize) gpointer;
pub extern fn g_try_realloc_n(mem: gpointer, n_blocks: gsize, n_block_bytes: gsize) gpointer;
pub extern fn g_aligned_alloc(n_blocks: gsize, n_block_bytes: gsize, alignment: gsize) gpointer;
pub extern fn g_aligned_alloc0(n_blocks: gsize, n_block_bytes: gsize, alignment: gsize) gpointer;
pub extern fn g_aligned_free(mem: gpointer) void;
pub extern fn g_aligned_free_sized(mem: gpointer, alignment: usize, size: usize) void;
pub fn g_steal_pointer(arg_pp: gpointer) callconv(.c) gpointer {
    var pp = arg_pp;
    _ = &pp;
    var ptr: [*c]gpointer = @as([*c]gpointer, @ptrCast(@alignCast(pp)));
    _ = &ptr;
    var ref: gpointer = undefined;
    _ = &ref;
    ref = ptr.*;
    ptr.* = @as(?*anyopaque, @ptrFromInt(@as(c_int, 0)));
    return ref;
}
pub extern fn g_mem_set_vtable(vtable: [*c]GMemVTable) void;
pub extern fn g_mem_is_system_malloc() gboolean;
pub extern var g_mem_gc_friendly: gboolean;
pub extern var glib_mem_profiler_table: [*c]GMemVTable;
pub extern fn g_mem_profile() void;
pub const GNode = struct__GNode;
pub const struct__GNode = extern struct {
    data: gpointer = @import("std").mem.zeroes(gpointer),
    next: [*c]GNode = @import("std").mem.zeroes([*c]GNode),
    prev: [*c]GNode = @import("std").mem.zeroes([*c]GNode),
    parent: [*c]GNode = @import("std").mem.zeroes([*c]GNode),
    children: [*c]GNode = @import("std").mem.zeroes([*c]GNode),
};
pub const G_TRAVERSE_LEAVES: c_int = 1;
pub const G_TRAVERSE_NON_LEAVES: c_int = 2;
pub const G_TRAVERSE_ALL: c_int = 3;
pub const G_TRAVERSE_MASK: c_int = 3;
pub const G_TRAVERSE_LEAFS: c_int = 1;
pub const G_TRAVERSE_NON_LEAFS: c_int = 2;
pub const GTraverseFlags = c_uint;
pub const G_IN_ORDER: c_int = 0;
pub const G_PRE_ORDER: c_int = 1;
pub const G_POST_ORDER: c_int = 2;
pub const G_LEVEL_ORDER: c_int = 3;
pub const GTraverseType = c_uint;
pub const GNodeTraverseFunc = ?*const fn ([*c]GNode, gpointer) callconv(.c) gboolean;
pub const GNodeForeachFunc = ?*const fn ([*c]GNode, gpointer) callconv(.c) void;
pub extern fn g_node_new(data: gpointer) [*c]GNode;
pub extern fn g_node_destroy(root: [*c]GNode) void;
pub extern fn g_node_unlink(node: [*c]GNode) void;
pub extern fn g_node_copy_deep(node: [*c]GNode, copy_func: GCopyFunc, data: gpointer) [*c]GNode;
pub extern fn g_node_copy(node: [*c]GNode) [*c]GNode;
pub extern fn g_node_insert(parent: [*c]GNode, position: gint, node: [*c]GNode) [*c]GNode;
pub extern fn g_node_insert_before(parent: [*c]GNode, sibling: [*c]GNode, node: [*c]GNode) [*c]GNode;
pub extern fn g_node_insert_after(parent: [*c]GNode, sibling: [*c]GNode, node: [*c]GNode) [*c]GNode;
pub extern fn g_node_prepend(parent: [*c]GNode, node: [*c]GNode) [*c]GNode;
pub extern fn g_node_n_nodes(root: [*c]GNode, flags: GTraverseFlags) guint;
pub extern fn g_node_get_root(node: [*c]GNode) [*c]GNode;
pub extern fn g_node_is_ancestor(node: [*c]GNode, descendant: [*c]GNode) gboolean;
pub extern fn g_node_depth(node: [*c]GNode) guint;
pub extern fn g_node_find(root: [*c]GNode, order: GTraverseType, flags: GTraverseFlags, data: gpointer) [*c]GNode;
pub extern fn g_node_traverse(root: [*c]GNode, order: GTraverseType, flags: GTraverseFlags, max_depth: gint, func: GNodeTraverseFunc, data: gpointer) void;
pub extern fn g_node_max_height(root: [*c]GNode) guint;
pub extern fn g_node_children_foreach(node: [*c]GNode, flags: GTraverseFlags, func: GNodeForeachFunc, data: gpointer) void;
pub extern fn g_node_reverse_children(node: [*c]GNode) void;
pub extern fn g_node_n_children(node: [*c]GNode) guint;
pub extern fn g_node_nth_child(node: [*c]GNode, n: guint) [*c]GNode;
pub extern fn g_node_last_child(node: [*c]GNode) [*c]GNode;
pub extern fn g_node_find_child(node: [*c]GNode, flags: GTraverseFlags, data: gpointer) [*c]GNode;
pub extern fn g_node_child_position(node: [*c]GNode, child: [*c]GNode) gint;
pub extern fn g_node_child_index(node: [*c]GNode, data: gpointer) gint;
pub extern fn g_node_first_sibling(node: [*c]GNode) [*c]GNode;
pub extern fn g_node_last_sibling(node: [*c]GNode) [*c]GNode;
pub const GList = struct__GList;
pub const struct__GList = extern struct {
    data: gpointer = @import("std").mem.zeroes(gpointer),
    next: [*c]GList = @import("std").mem.zeroes([*c]GList),
    prev: [*c]GList = @import("std").mem.zeroes([*c]GList),
};
pub extern fn g_list_alloc() [*c]GList;
pub extern fn g_list_free(list: [*c]GList) void;
pub extern fn g_list_free_1(list: [*c]GList) void;
pub extern fn g_list_free_full(list: [*c]GList, free_func: GDestroyNotify) void;
pub extern fn g_list_append(list: [*c]GList, data: gpointer) [*c]GList;
pub extern fn g_list_prepend(list: [*c]GList, data: gpointer) [*c]GList;
pub extern fn g_list_insert(list: [*c]GList, data: gpointer, position: gint) [*c]GList;
pub extern fn g_list_insert_sorted(list: [*c]GList, data: gpointer, func: GCompareFunc) [*c]GList;
pub extern fn g_list_insert_sorted_with_data(list: [*c]GList, data: gpointer, func: GCompareDataFunc, user_data: gpointer) [*c]GList;
pub extern fn g_list_insert_before(list: [*c]GList, sibling: [*c]GList, data: gpointer) [*c]GList;
pub extern fn g_list_insert_before_link(list: [*c]GList, sibling: [*c]GList, link_: [*c]GList) [*c]GList;
pub extern fn g_list_concat(list1: [*c]GList, list2: [*c]GList) [*c]GList;
pub extern fn g_list_remove(list: [*c]GList, data: gconstpointer) [*c]GList;
pub extern fn g_list_remove_all(list: [*c]GList, data: gconstpointer) [*c]GList;
pub extern fn g_list_remove_link(list: [*c]GList, llink: [*c]GList) [*c]GList;
pub extern fn g_list_delete_link(list: [*c]GList, link_: [*c]GList) [*c]GList;
pub extern fn g_list_reverse(list: [*c]GList) [*c]GList;
pub extern fn g_list_copy(list: [*c]GList) [*c]GList;
pub extern fn g_list_copy_deep(list: [*c]GList, func: GCopyFunc, user_data: gpointer) [*c]GList;
pub extern fn g_list_nth(list: [*c]GList, n: guint) [*c]GList;
pub extern fn g_list_nth_prev(list: [*c]GList, n: guint) [*c]GList;
pub extern fn g_list_find(list: [*c]GList, data: gconstpointer) [*c]GList;
pub extern fn g_list_find_custom(list: [*c]GList, data: gconstpointer, func: GCompareFunc) [*c]GList;
pub extern fn g_list_position(list: [*c]GList, llink: [*c]GList) gint;
pub extern fn g_list_index(list: [*c]GList, data: gconstpointer) gint;
pub extern fn g_list_last(list: [*c]GList) [*c]GList;
pub extern fn g_list_first(list: [*c]GList) [*c]GList;
pub extern fn g_list_length(list: [*c]GList) guint;
pub extern fn g_list_foreach(list: [*c]GList, func: GFunc, user_data: gpointer) void;
pub extern fn g_list_sort(list: [*c]GList, compare_func: GCompareFunc) [*c]GList;
pub extern fn g_list_sort_with_data(list: [*c]GList, compare_func: GCompareDataFunc, user_data: gpointer) [*c]GList;
pub extern fn g_list_nth_data(list: [*c]GList, n: guint) gpointer;
pub extern fn g_clear_list(list_ptr: [*c][*c]GList, destroy: GDestroyNotify) void;
pub const struct__GHashTable = opaque {};
pub const GHashTable = struct__GHashTable;
pub const GHRFunc = ?*const fn (gpointer, gpointer, gpointer) callconv(.c) gboolean;
pub const struct__GHashTableIter = extern struct {
    dummy1: gpointer = @import("std").mem.zeroes(gpointer),
    dummy2: gpointer = @import("std").mem.zeroes(gpointer),
    dummy3: gpointer = @import("std").mem.zeroes(gpointer),
    dummy4: c_int = @import("std").mem.zeroes(c_int),
    dummy5: gboolean = @import("std").mem.zeroes(gboolean),
    dummy6: gpointer = @import("std").mem.zeroes(gpointer),
};
pub const GHashTableIter = struct__GHashTableIter;
pub extern fn g_hash_table_new(hash_func: GHashFunc, key_equal_func: GEqualFunc) ?*GHashTable;
pub extern fn g_hash_table_new_full(hash_func: GHashFunc, key_equal_func: GEqualFunc, key_destroy_func: GDestroyNotify, value_destroy_func: GDestroyNotify) ?*GHashTable;
pub extern fn g_hash_table_new_similar(other_hash_table: ?*GHashTable) ?*GHashTable;
pub extern fn g_hash_table_destroy(hash_table: ?*GHashTable) void;
pub extern fn g_hash_table_insert(hash_table: ?*GHashTable, key: gpointer, value: gpointer) gboolean;
pub extern fn g_hash_table_replace(hash_table: ?*GHashTable, key: gpointer, value: gpointer) gboolean;
pub extern fn g_hash_table_add(hash_table: ?*GHashTable, key: gpointer) gboolean;
pub extern fn g_hash_table_remove(hash_table: ?*GHashTable, key: gconstpointer) gboolean;
pub extern fn g_hash_table_remove_all(hash_table: ?*GHashTable) void;
pub extern fn g_hash_table_steal(hash_table: ?*GHashTable, key: gconstpointer) gboolean;
pub extern fn g_hash_table_steal_extended(hash_table: ?*GHashTable, lookup_key: gconstpointer, stolen_key: [*c]gpointer, stolen_value: [*c]gpointer) gboolean;
pub extern fn g_hash_table_steal_all(hash_table: ?*GHashTable) void;
pub extern fn g_hash_table_steal_all_keys(hash_table: ?*GHashTable) [*c]GPtrArray;
pub extern fn g_hash_table_steal_all_values(hash_table: ?*GHashTable) [*c]GPtrArray;
pub extern fn g_hash_table_lookup(hash_table: ?*GHashTable, key: gconstpointer) gpointer;
pub extern fn g_hash_table_contains(hash_table: ?*GHashTable, key: gconstpointer) gboolean;
pub extern fn g_hash_table_lookup_extended(hash_table: ?*GHashTable, lookup_key: gconstpointer, orig_key: [*c]gpointer, value: [*c]gpointer) gboolean;
pub extern fn g_hash_table_foreach(hash_table: ?*GHashTable, func: GHFunc, user_data: gpointer) void;
pub extern fn g_hash_table_find(hash_table: ?*GHashTable, predicate: GHRFunc, user_data: gpointer) gpointer;
pub extern fn g_hash_table_foreach_remove(hash_table: ?*GHashTable, func: GHRFunc, user_data: gpointer) guint;
pub extern fn g_hash_table_foreach_steal(hash_table: ?*GHashTable, func: GHRFunc, user_data: gpointer) guint;
pub extern fn g_hash_table_size(hash_table: ?*GHashTable) guint;
pub extern fn g_hash_table_get_keys(hash_table: ?*GHashTable) [*c]GList;
pub extern fn g_hash_table_get_values(hash_table: ?*GHashTable) [*c]GList;
pub extern fn g_hash_table_get_keys_as_array(hash_table: ?*GHashTable, length: [*c]guint) [*c]gpointer;
pub extern fn g_hash_table_get_keys_as_ptr_array(hash_table: ?*GHashTable) [*c]GPtrArray;
pub extern fn g_hash_table_get_values_as_ptr_array(hash_table: ?*GHashTable) [*c]GPtrArray;
pub extern fn g_hash_table_iter_init(iter: [*c]GHashTableIter, hash_table: ?*GHashTable) void;
pub extern fn g_hash_table_iter_next(iter: [*c]GHashTableIter, key: [*c]gpointer, value: [*c]gpointer) gboolean;
pub extern fn g_hash_table_iter_get_hash_table(iter: [*c]GHashTableIter) ?*GHashTable;
pub extern fn g_hash_table_iter_remove(iter: [*c]GHashTableIter) void;
pub extern fn g_hash_table_iter_replace(iter: [*c]GHashTableIter, value: gpointer) void;
pub extern fn g_hash_table_iter_steal(iter: [*c]GHashTableIter) void;
pub extern fn g_hash_table_ref(hash_table: ?*GHashTable) ?*GHashTable;
pub extern fn g_hash_table_unref(hash_table: ?*GHashTable) void;
pub extern fn g_str_equal(v1: gconstpointer, v2: gconstpointer) gboolean;
pub extern fn g_str_hash(v: gconstpointer) guint;
pub extern fn g_int_equal(v1: gconstpointer, v2: gconstpointer) gboolean;
pub extern fn g_int_hash(v: gconstpointer) guint;
pub extern fn g_int64_equal(v1: gconstpointer, v2: gconstpointer) gboolean;
pub extern fn g_int64_hash(v: gconstpointer) guint;
pub extern fn g_double_equal(v1: gconstpointer, v2: gconstpointer) gboolean;
pub extern fn g_double_hash(v: gconstpointer) guint;
pub extern fn g_direct_hash(v: gconstpointer) guint;
pub extern fn g_direct_equal(v1: gconstpointer, v2: gconstpointer) gboolean;
pub const struct__GHmac = opaque {};
pub const GHmac = struct__GHmac;
pub extern fn g_hmac_new(digest_type: GChecksumType, key: [*c]const guchar, key_len: gsize) ?*GHmac;
pub extern fn g_hmac_copy(hmac: ?*const GHmac) ?*GHmac;
pub extern fn g_hmac_ref(hmac: ?*GHmac) ?*GHmac;
pub extern fn g_hmac_unref(hmac: ?*GHmac) void;
pub extern fn g_hmac_update(hmac: ?*GHmac, data: [*c]const guchar, length: gssize) void;
pub extern fn g_hmac_get_string(hmac: ?*GHmac) [*c]const gchar;
pub extern fn g_hmac_get_digest(hmac: ?*GHmac, buffer: [*c]guint8, digest_len: [*c]gsize) void;
pub extern fn g_compute_hmac_for_data(digest_type: GChecksumType, key: [*c]const guchar, key_len: gsize, data: [*c]const guchar, length: gsize) [*c]gchar;
pub extern fn g_compute_hmac_for_string(digest_type: GChecksumType, key: [*c]const guchar, key_len: gsize, str: [*c]const gchar, length: gssize) [*c]gchar;
pub extern fn g_compute_hmac_for_bytes(digest_type: GChecksumType, key: ?*GBytes, data: ?*GBytes) [*c]gchar;
pub const GHook = struct__GHook;
pub const struct__GHook = extern struct {
    data: gpointer = @import("std").mem.zeroes(gpointer),
    next: [*c]GHook = @import("std").mem.zeroes([*c]GHook),
    prev: [*c]GHook = @import("std").mem.zeroes([*c]GHook),
    ref_count: guint = @import("std").mem.zeroes(guint),
    hook_id: gulong = @import("std").mem.zeroes(gulong),
    flags: guint = @import("std").mem.zeroes(guint),
    func: gpointer = @import("std").mem.zeroes(gpointer),
    destroy: GDestroyNotify = @import("std").mem.zeroes(GDestroyNotify),
};
// /usr/include/glib-2.0/glib/ghook.h:68:14: warning: struct demoted to opaque type - has bitfield
pub const struct__GHookList = opaque {};
pub const GHookList = struct__GHookList;
pub const GHookCompareFunc = ?*const fn ([*c]GHook, [*c]GHook) callconv(.c) gint;
pub const GHookFindFunc = ?*const fn ([*c]GHook, gpointer) callconv(.c) gboolean;
pub const GHookMarshaller = ?*const fn ([*c]GHook, gpointer) callconv(.c) void;
pub const GHookCheckMarshaller = ?*const fn ([*c]GHook, gpointer) callconv(.c) gboolean;
pub const GHookFunc = ?*const fn (gpointer) callconv(.c) void;
pub const GHookCheckFunc = ?*const fn (gpointer) callconv(.c) gboolean;
pub const GHookFinalizeFunc = ?*const fn (?*GHookList, [*c]GHook) callconv(.c) void;
pub const G_HOOK_FLAG_ACTIVE: c_int = 1;
pub const G_HOOK_FLAG_IN_CALL: c_int = 2;
pub const G_HOOK_FLAG_MASK: c_int = 15;
pub const GHookFlagMask = c_uint;
pub extern fn g_hook_list_init(hook_list: ?*GHookList, hook_size: guint) void;
pub extern fn g_hook_list_clear(hook_list: ?*GHookList) void;
pub extern fn g_hook_alloc(hook_list: ?*GHookList) [*c]GHook;
pub extern fn g_hook_free(hook_list: ?*GHookList, hook: [*c]GHook) void;
pub extern fn g_hook_ref(hook_list: ?*GHookList, hook: [*c]GHook) [*c]GHook;
pub extern fn g_hook_unref(hook_list: ?*GHookList, hook: [*c]GHook) void;
pub extern fn g_hook_destroy(hook_list: ?*GHookList, hook_id: gulong) gboolean;
pub extern fn g_hook_destroy_link(hook_list: ?*GHookList, hook: [*c]GHook) void;
pub extern fn g_hook_prepend(hook_list: ?*GHookList, hook: [*c]GHook) void;
pub extern fn g_hook_insert_before(hook_list: ?*GHookList, sibling: [*c]GHook, hook: [*c]GHook) void;
pub extern fn g_hook_insert_sorted(hook_list: ?*GHookList, hook: [*c]GHook, func: GHookCompareFunc) void;
pub extern fn g_hook_get(hook_list: ?*GHookList, hook_id: gulong) [*c]GHook;
pub extern fn g_hook_find(hook_list: ?*GHookList, need_valids: gboolean, func: GHookFindFunc, data: gpointer) [*c]GHook;
pub extern fn g_hook_find_data(hook_list: ?*GHookList, need_valids: gboolean, data: gpointer) [*c]GHook;
pub extern fn g_hook_find_func(hook_list: ?*GHookList, need_valids: gboolean, func: gpointer) [*c]GHook;
pub extern fn g_hook_find_func_data(hook_list: ?*GHookList, need_valids: gboolean, func: gpointer, data: gpointer) [*c]GHook;
pub extern fn g_hook_first_valid(hook_list: ?*GHookList, may_be_in_call: gboolean) [*c]GHook;
pub extern fn g_hook_next_valid(hook_list: ?*GHookList, hook: [*c]GHook, may_be_in_call: gboolean) [*c]GHook;
pub extern fn g_hook_compare_ids(new_hook: [*c]GHook, sibling: [*c]GHook) gint;
pub extern fn g_hook_list_invoke(hook_list: ?*GHookList, may_recurse: gboolean) void;
pub extern fn g_hook_list_invoke_check(hook_list: ?*GHookList, may_recurse: gboolean) void;
pub extern fn g_hook_list_marshal(hook_list: ?*GHookList, may_recurse: gboolean, marshaller: GHookMarshaller, marshal_data: gpointer) void;
pub extern fn g_hook_list_marshal_check(hook_list: ?*GHookList, may_recurse: gboolean, marshaller: GHookCheckMarshaller, marshal_data: gpointer) void;
pub extern fn g_hostname_is_non_ascii(hostname: [*c]const gchar) gboolean;
pub extern fn g_hostname_is_ascii_encoded(hostname: [*c]const gchar) gboolean;
pub extern fn g_hostname_is_ip_address(hostname: [*c]const gchar) gboolean;
pub extern fn g_hostname_to_ascii(hostname: [*c]const gchar) [*c]gchar;
pub extern fn g_hostname_to_unicode(hostname: [*c]const gchar) [*c]gchar;
pub const struct__GPollFD = extern struct {
    fd: gint = @import("std").mem.zeroes(gint),
    events: gushort = @import("std").mem.zeroes(gushort),
    revents: gushort = @import("std").mem.zeroes(gushort),
};
pub const GPollFD = struct__GPollFD;
pub const GPollFunc = ?*const fn ([*c]GPollFD, guint, gint) callconv(.c) gint;
pub extern fn g_poll(fds: [*c]GPollFD, nfds: guint, timeout: gint) gint;
pub const GSList = struct__GSList;
pub const struct__GSList = extern struct {
    data: gpointer = @import("std").mem.zeroes(gpointer),
    next: [*c]GSList = @import("std").mem.zeroes([*c]GSList),
};
pub extern fn g_slist_alloc() [*c]GSList;
pub extern fn g_slist_free(list: [*c]GSList) void;
pub extern fn g_slist_free_1(list: [*c]GSList) void;
pub extern fn g_slist_free_full(list: [*c]GSList, free_func: GDestroyNotify) void;
pub extern fn g_slist_append(list: [*c]GSList, data: gpointer) [*c]GSList;
pub extern fn g_slist_prepend(list: [*c]GSList, data: gpointer) [*c]GSList;
pub extern fn g_slist_insert(list: [*c]GSList, data: gpointer, position: gint) [*c]GSList;
pub extern fn g_slist_insert_sorted(list: [*c]GSList, data: gpointer, func: GCompareFunc) [*c]GSList;
pub extern fn g_slist_insert_sorted_with_data(list: [*c]GSList, data: gpointer, func: GCompareDataFunc, user_data: gpointer) [*c]GSList;
pub extern fn g_slist_insert_before(slist: [*c]GSList, sibling: [*c]GSList, data: gpointer) [*c]GSList;
pub extern fn g_slist_concat(list1: [*c]GSList, list2: [*c]GSList) [*c]GSList;
pub extern fn g_slist_remove(list: [*c]GSList, data: gconstpointer) [*c]GSList;
pub extern fn g_slist_remove_all(list: [*c]GSList, data: gconstpointer) [*c]GSList;
pub extern fn g_slist_remove_link(list: [*c]GSList, link_: [*c]GSList) [*c]GSList;
pub extern fn g_slist_delete_link(list: [*c]GSList, link_: [*c]GSList) [*c]GSList;
pub extern fn g_slist_reverse(list: [*c]GSList) [*c]GSList;
pub extern fn g_slist_copy(list: [*c]GSList) [*c]GSList;
pub extern fn g_slist_copy_deep(list: [*c]GSList, func: GCopyFunc, user_data: gpointer) [*c]GSList;
pub extern fn g_slist_nth(list: [*c]GSList, n: guint) [*c]GSList;
pub extern fn g_slist_find(list: [*c]GSList, data: gconstpointer) [*c]GSList;
pub extern fn g_slist_find_custom(list: [*c]GSList, data: gconstpointer, func: GCompareFunc) [*c]GSList;
pub extern fn g_slist_position(list: [*c]GSList, llink: [*c]GSList) gint;
pub extern fn g_slist_index(list: [*c]GSList, data: gconstpointer) gint;
pub extern fn g_slist_last(list: [*c]GSList) [*c]GSList;
pub extern fn g_slist_length(list: [*c]GSList) guint;
pub extern fn g_slist_foreach(list: [*c]GSList, func: GFunc, user_data: gpointer) void;
pub extern fn g_slist_sort(list: [*c]GSList, compare_func: GCompareFunc) [*c]GSList;
pub extern fn g_slist_sort_with_data(list: [*c]GSList, compare_func: GCompareDataFunc, user_data: gpointer) [*c]GSList;
pub extern fn g_slist_nth_data(list: [*c]GSList, n: guint) gpointer;
pub extern fn g_clear_slist(slist_ptr: [*c][*c]GSList, destroy: GDestroyNotify) void;
pub const G_IO_IN: c_int = 1;
pub const G_IO_OUT: c_int = 4;
pub const G_IO_PRI: c_int = 2;
pub const G_IO_ERR: c_int = 8;
pub const G_IO_HUP: c_int = 16;
pub const G_IO_NVAL: c_int = 32;
pub const GIOCondition = c_uint;
pub const G_MAIN_CONTEXT_FLAGS_NONE: c_int = 0;
pub const G_MAIN_CONTEXT_FLAGS_OWNERLESS_POLLING: c_int = 1;
pub const GMainContextFlags = c_uint;
pub const struct__GMainContext = opaque {};
pub const GMainContext = struct__GMainContext;
pub const struct__GMainLoop = opaque {};
pub const GMainLoop = struct__GMainLoop;
pub const GSource = struct__GSource;
pub const GSourceFunc = ?*const fn (gpointer) callconv(.c) gboolean;
pub const struct__GSourceCallbackFuncs = extern struct {
    ref: ?*const fn (gpointer) callconv(.c) void = @import("std").mem.zeroes(?*const fn (gpointer) callconv(.c) void),
    unref: ?*const fn (gpointer) callconv(.c) void = @import("std").mem.zeroes(?*const fn (gpointer) callconv(.c) void),
    get: ?*const fn (gpointer, [*c]GSource, [*c]GSourceFunc, [*c]gpointer) callconv(.c) void = @import("std").mem.zeroes(?*const fn (gpointer, [*c]GSource, [*c]GSourceFunc, [*c]gpointer) callconv(.c) void),
};
pub const GSourceCallbackFuncs = struct__GSourceCallbackFuncs;
pub const GSourceFuncsPrepareFunc = ?*const fn ([*c]GSource, [*c]gint) callconv(.c) gboolean;
pub const GSourceFuncsCheckFunc = ?*const fn ([*c]GSource) callconv(.c) gboolean;
pub const GSourceFuncsDispatchFunc = ?*const fn ([*c]GSource, GSourceFunc, gpointer) callconv(.c) gboolean;
pub const GSourceFuncsFinalizeFunc = ?*const fn ([*c]GSource) callconv(.c) void;
pub const GSourceDummyMarshal = ?*const fn () callconv(.c) void;
pub const struct__GSourceFuncs = extern struct {
    prepare: GSourceFuncsPrepareFunc = @import("std").mem.zeroes(GSourceFuncsPrepareFunc),
    check: GSourceFuncsCheckFunc = @import("std").mem.zeroes(GSourceFuncsCheckFunc),
    dispatch: GSourceFuncsDispatchFunc = @import("std").mem.zeroes(GSourceFuncsDispatchFunc),
    finalize: GSourceFuncsFinalizeFunc = @import("std").mem.zeroes(GSourceFuncsFinalizeFunc),
    closure_callback: GSourceFunc = @import("std").mem.zeroes(GSourceFunc),
    closure_marshal: GSourceDummyMarshal = @import("std").mem.zeroes(GSourceDummyMarshal),
};
pub const GSourceFuncs = struct__GSourceFuncs;
pub const struct__GSourcePrivate = opaque {};
pub const GSourcePrivate = struct__GSourcePrivate;
pub const struct__GSource = extern struct {
    callback_data: gpointer = @import("std").mem.zeroes(gpointer),
    callback_funcs: [*c]GSourceCallbackFuncs = @import("std").mem.zeroes([*c]GSourceCallbackFuncs),
    source_funcs: [*c]const GSourceFuncs = @import("std").mem.zeroes([*c]const GSourceFuncs),
    ref_count: guint = @import("std").mem.zeroes(guint),
    context: ?*GMainContext = @import("std").mem.zeroes(?*GMainContext),
    priority: gint = @import("std").mem.zeroes(gint),
    flags: guint = @import("std").mem.zeroes(guint),
    source_id: guint = @import("std").mem.zeroes(guint),
    poll_fds: [*c]GSList = @import("std").mem.zeroes([*c]GSList),
    prev: [*c]GSource = @import("std").mem.zeroes([*c]GSource),
    next: [*c]GSource = @import("std").mem.zeroes([*c]GSource),
    name: [*c]u8 = @import("std").mem.zeroes([*c]u8),
    priv: ?*GSourcePrivate = @import("std").mem.zeroes(?*GSourcePrivate),
};
pub const GSourceOnceFunc = ?*const fn (gpointer) callconv(.c) void;
pub const GChildWatchFunc = ?*const fn (GPid, gint, gpointer) callconv(.c) void;
pub const GSourceDisposeFunc = ?*const fn ([*c]GSource) callconv(.c) void;
pub extern fn g_main_context_new() ?*GMainContext;
pub extern fn g_main_context_new_with_flags(flags: GMainContextFlags) ?*GMainContext;
pub extern fn g_main_context_ref(context: ?*GMainContext) ?*GMainContext;
pub extern fn g_main_context_unref(context: ?*GMainContext) void;
pub extern fn g_main_context_default() ?*GMainContext;
pub extern fn g_main_context_iteration(context: ?*GMainContext, may_block: gboolean) gboolean;
pub extern fn g_main_context_pending(context: ?*GMainContext) gboolean;
pub extern fn g_main_context_find_source_by_id(context: ?*GMainContext, source_id: guint) [*c]GSource;
pub extern fn g_main_context_find_source_by_user_data(context: ?*GMainContext, user_data: gpointer) [*c]GSource;
pub extern fn g_main_context_find_source_by_funcs_user_data(context: ?*GMainContext, funcs: [*c]GSourceFuncs, user_data: gpointer) [*c]GSource;
pub extern fn g_main_context_wakeup(context: ?*GMainContext) void;
pub extern fn g_main_context_acquire(context: ?*GMainContext) gboolean;
pub extern fn g_main_context_release(context: ?*GMainContext) void;
pub extern fn g_main_context_is_owner(context: ?*GMainContext) gboolean;
pub extern fn g_main_context_wait(context: ?*GMainContext, cond: [*c]GCond, mutex: [*c]GMutex) gboolean;
pub extern fn g_main_context_prepare(context: ?*GMainContext, priority: [*c]gint) gboolean;
pub extern fn g_main_context_query(context: ?*GMainContext, max_priority: gint, timeout_: [*c]gint, fds: [*c]GPollFD, n_fds: gint) gint;
pub extern fn g_main_context_check(context: ?*GMainContext, max_priority: gint, fds: [*c]GPollFD, n_fds: gint) gboolean;
pub extern fn g_main_context_dispatch(context: ?*GMainContext) void;
pub extern fn g_main_context_set_poll_func(context: ?*GMainContext, func: GPollFunc) void;
pub extern fn g_main_context_get_poll_func(context: ?*GMainContext) GPollFunc;
pub extern fn g_main_context_add_poll(context: ?*GMainContext, fd: [*c]GPollFD, priority: gint) void;
pub extern fn g_main_context_remove_poll(context: ?*GMainContext, fd: [*c]GPollFD) void;
pub extern fn g_main_depth() gint;
pub extern fn g_main_current_source() [*c]GSource;
pub extern fn g_main_context_push_thread_default(context: ?*GMainContext) void;
pub extern fn g_main_context_pop_thread_default(context: ?*GMainContext) void;
pub extern fn g_main_context_get_thread_default() ?*GMainContext;
pub extern fn g_main_context_ref_thread_default() ?*GMainContext;
pub const GMainContextPusher = anyopaque;
pub fn g_main_context_pusher_new(arg_main_context: ?*GMainContext) callconv(.c) ?*GMainContextPusher {
    var main_context = arg_main_context;
    _ = &main_context;
    g_main_context_push_thread_default(main_context);
    return @as(?*GMainContextPusher, @ptrCast(main_context));
}
pub fn g_main_context_pusher_free(arg_pusher: ?*GMainContextPusher) callconv(.c) void {
    var pusher = arg_pusher;
    _ = &pusher;
    g_main_context_pop_thread_default(@as(?*GMainContext, @ptrCast(pusher)));
}
pub extern fn g_main_loop_new(context: ?*GMainContext, is_running: gboolean) ?*GMainLoop;
pub extern fn g_main_loop_run(loop: ?*GMainLoop) void;
pub extern fn g_main_loop_quit(loop: ?*GMainLoop) void;
pub extern fn g_main_loop_ref(loop: ?*GMainLoop) ?*GMainLoop;
pub extern fn g_main_loop_unref(loop: ?*GMainLoop) void;
pub extern fn g_main_loop_is_running(loop: ?*GMainLoop) gboolean;
pub extern fn g_main_loop_get_context(loop: ?*GMainLoop) ?*GMainContext;
pub extern fn g_source_new(source_funcs: [*c]GSourceFuncs, struct_size: guint) [*c]GSource;
pub extern fn g_source_set_dispose_function(source: [*c]GSource, dispose: GSourceDisposeFunc) void;
pub extern fn g_source_ref(source: [*c]GSource) [*c]GSource;
pub extern fn g_source_unref(source: [*c]GSource) void;
pub extern fn g_source_attach(source: [*c]GSource, context: ?*GMainContext) guint;
pub extern fn g_source_destroy(source: [*c]GSource) void;
pub extern fn g_source_set_priority(source: [*c]GSource, priority: gint) void;
pub extern fn g_source_get_priority(source: [*c]GSource) gint;
pub extern fn g_source_set_can_recurse(source: [*c]GSource, can_recurse: gboolean) void;
pub extern fn g_source_get_can_recurse(source: [*c]GSource) gboolean;
pub extern fn g_source_get_id(source: [*c]GSource) guint;
pub extern fn g_source_get_context(source: [*c]GSource) ?*GMainContext;
pub extern fn g_source_dup_context(source: [*c]GSource) ?*GMainContext;
pub extern fn g_source_set_callback(source: [*c]GSource, func: GSourceFunc, data: gpointer, notify: GDestroyNotify) void;
pub extern fn g_source_set_funcs(source: [*c]GSource, funcs: [*c]GSourceFuncs) void;
pub extern fn g_source_is_destroyed(source: [*c]GSource) gboolean;
pub extern fn g_source_set_name(source: [*c]GSource, name: [*c]const u8) void;
pub extern fn g_source_set_static_name(source: [*c]GSource, name: [*c]const u8) void;
pub extern fn g_source_get_name(source: [*c]GSource) [*c]const u8;
pub extern fn g_source_set_name_by_id(tag: guint, name: [*c]const u8) void;
pub extern fn g_source_set_ready_time(source: [*c]GSource, ready_time: gint64) void;
pub extern fn g_source_get_ready_time(source: [*c]GSource) gint64;
pub extern fn g_source_add_unix_fd(source: [*c]GSource, fd: gint, events: GIOCondition) gpointer;
pub extern fn g_source_modify_unix_fd(source: [*c]GSource, tag: gpointer, new_events: GIOCondition) void;
pub extern fn g_source_remove_unix_fd(source: [*c]GSource, tag: gpointer) void;
pub extern fn g_source_query_unix_fd(source: [*c]GSource, tag: gpointer) GIOCondition;
pub extern fn g_source_set_callback_indirect(source: [*c]GSource, callback_data: gpointer, callback_funcs: [*c]GSourceCallbackFuncs) void;
pub extern fn g_source_add_poll(source: [*c]GSource, fd: [*c]GPollFD) void;
pub extern fn g_source_remove_poll(source: [*c]GSource, fd: [*c]GPollFD) void;
pub extern fn g_source_add_child_source(source: [*c]GSource, child_source: [*c]GSource) void;
pub extern fn g_source_remove_child_source(source: [*c]GSource, child_source: [*c]GSource) void;
pub extern fn g_source_get_current_time(source: [*c]GSource, timeval: [*c]GTimeVal) void;
pub extern fn g_source_get_time(source: [*c]GSource) gint64;
pub extern fn g_idle_source_new() [*c]GSource;
pub extern fn g_child_watch_source_new(pid: GPid) [*c]GSource;
pub extern fn g_timeout_source_new(interval: guint) [*c]GSource;
pub extern fn g_timeout_source_new_seconds(interval: guint) [*c]GSource;
pub extern fn g_get_current_time(result: [*c]GTimeVal) void;
pub extern fn g_get_monotonic_time() gint64;
pub extern fn g_get_real_time() gint64;
pub extern fn g_source_remove(tag: guint) gboolean;
pub extern fn g_source_remove_by_user_data(user_data: gpointer) gboolean;
pub extern fn g_source_remove_by_funcs_user_data(funcs: [*c]GSourceFuncs, user_data: gpointer) gboolean;
pub const GClearHandleFunc = ?*const fn (guint) callconv(.c) void;
pub extern fn g_clear_handle_id(tag_ptr: [*c]guint, clear_func: GClearHandleFunc) void;
pub fn g_steal_handle_id(arg_handle_pointer: [*c]c_uint) callconv(.c) c_uint {
    var handle_pointer = arg_handle_pointer;
    _ = &handle_pointer;
    var handle: c_uint = undefined;
    _ = &handle;
    handle = handle_pointer.*;
    handle_pointer.* = 0;
    return handle;
}
pub extern fn g_timeout_add_full(priority: gint, interval: guint, function: GSourceFunc, data: gpointer, notify: GDestroyNotify) guint;
pub extern fn g_timeout_add(interval: guint, function: GSourceFunc, data: gpointer) guint;
pub extern fn g_timeout_add_once(interval: guint, function: GSourceOnceFunc, data: gpointer) guint;
pub extern fn g_timeout_add_seconds_full(priority: gint, interval: guint, function: GSourceFunc, data: gpointer, notify: GDestroyNotify) guint;
pub extern fn g_timeout_add_seconds(interval: guint, function: GSourceFunc, data: gpointer) guint;
pub extern fn g_timeout_add_seconds_once(interval: guint, function: GSourceOnceFunc, data: gpointer) guint;
pub extern fn g_child_watch_add_full(priority: gint, pid: GPid, function: GChildWatchFunc, data: gpointer, notify: GDestroyNotify) guint;
pub extern fn g_child_watch_add(pid: GPid, function: GChildWatchFunc, data: gpointer) guint;
pub extern fn g_idle_add(function: GSourceFunc, data: gpointer) guint;
pub extern fn g_idle_add_full(priority: gint, function: GSourceFunc, data: gpointer, notify: GDestroyNotify) guint;
pub extern fn g_idle_add_once(function: GSourceOnceFunc, data: gpointer) guint;
pub extern fn g_idle_remove_by_data(data: gpointer) gboolean;
pub extern fn g_main_context_invoke_full(context: ?*GMainContext, priority: gint, function: GSourceFunc, data: gpointer, notify: GDestroyNotify) void;
pub extern fn g_main_context_invoke(context: ?*GMainContext, function: GSourceFunc, data: gpointer) void;
pub fn g_steal_fd(arg_fd_ptr: [*c]c_int) callconv(.c) c_int {
    var fd_ptr = arg_fd_ptr;
    _ = &fd_ptr;
    var fd: c_int = fd_ptr.*;
    _ = &fd;
    fd_ptr.* = -@as(c_int, 1);
    return fd;
}
pub extern var g_timeout_funcs: GSourceFuncs;
pub extern var g_child_watch_funcs: GSourceFuncs;
pub extern var g_idle_funcs: GSourceFuncs;
pub extern var g_unix_signal_funcs: GSourceFuncs;
pub extern var g_unix_fd_source_funcs: GSourceFuncs;
pub const gunichar = guint32;
pub const gunichar2 = guint16;
pub const G_UNICODE_CONTROL: c_int = 0;
pub const G_UNICODE_FORMAT: c_int = 1;
pub const G_UNICODE_UNASSIGNED: c_int = 2;
pub const G_UNICODE_PRIVATE_USE: c_int = 3;
pub const G_UNICODE_SURROGATE: c_int = 4;
pub const G_UNICODE_LOWERCASE_LETTER: c_int = 5;
pub const G_UNICODE_MODIFIER_LETTER: c_int = 6;
pub const G_UNICODE_OTHER_LETTER: c_int = 7;
pub const G_UNICODE_TITLECASE_LETTER: c_int = 8;
pub const G_UNICODE_UPPERCASE_LETTER: c_int = 9;
pub const G_UNICODE_SPACING_MARK: c_int = 10;
pub const G_UNICODE_ENCLOSING_MARK: c_int = 11;
pub const G_UNICODE_NON_SPACING_MARK: c_int = 12;
pub const G_UNICODE_DECIMAL_NUMBER: c_int = 13;
pub const G_UNICODE_LETTER_NUMBER: c_int = 14;
pub const G_UNICODE_OTHER_NUMBER: c_int = 15;
pub const G_UNICODE_CONNECT_PUNCTUATION: c_int = 16;
pub const G_UNICODE_DASH_PUNCTUATION: c_int = 17;
pub const G_UNICODE_CLOSE_PUNCTUATION: c_int = 18;
pub const G_UNICODE_FINAL_PUNCTUATION: c_int = 19;
pub const G_UNICODE_INITIAL_PUNCTUATION: c_int = 20;
pub const G_UNICODE_OTHER_PUNCTUATION: c_int = 21;
pub const G_UNICODE_OPEN_PUNCTUATION: c_int = 22;
pub const G_UNICODE_CURRENCY_SYMBOL: c_int = 23;
pub const G_UNICODE_MODIFIER_SYMBOL: c_int = 24;
pub const G_UNICODE_MATH_SYMBOL: c_int = 25;
pub const G_UNICODE_OTHER_SYMBOL: c_int = 26;
pub const G_UNICODE_LINE_SEPARATOR: c_int = 27;
pub const G_UNICODE_PARAGRAPH_SEPARATOR: c_int = 28;
pub const G_UNICODE_SPACE_SEPARATOR: c_int = 29;
pub const GUnicodeType = c_uint;
pub const G_UNICODE_BREAK_MANDATORY: c_int = 0;
pub const G_UNICODE_BREAK_CARRIAGE_RETURN: c_int = 1;
pub const G_UNICODE_BREAK_LINE_FEED: c_int = 2;
pub const G_UNICODE_BREAK_COMBINING_MARK: c_int = 3;
pub const G_UNICODE_BREAK_SURROGATE: c_int = 4;
pub const G_UNICODE_BREAK_ZERO_WIDTH_SPACE: c_int = 5;
pub const G_UNICODE_BREAK_INSEPARABLE: c_int = 6;
pub const G_UNICODE_BREAK_NON_BREAKING_GLUE: c_int = 7;
pub const G_UNICODE_BREAK_CONTINGENT: c_int = 8;
pub const G_UNICODE_BREAK_SPACE: c_int = 9;
pub const G_UNICODE_BREAK_AFTER: c_int = 10;
pub const G_UNICODE_BREAK_BEFORE: c_int = 11;
pub const G_UNICODE_BREAK_BEFORE_AND_AFTER: c_int = 12;
pub const G_UNICODE_BREAK_HYPHEN: c_int = 13;
pub const G_UNICODE_BREAK_NON_STARTER: c_int = 14;
pub const G_UNICODE_BREAK_OPEN_PUNCTUATION: c_int = 15;
pub const G_UNICODE_BREAK_CLOSE_PUNCTUATION: c_int = 16;
pub const G_UNICODE_BREAK_QUOTATION: c_int = 17;
pub const G_UNICODE_BREAK_EXCLAMATION: c_int = 18;
pub const G_UNICODE_BREAK_IDEOGRAPHIC: c_int = 19;
pub const G_UNICODE_BREAK_NUMERIC: c_int = 20;
pub const G_UNICODE_BREAK_INFIX_SEPARATOR: c_int = 21;
pub const G_UNICODE_BREAK_SYMBOL: c_int = 22;
pub const G_UNICODE_BREAK_ALPHABETIC: c_int = 23;
pub const G_UNICODE_BREAK_PREFIX: c_int = 24;
pub const G_UNICODE_BREAK_POSTFIX: c_int = 25;
pub const G_UNICODE_BREAK_COMPLEX_CONTEXT: c_int = 26;
pub const G_UNICODE_BREAK_AMBIGUOUS: c_int = 27;
pub const G_UNICODE_BREAK_UNKNOWN: c_int = 28;
pub const G_UNICODE_BREAK_NEXT_LINE: c_int = 29;
pub const G_UNICODE_BREAK_WORD_JOINER: c_int = 30;
pub const G_UNICODE_BREAK_HANGUL_L_JAMO: c_int = 31;
pub const G_UNICODE_BREAK_HANGUL_V_JAMO: c_int = 32;
pub const G_UNICODE_BREAK_HANGUL_T_JAMO: c_int = 33;
pub const G_UNICODE_BREAK_HANGUL_LV_SYLLABLE: c_int = 34;
pub const G_UNICODE_BREAK_HANGUL_LVT_SYLLABLE: c_int = 35;
pub const G_UNICODE_BREAK_CLOSE_PARANTHESIS: c_int = 36;
pub const G_UNICODE_BREAK_CLOSE_PARENTHESIS: c_int = 36;
pub const G_UNICODE_BREAK_CONDITIONAL_JAPANESE_STARTER: c_int = 37;
pub const G_UNICODE_BREAK_HEBREW_LETTER: c_int = 38;
pub const G_UNICODE_BREAK_REGIONAL_INDICATOR: c_int = 39;
pub const G_UNICODE_BREAK_EMOJI_BASE: c_int = 40;
pub const G_UNICODE_BREAK_EMOJI_MODIFIER: c_int = 41;
pub const G_UNICODE_BREAK_ZERO_WIDTH_JOINER: c_int = 42;
pub const G_UNICODE_BREAK_AKSARA: c_int = 43;
pub const G_UNICODE_BREAK_AKSARA_PRE_BASE: c_int = 44;
pub const G_UNICODE_BREAK_AKSARA_START: c_int = 45;
pub const G_UNICODE_BREAK_VIRAMA_FINAL: c_int = 46;
pub const G_UNICODE_BREAK_VIRAMA: c_int = 47;
pub const GUnicodeBreakType = c_uint;
pub const G_UNICODE_SCRIPT_INVALID_CODE: c_int = -1;
pub const G_UNICODE_SCRIPT_COMMON: c_int = 0;
pub const G_UNICODE_SCRIPT_INHERITED: c_int = 1;
pub const G_UNICODE_SCRIPT_ARABIC: c_int = 2;
pub const G_UNICODE_SCRIPT_ARMENIAN: c_int = 3;
pub const G_UNICODE_SCRIPT_BENGALI: c_int = 4;
pub const G_UNICODE_SCRIPT_BOPOMOFO: c_int = 5;
pub const G_UNICODE_SCRIPT_CHEROKEE: c_int = 6;
pub const G_UNICODE_SCRIPT_COPTIC: c_int = 7;
pub const G_UNICODE_SCRIPT_CYRILLIC: c_int = 8;
pub const G_UNICODE_SCRIPT_DESERET: c_int = 9;
pub const G_UNICODE_SCRIPT_DEVANAGARI: c_int = 10;
pub const G_UNICODE_SCRIPT_ETHIOPIC: c_int = 11;
pub const G_UNICODE_SCRIPT_GEORGIAN: c_int = 12;
pub const G_UNICODE_SCRIPT_GOTHIC: c_int = 13;
pub const G_UNICODE_SCRIPT_GREEK: c_int = 14;
pub const G_UNICODE_SCRIPT_GUJARATI: c_int = 15;
pub const G_UNICODE_SCRIPT_GURMUKHI: c_int = 16;
pub const G_UNICODE_SCRIPT_HAN: c_int = 17;
pub const G_UNICODE_SCRIPT_HANGUL: c_int = 18;
pub const G_UNICODE_SCRIPT_HEBREW: c_int = 19;
pub const G_UNICODE_SCRIPT_HIRAGANA: c_int = 20;
pub const G_UNICODE_SCRIPT_KANNADA: c_int = 21;
pub const G_UNICODE_SCRIPT_KATAKANA: c_int = 22;
pub const G_UNICODE_SCRIPT_KHMER: c_int = 23;
pub const G_UNICODE_SCRIPT_LAO: c_int = 24;
pub const G_UNICODE_SCRIPT_LATIN: c_int = 25;
pub const G_UNICODE_SCRIPT_MALAYALAM: c_int = 26;
pub const G_UNICODE_SCRIPT_MONGOLIAN: c_int = 27;
pub const G_UNICODE_SCRIPT_MYANMAR: c_int = 28;
pub const G_UNICODE_SCRIPT_OGHAM: c_int = 29;
pub const G_UNICODE_SCRIPT_OLD_ITALIC: c_int = 30;
pub const G_UNICODE_SCRIPT_ORIYA: c_int = 31;
pub const G_UNICODE_SCRIPT_RUNIC: c_int = 32;
pub const G_UNICODE_SCRIPT_SINHALA: c_int = 33;
pub const G_UNICODE_SCRIPT_SYRIAC: c_int = 34;
pub const G_UNICODE_SCRIPT_TAMIL: c_int = 35;
pub const G_UNICODE_SCRIPT_TELUGU: c_int = 36;
pub const G_UNICODE_SCRIPT_THAANA: c_int = 37;
pub const G_UNICODE_SCRIPT_THAI: c_int = 38;
pub const G_UNICODE_SCRIPT_TIBETAN: c_int = 39;
pub const G_UNICODE_SCRIPT_CANADIAN_ABORIGINAL: c_int = 40;
pub const G_UNICODE_SCRIPT_YI: c_int = 41;
pub const G_UNICODE_SCRIPT_TAGALOG: c_int = 42;
pub const G_UNICODE_SCRIPT_HANUNOO: c_int = 43;
pub const G_UNICODE_SCRIPT_BUHID: c_int = 44;
pub const G_UNICODE_SCRIPT_TAGBANWA: c_int = 45;
pub const G_UNICODE_SCRIPT_BRAILLE: c_int = 46;
pub const G_UNICODE_SCRIPT_CYPRIOT: c_int = 47;
pub const G_UNICODE_SCRIPT_LIMBU: c_int = 48;
pub const G_UNICODE_SCRIPT_OSMANYA: c_int = 49;
pub const G_UNICODE_SCRIPT_SHAVIAN: c_int = 50;
pub const G_UNICODE_SCRIPT_LINEAR_B: c_int = 51;
pub const G_UNICODE_SCRIPT_TAI_LE: c_int = 52;
pub const G_UNICODE_SCRIPT_UGARITIC: c_int = 53;
pub const G_UNICODE_SCRIPT_NEW_TAI_LUE: c_int = 54;
pub const G_UNICODE_SCRIPT_BUGINESE: c_int = 55;
pub const G_UNICODE_SCRIPT_GLAGOLITIC: c_int = 56;
pub const G_UNICODE_SCRIPT_TIFINAGH: c_int = 57;
pub const G_UNICODE_SCRIPT_SYLOTI_NAGRI: c_int = 58;
pub const G_UNICODE_SCRIPT_OLD_PERSIAN: c_int = 59;
pub const G_UNICODE_SCRIPT_KHAROSHTHI: c_int = 60;
pub const G_UNICODE_SCRIPT_UNKNOWN: c_int = 61;
pub const G_UNICODE_SCRIPT_BALINESE: c_int = 62;
pub const G_UNICODE_SCRIPT_CUNEIFORM: c_int = 63;
pub const G_UNICODE_SCRIPT_PHOENICIAN: c_int = 64;
pub const G_UNICODE_SCRIPT_PHAGS_PA: c_int = 65;
pub const G_UNICODE_SCRIPT_NKO: c_int = 66;
pub const G_UNICODE_SCRIPT_KAYAH_LI: c_int = 67;
pub const G_UNICODE_SCRIPT_LEPCHA: c_int = 68;
pub const G_UNICODE_SCRIPT_REJANG: c_int = 69;
pub const G_UNICODE_SCRIPT_SUNDANESE: c_int = 70;
pub const G_UNICODE_SCRIPT_SAURASHTRA: c_int = 71;
pub const G_UNICODE_SCRIPT_CHAM: c_int = 72;
pub const G_UNICODE_SCRIPT_OL_CHIKI: c_int = 73;
pub const G_UNICODE_SCRIPT_VAI: c_int = 74;
pub const G_UNICODE_SCRIPT_CARIAN: c_int = 75;
pub const G_UNICODE_SCRIPT_LYCIAN: c_int = 76;
pub const G_UNICODE_SCRIPT_LYDIAN: c_int = 77;
pub const G_UNICODE_SCRIPT_AVESTAN: c_int = 78;
pub const G_UNICODE_SCRIPT_BAMUM: c_int = 79;
pub const G_UNICODE_SCRIPT_EGYPTIAN_HIEROGLYPHS: c_int = 80;
pub const G_UNICODE_SCRIPT_IMPERIAL_ARAMAIC: c_int = 81;
pub const G_UNICODE_SCRIPT_INSCRIPTIONAL_PAHLAVI: c_int = 82;
pub const G_UNICODE_SCRIPT_INSCRIPTIONAL_PARTHIAN: c_int = 83;
pub const G_UNICODE_SCRIPT_JAVANESE: c_int = 84;
pub const G_UNICODE_SCRIPT_KAITHI: c_int = 85;
pub const G_UNICODE_SCRIPT_LISU: c_int = 86;
pub const G_UNICODE_SCRIPT_MEETEI_MAYEK: c_int = 87;
pub const G_UNICODE_SCRIPT_OLD_SOUTH_ARABIAN: c_int = 88;
pub const G_UNICODE_SCRIPT_OLD_TURKIC: c_int = 89;
pub const G_UNICODE_SCRIPT_SAMARITAN: c_int = 90;
pub const G_UNICODE_SCRIPT_TAI_THAM: c_int = 91;
pub const G_UNICODE_SCRIPT_TAI_VIET: c_int = 92;
pub const G_UNICODE_SCRIPT_BATAK: c_int = 93;
pub const G_UNICODE_SCRIPT_BRAHMI: c_int = 94;
pub const G_UNICODE_SCRIPT_MANDAIC: c_int = 95;
pub const G_UNICODE_SCRIPT_CHAKMA: c_int = 96;
pub const G_UNICODE_SCRIPT_MEROITIC_CURSIVE: c_int = 97;
pub const G_UNICODE_SCRIPT_MEROITIC_HIEROGLYPHS: c_int = 98;
pub const G_UNICODE_SCRIPT_MIAO: c_int = 99;
pub const G_UNICODE_SCRIPT_SHARADA: c_int = 100;
pub const G_UNICODE_SCRIPT_SORA_SOMPENG: c_int = 101;
pub const G_UNICODE_SCRIPT_TAKRI: c_int = 102;
pub const G_UNICODE_SCRIPT_BASSA_VAH: c_int = 103;
pub const G_UNICODE_SCRIPT_CAUCASIAN_ALBANIAN: c_int = 104;
pub const G_UNICODE_SCRIPT_DUPLOYAN: c_int = 105;
pub const G_UNICODE_SCRIPT_ELBASAN: c_int = 106;
pub const G_UNICODE_SCRIPT_GRANTHA: c_int = 107;
pub const G_UNICODE_SCRIPT_KHOJKI: c_int = 108;
pub const G_UNICODE_SCRIPT_KHUDAWADI: c_int = 109;
pub const G_UNICODE_SCRIPT_LINEAR_A: c_int = 110;
pub const G_UNICODE_SCRIPT_MAHAJANI: c_int = 111;
pub const G_UNICODE_SCRIPT_MANICHAEAN: c_int = 112;
pub const G_UNICODE_SCRIPT_MENDE_KIKAKUI: c_int = 113;
pub const G_UNICODE_SCRIPT_MODI: c_int = 114;
pub const G_UNICODE_SCRIPT_MRO: c_int = 115;
pub const G_UNICODE_SCRIPT_NABATAEAN: c_int = 116;
pub const G_UNICODE_SCRIPT_OLD_NORTH_ARABIAN: c_int = 117;
pub const G_UNICODE_SCRIPT_OLD_PERMIC: c_int = 118;
pub const G_UNICODE_SCRIPT_PAHAWH_HMONG: c_int = 119;
pub const G_UNICODE_SCRIPT_PALMYRENE: c_int = 120;
pub const G_UNICODE_SCRIPT_PAU_CIN_HAU: c_int = 121;
pub const G_UNICODE_SCRIPT_PSALTER_PAHLAVI: c_int = 122;
pub const G_UNICODE_SCRIPT_SIDDHAM: c_int = 123;
pub const G_UNICODE_SCRIPT_TIRHUTA: c_int = 124;
pub const G_UNICODE_SCRIPT_WARANG_CITI: c_int = 125;
pub const G_UNICODE_SCRIPT_AHOM: c_int = 126;
pub const G_UNICODE_SCRIPT_ANATOLIAN_HIEROGLYPHS: c_int = 127;
pub const G_UNICODE_SCRIPT_HATRAN: c_int = 128;
pub const G_UNICODE_SCRIPT_MULTANI: c_int = 129;
pub const G_UNICODE_SCRIPT_OLD_HUNGARIAN: c_int = 130;
pub const G_UNICODE_SCRIPT_SIGNWRITING: c_int = 131;
pub const G_UNICODE_SCRIPT_ADLAM: c_int = 132;
pub const G_UNICODE_SCRIPT_BHAIKSUKI: c_int = 133;
pub const G_UNICODE_SCRIPT_MARCHEN: c_int = 134;
pub const G_UNICODE_SCRIPT_NEWA: c_int = 135;
pub const G_UNICODE_SCRIPT_OSAGE: c_int = 136;
pub const G_UNICODE_SCRIPT_TANGUT: c_int = 137;
pub const G_UNICODE_SCRIPT_MASARAM_GONDI: c_int = 138;
pub const G_UNICODE_SCRIPT_NUSHU: c_int = 139;
pub const G_UNICODE_SCRIPT_SOYOMBO: c_int = 140;
pub const G_UNICODE_SCRIPT_ZANABAZAR_SQUARE: c_int = 141;
pub const G_UNICODE_SCRIPT_DOGRA: c_int = 142;
pub const G_UNICODE_SCRIPT_GUNJALA_GONDI: c_int = 143;
pub const G_UNICODE_SCRIPT_HANIFI_ROHINGYA: c_int = 144;
pub const G_UNICODE_SCRIPT_MAKASAR: c_int = 145;
pub const G_UNICODE_SCRIPT_MEDEFAIDRIN: c_int = 146;
pub const G_UNICODE_SCRIPT_OLD_SOGDIAN: c_int = 147;
pub const G_UNICODE_SCRIPT_SOGDIAN: c_int = 148;
pub const G_UNICODE_SCRIPT_ELYMAIC: c_int = 149;
pub const G_UNICODE_SCRIPT_NANDINAGARI: c_int = 150;
pub const G_UNICODE_SCRIPT_NYIAKENG_PUACHUE_HMONG: c_int = 151;
pub const G_UNICODE_SCRIPT_WANCHO: c_int = 152;
pub const G_UNICODE_SCRIPT_CHORASMIAN: c_int = 153;
pub const G_UNICODE_SCRIPT_DIVES_AKURU: c_int = 154;
pub const G_UNICODE_SCRIPT_KHITAN_SMALL_SCRIPT: c_int = 155;
pub const G_UNICODE_SCRIPT_YEZIDI: c_int = 156;
pub const G_UNICODE_SCRIPT_CYPRO_MINOAN: c_int = 157;
pub const G_UNICODE_SCRIPT_OLD_UYGHUR: c_int = 158;
pub const G_UNICODE_SCRIPT_TANGSA: c_int = 159;
pub const G_UNICODE_SCRIPT_TOTO: c_int = 160;
pub const G_UNICODE_SCRIPT_VITHKUQI: c_int = 161;
pub const G_UNICODE_SCRIPT_MATH: c_int = 162;
pub const G_UNICODE_SCRIPT_KAWI: c_int = 163;
pub const G_UNICODE_SCRIPT_NAG_MUNDARI: c_int = 164;
pub const G_UNICODE_SCRIPT_TODHRI: c_int = 165;
pub const G_UNICODE_SCRIPT_GARAY: c_int = 166;
pub const G_UNICODE_SCRIPT_TULU_TIGALARI: c_int = 167;
pub const G_UNICODE_SCRIPT_SUNUWAR: c_int = 168;
pub const G_UNICODE_SCRIPT_GURUNG_KHEMA: c_int = 169;
pub const G_UNICODE_SCRIPT_KIRAT_RAI: c_int = 170;
pub const G_UNICODE_SCRIPT_OL_ONAL: c_int = 171;
pub const GUnicodeScript = c_int;
pub extern fn g_unicode_script_to_iso15924(script: GUnicodeScript) guint32;
pub extern fn g_unicode_script_from_iso15924(iso15924: guint32) GUnicodeScript;
pub extern fn g_unichar_isalnum(c: gunichar) gboolean;
pub extern fn g_unichar_isalpha(c: gunichar) gboolean;
pub extern fn g_unichar_iscntrl(c: gunichar) gboolean;
pub extern fn g_unichar_isdigit(c: gunichar) gboolean;
pub extern fn g_unichar_isgraph(c: gunichar) gboolean;
pub extern fn g_unichar_islower(c: gunichar) gboolean;
pub extern fn g_unichar_isprint(c: gunichar) gboolean;
pub extern fn g_unichar_ispunct(c: gunichar) gboolean;
pub extern fn g_unichar_isspace(c: gunichar) gboolean;
pub extern fn g_unichar_isupper(c: gunichar) gboolean;
pub extern fn g_unichar_isxdigit(c: gunichar) gboolean;
pub extern fn g_unichar_istitle(c: gunichar) gboolean;
pub extern fn g_unichar_isdefined(c: gunichar) gboolean;
pub extern fn g_unichar_iswide(c: gunichar) gboolean;
pub extern fn g_unichar_iswide_cjk(c: gunichar) gboolean;
pub extern fn g_unichar_iszerowidth(c: gunichar) gboolean;
pub extern fn g_unichar_ismark(c: gunichar) gboolean;
pub extern fn g_unichar_toupper(c: gunichar) gunichar;
pub extern fn g_unichar_tolower(c: gunichar) gunichar;
pub extern fn g_unichar_totitle(c: gunichar) gunichar;
pub extern fn g_unichar_digit_value(c: gunichar) gint;
pub extern fn g_unichar_xdigit_value(c: gunichar) gint;
pub extern fn g_unichar_type(c: gunichar) GUnicodeType;
pub extern fn g_unichar_break_type(c: gunichar) GUnicodeBreakType;
pub extern fn g_unichar_combining_class(uc: gunichar) gint;
pub extern fn g_unichar_get_mirror_char(ch: gunichar, mirrored_ch: [*c]gunichar) gboolean;
pub extern fn g_unichar_get_script(ch: gunichar) GUnicodeScript;
pub extern fn g_unichar_validate(ch: gunichar) gboolean;
pub extern fn g_unichar_compose(a: gunichar, b: gunichar, ch: [*c]gunichar) gboolean;
pub extern fn g_unichar_decompose(ch: gunichar, a: [*c]gunichar, b: [*c]gunichar) gboolean;
pub extern fn g_unichar_fully_decompose(ch: gunichar, compat: gboolean, result: [*c]gunichar, result_len: gsize) gsize;
pub extern fn g_unicode_canonical_ordering(string: [*c]gunichar, len: gsize) void;
pub extern fn g_unicode_canonical_decomposition(ch: gunichar, result_len: [*c]gsize) [*c]gunichar;
pub extern const g_utf8_skip: [*c]const gchar;
pub extern fn g_utf8_get_char(p: [*c]const gchar) gunichar;
pub extern fn g_utf8_get_char_validated(p: [*c]const gchar, max_len: gssize) gunichar;
pub extern fn g_utf8_offset_to_pointer(str: [*c]const gchar, offset: glong) [*c]gchar;
pub extern fn g_utf8_pointer_to_offset(str: [*c]const gchar, pos: [*c]const gchar) glong;
pub extern fn g_utf8_prev_char(p: [*c]const gchar) [*c]gchar;
pub extern fn g_utf8_find_next_char(p: [*c]const gchar, end: [*c]const gchar) [*c]gchar;
pub extern fn g_utf8_find_prev_char(str: [*c]const gchar, p: [*c]const gchar) [*c]gchar;
pub extern fn g_utf8_strlen(p: [*c]const gchar, max: gssize) glong;
pub extern fn g_utf8_substring(str: [*c]const gchar, start_pos: glong, end_pos: glong) [*c]gchar;
pub extern fn g_utf8_strncpy(dest: [*c]gchar, src: [*c]const gchar, n: gsize) [*c]gchar;
pub extern fn g_utf8_truncate_middle(string: [*c]const gchar, truncate_length: gsize) [*c]gchar;
pub extern fn g_utf8_strchr(p: [*c]const gchar, len: gssize, c: gunichar) [*c]gchar;
pub extern fn g_utf8_strrchr(p: [*c]const gchar, len: gssize, c: gunichar) [*c]gchar;
pub extern fn g_utf8_strreverse(str: [*c]const gchar, len: gssize) [*c]gchar;
pub extern fn g_utf8_to_utf16(str: [*c]const gchar, len: glong, items_read: [*c]glong, items_written: [*c]glong, @"error": [*c][*c]GError) [*c]gunichar2;
pub extern fn g_utf8_to_ucs4(str: [*c]const gchar, len: glong, items_read: [*c]glong, items_written: [*c]glong, @"error": [*c][*c]GError) [*c]gunichar;
pub extern fn g_utf8_to_ucs4_fast(str: [*c]const gchar, len: glong, items_written: [*c]glong) [*c]gunichar;
pub extern fn g_utf16_to_ucs4(str: [*c]const gunichar2, len: glong, items_read: [*c]glong, items_written: [*c]glong, @"error": [*c][*c]GError) [*c]gunichar;
pub extern fn g_utf16_to_utf8(str: [*c]const gunichar2, len: glong, items_read: [*c]glong, items_written: [*c]glong, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_ucs4_to_utf16(str: [*c]const gunichar, len: glong, items_read: [*c]glong, items_written: [*c]glong, @"error": [*c][*c]GError) [*c]gunichar2;
pub extern fn g_ucs4_to_utf8(str: [*c]const gunichar, len: glong, items_read: [*c]glong, items_written: [*c]glong, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_unichar_to_utf8(c: gunichar, outbuf: [*c]gchar) gint;
pub extern fn g_utf8_validate(str: [*c]const gchar, max_len: gssize, end: [*c][*c]const gchar) gboolean;
pub extern fn g_utf8_validate_len(str: [*c]const gchar, max_len: gsize, end: [*c][*c]const gchar) gboolean;
pub extern fn g_utf8_strup(str: [*c]const gchar, len: gssize) [*c]gchar;
pub extern fn g_utf8_strdown(str: [*c]const gchar, len: gssize) [*c]gchar;
pub extern fn g_utf8_casefold(str: [*c]const gchar, len: gssize) [*c]gchar;
pub const G_NORMALIZE_DEFAULT: c_int = 0;
pub const G_NORMALIZE_NFD: c_int = 0;
pub const G_NORMALIZE_DEFAULT_COMPOSE: c_int = 1;
pub const G_NORMALIZE_NFC: c_int = 1;
pub const G_NORMALIZE_ALL: c_int = 2;
pub const G_NORMALIZE_NFKD: c_int = 2;
pub const G_NORMALIZE_ALL_COMPOSE: c_int = 3;
pub const G_NORMALIZE_NFKC: c_int = 3;
pub const GNormalizeMode = c_uint;
pub extern fn g_utf8_normalize(str: [*c]const gchar, len: gssize, mode: GNormalizeMode) [*c]gchar;
pub extern fn g_utf8_collate(str1: [*c]const gchar, str2: [*c]const gchar) gint;
pub extern fn g_utf8_collate_key(str: [*c]const gchar, len: gssize) [*c]gchar;
pub extern fn g_utf8_collate_key_for_filename(str: [*c]const gchar, len: gssize) [*c]gchar;
pub extern fn g_utf8_make_valid(str: [*c]const gchar, len: gssize) [*c]gchar;
pub const G_ASCII_ALNUM: c_int = 1;
pub const G_ASCII_ALPHA: c_int = 2;
pub const G_ASCII_CNTRL: c_int = 4;
pub const G_ASCII_DIGIT: c_int = 8;
pub const G_ASCII_GRAPH: c_int = 16;
pub const G_ASCII_LOWER: c_int = 32;
pub const G_ASCII_PRINT: c_int = 64;
pub const G_ASCII_PUNCT: c_int = 128;
pub const G_ASCII_SPACE: c_int = 256;
pub const G_ASCII_UPPER: c_int = 512;
pub const G_ASCII_XDIGIT: c_int = 1024;
pub const GAsciiType = c_uint;
pub extern const g_ascii_table: [*c]const guint16;
pub extern fn g_ascii_tolower(c: gchar) gchar;
pub extern fn g_ascii_toupper(c: gchar) gchar;
pub extern fn g_ascii_digit_value(c: gchar) gint;
pub extern fn g_ascii_xdigit_value(c: gchar) gint;
pub extern fn g_strdelimit(string: [*c]gchar, delimiters: [*c]const gchar, new_delimiter: gchar) [*c]gchar;
pub extern fn g_strcanon(string: [*c]gchar, valid_chars: [*c]const gchar, substitutor: gchar) [*c]gchar;
pub extern fn g_strerror(errnum: gint) [*c]const gchar;
pub extern fn g_strsignal(signum: gint) [*c]const gchar;
pub extern fn g_strreverse(string: [*c]gchar) [*c]gchar;
pub extern fn g_strlcpy(dest: [*c]gchar, src: [*c]const gchar, dest_size: gsize) gsize;
pub extern fn g_strlcat(dest: [*c]gchar, src: [*c]const gchar, dest_size: gsize) gsize;
pub extern fn g_strstr_len(haystack: [*c]const gchar, haystack_len: gssize, needle: [*c]const gchar) [*c]gchar;
pub extern fn g_strrstr(haystack: [*c]const gchar, needle: [*c]const gchar) [*c]gchar;
pub extern fn g_strrstr_len(haystack: [*c]const gchar, haystack_len: gssize, needle: [*c]const gchar) [*c]gchar;
pub extern fn g_str_has_suffix(str: [*c]const gchar, suffix: [*c]const gchar) gboolean;
pub extern fn g_str_has_prefix(str: [*c]const gchar, prefix: [*c]const gchar) gboolean;
pub extern fn g_strtod(nptr: [*c]const gchar, endptr: [*c][*c]gchar) gdouble;
pub extern fn g_ascii_strtod(nptr: [*c]const gchar, endptr: [*c][*c]gchar) gdouble;
pub extern fn g_ascii_strtoull(nptr: [*c]const gchar, endptr: [*c][*c]gchar, base: guint) guint64;
pub extern fn g_ascii_strtoll(nptr: [*c]const gchar, endptr: [*c][*c]gchar, base: guint) gint64;
pub extern fn g_ascii_dtostr(buffer: [*c]gchar, buf_len: gint, d: gdouble) [*c]gchar;
pub extern fn g_ascii_formatd(buffer: [*c]gchar, buf_len: gint, format: [*c]const gchar, d: gdouble) [*c]gchar;
pub extern fn g_strchug(string: [*c]gchar) [*c]gchar;
pub extern fn g_strchomp(string: [*c]gchar) [*c]gchar;
pub extern fn g_ascii_strcasecmp(s1: [*c]const gchar, s2: [*c]const gchar) gint;
pub extern fn g_ascii_strncasecmp(s1: [*c]const gchar, s2: [*c]const gchar, n: gsize) gint;
pub extern fn g_ascii_strdown(str: [*c]const gchar, len: gssize) [*c]gchar;
pub extern fn g_ascii_strup(str: [*c]const gchar, len: gssize) [*c]gchar;
pub extern fn g_str_is_ascii(str: [*c]const gchar) gboolean;
pub extern fn g_strcasecmp(s1: [*c]const gchar, s2: [*c]const gchar) gint;
pub extern fn g_strncasecmp(s1: [*c]const gchar, s2: [*c]const gchar, n: guint) gint;
pub extern fn g_strdown(string: [*c]gchar) [*c]gchar;
pub extern fn g_strup(string: [*c]gchar) [*c]gchar;
pub extern fn g_strdup(str: [*c]const gchar) [*c]gchar;
pub extern fn g_strdup_printf(format: [*c]const gchar, ...) [*c]gchar;
pub extern fn g_strdup_vprintf(format: [*c]const gchar, args: [*c]struct___va_list_tag_6) [*c]gchar;
pub extern fn g_strndup(str: [*c]const gchar, n: gsize) [*c]gchar;
pub extern fn g_strnfill(length: gsize, fill_char: gchar) [*c]gchar;
pub extern fn g_strconcat(string1: [*c]const gchar, ...) [*c]gchar;
pub extern fn g_strjoin(separator: [*c]const gchar, ...) [*c]gchar;
pub inline fn g_strdup_inline(arg_str: [*c]const u8) [*c]u8 {
    var str = arg_str;
    _ = &str;
    if ((__builtin_constant_p(!(str != null)) != 0) and !(str != null)) return null;
    if (((__builtin_constant_p(!!(str != null)) != 0) and !!(str != null)) and (__builtin_constant_p(strlen(str)) != 0)) {
        const len: usize = strlen(str) +% @as(c_ulong, @bitCast(@as(c_long, @as(c_int, 1))));
        _ = &len;
        var dup_str: [*c]u8 = @as([*c]u8, @ptrCast(@alignCast(g_malloc(len))));
        _ = &dup_str;
        return @as([*c]u8, @ptrCast(@alignCast(memcpy(@as(?*anyopaque, @ptrCast(dup_str)), @as(?*const anyopaque, @ptrCast(str)), len))));
    }
    return g_strdup(str);
}
pub extern fn g_strcompress(source: [*c]const gchar) [*c]gchar;
pub extern fn g_strescape(source: [*c]const gchar, exceptions: [*c]const gchar) [*c]gchar;
pub extern fn g_memdup(mem: gconstpointer, byte_size: guint) gpointer;
pub extern fn g_memdup2(mem: gconstpointer, byte_size: gsize) gpointer;
pub const GStrv = [*c][*c]gchar;
pub extern fn g_strsplit(string: [*c]const gchar, delimiter: [*c]const gchar, max_tokens: gint) [*c][*c]gchar;
pub extern fn g_strsplit_set(string: [*c]const gchar, delimiters: [*c]const gchar, max_tokens: gint) [*c][*c]gchar;
pub extern fn g_strjoinv(separator: [*c]const gchar, str_array: [*c][*c]gchar) [*c]gchar;
pub extern fn g_strfreev(str_array: [*c][*c]gchar) void;
pub extern fn g_strdupv(str_array: [*c][*c]gchar) [*c][*c]gchar;
pub extern fn g_strv_length(str_array: [*c][*c]gchar) guint;
pub extern fn g_stpcpy(dest: [*c]gchar, src: [*c]const u8) [*c]gchar;
pub extern fn g_str_to_ascii(str: [*c]const gchar, from_locale: [*c]const gchar) [*c]gchar;
pub extern fn g_str_tokenize_and_fold(string: [*c]const gchar, translit_locale: [*c]const gchar, ascii_alternates: [*c][*c][*c]gchar) [*c][*c]gchar;
pub extern fn g_str_match_string(search_term: [*c]const gchar, potential_hit: [*c]const gchar, accept_alternates: gboolean) gboolean;
pub extern fn g_strv_contains(strv: [*c]const [*c]const gchar, str: [*c]const gchar) gboolean;
pub extern fn g_strv_equal(strv1: [*c]const [*c]const gchar, strv2: [*c]const [*c]const gchar) gboolean;
pub const G_NUMBER_PARSER_ERROR_INVALID: c_int = 0;
pub const G_NUMBER_PARSER_ERROR_OUT_OF_BOUNDS: c_int = 1;
pub const GNumberParserError = c_uint;
pub extern fn g_number_parser_error_quark() GQuark;
pub extern fn g_ascii_string_to_signed(str: [*c]const gchar, base: guint, min: gint64, max: gint64, out_num: [*c]gint64, @"error": [*c][*c]GError) gboolean;
pub extern fn g_ascii_string_to_unsigned(str: [*c]const gchar, base: guint, min: guint64, max: guint64, out_num: [*c]guint64, @"error": [*c][*c]GError) gboolean;
pub fn g_set_str(arg_str_pointer: [*c][*c]u8, arg_new_str: [*c]const u8) callconv(.c) gboolean {
    var str_pointer = arg_str_pointer;
    _ = &str_pointer;
    var new_str = arg_new_str;
    _ = &new_str;
    var copy: [*c]u8 = undefined;
    _ = &copy;
    if ((str_pointer.* == @as([*c]u8, @ptrCast(@constCast(@volatileCast(new_str))))) or (((str_pointer.* != null) and (new_str != null)) and (strcmp(str_pointer.*, new_str) == @as(c_int, 0)))) return @as(c_int, 0);
    copy = g_strdup_inline(new_str);
    g_free(@as(gpointer, @ptrCast(str_pointer.*)));
    str_pointer.* = copy;
    return @intFromBool(!(@as(c_int, 0) != 0));
}
pub const struct__GString = extern struct {
    str: [*c]gchar = @import("std").mem.zeroes([*c]gchar),
    len: gsize = @import("std").mem.zeroes(gsize),
    allocated_len: gsize = @import("std").mem.zeroes(gsize),
};
pub const GString = struct__GString;
pub extern fn g_string_new(init: [*c]const gchar) [*c]GString;
pub extern fn g_string_new_take(init: [*c]gchar) [*c]GString;
pub extern fn g_string_new_len(init: [*c]const gchar, len: gssize) [*c]GString;
pub extern fn g_string_sized_new(dfl_size: gsize) [*c]GString;
pub extern fn g_string_copy(string: [*c]GString) [*c]GString;
pub extern fn g_string_free(string: [*c]GString, free_segment: gboolean) [*c]gchar;
pub extern fn g_string_free_and_steal(string: [*c]GString) [*c]gchar;
pub extern fn g_string_free_to_bytes(string: [*c]GString) ?*GBytes;
pub extern fn g_string_equal(v: [*c]const GString, v2: [*c]const GString) gboolean;
pub extern fn g_string_hash(str: [*c]const GString) guint;
pub extern fn g_string_assign(string: [*c]GString, rval: [*c]const gchar) [*c]GString;
pub extern fn g_string_truncate(string: [*c]GString, len: gsize) [*c]GString;
pub extern fn g_string_set_size(string: [*c]GString, len: gsize) [*c]GString;
pub extern fn g_string_insert_len(string: [*c]GString, pos: gssize, val: [*c]const gchar, len: gssize) [*c]GString;
pub extern fn g_string_append(string: [*c]GString, val: [*c]const gchar) [*c]GString;
pub extern fn g_string_append_len(string: [*c]GString, val: [*c]const gchar, len: gssize) [*c]GString;
pub extern fn g_string_append_c(string: [*c]GString, c: gchar) [*c]GString;
pub extern fn g_string_append_unichar(string: [*c]GString, wc: gunichar) [*c]GString;
pub extern fn g_string_prepend(string: [*c]GString, val: [*c]const gchar) [*c]GString;
pub extern fn g_string_prepend_c(string: [*c]GString, c: gchar) [*c]GString;
pub extern fn g_string_prepend_unichar(string: [*c]GString, wc: gunichar) [*c]GString;
pub extern fn g_string_prepend_len(string: [*c]GString, val: [*c]const gchar, len: gssize) [*c]GString;
pub extern fn g_string_insert(string: [*c]GString, pos: gssize, val: [*c]const gchar) [*c]GString;
pub extern fn g_string_insert_c(string: [*c]GString, pos: gssize, c: gchar) [*c]GString;
pub extern fn g_string_insert_unichar(string: [*c]GString, pos: gssize, wc: gunichar) [*c]GString;
pub extern fn g_string_overwrite(string: [*c]GString, pos: gsize, val: [*c]const gchar) [*c]GString;
pub extern fn g_string_overwrite_len(string: [*c]GString, pos: gsize, val: [*c]const gchar, len: gssize) [*c]GString;
pub extern fn g_string_erase(string: [*c]GString, pos: gssize, len: gssize) [*c]GString;
pub extern fn g_string_replace(string: [*c]GString, find: [*c]const gchar, replace: [*c]const gchar, limit: guint) guint;
pub extern fn g_string_ascii_down(string: [*c]GString) [*c]GString;
pub extern fn g_string_ascii_up(string: [*c]GString) [*c]GString;
pub extern fn g_string_vprintf(string: [*c]GString, format: [*c]const gchar, args: [*c]struct___va_list_tag_6) void;
pub extern fn g_string_printf(string: [*c]GString, format: [*c]const gchar, ...) void;
pub extern fn g_string_append_vprintf(string: [*c]GString, format: [*c]const gchar, args: [*c]struct___va_list_tag_6) void;
pub extern fn g_string_append_printf(string: [*c]GString, format: [*c]const gchar, ...) void;
pub extern fn g_string_append_uri_escaped(string: [*c]GString, unescaped: [*c]const gchar, reserved_chars_allowed: [*c]const gchar, allow_utf8: gboolean) [*c]GString;
pub inline fn g_string_append_c_inline(arg_gstring: [*c]GString, arg_c: gchar) [*c]GString {
    var gstring = arg_gstring;
    _ = &gstring;
    var c = arg_c;
    _ = &c;
    if ((gstring != @as([*c]GString, @ptrCast(@alignCast(@as(?*anyopaque, @ptrFromInt(@as(c_int, 0))))))) and ((gstring.*.len +% @as(gsize, @bitCast(@as(c_long, @as(c_int, 1))))) < gstring.*.allocated_len)) {
        gstring.*.str[blk: {
            const ref = &gstring.*.len;
            const tmp = ref.*;
            ref.* +%= 1;
            break :blk tmp;
        }] = c;
        gstring.*.str[gstring.*.len] = 0;
    } else {
        _ = g_string_insert_c(gstring, @as(gssize, @bitCast(@as(c_long, -@as(c_int, 1)))), c);
    }
    return gstring;
}
pub inline fn g_string_append_len_inline(arg_gstring: [*c]GString, arg_val: [*c]const u8, arg_len: gssize) [*c]GString {
    var gstring = arg_gstring;
    _ = &gstring;
    var val = arg_val;
    _ = &val;
    var len = arg_len;
    _ = &len;
    var len_unsigned: gsize = undefined;
    _ = &len_unsigned;
    if (gstring == @as([*c]GString, @ptrCast(@alignCast(@as(?*anyopaque, @ptrFromInt(@as(c_int, 0))))))) return g_string_append_len(gstring, val, len);
    if (val == @as([*c]const u8, @ptrCast(@alignCast(@as(?*anyopaque, @ptrFromInt(@as(c_int, 0))))))) return if (len != @as(gssize, @bitCast(@as(c_long, @as(c_int, 0))))) g_string_append_len(gstring, val, len) else gstring;
    if (len < @as(gssize, @bitCast(@as(c_long, @as(c_int, 0))))) {
        len_unsigned = strlen(val);
    } else {
        len_unsigned = @as(gsize, @bitCast(len));
    }
    if (len_unsigned < (gstring.*.allocated_len -% gstring.*.len)) {
        var end: [*c]u8 = gstring.*.str + gstring.*.len;
        _ = &end;
        if (((val + len_unsigned) <= @as([*c]const u8, @ptrCast(@alignCast(end)))) or (val >= @as([*c]const u8, @ptrCast(@alignCast(end + len_unsigned))))) {
            _ = memcpy(@as(?*anyopaque, @ptrCast(end)), @as(?*const anyopaque, @ptrCast(val)), len_unsigned);
        } else {
            _ = memmove(@as(?*anyopaque, @ptrCast(end)), @as(?*const anyopaque, @ptrCast(val)), len_unsigned);
        }
        gstring.*.len +%= len_unsigned;
        gstring.*.str[gstring.*.len] = 0;
        return gstring;
    } else return g_string_insert_len(gstring, @as(gssize, @bitCast(@as(c_long, -@as(c_int, 1)))), val, len);
    return null;
}
pub inline fn g_string_truncate_inline(arg_gstring: [*c]GString, arg_len: gsize) [*c]GString {
    var gstring = arg_gstring;
    _ = &gstring;
    var len = arg_len;
    _ = &len;
    gstring.*.len = if (len < gstring.*.len) len else gstring.*.len;
    gstring.*.str[gstring.*.len] = '\x00';
    return gstring;
}
pub extern fn g_string_down(string: [*c]GString) [*c]GString;
pub extern fn g_string_up(string: [*c]GString) [*c]GString;
pub const GIOChannel = struct__GIOChannel;
pub const struct__GIOFuncs = extern struct {
    io_read: ?*const fn (?*GIOChannel, [*c]gchar, gsize, [*c]gsize, [*c][*c]GError) callconv(.c) GIOStatus = @import("std").mem.zeroes(?*const fn (?*GIOChannel, [*c]gchar, gsize, [*c]gsize, [*c][*c]GError) callconv(.c) GIOStatus),
    io_write: ?*const fn (?*GIOChannel, [*c]const gchar, gsize, [*c]gsize, [*c][*c]GError) callconv(.c) GIOStatus = @import("std").mem.zeroes(?*const fn (?*GIOChannel, [*c]const gchar, gsize, [*c]gsize, [*c][*c]GError) callconv(.c) GIOStatus),
    io_seek: ?*const fn (?*GIOChannel, gint64, GSeekType, [*c][*c]GError) callconv(.c) GIOStatus = @import("std").mem.zeroes(?*const fn (?*GIOChannel, gint64, GSeekType, [*c][*c]GError) callconv(.c) GIOStatus),
    io_close: ?*const fn (?*GIOChannel, [*c][*c]GError) callconv(.c) GIOStatus = @import("std").mem.zeroes(?*const fn (?*GIOChannel, [*c][*c]GError) callconv(.c) GIOStatus),
    io_create_watch: ?*const fn (?*GIOChannel, GIOCondition) callconv(.c) [*c]GSource = @import("std").mem.zeroes(?*const fn (?*GIOChannel, GIOCondition) callconv(.c) [*c]GSource),
    io_free: ?*const fn (?*GIOChannel) callconv(.c) void = @import("std").mem.zeroes(?*const fn (?*GIOChannel) callconv(.c) void),
    io_set_flags: ?*const fn (?*GIOChannel, GIOFlags, [*c][*c]GError) callconv(.c) GIOStatus = @import("std").mem.zeroes(?*const fn (?*GIOChannel, GIOFlags, [*c][*c]GError) callconv(.c) GIOStatus),
    io_get_flags: ?*const fn (?*GIOChannel) callconv(.c) GIOFlags = @import("std").mem.zeroes(?*const fn (?*GIOChannel) callconv(.c) GIOFlags),
};
pub const GIOFuncs = struct__GIOFuncs;
// /usr/include/glib-2.0/glib/giochannel.h:120:9: warning: struct demoted to opaque type - has bitfield
pub const struct__GIOChannel = opaque {};
pub const G_IO_ERROR_NONE: c_int = 0;
pub const G_IO_ERROR_AGAIN: c_int = 1;
pub const G_IO_ERROR_INVAL: c_int = 2;
pub const G_IO_ERROR_UNKNOWN: c_int = 3;
pub const GIOError = c_uint;
pub const G_IO_CHANNEL_ERROR_FBIG: c_int = 0;
pub const G_IO_CHANNEL_ERROR_INVAL: c_int = 1;
pub const G_IO_CHANNEL_ERROR_IO: c_int = 2;
pub const G_IO_CHANNEL_ERROR_ISDIR: c_int = 3;
pub const G_IO_CHANNEL_ERROR_NOSPC: c_int = 4;
pub const G_IO_CHANNEL_ERROR_NXIO: c_int = 5;
pub const G_IO_CHANNEL_ERROR_OVERFLOW: c_int = 6;
pub const G_IO_CHANNEL_ERROR_PIPE: c_int = 7;
pub const G_IO_CHANNEL_ERROR_FAILED: c_int = 8;
pub const GIOChannelError = c_uint;
pub const G_IO_STATUS_ERROR: c_int = 0;
pub const G_IO_STATUS_NORMAL: c_int = 1;
pub const G_IO_STATUS_EOF: c_int = 2;
pub const G_IO_STATUS_AGAIN: c_int = 3;
pub const GIOStatus = c_uint;
pub const G_SEEK_CUR: c_int = 0;
pub const G_SEEK_SET: c_int = 1;
pub const G_SEEK_END: c_int = 2;
pub const GSeekType = c_uint;
pub const G_IO_FLAG_NONE: c_int = 0;
pub const G_IO_FLAG_APPEND: c_int = 1;
pub const G_IO_FLAG_NONBLOCK: c_int = 2;
pub const G_IO_FLAG_IS_READABLE: c_int = 4;
pub const G_IO_FLAG_IS_WRITABLE: c_int = 8;
pub const G_IO_FLAG_IS_WRITEABLE: c_int = 8;
pub const G_IO_FLAG_IS_SEEKABLE: c_int = 16;
pub const G_IO_FLAG_MASK: c_int = 31;
pub const G_IO_FLAG_GET_MASK: c_int = 31;
pub const G_IO_FLAG_SET_MASK: c_int = 3;
pub const GIOFlags = c_uint;
pub const GIOFunc = ?*const fn (?*GIOChannel, GIOCondition, gpointer) callconv(.c) gboolean;
pub extern fn g_io_channel_init(channel: ?*GIOChannel) void;
pub extern fn g_io_channel_ref(channel: ?*GIOChannel) ?*GIOChannel;
pub extern fn g_io_channel_unref(channel: ?*GIOChannel) void;
pub extern fn g_io_channel_read(channel: ?*GIOChannel, buf: [*c]gchar, count: gsize, bytes_read: [*c]gsize) GIOError;
pub extern fn g_io_channel_write(channel: ?*GIOChannel, buf: [*c]const gchar, count: gsize, bytes_written: [*c]gsize) GIOError;
pub extern fn g_io_channel_seek(channel: ?*GIOChannel, offset: gint64, @"type": GSeekType) GIOError;
pub extern fn g_io_channel_close(channel: ?*GIOChannel) void;
pub extern fn g_io_channel_shutdown(channel: ?*GIOChannel, flush: gboolean, err: [*c][*c]GError) GIOStatus;
pub extern fn g_io_add_watch_full(channel: ?*GIOChannel, priority: gint, condition: GIOCondition, func: GIOFunc, user_data: gpointer, notify: GDestroyNotify) guint;
pub extern fn g_io_create_watch(channel: ?*GIOChannel, condition: GIOCondition) [*c]GSource;
pub extern fn g_io_add_watch(channel: ?*GIOChannel, condition: GIOCondition, func: GIOFunc, user_data: gpointer) guint;
pub extern fn g_io_channel_set_buffer_size(channel: ?*GIOChannel, size: gsize) void;
pub extern fn g_io_channel_get_buffer_size(channel: ?*GIOChannel) gsize;
pub extern fn g_io_channel_get_buffer_condition(channel: ?*GIOChannel) GIOCondition;
pub extern fn g_io_channel_set_flags(channel: ?*GIOChannel, flags: GIOFlags, @"error": [*c][*c]GError) GIOStatus;
pub extern fn g_io_channel_get_flags(channel: ?*GIOChannel) GIOFlags;
pub extern fn g_io_channel_set_line_term(channel: ?*GIOChannel, line_term: [*c]const gchar, length: gint) void;
pub extern fn g_io_channel_get_line_term(channel: ?*GIOChannel, length: [*c]gint) [*c]const gchar;
pub extern fn g_io_channel_set_buffered(channel: ?*GIOChannel, buffered: gboolean) void;
pub extern fn g_io_channel_get_buffered(channel: ?*GIOChannel) gboolean;
pub extern fn g_io_channel_set_encoding(channel: ?*GIOChannel, encoding: [*c]const gchar, @"error": [*c][*c]GError) GIOStatus;
pub extern fn g_io_channel_get_encoding(channel: ?*GIOChannel) [*c]const gchar;
pub extern fn g_io_channel_set_close_on_unref(channel: ?*GIOChannel, do_close: gboolean) void;
pub extern fn g_io_channel_get_close_on_unref(channel: ?*GIOChannel) gboolean;
pub extern fn g_io_channel_flush(channel: ?*GIOChannel, @"error": [*c][*c]GError) GIOStatus;
pub extern fn g_io_channel_read_line(channel: ?*GIOChannel, str_return: [*c][*c]gchar, length: [*c]gsize, terminator_pos: [*c]gsize, @"error": [*c][*c]GError) GIOStatus;
pub extern fn g_io_channel_read_line_string(channel: ?*GIOChannel, buffer: [*c]GString, terminator_pos: [*c]gsize, @"error": [*c][*c]GError) GIOStatus;
pub extern fn g_io_channel_read_to_end(channel: ?*GIOChannel, str_return: [*c][*c]gchar, length: [*c]gsize, @"error": [*c][*c]GError) GIOStatus;
pub extern fn g_io_channel_read_chars(channel: ?*GIOChannel, buf: [*c]gchar, count: gsize, bytes_read: [*c]gsize, @"error": [*c][*c]GError) GIOStatus;
pub extern fn g_io_channel_read_unichar(channel: ?*GIOChannel, thechar: [*c]gunichar, @"error": [*c][*c]GError) GIOStatus;
pub extern fn g_io_channel_write_chars(channel: ?*GIOChannel, buf: [*c]const gchar, count: gssize, bytes_written: [*c]gsize, @"error": [*c][*c]GError) GIOStatus;
pub extern fn g_io_channel_write_unichar(channel: ?*GIOChannel, thechar: gunichar, @"error": [*c][*c]GError) GIOStatus;
pub extern fn g_io_channel_seek_position(channel: ?*GIOChannel, offset: gint64, @"type": GSeekType, @"error": [*c][*c]GError) GIOStatus;
pub extern fn g_io_channel_new_file(filename: [*c]const gchar, mode: [*c]const gchar, @"error": [*c][*c]GError) ?*GIOChannel;
pub extern fn g_io_channel_error_quark() GQuark;
pub extern fn g_io_channel_error_from_errno(en: gint) GIOChannelError;
pub extern fn g_io_channel_unix_new(fd: c_int) ?*GIOChannel;
pub extern fn g_io_channel_unix_get_fd(channel: ?*GIOChannel) gint;
pub extern var g_io_watch_funcs: GSourceFuncs;
pub const G_KEY_FILE_ERROR_UNKNOWN_ENCODING: c_int = 0;
pub const G_KEY_FILE_ERROR_PARSE: c_int = 1;
pub const G_KEY_FILE_ERROR_NOT_FOUND: c_int = 2;
pub const G_KEY_FILE_ERROR_KEY_NOT_FOUND: c_int = 3;
pub const G_KEY_FILE_ERROR_GROUP_NOT_FOUND: c_int = 4;
pub const G_KEY_FILE_ERROR_INVALID_VALUE: c_int = 5;
pub const GKeyFileError = c_uint;
pub extern fn g_key_file_error_quark() GQuark;
pub const struct__GKeyFile = opaque {};
pub const GKeyFile = struct__GKeyFile;
pub const G_KEY_FILE_NONE: c_int = 0;
pub const G_KEY_FILE_KEEP_COMMENTS: c_int = 1;
pub const G_KEY_FILE_KEEP_TRANSLATIONS: c_int = 2;
pub const GKeyFileFlags = c_uint;
pub extern fn g_key_file_new() ?*GKeyFile;
pub extern fn g_key_file_ref(key_file: ?*GKeyFile) ?*GKeyFile;
pub extern fn g_key_file_unref(key_file: ?*GKeyFile) void;
pub extern fn g_key_file_free(key_file: ?*GKeyFile) void;
pub extern fn g_key_file_set_list_separator(key_file: ?*GKeyFile, separator: gchar) void;
pub extern fn g_key_file_load_from_file(key_file: ?*GKeyFile, file: [*c]const gchar, flags: GKeyFileFlags, @"error": [*c][*c]GError) gboolean;
pub extern fn g_key_file_load_from_data(key_file: ?*GKeyFile, data: [*c]const gchar, length: gsize, flags: GKeyFileFlags, @"error": [*c][*c]GError) gboolean;
pub extern fn g_key_file_load_from_bytes(key_file: ?*GKeyFile, bytes: ?*GBytes, flags: GKeyFileFlags, @"error": [*c][*c]GError) gboolean;
pub extern fn g_key_file_load_from_dirs(key_file: ?*GKeyFile, file: [*c]const gchar, search_dirs: [*c][*c]const gchar, full_path: [*c][*c]gchar, flags: GKeyFileFlags, @"error": [*c][*c]GError) gboolean;
pub extern fn g_key_file_load_from_data_dirs(key_file: ?*GKeyFile, file: [*c]const gchar, full_path: [*c][*c]gchar, flags: GKeyFileFlags, @"error": [*c][*c]GError) gboolean;
pub extern fn g_key_file_to_data(key_file: ?*GKeyFile, length: [*c]gsize, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_key_file_save_to_file(key_file: ?*GKeyFile, filename: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_key_file_get_start_group(key_file: ?*GKeyFile) [*c]gchar;
pub extern fn g_key_file_get_groups(key_file: ?*GKeyFile, length: [*c]gsize) [*c][*c]gchar;
pub extern fn g_key_file_get_keys(key_file: ?*GKeyFile, group_name: [*c]const gchar, length: [*c]gsize, @"error": [*c][*c]GError) [*c][*c]gchar;
pub extern fn g_key_file_has_group(key_file: ?*GKeyFile, group_name: [*c]const gchar) gboolean;
pub extern fn g_key_file_has_key(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_key_file_get_value(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_key_file_set_value(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, value: [*c]const gchar) void;
pub extern fn g_key_file_get_string(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_key_file_set_string(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, string: [*c]const gchar) void;
pub extern fn g_key_file_get_locale_string(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, locale: [*c]const gchar, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_key_file_get_locale_for_key(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, locale: [*c]const gchar) [*c]gchar;
pub extern fn g_key_file_set_locale_string(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, locale: [*c]const gchar, string: [*c]const gchar) void;
pub extern fn g_key_file_get_boolean(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_key_file_set_boolean(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, value: gboolean) void;
pub extern fn g_key_file_get_integer(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, @"error": [*c][*c]GError) gint;
pub extern fn g_key_file_set_integer(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, value: gint) void;
pub extern fn g_key_file_get_int64(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, @"error": [*c][*c]GError) gint64;
pub extern fn g_key_file_set_int64(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, value: gint64) void;
pub extern fn g_key_file_get_uint64(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, @"error": [*c][*c]GError) guint64;
pub extern fn g_key_file_set_uint64(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, value: guint64) void;
pub extern fn g_key_file_get_double(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, @"error": [*c][*c]GError) gdouble;
pub extern fn g_key_file_set_double(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, value: gdouble) void;
pub extern fn g_key_file_get_string_list(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, length: [*c]gsize, @"error": [*c][*c]GError) [*c][*c]gchar;
pub extern fn g_key_file_set_string_list(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, list: [*c]const [*c]const gchar, length: gsize) void;
pub extern fn g_key_file_get_locale_string_list(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, locale: [*c]const gchar, length: [*c]gsize, @"error": [*c][*c]GError) [*c][*c]gchar;
pub extern fn g_key_file_set_locale_string_list(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, locale: [*c]const gchar, list: [*c]const [*c]const gchar, length: gsize) void;
pub extern fn g_key_file_get_boolean_list(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, length: [*c]gsize, @"error": [*c][*c]GError) [*c]gboolean;
pub extern fn g_key_file_set_boolean_list(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, list: [*c]gboolean, length: gsize) void;
pub extern fn g_key_file_get_integer_list(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, length: [*c]gsize, @"error": [*c][*c]GError) [*c]gint;
pub extern fn g_key_file_set_double_list(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, list: [*c]gdouble, length: gsize) void;
pub extern fn g_key_file_get_double_list(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, length: [*c]gsize, @"error": [*c][*c]GError) [*c]gdouble;
pub extern fn g_key_file_set_integer_list(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, list: [*c]gint, length: gsize) void;
pub extern fn g_key_file_set_comment(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, comment: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_key_file_get_comment(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_key_file_remove_comment(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_key_file_remove_key(key_file: ?*GKeyFile, group_name: [*c]const gchar, key: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_key_file_remove_group(key_file: ?*GKeyFile, group_name: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub const struct__GMappedFile = opaque {};
pub const GMappedFile = struct__GMappedFile;
pub extern fn g_mapped_file_new(filename: [*c]const gchar, writable: gboolean, @"error": [*c][*c]GError) ?*GMappedFile;
pub extern fn g_mapped_file_new_from_fd(fd: gint, writable: gboolean, @"error": [*c][*c]GError) ?*GMappedFile;
pub extern fn g_mapped_file_get_length(file: ?*GMappedFile) gsize;
pub extern fn g_mapped_file_get_contents(file: ?*GMappedFile) [*c]gchar;
pub extern fn g_mapped_file_get_bytes(file: ?*GMappedFile) ?*GBytes;
pub extern fn g_mapped_file_ref(file: ?*GMappedFile) ?*GMappedFile;
pub extern fn g_mapped_file_unref(file: ?*GMappedFile) void;
pub extern fn g_mapped_file_free(file: ?*GMappedFile) void;
pub const G_MARKUP_ERROR_BAD_UTF8: c_int = 0;
pub const G_MARKUP_ERROR_EMPTY: c_int = 1;
pub const G_MARKUP_ERROR_PARSE: c_int = 2;
pub const G_MARKUP_ERROR_UNKNOWN_ELEMENT: c_int = 3;
pub const G_MARKUP_ERROR_UNKNOWN_ATTRIBUTE: c_int = 4;
pub const G_MARKUP_ERROR_INVALID_CONTENT: c_int = 5;
pub const G_MARKUP_ERROR_MISSING_ATTRIBUTE: c_int = 6;
pub const GMarkupError = c_uint;
pub extern fn g_markup_error_quark() GQuark;
pub const G_MARKUP_DEFAULT_FLAGS: c_int = 0;
pub const G_MARKUP_DO_NOT_USE_THIS_UNSUPPORTED_FLAG: c_int = 1;
pub const G_MARKUP_TREAT_CDATA_AS_TEXT: c_int = 2;
pub const G_MARKUP_PREFIX_ERROR_POSITION: c_int = 4;
pub const G_MARKUP_IGNORE_QUALIFIED: c_int = 8;
pub const GMarkupParseFlags = c_uint;
pub const struct__GMarkupParseContext = opaque {};
pub const GMarkupParseContext = struct__GMarkupParseContext;
pub const struct__GMarkupParser = extern struct {
    start_element: ?*const fn (?*GMarkupParseContext, [*c]const gchar, [*c][*c]const gchar, [*c][*c]const gchar, gpointer, [*c][*c]GError) callconv(.c) void = @import("std").mem.zeroes(?*const fn (?*GMarkupParseContext, [*c]const gchar, [*c][*c]const gchar, [*c][*c]const gchar, gpointer, [*c][*c]GError) callconv(.c) void),
    end_element: ?*const fn (?*GMarkupParseContext, [*c]const gchar, gpointer, [*c][*c]GError) callconv(.c) void = @import("std").mem.zeroes(?*const fn (?*GMarkupParseContext, [*c]const gchar, gpointer, [*c][*c]GError) callconv(.c) void),
    text: ?*const fn (?*GMarkupParseContext, [*c]const gchar, gsize, gpointer, [*c][*c]GError) callconv(.c) void = @import("std").mem.zeroes(?*const fn (?*GMarkupParseContext, [*c]const gchar, gsize, gpointer, [*c][*c]GError) callconv(.c) void),
    passthrough: ?*const fn (?*GMarkupParseContext, [*c]const gchar, gsize, gpointer, [*c][*c]GError) callconv(.c) void = @import("std").mem.zeroes(?*const fn (?*GMarkupParseContext, [*c]const gchar, gsize, gpointer, [*c][*c]GError) callconv(.c) void),
    @"error": ?*const fn (?*GMarkupParseContext, [*c]GError, gpointer) callconv(.c) void = @import("std").mem.zeroes(?*const fn (?*GMarkupParseContext, [*c]GError, gpointer) callconv(.c) void),
};
pub const GMarkupParser = struct__GMarkupParser;
pub extern fn g_markup_parse_context_new(parser: [*c]const GMarkupParser, flags: GMarkupParseFlags, user_data: gpointer, user_data_dnotify: GDestroyNotify) ?*GMarkupParseContext;
pub extern fn g_markup_parse_context_ref(context: ?*GMarkupParseContext) ?*GMarkupParseContext;
pub extern fn g_markup_parse_context_unref(context: ?*GMarkupParseContext) void;
pub extern fn g_markup_parse_context_free(context: ?*GMarkupParseContext) void;
pub extern fn g_markup_parse_context_parse(context: ?*GMarkupParseContext, text: [*c]const gchar, text_len: gssize, @"error": [*c][*c]GError) gboolean;
pub extern fn g_markup_parse_context_push(context: ?*GMarkupParseContext, parser: [*c]const GMarkupParser, user_data: gpointer) void;
pub extern fn g_markup_parse_context_pop(context: ?*GMarkupParseContext) gpointer;
pub extern fn g_markup_parse_context_end_parse(context: ?*GMarkupParseContext, @"error": [*c][*c]GError) gboolean;
pub extern fn g_markup_parse_context_get_element(context: ?*GMarkupParseContext) [*c]const gchar;
pub extern fn g_markup_parse_context_get_element_stack(context: ?*GMarkupParseContext) [*c]const GSList;
pub extern fn g_markup_parse_context_get_position(context: ?*GMarkupParseContext, line_number: [*c]gint, char_number: [*c]gint) void;
pub extern fn g_markup_parse_context_get_user_data(context: ?*GMarkupParseContext) gpointer;
pub extern fn g_markup_escape_text(text: [*c]const gchar, length: gssize) [*c]gchar;
pub extern fn g_markup_printf_escaped(format: [*c]const u8, ...) [*c]gchar;
pub extern fn g_markup_vprintf_escaped(format: [*c]const u8, args: [*c]struct___va_list_tag_6) [*c]gchar;
pub const G_MARKUP_COLLECT_INVALID: c_int = 0;
pub const G_MARKUP_COLLECT_STRING: c_int = 1;
pub const G_MARKUP_COLLECT_STRDUP: c_int = 2;
pub const G_MARKUP_COLLECT_BOOLEAN: c_int = 3;
pub const G_MARKUP_COLLECT_TRISTATE: c_int = 4;
pub const G_MARKUP_COLLECT_OPTIONAL: c_int = 65536;
pub const GMarkupCollectType = c_uint;
pub extern fn g_markup_collect_attributes(element_name: [*c]const gchar, attribute_names: [*c][*c]const gchar, attribute_values: [*c][*c]const gchar, @"error": [*c][*c]GError, first_type: GMarkupCollectType, first_attr: [*c]const gchar, ...) gboolean;
pub const struct__GVariantType = opaque {};
pub const GVariantType = struct__GVariantType;
pub extern fn g_variant_type_string_is_valid(type_string: [*c]const gchar) gboolean;
pub extern fn g_variant_type_string_scan(string: [*c]const gchar, limit: [*c]const gchar, endptr: [*c][*c]const gchar) gboolean;
pub extern fn g_variant_type_free(@"type": ?*GVariantType) void;
pub extern fn g_variant_type_copy(@"type": ?*const GVariantType) ?*GVariantType;
pub extern fn g_variant_type_new(type_string: [*c]const gchar) ?*GVariantType;
pub extern fn g_variant_type_get_string_length(@"type": ?*const GVariantType) gsize;
pub extern fn g_variant_type_peek_string(@"type": ?*const GVariantType) [*c]const gchar;
pub extern fn g_variant_type_dup_string(@"type": ?*const GVariantType) [*c]gchar;
pub extern fn g_variant_type_is_definite(@"type": ?*const GVariantType) gboolean;
pub extern fn g_variant_type_is_container(@"type": ?*const GVariantType) gboolean;
pub extern fn g_variant_type_is_basic(@"type": ?*const GVariantType) gboolean;
pub extern fn g_variant_type_is_maybe(@"type": ?*const GVariantType) gboolean;
pub extern fn g_variant_type_is_array(@"type": ?*const GVariantType) gboolean;
pub extern fn g_variant_type_is_tuple(@"type": ?*const GVariantType) gboolean;
pub extern fn g_variant_type_is_dict_entry(@"type": ?*const GVariantType) gboolean;
pub extern fn g_variant_type_is_variant(@"type": ?*const GVariantType) gboolean;
pub extern fn g_variant_type_hash(@"type": gconstpointer) guint;
pub extern fn g_variant_type_equal(type1: gconstpointer, type2: gconstpointer) gboolean;
pub extern fn g_variant_type_is_subtype_of(@"type": ?*const GVariantType, supertype: ?*const GVariantType) gboolean;
pub extern fn g_variant_type_element(@"type": ?*const GVariantType) ?*const GVariantType;
pub extern fn g_variant_type_first(@"type": ?*const GVariantType) ?*const GVariantType;
pub extern fn g_variant_type_next(@"type": ?*const GVariantType) ?*const GVariantType;
pub extern fn g_variant_type_n_items(@"type": ?*const GVariantType) gsize;
pub extern fn g_variant_type_key(@"type": ?*const GVariantType) ?*const GVariantType;
pub extern fn g_variant_type_value(@"type": ?*const GVariantType) ?*const GVariantType;
pub extern fn g_variant_type_new_array(element: ?*const GVariantType) ?*GVariantType;
pub extern fn g_variant_type_new_maybe(element: ?*const GVariantType) ?*GVariantType;
pub extern fn g_variant_type_new_tuple(items: [*c]const ?*const GVariantType, length: gint) ?*GVariantType;
pub extern fn g_variant_type_new_dict_entry(key: ?*const GVariantType, value: ?*const GVariantType) ?*GVariantType;
pub extern fn g_variant_type_checked_(type_string: [*c]const gchar) ?*const GVariantType;
pub extern fn g_variant_type_string_get_depth_(type_string: [*c]const gchar) gsize;
pub const struct__GVariant = opaque {};
pub const GVariant = struct__GVariant;
pub const G_VARIANT_CLASS_BOOLEAN: c_int = 98;
pub const G_VARIANT_CLASS_BYTE: c_int = 121;
pub const G_VARIANT_CLASS_INT16: c_int = 110;
pub const G_VARIANT_CLASS_UINT16: c_int = 113;
pub const G_VARIANT_CLASS_INT32: c_int = 105;
pub const G_VARIANT_CLASS_UINT32: c_int = 117;
pub const G_VARIANT_CLASS_INT64: c_int = 120;
pub const G_VARIANT_CLASS_UINT64: c_int = 116;
pub const G_VARIANT_CLASS_HANDLE: c_int = 104;
pub const G_VARIANT_CLASS_DOUBLE: c_int = 100;
pub const G_VARIANT_CLASS_STRING: c_int = 115;
pub const G_VARIANT_CLASS_OBJECT_PATH: c_int = 111;
pub const G_VARIANT_CLASS_SIGNATURE: c_int = 103;
pub const G_VARIANT_CLASS_VARIANT: c_int = 118;
pub const G_VARIANT_CLASS_MAYBE: c_int = 109;
pub const G_VARIANT_CLASS_ARRAY: c_int = 97;
pub const G_VARIANT_CLASS_TUPLE: c_int = 40;
pub const G_VARIANT_CLASS_DICT_ENTRY: c_int = 123;
pub const GVariantClass = c_uint;
pub extern fn g_variant_unref(value: ?*GVariant) void;
pub extern fn g_variant_ref(value: ?*GVariant) ?*GVariant;
pub extern fn g_variant_ref_sink(value: ?*GVariant) ?*GVariant;
pub extern fn g_variant_is_floating(value: ?*GVariant) gboolean;
pub extern fn g_variant_take_ref(value: ?*GVariant) ?*GVariant;
pub extern fn g_variant_get_type(value: ?*GVariant) ?*const GVariantType;
pub extern fn g_variant_get_type_string(value: ?*GVariant) [*c]const gchar;
pub extern fn g_variant_is_of_type(value: ?*GVariant, @"type": ?*const GVariantType) gboolean;
pub extern fn g_variant_is_container(value: ?*GVariant) gboolean;
pub extern fn g_variant_classify(value: ?*GVariant) GVariantClass;
pub extern fn g_variant_new_boolean(value: gboolean) ?*GVariant;
pub extern fn g_variant_new_byte(value: guint8) ?*GVariant;
pub extern fn g_variant_new_int16(value: gint16) ?*GVariant;
pub extern fn g_variant_new_uint16(value: guint16) ?*GVariant;
pub extern fn g_variant_new_int32(value: gint32) ?*GVariant;
pub extern fn g_variant_new_uint32(value: guint32) ?*GVariant;
pub extern fn g_variant_new_int64(value: gint64) ?*GVariant;
pub extern fn g_variant_new_uint64(value: guint64) ?*GVariant;
pub extern fn g_variant_new_handle(value: gint32) ?*GVariant;
pub extern fn g_variant_new_double(value: gdouble) ?*GVariant;
pub extern fn g_variant_new_string(string: [*c]const gchar) ?*GVariant;
pub extern fn g_variant_new_take_string(string: [*c]gchar) ?*GVariant;
pub extern fn g_variant_new_printf(format_string: [*c]const gchar, ...) ?*GVariant;
pub extern fn g_variant_new_object_path(object_path: [*c]const gchar) ?*GVariant;
pub extern fn g_variant_is_object_path(string: [*c]const gchar) gboolean;
pub extern fn g_variant_new_signature(signature: [*c]const gchar) ?*GVariant;
pub extern fn g_variant_is_signature(string: [*c]const gchar) gboolean;
pub extern fn g_variant_new_variant(value: ?*GVariant) ?*GVariant;
pub extern fn g_variant_new_strv(strv: [*c]const [*c]const gchar, length: gssize) ?*GVariant;
pub extern fn g_variant_new_objv(strv: [*c]const [*c]const gchar, length: gssize) ?*GVariant;
pub extern fn g_variant_new_bytestring(string: [*c]const gchar) ?*GVariant;
pub extern fn g_variant_new_bytestring_array(strv: [*c]const [*c]const gchar, length: gssize) ?*GVariant;
pub extern fn g_variant_new_fixed_array(element_type: ?*const GVariantType, elements: gconstpointer, n_elements: gsize, element_size: gsize) ?*GVariant;
pub extern fn g_variant_get_boolean(value: ?*GVariant) gboolean;
pub extern fn g_variant_get_byte(value: ?*GVariant) guint8;
pub extern fn g_variant_get_int16(value: ?*GVariant) gint16;
pub extern fn g_variant_get_uint16(value: ?*GVariant) guint16;
pub extern fn g_variant_get_int32(value: ?*GVariant) gint32;
pub extern fn g_variant_get_uint32(value: ?*GVariant) guint32;
pub extern fn g_variant_get_int64(value: ?*GVariant) gint64;
pub extern fn g_variant_get_uint64(value: ?*GVariant) guint64;
pub extern fn g_variant_get_handle(value: ?*GVariant) gint32;
pub extern fn g_variant_get_double(value: ?*GVariant) gdouble;
pub extern fn g_variant_get_variant(value: ?*GVariant) ?*GVariant;
pub extern fn g_variant_get_string(value: ?*GVariant, length: [*c]gsize) [*c]const gchar;
pub extern fn g_variant_dup_string(value: ?*GVariant, length: [*c]gsize) [*c]gchar;
pub extern fn g_variant_get_strv(value: ?*GVariant, length: [*c]gsize) [*c][*c]const gchar;
pub extern fn g_variant_dup_strv(value: ?*GVariant, length: [*c]gsize) [*c][*c]gchar;
pub extern fn g_variant_get_objv(value: ?*GVariant, length: [*c]gsize) [*c][*c]const gchar;
pub extern fn g_variant_dup_objv(value: ?*GVariant, length: [*c]gsize) [*c][*c]gchar;
pub extern fn g_variant_get_bytestring(value: ?*GVariant) [*c]const gchar;
pub extern fn g_variant_dup_bytestring(value: ?*GVariant, length: [*c]gsize) [*c]gchar;
pub extern fn g_variant_get_bytestring_array(value: ?*GVariant, length: [*c]gsize) [*c][*c]const gchar;
pub extern fn g_variant_dup_bytestring_array(value: ?*GVariant, length: [*c]gsize) [*c][*c]gchar;
pub extern fn g_variant_new_maybe(child_type: ?*const GVariantType, child: ?*GVariant) ?*GVariant;
pub extern fn g_variant_new_array(child_type: ?*const GVariantType, children: [*c]const ?*GVariant, n_children: gsize) ?*GVariant;
pub extern fn g_variant_new_tuple(children: [*c]const ?*GVariant, n_children: gsize) ?*GVariant;
pub extern fn g_variant_new_dict_entry(key: ?*GVariant, value: ?*GVariant) ?*GVariant;
pub extern fn g_variant_get_maybe(value: ?*GVariant) ?*GVariant;
pub extern fn g_variant_n_children(value: ?*GVariant) gsize;
pub extern fn g_variant_get_child(value: ?*GVariant, index_: gsize, format_string: [*c]const gchar, ...) void;
pub extern fn g_variant_get_child_value(value: ?*GVariant, index_: gsize) ?*GVariant;
pub extern fn g_variant_lookup(dictionary: ?*GVariant, key: [*c]const gchar, format_string: [*c]const gchar, ...) gboolean;
pub extern fn g_variant_lookup_value(dictionary: ?*GVariant, key: [*c]const gchar, expected_type: ?*const GVariantType) ?*GVariant;
pub extern fn g_variant_get_fixed_array(value: ?*GVariant, n_elements: [*c]gsize, element_size: gsize) gconstpointer;
pub extern fn g_variant_get_size(value: ?*GVariant) gsize;
pub extern fn g_variant_get_data(value: ?*GVariant) gconstpointer;
pub extern fn g_variant_get_data_as_bytes(value: ?*GVariant) ?*GBytes;
pub extern fn g_variant_store(value: ?*GVariant, data: gpointer) void;
pub extern fn g_variant_print(value: ?*GVariant, type_annotate: gboolean) [*c]gchar;
pub extern fn g_variant_print_string(value: ?*GVariant, string: [*c]GString, type_annotate: gboolean) [*c]GString;
pub extern fn g_variant_hash(value: gconstpointer) guint;
pub extern fn g_variant_equal(one: gconstpointer, two: gconstpointer) gboolean;
pub extern fn g_variant_get_normal_form(value: ?*GVariant) ?*GVariant;
pub extern fn g_variant_is_normal_form(value: ?*GVariant) gboolean;
pub extern fn g_variant_byteswap(value: ?*GVariant) ?*GVariant;
pub extern fn g_variant_new_from_bytes(@"type": ?*const GVariantType, bytes: ?*GBytes, trusted: gboolean) ?*GVariant;
pub extern fn g_variant_new_from_data(@"type": ?*const GVariantType, data: gconstpointer, size: gsize, trusted: gboolean, notify: GDestroyNotify, user_data: gpointer) ?*GVariant;
pub const struct__GVariantIter = extern struct {
    x: [16]guintptr = @import("std").mem.zeroes([16]guintptr),
};
pub const GVariantIter = struct__GVariantIter;
pub extern fn g_variant_iter_new(value: ?*GVariant) [*c]GVariantIter;
pub extern fn g_variant_iter_init(iter: [*c]GVariantIter, value: ?*GVariant) gsize;
pub extern fn g_variant_iter_copy(iter: [*c]GVariantIter) [*c]GVariantIter;
pub extern fn g_variant_iter_n_children(iter: [*c]GVariantIter) gsize;
pub extern fn g_variant_iter_free(iter: [*c]GVariantIter) void;
pub extern fn g_variant_iter_next_value(iter: [*c]GVariantIter) ?*GVariant;
pub extern fn g_variant_iter_next(iter: [*c]GVariantIter, format_string: [*c]const gchar, ...) gboolean;
pub extern fn g_variant_iter_loop(iter: [*c]GVariantIter, format_string: [*c]const gchar, ...) gboolean;
const struct_unnamed_31 = extern struct {
    partial_magic: gsize = @import("std").mem.zeroes(gsize),
    type: ?*const GVariantType = @import("std").mem.zeroes(?*const GVariantType),
    y: [14]guintptr = @import("std").mem.zeroes([14]guintptr),
};
const union_unnamed_30 = extern union {
    s: struct_unnamed_31,
    x: [16]guintptr,
};
pub const struct__GVariantBuilder = extern struct {
    u: union_unnamed_30 = @import("std").mem.zeroes(union_unnamed_30),
};
pub const GVariantBuilder = struct__GVariantBuilder;
pub const G_VARIANT_PARSE_ERROR_FAILED: c_int = 0;
pub const G_VARIANT_PARSE_ERROR_BASIC_TYPE_EXPECTED: c_int = 1;
pub const G_VARIANT_PARSE_ERROR_CANNOT_INFER_TYPE: c_int = 2;
pub const G_VARIANT_PARSE_ERROR_DEFINITE_TYPE_EXPECTED: c_int = 3;
pub const G_VARIANT_PARSE_ERROR_INPUT_NOT_AT_END: c_int = 4;
pub const G_VARIANT_PARSE_ERROR_INVALID_CHARACTER: c_int = 5;
pub const G_VARIANT_PARSE_ERROR_INVALID_FORMAT_STRING: c_int = 6;
pub const G_VARIANT_PARSE_ERROR_INVALID_OBJECT_PATH: c_int = 7;
pub const G_VARIANT_PARSE_ERROR_INVALID_SIGNATURE: c_int = 8;
pub const G_VARIANT_PARSE_ERROR_INVALID_TYPE_STRING: c_int = 9;
pub const G_VARIANT_PARSE_ERROR_NO_COMMON_TYPE: c_int = 10;
pub const G_VARIANT_PARSE_ERROR_NUMBER_OUT_OF_RANGE: c_int = 11;
pub const G_VARIANT_PARSE_ERROR_NUMBER_TOO_BIG: c_int = 12;
pub const G_VARIANT_PARSE_ERROR_TYPE_ERROR: c_int = 13;
pub const G_VARIANT_PARSE_ERROR_UNEXPECTED_TOKEN: c_int = 14;
pub const G_VARIANT_PARSE_ERROR_UNKNOWN_KEYWORD: c_int = 15;
pub const G_VARIANT_PARSE_ERROR_UNTERMINATED_STRING_CONSTANT: c_int = 16;
pub const G_VARIANT_PARSE_ERROR_VALUE_EXPECTED: c_int = 17;
pub const G_VARIANT_PARSE_ERROR_RECURSION: c_int = 18;
pub const GVariantParseError = c_uint;
pub extern fn g_variant_parser_get_error_quark() GQuark;
pub extern fn g_variant_parse_error_quark() GQuark;
pub extern fn g_variant_builder_new(@"type": ?*const GVariantType) [*c]GVariantBuilder;
pub extern fn g_variant_builder_unref(builder: [*c]GVariantBuilder) void;
pub extern fn g_variant_builder_ref(builder: [*c]GVariantBuilder) [*c]GVariantBuilder;
pub extern fn g_variant_builder_init(builder: [*c]GVariantBuilder, @"type": ?*const GVariantType) void;
pub extern fn g_variant_builder_init_static(builder: [*c]GVariantBuilder, @"type": ?*const GVariantType) void;
pub extern fn g_variant_builder_end(builder: [*c]GVariantBuilder) ?*GVariant;
pub extern fn g_variant_builder_clear(builder: [*c]GVariantBuilder) void;
pub extern fn g_variant_builder_open(builder: [*c]GVariantBuilder, @"type": ?*const GVariantType) void;
pub extern fn g_variant_builder_close(builder: [*c]GVariantBuilder) void;
pub extern fn g_variant_builder_add_value(builder: [*c]GVariantBuilder, value: ?*GVariant) void;
pub extern fn g_variant_builder_add(builder: [*c]GVariantBuilder, format_string: [*c]const gchar, ...) void;
pub extern fn g_variant_builder_add_parsed(builder: [*c]GVariantBuilder, format: [*c]const gchar, ...) void;
pub extern fn g_variant_new(format_string: [*c]const gchar, ...) ?*GVariant;
pub extern fn g_variant_get(value: ?*GVariant, format_string: [*c]const gchar, ...) void;
pub extern fn g_variant_new_va(format_string: [*c]const gchar, endptr: [*c][*c]const gchar, app: [*c]va_list) ?*GVariant;
pub extern fn g_variant_get_va(value: ?*GVariant, format_string: [*c]const gchar, endptr: [*c][*c]const gchar, app: [*c]va_list) void;
pub extern fn g_variant_check_format_string(value: ?*GVariant, format_string: [*c]const gchar, copy_only: gboolean) gboolean;
pub extern fn g_variant_parse(@"type": ?*const GVariantType, text: [*c]const gchar, limit: [*c]const gchar, endptr: [*c][*c]const gchar, @"error": [*c][*c]GError) ?*GVariant;
pub extern fn g_variant_new_parsed(format: [*c]const gchar, ...) ?*GVariant;
pub extern fn g_variant_new_parsed_va(format: [*c]const gchar, app: [*c]va_list) ?*GVariant;
pub extern fn g_variant_parse_error_print_context(@"error": [*c]GError, source_str: [*c]const gchar) [*c]gchar;
pub extern fn g_variant_compare(one: gconstpointer, two: gconstpointer) gint;
const struct_unnamed_33 = extern struct {
    asv: ?*GVariant = @import("std").mem.zeroes(?*GVariant),
    partial_magic: gsize = @import("std").mem.zeroes(gsize),
    y: [14]guintptr = @import("std").mem.zeroes([14]guintptr),
};
const union_unnamed_32 = extern union {
    s: struct_unnamed_33,
    x: [16]guintptr,
};
pub const struct__GVariantDict = extern struct {
    u: union_unnamed_32 = @import("std").mem.zeroes(union_unnamed_32),
};
pub const GVariantDict = struct__GVariantDict;
pub extern fn g_variant_dict_new(from_asv: ?*GVariant) [*c]GVariantDict;
pub extern fn g_variant_dict_init(dict: [*c]GVariantDict, from_asv: ?*GVariant) void;
pub extern fn g_variant_dict_lookup(dict: [*c]GVariantDict, key: [*c]const gchar, format_string: [*c]const gchar, ...) gboolean;
pub extern fn g_variant_dict_lookup_value(dict: [*c]GVariantDict, key: [*c]const gchar, expected_type: ?*const GVariantType) ?*GVariant;
pub extern fn g_variant_dict_contains(dict: [*c]GVariantDict, key: [*c]const gchar) gboolean;
pub extern fn g_variant_dict_insert(dict: [*c]GVariantDict, key: [*c]const gchar, format_string: [*c]const gchar, ...) void;
pub extern fn g_variant_dict_insert_value(dict: [*c]GVariantDict, key: [*c]const gchar, value: ?*GVariant) void;
pub extern fn g_variant_dict_remove(dict: [*c]GVariantDict, key: [*c]const gchar) gboolean;
pub extern fn g_variant_dict_clear(dict: [*c]GVariantDict) void;
pub extern fn g_variant_dict_end(dict: [*c]GVariantDict) ?*GVariant;
pub extern fn g_variant_dict_ref(dict: [*c]GVariantDict) [*c]GVariantDict;
pub extern fn g_variant_dict_unref(dict: [*c]GVariantDict) void;
pub extern fn g_printf_string_upper_bound(format: [*c]const gchar, args: [*c]struct___va_list_tag_6) gsize;
pub const G_LOG_FLAG_RECURSION: c_int = 1;
pub const G_LOG_FLAG_FATAL: c_int = 2;
pub const G_LOG_LEVEL_ERROR: c_int = 4;
pub const G_LOG_LEVEL_CRITICAL: c_int = 8;
pub const G_LOG_LEVEL_WARNING: c_int = 16;
pub const G_LOG_LEVEL_MESSAGE: c_int = 32;
pub const G_LOG_LEVEL_INFO: c_int = 64;
pub const G_LOG_LEVEL_DEBUG: c_int = 128;
pub const G_LOG_LEVEL_MASK: c_int = -4;
pub const GLogLevelFlags = c_int;
pub const GLogFunc = ?*const fn ([*c]const gchar, GLogLevelFlags, [*c]const gchar, gpointer) callconv(.c) void;
pub extern fn g_log_set_handler(log_domain: [*c]const gchar, log_levels: GLogLevelFlags, log_func: GLogFunc, user_data: gpointer) guint;
pub extern fn g_log_set_handler_full(log_domain: [*c]const gchar, log_levels: GLogLevelFlags, log_func: GLogFunc, user_data: gpointer, destroy: GDestroyNotify) guint;
pub extern fn g_log_remove_handler(log_domain: [*c]const gchar, handler_id: guint) void;
pub extern fn g_log_default_handler(log_domain: [*c]const gchar, log_level: GLogLevelFlags, message: [*c]const gchar, unused_data: gpointer) void;
pub extern fn g_log_set_default_handler(log_func: GLogFunc, user_data: gpointer) GLogFunc;
pub extern fn g_log(log_domain: [*c]const gchar, log_level: GLogLevelFlags, format: [*c]const gchar, ...) void;
pub extern fn g_logv(log_domain: [*c]const gchar, log_level: GLogLevelFlags, format: [*c]const gchar, args: [*c]struct___va_list_tag_6) void;
pub extern fn g_log_set_fatal_mask(log_domain: [*c]const gchar, fatal_mask: GLogLevelFlags) GLogLevelFlags;
pub extern fn g_log_set_always_fatal(fatal_mask: GLogLevelFlags) GLogLevelFlags;
pub extern fn g_log_get_always_fatal() GLogLevelFlags;
pub const G_LOG_WRITER_HANDLED: c_int = 1;
pub const G_LOG_WRITER_UNHANDLED: c_int = 0;
pub const GLogWriterOutput = c_uint;
pub const struct__GLogField = extern struct {
    key: [*c]const gchar = @import("std").mem.zeroes([*c]const gchar),
    value: gconstpointer = @import("std").mem.zeroes(gconstpointer),
    length: gssize = @import("std").mem.zeroes(gssize),
};
pub const GLogField = struct__GLogField;
pub const GLogWriterFunc = ?*const fn (GLogLevelFlags, [*c]const GLogField, gsize, gpointer) callconv(.c) GLogWriterOutput;
pub extern fn g_log_structured(log_domain: [*c]const gchar, log_level: GLogLevelFlags, ...) void;
pub extern fn g_log_structured_array(log_level: GLogLevelFlags, fields: [*c]const GLogField, n_fields: gsize) void;
pub extern fn g_log_variant(log_domain: [*c]const gchar, log_level: GLogLevelFlags, fields: ?*GVariant) void;
pub extern fn g_log_set_writer_func(func: GLogWriterFunc, user_data: gpointer, user_data_free: GDestroyNotify) void;
pub extern fn g_log_writer_supports_color(output_fd: gint) gboolean;
pub extern fn g_log_writer_is_journald(output_fd: gint) gboolean;
pub extern fn g_log_writer_format_fields(log_level: GLogLevelFlags, fields: [*c]const GLogField, n_fields: gsize, use_color: gboolean) [*c]gchar;
pub extern fn g_log_writer_syslog(log_level: GLogLevelFlags, fields: [*c]const GLogField, n_fields: gsize, user_data: gpointer) GLogWriterOutput;
pub extern fn g_log_writer_journald(log_level: GLogLevelFlags, fields: [*c]const GLogField, n_fields: gsize, user_data: gpointer) GLogWriterOutput;
pub extern fn g_log_writer_standard_streams(log_level: GLogLevelFlags, fields: [*c]const GLogField, n_fields: gsize, user_data: gpointer) GLogWriterOutput;
pub extern fn g_log_writer_default(log_level: GLogLevelFlags, fields: [*c]const GLogField, n_fields: gsize, user_data: gpointer) GLogWriterOutput;
pub extern fn g_log_writer_default_set_use_stderr(use_stderr: gboolean) void;
pub extern fn g_log_writer_default_would_drop(log_level: GLogLevelFlags, log_domain: [*c]const u8) gboolean;
pub extern fn g_log_writer_default_set_debug_domains(domains: [*c]const [*c]const gchar) void;
pub extern fn g_log_get_debug_enabled() gboolean;
pub extern fn g_log_set_debug_enabled(enabled: gboolean) void;
pub extern fn _g_log_fallback_handler(log_domain: [*c]const gchar, log_level: GLogLevelFlags, message: [*c]const gchar, unused_data: gpointer) void;
pub extern fn g_return_if_fail_warning(log_domain: [*c]const u8, pretty_function: [*c]const u8, expression: [*c]const u8) void;
pub extern fn g_warn_message(domain: [*c]const u8, file: [*c]const u8, line: c_int, func: [*c]const u8, warnexpr: [*c]const u8) void;
pub extern fn g_assert_warning(log_domain: [*c]const u8, file: [*c]const u8, line: c_int, pretty_function: [*c]const u8, expression: [*c]const u8) noreturn;
pub extern fn g_log_structured_standard(log_domain: [*c]const gchar, log_level: GLogLevelFlags, file: [*c]const gchar, line: [*c]const gchar, func: [*c]const gchar, message_format: [*c]const gchar, ...) void;
pub const GPrintFunc = ?*const fn ([*c]const gchar) callconv(.c) void;
pub extern fn g_print(format: [*c]const gchar, ...) void;
pub extern fn g_set_print_handler(func: GPrintFunc) GPrintFunc;
pub extern fn g_printerr(format: [*c]const gchar, ...) void;
pub extern fn g_set_printerr_handler(func: GPrintFunc) GPrintFunc;
pub const struct__GOptionContext = opaque {};
pub const GOptionContext = struct__GOptionContext;
pub const struct__GOptionGroup = opaque {};
pub const GOptionGroup = struct__GOptionGroup;
pub const struct__GOptionEntry = extern struct {
    long_name: [*c]const gchar = @import("std").mem.zeroes([*c]const gchar),
    short_name: gchar = @import("std").mem.zeroes(gchar),
    flags: gint = @import("std").mem.zeroes(gint),
    arg: GOptionArg = @import("std").mem.zeroes(GOptionArg),
    arg_data: gpointer = @import("std").mem.zeroes(gpointer),
    description: [*c]const gchar = @import("std").mem.zeroes([*c]const gchar),
    arg_description: [*c]const gchar = @import("std").mem.zeroes([*c]const gchar),
};
pub const GOptionEntry = struct__GOptionEntry;
pub const G_OPTION_FLAG_NONE: c_int = 0;
pub const G_OPTION_FLAG_HIDDEN: c_int = 1;
pub const G_OPTION_FLAG_IN_MAIN: c_int = 2;
pub const G_OPTION_FLAG_REVERSE: c_int = 4;
pub const G_OPTION_FLAG_NO_ARG: c_int = 8;
pub const G_OPTION_FLAG_FILENAME: c_int = 16;
pub const G_OPTION_FLAG_OPTIONAL_ARG: c_int = 32;
pub const G_OPTION_FLAG_NOALIAS: c_int = 64;
pub const G_OPTION_FLAG_DEPRECATED: c_int = 128;
pub const GOptionFlags = c_uint;
pub const G_OPTION_ARG_NONE: c_int = 0;
pub const G_OPTION_ARG_STRING: c_int = 1;
pub const G_OPTION_ARG_INT: c_int = 2;
pub const G_OPTION_ARG_CALLBACK: c_int = 3;
pub const G_OPTION_ARG_FILENAME: c_int = 4;
pub const G_OPTION_ARG_STRING_ARRAY: c_int = 5;
pub const G_OPTION_ARG_FILENAME_ARRAY: c_int = 6;
pub const G_OPTION_ARG_DOUBLE: c_int = 7;
pub const G_OPTION_ARG_INT64: c_int = 8;
pub const GOptionArg = c_uint;
pub const GOptionArgFunc = ?*const fn ([*c]const gchar, [*c]const gchar, gpointer, [*c][*c]GError) callconv(.c) gboolean;
pub const GOptionParseFunc = ?*const fn (?*GOptionContext, ?*GOptionGroup, gpointer, [*c][*c]GError) callconv(.c) gboolean;
pub const GOptionErrorFunc = ?*const fn (?*GOptionContext, ?*GOptionGroup, gpointer, [*c][*c]GError) callconv(.c) void;
pub const G_OPTION_ERROR_UNKNOWN_OPTION: c_int = 0;
pub const G_OPTION_ERROR_BAD_VALUE: c_int = 1;
pub const G_OPTION_ERROR_FAILED: c_int = 2;
pub const GOptionError = c_uint;
pub extern fn g_option_error_quark() GQuark;
pub extern fn g_option_context_new(parameter_string: [*c]const gchar) ?*GOptionContext;
pub extern fn g_option_context_set_summary(context: ?*GOptionContext, summary: [*c]const gchar) void;
pub extern fn g_option_context_get_summary(context: ?*GOptionContext) [*c]const gchar;
pub extern fn g_option_context_set_description(context: ?*GOptionContext, description: [*c]const gchar) void;
pub extern fn g_option_context_get_description(context: ?*GOptionContext) [*c]const gchar;
pub extern fn g_option_context_free(context: ?*GOptionContext) void;
pub extern fn g_option_context_set_help_enabled(context: ?*GOptionContext, help_enabled: gboolean) void;
pub extern fn g_option_context_get_help_enabled(context: ?*GOptionContext) gboolean;
pub extern fn g_option_context_set_ignore_unknown_options(context: ?*GOptionContext, ignore_unknown: gboolean) void;
pub extern fn g_option_context_get_ignore_unknown_options(context: ?*GOptionContext) gboolean;
pub extern fn g_option_context_set_strict_posix(context: ?*GOptionContext, strict_posix: gboolean) void;
pub extern fn g_option_context_get_strict_posix(context: ?*GOptionContext) gboolean;
pub extern fn g_option_context_add_main_entries(context: ?*GOptionContext, entries: [*c]const GOptionEntry, translation_domain: [*c]const gchar) void;
pub extern fn g_option_context_parse(context: ?*GOptionContext, argc: [*c]gint, argv: [*c][*c][*c]gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_option_context_parse_strv(context: ?*GOptionContext, arguments: [*c][*c][*c]gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_option_context_set_translate_func(context: ?*GOptionContext, func: GTranslateFunc, data: gpointer, destroy_notify: GDestroyNotify) void;
pub extern fn g_option_context_set_translation_domain(context: ?*GOptionContext, domain: [*c]const gchar) void;
pub extern fn g_option_context_add_group(context: ?*GOptionContext, group: ?*GOptionGroup) void;
pub extern fn g_option_context_set_main_group(context: ?*GOptionContext, group: ?*GOptionGroup) void;
pub extern fn g_option_context_get_main_group(context: ?*GOptionContext) ?*GOptionGroup;
pub extern fn g_option_context_get_help(context: ?*GOptionContext, main_help: gboolean, group: ?*GOptionGroup) [*c]gchar;
pub extern fn g_option_group_new(name: [*c]const gchar, description: [*c]const gchar, help_description: [*c]const gchar, user_data: gpointer, destroy: GDestroyNotify) ?*GOptionGroup;
pub extern fn g_option_group_set_parse_hooks(group: ?*GOptionGroup, pre_parse_func: GOptionParseFunc, post_parse_func: GOptionParseFunc) void;
pub extern fn g_option_group_set_error_hook(group: ?*GOptionGroup, error_func: GOptionErrorFunc) void;
pub extern fn g_option_group_free(group: ?*GOptionGroup) void;
pub extern fn g_option_group_ref(group: ?*GOptionGroup) ?*GOptionGroup;
pub extern fn g_option_group_unref(group: ?*GOptionGroup) void;
pub extern fn g_option_group_add_entries(group: ?*GOptionGroup, entries: [*c]const GOptionEntry) void;
pub extern fn g_option_group_set_translate_func(group: ?*GOptionGroup, func: GTranslateFunc, data: gpointer, destroy_notify: GDestroyNotify) void;
pub extern fn g_option_group_set_translation_domain(group: ?*GOptionGroup, domain: [*c]const gchar) void;
pub const struct__GPathBuf = extern struct {
    dummy: [8]gpointer = @import("std").mem.zeroes([8]gpointer),
};
pub const GPathBuf = struct__GPathBuf;
pub extern fn g_path_buf_new() [*c]GPathBuf;
pub extern fn g_path_buf_new_from_path(path: [*c]const u8) [*c]GPathBuf;
pub extern fn g_path_buf_init(buf: [*c]GPathBuf) [*c]GPathBuf;
pub extern fn g_path_buf_init_from_path(buf: [*c]GPathBuf, path: [*c]const u8) [*c]GPathBuf;
pub extern fn g_path_buf_clear(buf: [*c]GPathBuf) void;
pub extern fn g_path_buf_clear_to_path(buf: [*c]GPathBuf) [*c]u8;
pub extern fn g_path_buf_free(buf: [*c]GPathBuf) void;
pub extern fn g_path_buf_free_to_path(buf: [*c]GPathBuf) [*c]u8;
pub extern fn g_path_buf_copy(buf: [*c]GPathBuf) [*c]GPathBuf;
pub extern fn g_path_buf_push(buf: [*c]GPathBuf, path: [*c]const u8) [*c]GPathBuf;
pub extern fn g_path_buf_pop(buf: [*c]GPathBuf) gboolean;
pub extern fn g_path_buf_set_filename(buf: [*c]GPathBuf, file_name: [*c]const u8) gboolean;
pub extern fn g_path_buf_set_extension(buf: [*c]GPathBuf, extension: [*c]const u8) gboolean;
pub extern fn g_path_buf_to_path(buf: [*c]GPathBuf) [*c]u8;
pub extern fn g_path_buf_equal(v1: gconstpointer, v2: gconstpointer) gboolean;
pub const struct__GPatternSpec = opaque {};
pub const GPatternSpec = struct__GPatternSpec;
pub extern fn g_pattern_spec_new(pattern: [*c]const gchar) ?*GPatternSpec;
pub extern fn g_pattern_spec_free(pspec: ?*GPatternSpec) void;
pub extern fn g_pattern_spec_copy(pspec: ?*GPatternSpec) ?*GPatternSpec;
pub extern fn g_pattern_spec_equal(pspec1: ?*GPatternSpec, pspec2: ?*GPatternSpec) gboolean;
pub extern fn g_pattern_spec_match(pspec: ?*GPatternSpec, string_length: gsize, string: [*c]const gchar, string_reversed: [*c]const gchar) gboolean;
pub extern fn g_pattern_spec_match_string(pspec: ?*GPatternSpec, string: [*c]const gchar) gboolean;
pub extern fn g_pattern_match(pspec: ?*GPatternSpec, string_length: guint, string: [*c]const gchar, string_reversed: [*c]const gchar) gboolean;
pub extern fn g_pattern_match_string(pspec: ?*GPatternSpec, string: [*c]const gchar) gboolean;
pub extern fn g_pattern_match_simple(pattern: [*c]const gchar, string: [*c]const gchar) gboolean;
pub extern fn g_spaced_primes_closest(num: guint) guint;
pub extern fn g_qsort_with_data(pbase: gconstpointer, total_elems: gint, size: gsize, compare_func: GCompareDataFunc, user_data: gpointer) void;
pub extern fn g_sort_array(array: ?*const anyopaque, n_elements: usize, element_size: usize, compare_func: GCompareDataFunc, user_data: ?*anyopaque) void;
pub const struct__GQueue = extern struct {
    head: [*c]GList = @import("std").mem.zeroes([*c]GList),
    tail: [*c]GList = @import("std").mem.zeroes([*c]GList),
    length: guint = @import("std").mem.zeroes(guint),
};
pub const GQueue = struct__GQueue;
pub extern fn g_queue_new() [*c]GQueue;
pub extern fn g_queue_free(queue: [*c]GQueue) void;
pub extern fn g_queue_free_full(queue: [*c]GQueue, free_func: GDestroyNotify) void;
pub extern fn g_queue_init(queue: [*c]GQueue) void;
pub extern fn g_queue_clear(queue: [*c]GQueue) void;
pub extern fn g_queue_is_empty(queue: [*c]GQueue) gboolean;
pub extern fn g_queue_clear_full(queue: [*c]GQueue, free_func: GDestroyNotify) void;
pub extern fn g_queue_get_length(queue: [*c]GQueue) guint;
pub extern fn g_queue_reverse(queue: [*c]GQueue) void;
pub extern fn g_queue_copy(queue: [*c]GQueue) [*c]GQueue;
pub extern fn g_queue_foreach(queue: [*c]GQueue, func: GFunc, user_data: gpointer) void;
pub extern fn g_queue_find(queue: [*c]GQueue, data: gconstpointer) [*c]GList;
pub extern fn g_queue_find_custom(queue: [*c]GQueue, data: gconstpointer, func: GCompareFunc) [*c]GList;
pub extern fn g_queue_sort(queue: [*c]GQueue, compare_func: GCompareDataFunc, user_data: gpointer) void;
pub extern fn g_queue_push_head(queue: [*c]GQueue, data: gpointer) void;
pub extern fn g_queue_push_tail(queue: [*c]GQueue, data: gpointer) void;
pub extern fn g_queue_push_nth(queue: [*c]GQueue, data: gpointer, n: gint) void;
pub extern fn g_queue_pop_head(queue: [*c]GQueue) gpointer;
pub extern fn g_queue_pop_tail(queue: [*c]GQueue) gpointer;
pub extern fn g_queue_pop_nth(queue: [*c]GQueue, n: guint) gpointer;
pub extern fn g_queue_peek_head(queue: [*c]GQueue) gpointer;
pub extern fn g_queue_peek_tail(queue: [*c]GQueue) gpointer;
pub extern fn g_queue_peek_nth(queue: [*c]GQueue, n: guint) gpointer;
pub extern fn g_queue_index(queue: [*c]GQueue, data: gconstpointer) gint;
pub extern fn g_queue_remove(queue: [*c]GQueue, data: gconstpointer) gboolean;
pub extern fn g_queue_remove_all(queue: [*c]GQueue, data: gconstpointer) guint;
pub extern fn g_queue_insert_before(queue: [*c]GQueue, sibling: [*c]GList, data: gpointer) void;
pub extern fn g_queue_insert_before_link(queue: [*c]GQueue, sibling: [*c]GList, link_: [*c]GList) void;
pub extern fn g_queue_insert_after(queue: [*c]GQueue, sibling: [*c]GList, data: gpointer) void;
pub extern fn g_queue_insert_after_link(queue: [*c]GQueue, sibling: [*c]GList, link_: [*c]GList) void;
pub extern fn g_queue_insert_sorted(queue: [*c]GQueue, data: gpointer, func: GCompareDataFunc, user_data: gpointer) void;
pub extern fn g_queue_push_head_link(queue: [*c]GQueue, link_: [*c]GList) void;
pub extern fn g_queue_push_tail_link(queue: [*c]GQueue, link_: [*c]GList) void;
pub extern fn g_queue_push_nth_link(queue: [*c]GQueue, n: gint, link_: [*c]GList) void;
pub extern fn g_queue_pop_head_link(queue: [*c]GQueue) [*c]GList;
pub extern fn g_queue_pop_tail_link(queue: [*c]GQueue) [*c]GList;
pub extern fn g_queue_pop_nth_link(queue: [*c]GQueue, n: guint) [*c]GList;
pub extern fn g_queue_peek_head_link(queue: [*c]GQueue) [*c]GList;
pub extern fn g_queue_peek_tail_link(queue: [*c]GQueue) [*c]GList;
pub extern fn g_queue_peek_nth_link(queue: [*c]GQueue, n: guint) [*c]GList;
pub extern fn g_queue_link_index(queue: [*c]GQueue, link_: [*c]GList) gint;
pub extern fn g_queue_unlink(queue: [*c]GQueue, link_: [*c]GList) void;
pub extern fn g_queue_delete_link(queue: [*c]GQueue, link_: [*c]GList) void;
pub const struct__GRand = opaque {};
pub const GRand = struct__GRand;
pub extern fn g_rand_new_with_seed(seed: guint32) ?*GRand;
pub extern fn g_rand_new_with_seed_array(seed: [*c]const guint32, seed_length: guint) ?*GRand;
pub extern fn g_rand_new() ?*GRand;
pub extern fn g_rand_free(rand_: ?*GRand) void;
pub extern fn g_rand_copy(rand_: ?*GRand) ?*GRand;
pub extern fn g_rand_set_seed(rand_: ?*GRand, seed: guint32) void;
pub extern fn g_rand_set_seed_array(rand_: ?*GRand, seed: [*c]const guint32, seed_length: guint) void;
pub extern fn g_rand_int(rand_: ?*GRand) guint32;
pub extern fn g_rand_int_range(rand_: ?*GRand, begin: gint32, end: gint32) gint32;
pub extern fn g_rand_double(rand_: ?*GRand) gdouble;
pub extern fn g_rand_double_range(rand_: ?*GRand, begin: gdouble, end: gdouble) gdouble;
pub extern fn g_random_set_seed(seed: guint32) void;
pub extern fn g_random_int() guint32;
pub extern fn g_random_int_range(begin: gint32, end: gint32) gint32;
pub extern fn g_random_double() gdouble;
pub extern fn g_random_double_range(begin: gdouble, end: gdouble) gdouble;
pub extern fn g_rc_box_alloc(block_size: gsize) gpointer;
pub extern fn g_rc_box_alloc0(block_size: gsize) gpointer;
pub extern fn g_rc_box_dup(block_size: gsize, mem_block: gconstpointer) gpointer;
pub extern fn g_rc_box_acquire(mem_block: gpointer) gpointer;
pub extern fn g_rc_box_release(mem_block: gpointer) void;
pub extern fn g_rc_box_release_full(mem_block: gpointer, clear_func: GDestroyNotify) void;
pub extern fn g_rc_box_get_size(mem_block: gpointer) gsize;
pub extern fn g_atomic_rc_box_alloc(block_size: gsize) gpointer;
pub extern fn g_atomic_rc_box_alloc0(block_size: gsize) gpointer;
pub extern fn g_atomic_rc_box_dup(block_size: gsize, mem_block: gconstpointer) gpointer;
pub extern fn g_atomic_rc_box_acquire(mem_block: gpointer) gpointer;
pub extern fn g_atomic_rc_box_release(mem_block: gpointer) void;
pub extern fn g_atomic_rc_box_release_full(mem_block: gpointer, clear_func: GDestroyNotify) void;
pub extern fn g_atomic_rc_box_get_size(mem_block: gpointer) gsize;
pub extern fn g_ref_count_init(rc: [*c]grefcount) void;
pub extern fn g_ref_count_inc(rc: [*c]grefcount) void;
pub extern fn g_ref_count_dec(rc: [*c]grefcount) gboolean;
pub extern fn g_ref_count_compare(rc: [*c]grefcount, val: gint) gboolean;
pub extern fn g_atomic_ref_count_init(arc: [*c]gatomicrefcount) void;
pub extern fn g_atomic_ref_count_inc(arc: [*c]gatomicrefcount) void;
pub extern fn g_atomic_ref_count_dec(arc: [*c]gatomicrefcount) gboolean;
pub extern fn g_atomic_ref_count_compare(arc: [*c]gatomicrefcount, val: gint) gboolean;
pub extern fn g_ref_string_new(str: [*c]const u8) [*c]u8;
pub extern fn g_ref_string_new_len(str: [*c]const u8, len: gssize) [*c]u8;
pub extern fn g_ref_string_new_intern(str: [*c]const u8) [*c]u8;
pub extern fn g_ref_string_acquire(str: [*c]u8) [*c]u8;
pub extern fn g_ref_string_release(str: [*c]u8) void;
pub extern fn g_ref_string_length(str: [*c]u8) gsize;
pub const GRefString = u8;
pub extern fn g_ref_string_equal(str1: [*c]const u8, str2: [*c]const u8) gboolean;
pub const G_REGEX_ERROR_COMPILE: c_int = 0;
pub const G_REGEX_ERROR_OPTIMIZE: c_int = 1;
pub const G_REGEX_ERROR_REPLACE: c_int = 2;
pub const G_REGEX_ERROR_MATCH: c_int = 3;
pub const G_REGEX_ERROR_INTERNAL: c_int = 4;
pub const G_REGEX_ERROR_STRAY_BACKSLASH: c_int = 101;
pub const G_REGEX_ERROR_MISSING_CONTROL_CHAR: c_int = 102;
pub const G_REGEX_ERROR_UNRECOGNIZED_ESCAPE: c_int = 103;
pub const G_REGEX_ERROR_QUANTIFIERS_OUT_OF_ORDER: c_int = 104;
pub const G_REGEX_ERROR_QUANTIFIER_TOO_BIG: c_int = 105;
pub const G_REGEX_ERROR_UNTERMINATED_CHARACTER_CLASS: c_int = 106;
pub const G_REGEX_ERROR_INVALID_ESCAPE_IN_CHARACTER_CLASS: c_int = 107;
pub const G_REGEX_ERROR_RANGE_OUT_OF_ORDER: c_int = 108;
pub const G_REGEX_ERROR_NOTHING_TO_REPEAT: c_int = 109;
pub const G_REGEX_ERROR_UNRECOGNIZED_CHARACTER: c_int = 112;
pub const G_REGEX_ERROR_POSIX_NAMED_CLASS_OUTSIDE_CLASS: c_int = 113;
pub const G_REGEX_ERROR_UNMATCHED_PARENTHESIS: c_int = 114;
pub const G_REGEX_ERROR_INEXISTENT_SUBPATTERN_REFERENCE: c_int = 115;
pub const G_REGEX_ERROR_UNTERMINATED_COMMENT: c_int = 118;
pub const G_REGEX_ERROR_EXPRESSION_TOO_LARGE: c_int = 120;
pub const G_REGEX_ERROR_MEMORY_ERROR: c_int = 121;
pub const G_REGEX_ERROR_VARIABLE_LENGTH_LOOKBEHIND: c_int = 125;
pub const G_REGEX_ERROR_MALFORMED_CONDITION: c_int = 126;
pub const G_REGEX_ERROR_TOO_MANY_CONDITIONAL_BRANCHES: c_int = 127;
pub const G_REGEX_ERROR_ASSERTION_EXPECTED: c_int = 128;
pub const G_REGEX_ERROR_UNKNOWN_POSIX_CLASS_NAME: c_int = 130;
pub const G_REGEX_ERROR_POSIX_COLLATING_ELEMENTS_NOT_SUPPORTED: c_int = 131;
pub const G_REGEX_ERROR_HEX_CODE_TOO_LARGE: c_int = 134;
pub const G_REGEX_ERROR_INVALID_CONDITION: c_int = 135;
pub const G_REGEX_ERROR_SINGLE_BYTE_MATCH_IN_LOOKBEHIND: c_int = 136;
pub const G_REGEX_ERROR_INFINITE_LOOP: c_int = 140;
pub const G_REGEX_ERROR_MISSING_SUBPATTERN_NAME_TERMINATOR: c_int = 142;
pub const G_REGEX_ERROR_DUPLICATE_SUBPATTERN_NAME: c_int = 143;
pub const G_REGEX_ERROR_MALFORMED_PROPERTY: c_int = 146;
pub const G_REGEX_ERROR_UNKNOWN_PROPERTY: c_int = 147;
pub const G_REGEX_ERROR_SUBPATTERN_NAME_TOO_LONG: c_int = 148;
pub const G_REGEX_ERROR_TOO_MANY_SUBPATTERNS: c_int = 149;
pub const G_REGEX_ERROR_INVALID_OCTAL_VALUE: c_int = 151;
pub const G_REGEX_ERROR_TOO_MANY_BRANCHES_IN_DEFINE: c_int = 154;
pub const G_REGEX_ERROR_DEFINE_REPETION: c_int = 155;
pub const G_REGEX_ERROR_INCONSISTENT_NEWLINE_OPTIONS: c_int = 156;
pub const G_REGEX_ERROR_MISSING_BACK_REFERENCE: c_int = 157;
pub const G_REGEX_ERROR_INVALID_RELATIVE_REFERENCE: c_int = 158;
pub const G_REGEX_ERROR_BACKTRACKING_CONTROL_VERB_ARGUMENT_FORBIDDEN: c_int = 159;
pub const G_REGEX_ERROR_UNKNOWN_BACKTRACKING_CONTROL_VERB: c_int = 160;
pub const G_REGEX_ERROR_NUMBER_TOO_BIG: c_int = 161;
pub const G_REGEX_ERROR_MISSING_SUBPATTERN_NAME: c_int = 162;
pub const G_REGEX_ERROR_MISSING_DIGIT: c_int = 163;
pub const G_REGEX_ERROR_INVALID_DATA_CHARACTER: c_int = 164;
pub const G_REGEX_ERROR_EXTRA_SUBPATTERN_NAME: c_int = 165;
pub const G_REGEX_ERROR_BACKTRACKING_CONTROL_VERB_ARGUMENT_REQUIRED: c_int = 166;
pub const G_REGEX_ERROR_INVALID_CONTROL_CHAR: c_int = 168;
pub const G_REGEX_ERROR_MISSING_NAME: c_int = 169;
pub const G_REGEX_ERROR_NOT_SUPPORTED_IN_CLASS: c_int = 171;
pub const G_REGEX_ERROR_TOO_MANY_FORWARD_REFERENCES: c_int = 172;
pub const G_REGEX_ERROR_NAME_TOO_LONG: c_int = 175;
pub const G_REGEX_ERROR_CHARACTER_VALUE_TOO_LARGE: c_int = 176;
pub const GRegexError = c_uint;
pub extern fn g_regex_error_quark() GQuark;
pub const G_REGEX_DEFAULT: c_int = 0;
pub const G_REGEX_CASELESS: c_int = 1;
pub const G_REGEX_MULTILINE: c_int = 2;
pub const G_REGEX_DOTALL: c_int = 4;
pub const G_REGEX_EXTENDED: c_int = 8;
pub const G_REGEX_ANCHORED: c_int = 16;
pub const G_REGEX_DOLLAR_ENDONLY: c_int = 32;
pub const G_REGEX_UNGREEDY: c_int = 512;
pub const G_REGEX_RAW: c_int = 2048;
pub const G_REGEX_NO_AUTO_CAPTURE: c_int = 4096;
pub const G_REGEX_OPTIMIZE: c_int = 8192;
pub const G_REGEX_FIRSTLINE: c_int = 262144;
pub const G_REGEX_DUPNAMES: c_int = 524288;
pub const G_REGEX_NEWLINE_CR: c_int = 1048576;
pub const G_REGEX_NEWLINE_LF: c_int = 2097152;
pub const G_REGEX_NEWLINE_CRLF: c_int = 3145728;
pub const G_REGEX_NEWLINE_ANYCRLF: c_int = 5242880;
pub const G_REGEX_BSR_ANYCRLF: c_int = 8388608;
pub const G_REGEX_JAVASCRIPT_COMPAT: c_int = 33554432;
pub const GRegexCompileFlags = c_uint;
pub const G_REGEX_MATCH_DEFAULT: c_int = 0;
pub const G_REGEX_MATCH_ANCHORED: c_int = 16;
pub const G_REGEX_MATCH_NOTBOL: c_int = 128;
pub const G_REGEX_MATCH_NOTEOL: c_int = 256;
pub const G_REGEX_MATCH_NOTEMPTY: c_int = 1024;
pub const G_REGEX_MATCH_PARTIAL: c_int = 32768;
pub const G_REGEX_MATCH_NEWLINE_CR: c_int = 1048576;
pub const G_REGEX_MATCH_NEWLINE_LF: c_int = 2097152;
pub const G_REGEX_MATCH_NEWLINE_CRLF: c_int = 3145728;
pub const G_REGEX_MATCH_NEWLINE_ANY: c_int = 4194304;
pub const G_REGEX_MATCH_NEWLINE_ANYCRLF: c_int = 5242880;
pub const G_REGEX_MATCH_BSR_ANYCRLF: c_int = 8388608;
pub const G_REGEX_MATCH_BSR_ANY: c_int = 16777216;
pub const G_REGEX_MATCH_PARTIAL_SOFT: c_int = 32768;
pub const G_REGEX_MATCH_PARTIAL_HARD: c_int = 134217728;
pub const G_REGEX_MATCH_NOTEMPTY_ATSTART: c_int = 268435456;
pub const GRegexMatchFlags = c_uint;
pub const struct__GRegex = opaque {};
pub const GRegex = struct__GRegex;
pub const struct__GMatchInfo = opaque {};
pub const GMatchInfo = struct__GMatchInfo;
pub const GRegexEvalCallback = ?*const fn (?*const GMatchInfo, [*c]GString, gpointer) callconv(.c) gboolean;
pub extern fn g_regex_new(pattern: [*c]const gchar, compile_options: GRegexCompileFlags, match_options: GRegexMatchFlags, @"error": [*c][*c]GError) ?*GRegex;
pub extern fn g_regex_ref(regex: ?*GRegex) ?*GRegex;
pub extern fn g_regex_unref(regex: ?*GRegex) void;
pub extern fn g_regex_get_pattern(regex: ?*const GRegex) [*c]const gchar;
pub extern fn g_regex_get_max_backref(regex: ?*const GRegex) gint;
pub extern fn g_regex_get_capture_count(regex: ?*const GRegex) gint;
pub extern fn g_regex_get_has_cr_or_lf(regex: ?*const GRegex) gboolean;
pub extern fn g_regex_get_max_lookbehind(regex: ?*const GRegex) gint;
pub extern fn g_regex_get_string_number(regex: ?*const GRegex, name: [*c]const gchar) gint;
pub extern fn g_regex_escape_string(string: [*c]const gchar, length: gint) [*c]gchar;
pub extern fn g_regex_escape_nul(string: [*c]const gchar, length: gint) [*c]gchar;
pub extern fn g_regex_get_compile_flags(regex: ?*const GRegex) GRegexCompileFlags;
pub extern fn g_regex_get_match_flags(regex: ?*const GRegex) GRegexMatchFlags;
pub extern fn g_regex_match_simple(pattern: [*c]const gchar, string: [*c]const gchar, compile_options: GRegexCompileFlags, match_options: GRegexMatchFlags) gboolean;
pub extern fn g_regex_match(regex: ?*const GRegex, string: [*c]const gchar, match_options: GRegexMatchFlags, match_info: [*c]?*GMatchInfo) gboolean;
pub extern fn g_regex_match_full(regex: ?*const GRegex, string: [*c]const gchar, string_len: gssize, start_position: gint, match_options: GRegexMatchFlags, match_info: [*c]?*GMatchInfo, @"error": [*c][*c]GError) gboolean;
pub extern fn g_regex_match_all(regex: ?*const GRegex, string: [*c]const gchar, match_options: GRegexMatchFlags, match_info: [*c]?*GMatchInfo) gboolean;
pub extern fn g_regex_match_all_full(regex: ?*const GRegex, string: [*c]const gchar, string_len: gssize, start_position: gint, match_options: GRegexMatchFlags, match_info: [*c]?*GMatchInfo, @"error": [*c][*c]GError) gboolean;
pub extern fn g_regex_split_simple(pattern: [*c]const gchar, string: [*c]const gchar, compile_options: GRegexCompileFlags, match_options: GRegexMatchFlags) [*c][*c]gchar;
pub extern fn g_regex_split(regex: ?*const GRegex, string: [*c]const gchar, match_options: GRegexMatchFlags) [*c][*c]gchar;
pub extern fn g_regex_split_full(regex: ?*const GRegex, string: [*c]const gchar, string_len: gssize, start_position: gint, match_options: GRegexMatchFlags, max_tokens: gint, @"error": [*c][*c]GError) [*c][*c]gchar;
pub extern fn g_regex_replace(regex: ?*const GRegex, string: [*c]const gchar, string_len: gssize, start_position: gint, replacement: [*c]const gchar, match_options: GRegexMatchFlags, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_regex_replace_literal(regex: ?*const GRegex, string: [*c]const gchar, string_len: gssize, start_position: gint, replacement: [*c]const gchar, match_options: GRegexMatchFlags, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_regex_replace_eval(regex: ?*const GRegex, string: [*c]const gchar, string_len: gssize, start_position: gint, match_options: GRegexMatchFlags, eval: GRegexEvalCallback, user_data: gpointer, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_regex_check_replacement(replacement: [*c]const gchar, has_references: [*c]gboolean, @"error": [*c][*c]GError) gboolean;
pub extern fn g_match_info_get_regex(match_info: ?*const GMatchInfo) ?*GRegex;
pub extern fn g_match_info_get_string(match_info: ?*const GMatchInfo) [*c]const gchar;
pub extern fn g_match_info_ref(match_info: ?*GMatchInfo) ?*GMatchInfo;
pub extern fn g_match_info_unref(match_info: ?*GMatchInfo) void;
pub extern fn g_match_info_free(match_info: ?*GMatchInfo) void;
pub extern fn g_match_info_next(match_info: ?*GMatchInfo, @"error": [*c][*c]GError) gboolean;
pub extern fn g_match_info_matches(match_info: ?*const GMatchInfo) gboolean;
pub extern fn g_match_info_get_match_count(match_info: ?*const GMatchInfo) gint;
pub extern fn g_match_info_is_partial_match(match_info: ?*const GMatchInfo) gboolean;
pub extern fn g_match_info_expand_references(match_info: ?*const GMatchInfo, string_to_expand: [*c]const gchar, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_match_info_fetch(match_info: ?*const GMatchInfo, match_num: gint) [*c]gchar;
pub extern fn g_match_info_fetch_pos(match_info: ?*const GMatchInfo, match_num: gint, start_pos: [*c]gint, end_pos: [*c]gint) gboolean;
pub extern fn g_match_info_fetch_named(match_info: ?*const GMatchInfo, name: [*c]const gchar) [*c]gchar;
pub extern fn g_match_info_fetch_named_pos(match_info: ?*const GMatchInfo, name: [*c]const gchar, start_pos: [*c]gint, end_pos: [*c]gint) gboolean;
pub extern fn g_match_info_fetch_all(match_info: ?*const GMatchInfo) [*c][*c]gchar;
// /usr/include/glib-2.0/glib/gscanner.h:140:10: warning: struct demoted to opaque type - has bitfield
pub const struct__GScannerConfig = opaque {};
pub const GScannerConfig = struct__GScannerConfig;
pub const union__GTokenValue = extern union {
    v_symbol: gpointer,
    v_identifier: [*c]gchar,
    v_binary: gulong,
    v_octal: gulong,
    v_int: gulong,
    v_int64: guint64,
    v_float: gdouble,
    v_hex: gulong,
    v_string: [*c]gchar,
    v_comment: [*c]gchar,
    v_char: guchar,
    v_error: guint,
};
pub const GTokenValue = union__GTokenValue;
pub const GScanner = struct__GScanner;
pub const GScannerMsgFunc = ?*const fn ([*c]GScanner, [*c]gchar, gboolean) callconv(.c) void;
pub const struct__GScanner = extern struct {
    user_data: gpointer = @import("std").mem.zeroes(gpointer),
    max_parse_errors: guint = @import("std").mem.zeroes(guint),
    parse_errors: guint = @import("std").mem.zeroes(guint),
    input_name: [*c]const gchar = @import("std").mem.zeroes([*c]const gchar),
    qdata: ?*GData = @import("std").mem.zeroes(?*GData),
    config: ?*GScannerConfig = @import("std").mem.zeroes(?*GScannerConfig),
    token: GTokenType = @import("std").mem.zeroes(GTokenType),
    value: GTokenValue = @import("std").mem.zeroes(GTokenValue),
    line: guint = @import("std").mem.zeroes(guint),
    position: guint = @import("std").mem.zeroes(guint),
    next_token: GTokenType = @import("std").mem.zeroes(GTokenType),
    next_value: GTokenValue = @import("std").mem.zeroes(GTokenValue),
    next_line: guint = @import("std").mem.zeroes(guint),
    next_position: guint = @import("std").mem.zeroes(guint),
    symbol_table: ?*GHashTable = @import("std").mem.zeroes(?*GHashTable),
    input_fd: gint = @import("std").mem.zeroes(gint),
    text: [*c]const gchar = @import("std").mem.zeroes([*c]const gchar),
    text_end: [*c]const gchar = @import("std").mem.zeroes([*c]const gchar),
    buffer: [*c]gchar = @import("std").mem.zeroes([*c]gchar),
    scope_id: guint = @import("std").mem.zeroes(guint),
    msg_handler: GScannerMsgFunc = @import("std").mem.zeroes(GScannerMsgFunc),
};
pub const G_ERR_UNKNOWN: c_int = 0;
pub const G_ERR_UNEXP_EOF: c_int = 1;
pub const G_ERR_UNEXP_EOF_IN_STRING: c_int = 2;
pub const G_ERR_UNEXP_EOF_IN_COMMENT: c_int = 3;
pub const G_ERR_NON_DIGIT_IN_CONST: c_int = 4;
pub const G_ERR_DIGIT_RADIX: c_int = 5;
pub const G_ERR_FLOAT_RADIX: c_int = 6;
pub const G_ERR_FLOAT_MALFORMED: c_int = 7;
pub const GErrorType = c_uint;
pub const G_TOKEN_EOF: c_int = 0;
pub const G_TOKEN_LEFT_PAREN: c_int = 40;
pub const G_TOKEN_RIGHT_PAREN: c_int = 41;
pub const G_TOKEN_LEFT_CURLY: c_int = 123;
pub const G_TOKEN_RIGHT_CURLY: c_int = 125;
pub const G_TOKEN_LEFT_BRACE: c_int = 91;
pub const G_TOKEN_RIGHT_BRACE: c_int = 93;
pub const G_TOKEN_EQUAL_SIGN: c_int = 61;
pub const G_TOKEN_COMMA: c_int = 44;
pub const G_TOKEN_NONE: c_int = 256;
pub const G_TOKEN_ERROR: c_int = 257;
pub const G_TOKEN_CHAR: c_int = 258;
pub const G_TOKEN_BINARY: c_int = 259;
pub const G_TOKEN_OCTAL: c_int = 260;
pub const G_TOKEN_INT: c_int = 261;
pub const G_TOKEN_HEX: c_int = 262;
pub const G_TOKEN_FLOAT: c_int = 263;
pub const G_TOKEN_STRING: c_int = 264;
pub const G_TOKEN_SYMBOL: c_int = 265;
pub const G_TOKEN_IDENTIFIER: c_int = 266;
pub const G_TOKEN_IDENTIFIER_NULL: c_int = 267;
pub const G_TOKEN_COMMENT_SINGLE: c_int = 268;
pub const G_TOKEN_COMMENT_MULTI: c_int = 269;
pub const G_TOKEN_LAST: c_int = 270;
pub const GTokenType = c_uint;
pub extern fn g_scanner_new(config_templ: ?*const GScannerConfig) [*c]GScanner;
pub extern fn g_scanner_destroy(scanner: [*c]GScanner) void;
pub extern fn g_scanner_input_file(scanner: [*c]GScanner, input_fd: gint) void;
pub extern fn g_scanner_sync_file_offset(scanner: [*c]GScanner) void;
pub extern fn g_scanner_input_text(scanner: [*c]GScanner, text: [*c]const gchar, text_len: guint) void;
pub extern fn g_scanner_get_next_token(scanner: [*c]GScanner) GTokenType;
pub extern fn g_scanner_peek_next_token(scanner: [*c]GScanner) GTokenType;
pub extern fn g_scanner_cur_token(scanner: [*c]GScanner) GTokenType;
pub extern fn g_scanner_cur_value(scanner: [*c]GScanner) GTokenValue;
pub extern fn g_scanner_cur_line(scanner: [*c]GScanner) guint;
pub extern fn g_scanner_cur_position(scanner: [*c]GScanner) guint;
pub extern fn g_scanner_eof(scanner: [*c]GScanner) gboolean;
pub extern fn g_scanner_set_scope(scanner: [*c]GScanner, scope_id: guint) guint;
pub extern fn g_scanner_scope_add_symbol(scanner: [*c]GScanner, scope_id: guint, symbol: [*c]const gchar, value: gpointer) void;
pub extern fn g_scanner_scope_remove_symbol(scanner: [*c]GScanner, scope_id: guint, symbol: [*c]const gchar) void;
pub extern fn g_scanner_scope_lookup_symbol(scanner: [*c]GScanner, scope_id: guint, symbol: [*c]const gchar) gpointer;
pub extern fn g_scanner_scope_foreach_symbol(scanner: [*c]GScanner, scope_id: guint, func: GHFunc, user_data: gpointer) void;
pub extern fn g_scanner_lookup_symbol(scanner: [*c]GScanner, symbol: [*c]const gchar) gpointer;
pub extern fn g_scanner_unexp_token(scanner: [*c]GScanner, expected_token: GTokenType, identifier_spec: [*c]const gchar, symbol_spec: [*c]const gchar, symbol_name: [*c]const gchar, message: [*c]const gchar, is_error: gint) void;
pub extern fn g_scanner_error(scanner: [*c]GScanner, format: [*c]const gchar, ...) void;
pub extern fn g_scanner_warn(scanner: [*c]GScanner, format: [*c]const gchar, ...) void;
pub const struct__GSequence = opaque {};
pub const GSequence = struct__GSequence;
pub const struct__GSequenceNode = opaque {};
pub const GSequenceIter = struct__GSequenceNode;
pub const GSequenceIterCompareFunc = ?*const fn (?*GSequenceIter, ?*GSequenceIter, gpointer) callconv(.c) gint;
pub extern fn g_sequence_new(data_destroy: GDestroyNotify) ?*GSequence;
pub extern fn g_sequence_free(seq: ?*GSequence) void;
pub extern fn g_sequence_get_length(seq: ?*GSequence) gint;
pub extern fn g_sequence_foreach(seq: ?*GSequence, func: GFunc, user_data: gpointer) void;
pub extern fn g_sequence_foreach_range(begin: ?*GSequenceIter, end: ?*GSequenceIter, func: GFunc, user_data: gpointer) void;
pub extern fn g_sequence_sort(seq: ?*GSequence, cmp_func: GCompareDataFunc, cmp_data: gpointer) void;
pub extern fn g_sequence_sort_iter(seq: ?*GSequence, cmp_func: GSequenceIterCompareFunc, cmp_data: gpointer) void;
pub extern fn g_sequence_is_empty(seq: ?*GSequence) gboolean;
pub extern fn g_sequence_get_begin_iter(seq: ?*GSequence) ?*GSequenceIter;
pub extern fn g_sequence_get_end_iter(seq: ?*GSequence) ?*GSequenceIter;
pub extern fn g_sequence_get_iter_at_pos(seq: ?*GSequence, pos: gint) ?*GSequenceIter;
pub extern fn g_sequence_append(seq: ?*GSequence, data: gpointer) ?*GSequenceIter;
pub extern fn g_sequence_prepend(seq: ?*GSequence, data: gpointer) ?*GSequenceIter;
pub extern fn g_sequence_insert_before(iter: ?*GSequenceIter, data: gpointer) ?*GSequenceIter;
pub extern fn g_sequence_move(src: ?*GSequenceIter, dest: ?*GSequenceIter) void;
pub extern fn g_sequence_swap(a: ?*GSequenceIter, b: ?*GSequenceIter) void;
pub extern fn g_sequence_insert_sorted(seq: ?*GSequence, data: gpointer, cmp_func: GCompareDataFunc, cmp_data: gpointer) ?*GSequenceIter;
pub extern fn g_sequence_insert_sorted_iter(seq: ?*GSequence, data: gpointer, iter_cmp: GSequenceIterCompareFunc, cmp_data: gpointer) ?*GSequenceIter;
pub extern fn g_sequence_sort_changed(iter: ?*GSequenceIter, cmp_func: GCompareDataFunc, cmp_data: gpointer) void;
pub extern fn g_sequence_sort_changed_iter(iter: ?*GSequenceIter, iter_cmp: GSequenceIterCompareFunc, cmp_data: gpointer) void;
pub extern fn g_sequence_remove(iter: ?*GSequenceIter) void;
pub extern fn g_sequence_remove_range(begin: ?*GSequenceIter, end: ?*GSequenceIter) void;
pub extern fn g_sequence_move_range(dest: ?*GSequenceIter, begin: ?*GSequenceIter, end: ?*GSequenceIter) void;
pub extern fn g_sequence_search(seq: ?*GSequence, data: gpointer, cmp_func: GCompareDataFunc, cmp_data: gpointer) ?*GSequenceIter;
pub extern fn g_sequence_search_iter(seq: ?*GSequence, data: gpointer, iter_cmp: GSequenceIterCompareFunc, cmp_data: gpointer) ?*GSequenceIter;
pub extern fn g_sequence_lookup(seq: ?*GSequence, data: gpointer, cmp_func: GCompareDataFunc, cmp_data: gpointer) ?*GSequenceIter;
pub extern fn g_sequence_lookup_iter(seq: ?*GSequence, data: gpointer, iter_cmp: GSequenceIterCompareFunc, cmp_data: gpointer) ?*GSequenceIter;
pub extern fn g_sequence_get(iter: ?*GSequenceIter) gpointer;
pub extern fn g_sequence_set(iter: ?*GSequenceIter, data: gpointer) void;
pub extern fn g_sequence_iter_is_begin(iter: ?*GSequenceIter) gboolean;
pub extern fn g_sequence_iter_is_end(iter: ?*GSequenceIter) gboolean;
pub extern fn g_sequence_iter_next(iter: ?*GSequenceIter) ?*GSequenceIter;
pub extern fn g_sequence_iter_prev(iter: ?*GSequenceIter) ?*GSequenceIter;
pub extern fn g_sequence_iter_get_position(iter: ?*GSequenceIter) gint;
pub extern fn g_sequence_iter_move(iter: ?*GSequenceIter, delta: gint) ?*GSequenceIter;
pub extern fn g_sequence_iter_get_sequence(iter: ?*GSequenceIter) ?*GSequence;
pub extern fn g_sequence_iter_compare(a: ?*GSequenceIter, b: ?*GSequenceIter) gint;
pub extern fn g_sequence_range_get_midpoint(begin: ?*GSequenceIter, end: ?*GSequenceIter) ?*GSequenceIter;
pub const G_SHELL_ERROR_BAD_QUOTING: c_int = 0;
pub const G_SHELL_ERROR_EMPTY_STRING: c_int = 1;
pub const G_SHELL_ERROR_FAILED: c_int = 2;
pub const GShellError = c_uint;
pub extern fn g_shell_error_quark() GQuark;
pub extern fn g_shell_quote(unquoted_string: [*c]const gchar) [*c]gchar;
pub extern fn g_shell_unquote(quoted_string: [*c]const gchar, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_shell_parse_argv(command_line: [*c]const gchar, argcp: [*c]gint, argvp: [*c][*c][*c]gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_slice_alloc(block_size: gsize) gpointer;
pub extern fn g_slice_alloc0(block_size: gsize) gpointer;
pub extern fn g_slice_copy(block_size: gsize, mem_block: gconstpointer) gpointer;
pub extern fn g_slice_free1(block_size: gsize, mem_block: gpointer) void;
pub extern fn g_slice_free_chain_with_offset(block_size: gsize, mem_chain: gpointer, next_offset: gsize) void;
pub const G_SLICE_CONFIG_ALWAYS_MALLOC: c_int = 1;
pub const G_SLICE_CONFIG_BYPASS_MAGAZINES: c_int = 2;
pub const G_SLICE_CONFIG_WORKING_SET_MSECS: c_int = 3;
pub const G_SLICE_CONFIG_COLOR_INCREMENT: c_int = 4;
pub const G_SLICE_CONFIG_CHUNK_SIZES: c_int = 5;
pub const G_SLICE_CONFIG_CONTENTION_COUNTER: c_int = 6;
pub const GSliceConfig = c_uint;
pub extern fn g_slice_set_config(ckey: GSliceConfig, value: gint64) void;
pub extern fn g_slice_get_config(ckey: GSliceConfig) gint64;
pub extern fn g_slice_get_config_state(ckey: GSliceConfig, address: gint64, n_values: [*c]guint) [*c]gint64;
pub const G_SPAWN_ERROR_FORK: c_int = 0;
pub const G_SPAWN_ERROR_READ: c_int = 1;
pub const G_SPAWN_ERROR_CHDIR: c_int = 2;
pub const G_SPAWN_ERROR_ACCES: c_int = 3;
pub const G_SPAWN_ERROR_PERM: c_int = 4;
pub const G_SPAWN_ERROR_TOO_BIG: c_int = 5;
pub const G_SPAWN_ERROR_2BIG: c_int = 5;
pub const G_SPAWN_ERROR_NOEXEC: c_int = 6;
pub const G_SPAWN_ERROR_NAMETOOLONG: c_int = 7;
pub const G_SPAWN_ERROR_NOENT: c_int = 8;
pub const G_SPAWN_ERROR_NOMEM: c_int = 9;
pub const G_SPAWN_ERROR_NOTDIR: c_int = 10;
pub const G_SPAWN_ERROR_LOOP: c_int = 11;
pub const G_SPAWN_ERROR_TXTBUSY: c_int = 12;
pub const G_SPAWN_ERROR_IO: c_int = 13;
pub const G_SPAWN_ERROR_NFILE: c_int = 14;
pub const G_SPAWN_ERROR_MFILE: c_int = 15;
pub const G_SPAWN_ERROR_INVAL: c_int = 16;
pub const G_SPAWN_ERROR_ISDIR: c_int = 17;
pub const G_SPAWN_ERROR_LIBBAD: c_int = 18;
pub const G_SPAWN_ERROR_FAILED: c_int = 19;
pub const GSpawnError = c_uint;
pub const GSpawnChildSetupFunc = ?*const fn (gpointer) callconv(.c) void;
pub const G_SPAWN_DEFAULT: c_int = 0;
pub const G_SPAWN_LEAVE_DESCRIPTORS_OPEN: c_int = 1;
pub const G_SPAWN_DO_NOT_REAP_CHILD: c_int = 2;
pub const G_SPAWN_SEARCH_PATH: c_int = 4;
pub const G_SPAWN_STDOUT_TO_DEV_NULL: c_int = 8;
pub const G_SPAWN_STDERR_TO_DEV_NULL: c_int = 16;
pub const G_SPAWN_CHILD_INHERITS_STDIN: c_int = 32;
pub const G_SPAWN_FILE_AND_ARGV_ZERO: c_int = 64;
pub const G_SPAWN_SEARCH_PATH_FROM_ENVP: c_int = 128;
pub const G_SPAWN_CLOEXEC_PIPES: c_int = 256;
pub const G_SPAWN_CHILD_INHERITS_STDOUT: c_int = 512;
pub const G_SPAWN_CHILD_INHERITS_STDERR: c_int = 1024;
pub const G_SPAWN_STDIN_FROM_DEV_NULL: c_int = 2048;
pub const GSpawnFlags = c_uint;
pub extern fn g_spawn_error_quark() GQuark;
pub extern fn g_spawn_exit_error_quark() GQuark;
pub extern fn g_spawn_async(working_directory: [*c]const gchar, argv: [*c][*c]gchar, envp: [*c][*c]gchar, flags: GSpawnFlags, child_setup: GSpawnChildSetupFunc, user_data: gpointer, child_pid: [*c]GPid, @"error": [*c][*c]GError) gboolean;
pub extern fn g_spawn_async_with_pipes(working_directory: [*c]const gchar, argv: [*c][*c]gchar, envp: [*c][*c]gchar, flags: GSpawnFlags, child_setup: GSpawnChildSetupFunc, user_data: gpointer, child_pid: [*c]GPid, standard_input: [*c]gint, standard_output: [*c]gint, standard_error: [*c]gint, @"error": [*c][*c]GError) gboolean;
pub extern fn g_spawn_async_with_pipes_and_fds(working_directory: [*c]const gchar, argv: [*c]const [*c]const gchar, envp: [*c]const [*c]const gchar, flags: GSpawnFlags, child_setup: GSpawnChildSetupFunc, user_data: gpointer, stdin_fd: gint, stdout_fd: gint, stderr_fd: gint, source_fds: [*c]const gint, target_fds: [*c]const gint, n_fds: gsize, child_pid_out: [*c]GPid, stdin_pipe_out: [*c]gint, stdout_pipe_out: [*c]gint, stderr_pipe_out: [*c]gint, @"error": [*c][*c]GError) gboolean;
pub extern fn g_spawn_async_with_fds(working_directory: [*c]const gchar, argv: [*c][*c]gchar, envp: [*c][*c]gchar, flags: GSpawnFlags, child_setup: GSpawnChildSetupFunc, user_data: gpointer, child_pid: [*c]GPid, stdin_fd: gint, stdout_fd: gint, stderr_fd: gint, @"error": [*c][*c]GError) gboolean;
pub extern fn g_spawn_sync(working_directory: [*c]const gchar, argv: [*c][*c]gchar, envp: [*c][*c]gchar, flags: GSpawnFlags, child_setup: GSpawnChildSetupFunc, user_data: gpointer, standard_output: [*c][*c]gchar, standard_error: [*c][*c]gchar, wait_status: [*c]gint, @"error": [*c][*c]GError) gboolean;
pub extern fn g_spawn_command_line_sync(command_line: [*c]const gchar, standard_output: [*c][*c]gchar, standard_error: [*c][*c]gchar, wait_status: [*c]gint, @"error": [*c][*c]GError) gboolean;
pub extern fn g_spawn_command_line_async(command_line: [*c]const gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_spawn_check_wait_status(wait_status: gint, @"error": [*c][*c]GError) gboolean;
pub extern fn g_spawn_check_exit_status(wait_status: gint, @"error": [*c][*c]GError) gboolean;
pub extern fn g_spawn_close_pid(pid: GPid) void;
pub const struct__GStringChunk = opaque {};
pub const GStringChunk = struct__GStringChunk;
pub extern fn g_string_chunk_new(size: gsize) ?*GStringChunk;
pub extern fn g_string_chunk_free(chunk: ?*GStringChunk) void;
pub extern fn g_string_chunk_clear(chunk: ?*GStringChunk) void;
pub extern fn g_string_chunk_insert(chunk: ?*GStringChunk, string: [*c]const gchar) [*c]gchar;
pub extern fn g_string_chunk_insert_len(chunk: ?*GStringChunk, string: [*c]const gchar, len: gssize) [*c]gchar;
pub extern fn g_string_chunk_insert_const(chunk: ?*GStringChunk, string: [*c]const gchar) [*c]gchar;
pub const struct__GStrvBuilder = opaque {};
pub const GStrvBuilder = struct__GStrvBuilder;
pub extern fn g_strv_builder_new() ?*GStrvBuilder;
pub extern fn g_strv_builder_unref(builder: ?*GStrvBuilder) void;
pub extern fn g_strv_builder_unref_to_strv(builder: ?*GStrvBuilder) GStrv;
pub extern fn g_strv_builder_ref(builder: ?*GStrvBuilder) ?*GStrvBuilder;
pub extern fn g_strv_builder_add(builder: ?*GStrvBuilder, value: [*c]const u8) void;
pub extern fn g_strv_builder_addv(builder: ?*GStrvBuilder, value: [*c][*c]const u8) void;
pub extern fn g_strv_builder_add_many(builder: ?*GStrvBuilder, ...) void;
pub extern fn g_strv_builder_take(builder: ?*GStrvBuilder, value: [*c]u8) void;
pub extern fn g_strv_builder_end(builder: ?*GStrvBuilder) GStrv;
pub extern fn __errno_location() [*c]c_int;
pub const struct_GTestCase = opaque {};
pub const GTestCase = struct_GTestCase;
pub const struct_GTestSuite = opaque {};
pub const GTestSuite = struct_GTestSuite;
pub const GTestFunc = ?*const fn () callconv(.c) void;
pub const GTestDataFunc = ?*const fn (gconstpointer) callconv(.c) void;
pub const GTestFixtureFunc = ?*const fn (gpointer, gconstpointer) callconv(.c) void;
pub extern fn g_strcmp0(str1: [*c]const u8, str2: [*c]const u8) c_int;
pub extern fn g_test_minimized_result(minimized_quantity: f64, format: [*c]const u8, ...) void;
pub extern fn g_test_maximized_result(maximized_quantity: f64, format: [*c]const u8, ...) void;
pub extern fn g_test_init(argc: [*c]c_int, argv: [*c][*c][*c]u8, ...) void;
pub extern fn g_test_subprocess() gboolean;
pub extern fn g_test_run() c_int;
pub extern fn g_test_add_func(testpath: [*c]const u8, test_func: GTestFunc) void;
pub extern fn g_test_add_data_func(testpath: [*c]const u8, test_data: gconstpointer, test_func: GTestDataFunc) void;
pub extern fn g_test_add_data_func_full(testpath: [*c]const u8, test_data: gpointer, test_func: GTestDataFunc, data_free_func: GDestroyNotify) void;
pub extern fn g_test_get_path() [*c]const u8;
pub extern fn g_test_fail() void;
pub extern fn g_test_fail_printf(format: [*c]const u8, ...) void;
pub extern fn g_test_incomplete(msg: [*c]const gchar) void;
pub extern fn g_test_incomplete_printf(format: [*c]const u8, ...) void;
pub extern fn g_test_skip(msg: [*c]const gchar) void;
pub extern fn g_test_skip_printf(format: [*c]const u8, ...) void;
pub extern fn g_test_failed() gboolean;
pub extern fn g_test_set_nonfatal_assertions() void;
pub extern fn g_test_disable_crash_reporting() void;
pub extern fn g_test_message(format: [*c]const u8, ...) void;
pub extern fn g_test_bug_base(uri_pattern: [*c]const u8) void;
pub extern fn g_test_bug(bug_uri_snippet: [*c]const u8) void;
pub extern fn g_test_summary(summary: [*c]const u8) void;
pub extern fn g_test_timer_start() void;
pub extern fn g_test_timer_elapsed() f64;
pub extern fn g_test_timer_last() f64;
pub extern fn g_test_queue_free(gfree_pointer: gpointer) void;
pub extern fn g_test_queue_destroy(destroy_func: GDestroyNotify, destroy_data: gpointer) void;
pub const G_TEST_TRAP_DEFAULT: c_int = 0;
pub const G_TEST_TRAP_SILENCE_STDOUT: c_int = 128;
pub const G_TEST_TRAP_SILENCE_STDERR: c_int = 256;
pub const G_TEST_TRAP_INHERIT_STDIN: c_int = 512;
pub const GTestTrapFlags = c_uint;
pub extern fn g_test_trap_fork(usec_timeout: guint64, test_trap_flags: GTestTrapFlags) gboolean;
pub const G_TEST_SUBPROCESS_DEFAULT: c_int = 0;
pub const G_TEST_SUBPROCESS_INHERIT_STDIN: c_int = 1;
pub const G_TEST_SUBPROCESS_INHERIT_STDOUT: c_int = 2;
pub const G_TEST_SUBPROCESS_INHERIT_STDERR: c_int = 4;
pub const GTestSubprocessFlags = c_uint;
pub extern fn g_test_trap_subprocess(test_path: [*c]const u8, usec_timeout: guint64, test_flags: GTestSubprocessFlags) void;
pub extern fn g_test_trap_subprocess_with_envp(test_path: [*c]const u8, envp: [*c]const [*c]const u8, usec_timeout: guint64, test_flags: GTestSubprocessFlags) void;
pub extern fn g_test_trap_has_passed() gboolean;
pub extern fn g_test_trap_reached_timeout() gboolean;
pub extern fn g_test_rand_int() gint32;
pub extern fn g_test_rand_int_range(begin: gint32, end: gint32) gint32;
pub extern fn g_test_rand_double() f64;
pub extern fn g_test_rand_double_range(range_start: f64, range_end: f64) f64;
pub extern fn g_test_create_case(test_name: [*c]const u8, data_size: gsize, test_data: gconstpointer, data_setup: GTestFixtureFunc, data_test: GTestFixtureFunc, data_teardown: GTestFixtureFunc) ?*GTestCase;
pub extern fn g_test_create_suite(suite_name: [*c]const u8) ?*GTestSuite;
pub extern fn g_test_get_root() ?*GTestSuite;
pub extern fn g_test_suite_add(suite: ?*GTestSuite, test_case: ?*GTestCase) void;
pub extern fn g_test_suite_add_suite(suite: ?*GTestSuite, nestedsuite: ?*GTestSuite) void;
pub extern fn g_test_run_suite(suite: ?*GTestSuite) c_int;
pub extern fn g_test_case_free(test_case: ?*GTestCase) void;
pub extern fn g_test_suite_free(suite: ?*GTestSuite) void;
pub extern fn g_test_trap_assertions(domain: [*c]const u8, file: [*c]const u8, line: c_int, func: [*c]const u8, assertion_flags: guint64, pattern: [*c]const u8) void;
pub extern fn g_assertion_message(domain: [*c]const u8, file: [*c]const u8, line: c_int, func: [*c]const u8, message: [*c]const u8) void;
pub extern fn g_assertion_message_expr(domain: [*c]const u8, file: [*c]const u8, line: c_int, func: [*c]const u8, expr: [*c]const u8) noreturn;
pub extern fn g_assertion_message_cmpstr(domain: [*c]const u8, file: [*c]const u8, line: c_int, func: [*c]const u8, expr: [*c]const u8, arg1: [*c]const u8, cmp: [*c]const u8, arg2: [*c]const u8) void;
pub extern fn g_assertion_message_cmpstrv(domain: [*c]const u8, file: [*c]const u8, line: c_int, func: [*c]const u8, expr: [*c]const u8, arg1: [*c]const [*c]const u8, arg2: [*c]const [*c]const u8, first_wrong_idx: gsize) void;
pub extern fn g_assertion_message_cmpint(domain: [*c]const u8, file: [*c]const u8, line: c_int, func: [*c]const u8, expr: [*c]const u8, arg1: guint64, cmp: [*c]const u8, arg2: guint64, numtype: u8) void;
pub extern fn g_assertion_message_cmpnum(domain: [*c]const u8, file: [*c]const u8, line: c_int, func: [*c]const u8, expr: [*c]const u8, arg1: c_longdouble, cmp: [*c]const u8, arg2: c_longdouble, numtype: u8) void;
pub extern fn g_assertion_message_error(domain: [*c]const u8, file: [*c]const u8, line: c_int, func: [*c]const u8, expr: [*c]const u8, @"error": [*c]const GError, error_domain: GQuark, error_code: c_int) void;
pub extern fn g_test_add_vtable(testpath: [*c]const u8, data_size: gsize, test_data: gconstpointer, data_setup: GTestFixtureFunc, data_test: GTestFixtureFunc, data_teardown: GTestFixtureFunc) void;
pub const GTestConfig = extern struct {
    test_initialized: gboolean = @import("std").mem.zeroes(gboolean),
    test_quick: gboolean = @import("std").mem.zeroes(gboolean),
    test_perf: gboolean = @import("std").mem.zeroes(gboolean),
    test_verbose: gboolean = @import("std").mem.zeroes(gboolean),
    test_quiet: gboolean = @import("std").mem.zeroes(gboolean),
    test_undefined: gboolean = @import("std").mem.zeroes(gboolean),
};
pub extern const g_test_config_vars: [*c]const GTestConfig;
pub const G_TEST_RUN_SUCCESS: c_int = 0;
pub const G_TEST_RUN_SKIPPED: c_int = 1;
pub const G_TEST_RUN_FAILURE: c_int = 2;
pub const G_TEST_RUN_INCOMPLETE: c_int = 3;
pub const GTestResult = c_uint;
pub const G_TEST_LOG_NONE: c_int = 0;
pub const G_TEST_LOG_ERROR: c_int = 1;
pub const G_TEST_LOG_START_BINARY: c_int = 2;
pub const G_TEST_LOG_LIST_CASE: c_int = 3;
pub const G_TEST_LOG_SKIP_CASE: c_int = 4;
pub const G_TEST_LOG_START_CASE: c_int = 5;
pub const G_TEST_LOG_STOP_CASE: c_int = 6;
pub const G_TEST_LOG_MIN_RESULT: c_int = 7;
pub const G_TEST_LOG_MAX_RESULT: c_int = 8;
pub const G_TEST_LOG_MESSAGE: c_int = 9;
pub const G_TEST_LOG_START_SUITE: c_int = 10;
pub const G_TEST_LOG_STOP_SUITE: c_int = 11;
pub const GTestLogType = c_uint;
pub const GTestLogMsg = extern struct {
    log_type: GTestLogType = @import("std").mem.zeroes(GTestLogType),
    n_strings: guint = @import("std").mem.zeroes(guint),
    strings: [*c][*c]gchar = @import("std").mem.zeroes([*c][*c]gchar),
    n_nums: guint = @import("std").mem.zeroes(guint),
    nums: [*c]c_longdouble = @import("std").mem.zeroes([*c]c_longdouble),
};
pub const GTestLogBuffer = extern struct {
    data: [*c]GString = @import("std").mem.zeroes([*c]GString),
    msgs: [*c]GSList = @import("std").mem.zeroes([*c]GSList),
};
pub extern fn g_test_log_type_name(log_type: GTestLogType) [*c]const u8;
pub extern fn g_test_log_buffer_new() [*c]GTestLogBuffer;
pub extern fn g_test_log_buffer_free(tbuffer: [*c]GTestLogBuffer) void;
pub extern fn g_test_log_buffer_push(tbuffer: [*c]GTestLogBuffer, n_bytes: guint, bytes: [*c]const guint8) void;
pub extern fn g_test_log_buffer_pop(tbuffer: [*c]GTestLogBuffer) [*c]GTestLogMsg;
pub extern fn g_test_log_msg_free(tmsg: [*c]GTestLogMsg) void;
pub const GTestLogFatalFunc = ?*const fn ([*c]const gchar, GLogLevelFlags, [*c]const gchar, gpointer) callconv(.c) gboolean;
pub extern fn g_test_log_set_fatal_handler(log_func: GTestLogFatalFunc, user_data: gpointer) void;
pub extern fn g_test_expect_message(log_domain: [*c]const gchar, log_level: GLogLevelFlags, pattern: [*c]const gchar) void;
pub extern fn g_test_assert_expected_messages_internal(domain: [*c]const u8, file: [*c]const u8, line: c_int, func: [*c]const u8) void;
pub const G_TEST_DIST: c_int = 0;
pub const G_TEST_BUILT: c_int = 1;
pub const GTestFileType = c_uint;
pub extern fn g_test_build_filename(file_type: GTestFileType, first_path: [*c]const gchar, ...) [*c]gchar;
pub extern fn g_test_get_dir(file_type: GTestFileType) [*c]const gchar;
pub extern fn g_test_get_filename(file_type: GTestFileType, first_path: [*c]const gchar, ...) [*c]const gchar;
pub const struct__GThreadPool = extern struct {
    func: GFunc = @import("std").mem.zeroes(GFunc),
    user_data: gpointer = @import("std").mem.zeroes(gpointer),
    exclusive: gboolean = @import("std").mem.zeroes(gboolean),
};
pub const GThreadPool = struct__GThreadPool;
pub extern fn g_thread_pool_new(func: GFunc, user_data: gpointer, max_threads: gint, exclusive: gboolean, @"error": [*c][*c]GError) [*c]GThreadPool;
pub extern fn g_thread_pool_new_full(func: GFunc, user_data: gpointer, item_free_func: GDestroyNotify, max_threads: gint, exclusive: gboolean, @"error": [*c][*c]GError) [*c]GThreadPool;
pub extern fn g_thread_pool_free(pool: [*c]GThreadPool, immediate: gboolean, wait_: gboolean) void;
pub extern fn g_thread_pool_push(pool: [*c]GThreadPool, data: gpointer, @"error": [*c][*c]GError) gboolean;
pub extern fn g_thread_pool_unprocessed(pool: [*c]GThreadPool) guint;
pub extern fn g_thread_pool_set_sort_function(pool: [*c]GThreadPool, func: GCompareDataFunc, user_data: gpointer) void;
pub extern fn g_thread_pool_move_to_front(pool: [*c]GThreadPool, data: gpointer) gboolean;
pub extern fn g_thread_pool_set_max_threads(pool: [*c]GThreadPool, max_threads: gint, @"error": [*c][*c]GError) gboolean;
pub extern fn g_thread_pool_get_max_threads(pool: [*c]GThreadPool) gint;
pub extern fn g_thread_pool_get_num_threads(pool: [*c]GThreadPool) guint;
pub extern fn g_thread_pool_set_max_unused_threads(max_threads: gint) void;
pub extern fn g_thread_pool_get_max_unused_threads() gint;
pub extern fn g_thread_pool_get_num_unused_threads() guint;
pub extern fn g_thread_pool_stop_unused_threads() void;
pub extern fn g_thread_pool_set_max_idle_time(interval: guint) void;
pub extern fn g_thread_pool_get_max_idle_time() guint;
pub const struct__GTimer = opaque {};
pub const GTimer = struct__GTimer;
pub extern fn g_timer_new() ?*GTimer;
pub extern fn g_timer_destroy(timer: ?*GTimer) void;
pub extern fn g_timer_start(timer: ?*GTimer) void;
pub extern fn g_timer_stop(timer: ?*GTimer) void;
pub extern fn g_timer_reset(timer: ?*GTimer) void;
pub extern fn g_timer_continue(timer: ?*GTimer) void;
pub extern fn g_timer_elapsed(timer: ?*GTimer, microseconds: [*c]gulong) gdouble;
pub extern fn g_timer_is_active(timer: ?*GTimer) gboolean;
pub extern fn g_usleep(microseconds: gulong) void;
pub extern fn g_time_val_add(time_: [*c]GTimeVal, microseconds: glong) void;
pub extern fn g_time_val_from_iso8601(iso_date: [*c]const gchar, time_: [*c]GTimeVal) gboolean;
pub extern fn g_time_val_to_iso8601(time_: [*c]GTimeVal) [*c]gchar;
pub const GTrashStack = struct__GTrashStack;
pub const struct__GTrashStack = extern struct {
    next: [*c]GTrashStack = @import("std").mem.zeroes([*c]GTrashStack),
};
pub extern fn g_trash_stack_push(stack_p: [*c][*c]GTrashStack, data_p: gpointer) void;
pub extern fn g_trash_stack_pop(stack_p: [*c][*c]GTrashStack) gpointer;
pub extern fn g_trash_stack_peek(stack_p: [*c][*c]GTrashStack) gpointer;
pub extern fn g_trash_stack_height(stack_p: [*c][*c]GTrashStack) guint;
pub const struct__GTree = opaque {};
pub const GTree = struct__GTree;
pub const struct__GTreeNode = opaque {};
pub const GTreeNode = struct__GTreeNode;
pub const GTraverseFunc = ?*const fn (gpointer, gpointer, gpointer) callconv(.c) gboolean;
pub const GTraverseNodeFunc = ?*const fn (?*GTreeNode, gpointer) callconv(.c) gboolean;
pub extern fn g_tree_new(key_compare_func: GCompareFunc) ?*GTree;
pub extern fn g_tree_new_with_data(key_compare_func: GCompareDataFunc, key_compare_data: gpointer) ?*GTree;
pub extern fn g_tree_new_full(key_compare_func: GCompareDataFunc, key_compare_data: gpointer, key_destroy_func: GDestroyNotify, value_destroy_func: GDestroyNotify) ?*GTree;
pub extern fn g_tree_node_first(tree: ?*GTree) ?*GTreeNode;
pub extern fn g_tree_node_last(tree: ?*GTree) ?*GTreeNode;
pub extern fn g_tree_node_previous(node: ?*GTreeNode) ?*GTreeNode;
pub extern fn g_tree_node_next(node: ?*GTreeNode) ?*GTreeNode;
pub extern fn g_tree_ref(tree: ?*GTree) ?*GTree;
pub extern fn g_tree_unref(tree: ?*GTree) void;
pub extern fn g_tree_destroy(tree: ?*GTree) void;
pub extern fn g_tree_insert_node(tree: ?*GTree, key: gpointer, value: gpointer) ?*GTreeNode;
pub extern fn g_tree_insert(tree: ?*GTree, key: gpointer, value: gpointer) void;
pub extern fn g_tree_replace_node(tree: ?*GTree, key: gpointer, value: gpointer) ?*GTreeNode;
pub extern fn g_tree_replace(tree: ?*GTree, key: gpointer, value: gpointer) void;
pub extern fn g_tree_remove(tree: ?*GTree, key: gconstpointer) gboolean;
pub extern fn g_tree_remove_all(tree: ?*GTree) void;
pub extern fn g_tree_steal(tree: ?*GTree, key: gconstpointer) gboolean;
pub extern fn g_tree_node_key(node: ?*GTreeNode) gpointer;
pub extern fn g_tree_node_value(node: ?*GTreeNode) gpointer;
pub extern fn g_tree_lookup_node(tree: ?*GTree, key: gconstpointer) ?*GTreeNode;
pub extern fn g_tree_lookup(tree: ?*GTree, key: gconstpointer) gpointer;
pub extern fn g_tree_lookup_extended(tree: ?*GTree, lookup_key: gconstpointer, orig_key: [*c]gpointer, value: [*c]gpointer) gboolean;
pub extern fn g_tree_foreach(tree: ?*GTree, func: GTraverseFunc, user_data: gpointer) void;
pub extern fn g_tree_foreach_node(tree: ?*GTree, func: GTraverseNodeFunc, user_data: gpointer) void;
pub extern fn g_tree_traverse(tree: ?*GTree, traverse_func: GTraverseFunc, traverse_type: GTraverseType, user_data: gpointer) void;
pub extern fn g_tree_search_node(tree: ?*GTree, search_func: GCompareFunc, user_data: gconstpointer) ?*GTreeNode;
pub extern fn g_tree_search(tree: ?*GTree, search_func: GCompareFunc, user_data: gconstpointer) gpointer;
pub extern fn g_tree_lower_bound(tree: ?*GTree, key: gconstpointer) ?*GTreeNode;
pub extern fn g_tree_upper_bound(tree: ?*GTree, key: gconstpointer) ?*GTreeNode;
pub extern fn g_tree_height(tree: ?*GTree) gint;
pub extern fn g_tree_nnodes(tree: ?*GTree) gint;
pub const struct__GUri = opaque {};
pub const GUri = struct__GUri;
pub extern fn g_uri_ref(uri: ?*GUri) ?*GUri;
pub extern fn g_uri_unref(uri: ?*GUri) void;
pub const G_URI_FLAGS_NONE: c_int = 0;
pub const G_URI_FLAGS_PARSE_RELAXED: c_int = 1;
pub const G_URI_FLAGS_HAS_PASSWORD: c_int = 2;
pub const G_URI_FLAGS_HAS_AUTH_PARAMS: c_int = 4;
pub const G_URI_FLAGS_ENCODED: c_int = 8;
pub const G_URI_FLAGS_NON_DNS: c_int = 16;
pub const G_URI_FLAGS_ENCODED_QUERY: c_int = 32;
pub const G_URI_FLAGS_ENCODED_PATH: c_int = 64;
pub const G_URI_FLAGS_ENCODED_FRAGMENT: c_int = 128;
pub const G_URI_FLAGS_SCHEME_NORMALIZE: c_int = 256;
pub const GUriFlags = c_uint;
pub extern fn g_uri_split(uri_ref: [*c]const gchar, flags: GUriFlags, scheme: [*c][*c]gchar, userinfo: [*c][*c]gchar, host: [*c][*c]gchar, port: [*c]gint, path: [*c][*c]gchar, query: [*c][*c]gchar, fragment: [*c][*c]gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_uri_split_with_user(uri_ref: [*c]const gchar, flags: GUriFlags, scheme: [*c][*c]gchar, user: [*c][*c]gchar, password: [*c][*c]gchar, auth_params: [*c][*c]gchar, host: [*c][*c]gchar, port: [*c]gint, path: [*c][*c]gchar, query: [*c][*c]gchar, fragment: [*c][*c]gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_uri_split_network(uri_string: [*c]const gchar, flags: GUriFlags, scheme: [*c][*c]gchar, host: [*c][*c]gchar, port: [*c]gint, @"error": [*c][*c]GError) gboolean;
pub extern fn g_uri_is_valid(uri_string: [*c]const gchar, flags: GUriFlags, @"error": [*c][*c]GError) gboolean;
pub extern fn g_uri_join(flags: GUriFlags, scheme: [*c]const gchar, userinfo: [*c]const gchar, host: [*c]const gchar, port: gint, path: [*c]const gchar, query: [*c]const gchar, fragment: [*c]const gchar) [*c]gchar;
pub extern fn g_uri_join_with_user(flags: GUriFlags, scheme: [*c]const gchar, user: [*c]const gchar, password: [*c]const gchar, auth_params: [*c]const gchar, host: [*c]const gchar, port: gint, path: [*c]const gchar, query: [*c]const gchar, fragment: [*c]const gchar) [*c]gchar;
pub extern fn g_uri_parse(uri_string: [*c]const gchar, flags: GUriFlags, @"error": [*c][*c]GError) ?*GUri;
pub extern fn g_uri_parse_relative(base_uri: ?*GUri, uri_ref: [*c]const gchar, flags: GUriFlags, @"error": [*c][*c]GError) ?*GUri;
pub extern fn g_uri_resolve_relative(base_uri_string: [*c]const gchar, uri_ref: [*c]const gchar, flags: GUriFlags, @"error": [*c][*c]GError) [*c]gchar;
pub extern fn g_uri_build(flags: GUriFlags, scheme: [*c]const gchar, userinfo: [*c]const gchar, host: [*c]const gchar, port: gint, path: [*c]const gchar, query: [*c]const gchar, fragment: [*c]const gchar) ?*GUri;
pub extern fn g_uri_build_with_user(flags: GUriFlags, scheme: [*c]const gchar, user: [*c]const gchar, password: [*c]const gchar, auth_params: [*c]const gchar, host: [*c]const gchar, port: gint, path: [*c]const gchar, query: [*c]const gchar, fragment: [*c]const gchar) ?*GUri;
pub const G_URI_HIDE_NONE: c_int = 0;
pub const G_URI_HIDE_USERINFO: c_int = 1;
pub const G_URI_HIDE_PASSWORD: c_int = 2;
pub const G_URI_HIDE_AUTH_PARAMS: c_int = 4;
pub const G_URI_HIDE_QUERY: c_int = 8;
pub const G_URI_HIDE_FRAGMENT: c_int = 16;
pub const GUriHideFlags = c_uint;
pub extern fn g_uri_to_string(uri: ?*GUri) [*c]u8;
pub extern fn g_uri_to_string_partial(uri: ?*GUri, flags: GUriHideFlags) [*c]u8;
pub extern fn g_uri_get_scheme(uri: ?*GUri) [*c]const gchar;
pub extern fn g_uri_get_userinfo(uri: ?*GUri) [*c]const gchar;
pub extern fn g_uri_get_user(uri: ?*GUri) [*c]const gchar;
pub extern fn g_uri_get_password(uri: ?*GUri) [*c]const gchar;
pub extern fn g_uri_get_auth_params(uri: ?*GUri) [*c]const gchar;
pub extern fn g_uri_get_host(uri: ?*GUri) [*c]const gchar;
pub extern fn g_uri_get_port(uri: ?*GUri) gint;
pub extern fn g_uri_get_path(uri: ?*GUri) [*c]const gchar;
pub extern fn g_uri_get_query(uri: ?*GUri) [*c]const gchar;
pub extern fn g_uri_get_fragment(uri: ?*GUri) [*c]const gchar;
pub extern fn g_uri_get_flags(uri: ?*GUri) GUriFlags;
pub const G_URI_PARAMS_NONE: c_int = 0;
pub const G_URI_PARAMS_CASE_INSENSITIVE: c_int = 1;
pub const G_URI_PARAMS_WWW_FORM: c_int = 2;
pub const G_URI_PARAMS_PARSE_RELAXED: c_int = 4;
pub const GUriParamsFlags = c_uint;
pub extern fn g_uri_parse_params(params: [*c]const gchar, length: gssize, separators: [*c]const gchar, flags: GUriParamsFlags, @"error": [*c][*c]GError) ?*GHashTable;
pub const struct__GUriParamsIter = extern struct {
    dummy0: gint = @import("std").mem.zeroes(gint),
    dummy1: gpointer = @import("std").mem.zeroes(gpointer),
    dummy2: gpointer = @import("std").mem.zeroes(gpointer),
    dummy3: [256]guint8 = @import("std").mem.zeroes([256]guint8),
};
pub const GUriParamsIter = struct__GUriParamsIter;
pub extern fn g_uri_params_iter_init(iter: [*c]GUriParamsIter, params: [*c]const gchar, length: gssize, separators: [*c]const gchar, flags: GUriParamsFlags) void;
pub extern fn g_uri_params_iter_next(iter: [*c]GUriParamsIter, attribute: [*c][*c]gchar, value: [*c][*c]gchar, @"error": [*c][*c]GError) gboolean;
pub extern fn g_uri_error_quark() GQuark;
pub const G_URI_ERROR_FAILED: c_int = 0;
pub const G_URI_ERROR_BAD_SCHEME: c_int = 1;
pub const G_URI_ERROR_BAD_USER: c_int = 2;
pub const G_URI_ERROR_BAD_PASSWORD: c_int = 3;
pub const G_URI_ERROR_BAD_AUTH_PARAMS: c_int = 4;
pub const G_URI_ERROR_BAD_HOST: c_int = 5;
pub const G_URI_ERROR_BAD_PORT: c_int = 6;
pub const G_URI_ERROR_BAD_PATH: c_int = 7;
pub const G_URI_ERROR_BAD_QUERY: c_int = 8;
pub const G_URI_ERROR_BAD_FRAGMENT: c_int = 9;
pub const GUriError = c_uint;
pub extern fn g_uri_unescape_string(escaped_string: [*c]const u8, illegal_characters: [*c]const u8) [*c]u8;
pub extern fn g_uri_unescape_segment(escaped_string: [*c]const u8, escaped_string_end: [*c]const u8, illegal_characters: [*c]const u8) [*c]u8;
pub extern fn g_uri_parse_scheme(uri: [*c]const u8) [*c]u8;
pub extern fn g_uri_peek_scheme(uri: [*c]const u8) [*c]const u8;
pub extern fn g_uri_escape_string(unescaped: [*c]const u8, reserved_chars_allowed: [*c]const u8, allow_utf8: gboolean) [*c]u8;
pub extern fn g_uri_unescape_bytes(escaped_string: [*c]const u8, length: gssize, illegal_characters: [*c]const u8, @"error": [*c][*c]GError) ?*GBytes;
pub extern fn g_uri_escape_bytes(unescaped: [*c]const guint8, length: gsize, reserved_chars_allowed: [*c]const u8) [*c]u8;
pub extern fn g_uuid_string_is_valid(str: [*c]const gchar) gboolean;
pub extern fn g_uuid_string_random() [*c]gchar;
pub extern const glib_major_version: guint;
pub extern const glib_minor_version: guint;
pub extern const glib_micro_version: guint;
pub extern const glib_interface_age: guint;
pub extern const glib_binary_age: guint;
pub extern fn glib_check_version(required_major: guint, required_minor: guint, required_micro: guint) [*c]const gchar;
pub const struct__GAllocator = opaque {};
pub const GAllocator = struct__GAllocator;
pub const struct__GMemChunk = opaque {};
pub const GMemChunk = struct__GMemChunk;
pub extern fn g_mem_chunk_new(name: [*c]const gchar, atom_size: gint, area_size: gsize, @"type": gint) ?*GMemChunk;
pub extern fn g_mem_chunk_destroy(mem_chunk: ?*GMemChunk) void;
pub extern fn g_mem_chunk_alloc(mem_chunk: ?*GMemChunk) gpointer;
pub extern fn g_mem_chunk_alloc0(mem_chunk: ?*GMemChunk) gpointer;
pub extern fn g_mem_chunk_free(mem_chunk: ?*GMemChunk, mem: gpointer) void;
pub extern fn g_mem_chunk_clean(mem_chunk: ?*GMemChunk) void;
pub extern fn g_mem_chunk_reset(mem_chunk: ?*GMemChunk) void;
pub extern fn g_mem_chunk_print(mem_chunk: ?*GMemChunk) void;
pub extern fn g_mem_chunk_info() void;
pub extern fn g_blow_chunks() void;
pub extern fn g_allocator_new(name: [*c]const gchar, n_preallocs: guint) ?*GAllocator;
pub extern fn g_allocator_free(allocator: ?*GAllocator) void;
pub extern fn g_list_push_allocator(allocator: ?*GAllocator) void;
pub extern fn g_list_pop_allocator() void;
pub extern fn g_slist_push_allocator(allocator: ?*GAllocator) void;
pub extern fn g_slist_pop_allocator() void;
pub extern fn g_node_push_allocator(allocator: ?*GAllocator) void;
pub extern fn g_node_pop_allocator() void;
pub const struct__GCache = opaque {};
pub const GCache = struct__GCache;
pub const GCacheNewFunc = ?*const fn (gpointer) callconv(.c) gpointer;
pub const GCacheDupFunc = ?*const fn (gpointer) callconv(.c) gpointer;
pub const GCacheDestroyFunc = ?*const fn (gpointer) callconv(.c) void;
pub extern fn g_cache_new(value_new_func: GCacheNewFunc, value_destroy_func: GCacheDestroyFunc, key_dup_func: GCacheDupFunc, key_destroy_func: GCacheDestroyFunc, hash_key_func: GHashFunc, hash_value_func: GHashFunc, key_equal_func: GEqualFunc) ?*GCache;
pub extern fn g_cache_destroy(cache: ?*GCache) void;
pub extern fn g_cache_insert(cache: ?*GCache, key: gpointer) gpointer;
pub extern fn g_cache_remove(cache: ?*GCache, value: gconstpointer) void;
pub extern fn g_cache_key_foreach(cache: ?*GCache, func: GHFunc, user_data: gpointer) void;
pub extern fn g_cache_value_foreach(cache: ?*GCache, func: GHFunc, user_data: gpointer) void;
pub const GCompletionFunc = ?*const fn (gpointer) callconv(.c) [*c]gchar;
pub const GCompletionStrncmpFunc = ?*const fn ([*c]const gchar, [*c]const gchar, gsize) callconv(.c) gint;
pub const struct__GCompletion = extern struct {
    items: [*c]GList = @import("std").mem.zeroes([*c]GList),
    func: GCompletionFunc = @import("std").mem.zeroes(GCompletionFunc),
    prefix: [*c]gchar = @import("std").mem.zeroes([*c]gchar),
    cache: [*c]GList = @import("std").mem.zeroes([*c]GList),
    strncmp_func: GCompletionStrncmpFunc = @import("std").mem.zeroes(GCompletionStrncmpFunc),
};
pub const GCompletion = struct__GCompletion;
pub extern fn g_completion_new(func: GCompletionFunc) [*c]GCompletion;
pub extern fn g_completion_add_items(cmp: [*c]GCompletion, items: [*c]GList) void;
pub extern fn g_completion_remove_items(cmp: [*c]GCompletion, items: [*c]GList) void;
pub extern fn g_completion_clear_items(cmp: [*c]GCompletion) void;
pub extern fn g_completion_complete(cmp: [*c]GCompletion, prefix: [*c]const gchar, new_prefix: [*c][*c]gchar) [*c]GList;
pub extern fn g_completion_complete_utf8(cmp: [*c]GCompletion, prefix: [*c]const gchar, new_prefix: [*c][*c]gchar) [*c]GList;
pub extern fn g_completion_set_compare(cmp: [*c]GCompletion, strncmp_func: GCompletionStrncmpFunc) void;
pub extern fn g_completion_free(cmp: [*c]GCompletion) void;
pub const struct__GRelation = opaque {};
pub const GRelation = struct__GRelation;
pub const struct__GTuples = extern struct {
    len: guint = @import("std").mem.zeroes(guint),
};
pub const GTuples = struct__GTuples;
pub extern fn g_relation_new(fields: gint) ?*GRelation;
pub extern fn g_relation_destroy(relation: ?*GRelation) void;
pub extern fn g_relation_index(relation: ?*GRelation, field: gint, hash_func: GHashFunc, key_equal_func: GEqualFunc) void;
pub extern fn g_relation_insert(relation: ?*GRelation, ...) void;
pub extern fn g_relation_delete(relation: ?*GRelation, key: gconstpointer, field: gint) gint;
pub extern fn g_relation_select(relation: ?*GRelation, key: gconstpointer, field: gint) [*c]GTuples;
pub extern fn g_relation_count(relation: ?*GRelation, key: gconstpointer, field: gint) gint;
pub extern fn g_relation_exists(relation: ?*GRelation, ...) gboolean;
pub extern fn g_relation_print(relation: ?*GRelation) void;
pub extern fn g_tuples_destroy(tuples: [*c]GTuples) void;
pub extern fn g_tuples_index(tuples: [*c]GTuples, index_: gint, field: gint) gpointer;
pub const G_THREAD_PRIORITY_LOW: c_int = 0;
pub const G_THREAD_PRIORITY_NORMAL: c_int = 1;
pub const G_THREAD_PRIORITY_HIGH: c_int = 2;
pub const G_THREAD_PRIORITY_URGENT: c_int = 3;
pub const GThreadPriority = c_uint;
pub const struct__GThreadFunctions = extern struct {
    mutex_new: ?*const fn () callconv(.c) [*c]GMutex = @import("std").mem.zeroes(?*const fn () callconv(.c) [*c]GMutex),
    mutex_lock: ?*const fn ([*c]GMutex) callconv(.c) void = @import("std").mem.zeroes(?*const fn ([*c]GMutex) callconv(.c) void),
    mutex_trylock: ?*const fn ([*c]GMutex) callconv(.c) gboolean = @import("std").mem.zeroes(?*const fn ([*c]GMutex) callconv(.c) gboolean),
    mutex_unlock: ?*const fn ([*c]GMutex) callconv(.c) void = @import("std").mem.zeroes(?*const fn ([*c]GMutex) callconv(.c) void),
    mutex_free: ?*const fn ([*c]GMutex) callconv(.c) void = @import("std").mem.zeroes(?*const fn ([*c]GMutex) callconv(.c) void),
    cond_new: ?*const fn () callconv(.c) [*c]GCond = @import("std").mem.zeroes(?*const fn () callconv(.c) [*c]GCond),
    cond_signal: ?*const fn ([*c]GCond) callconv(.c) void = @import("std").mem.zeroes(?*const fn ([*c]GCond) callconv(.c) void),
    cond_broadcast: ?*const fn ([*c]GCond) callconv(.c) void = @import("std").mem.zeroes(?*const fn ([*c]GCond) callconv(.c) void),
    cond_wait: ?*const fn ([*c]GCond, [*c]GMutex) callconv(.c) void = @import("std").mem.zeroes(?*const fn ([*c]GCond, [*c]GMutex) callconv(.c) void),
    cond_timed_wait: ?*const fn ([*c]GCond, [*c]GMutex, [*c]GTimeVal) callconv(.c) gboolean = @import("std").mem.zeroes(?*const fn ([*c]GCond, [*c]GMutex, [*c]GTimeVal) callconv(.c) gboolean),
    cond_free: ?*const fn ([*c]GCond) callconv(.c) void = @import("std").mem.zeroes(?*const fn ([*c]GCond) callconv(.c) void),
    private_new: ?*const fn (GDestroyNotify) callconv(.c) [*c]GPrivate = @import("std").mem.zeroes(?*const fn (GDestroyNotify) callconv(.c) [*c]GPrivate),
    private_get: ?*const fn ([*c]GPrivate) callconv(.c) gpointer = @import("std").mem.zeroes(?*const fn ([*c]GPrivate) callconv(.c) gpointer),
    private_set: ?*const fn ([*c]GPrivate, gpointer) callconv(.c) void = @import("std").mem.zeroes(?*const fn ([*c]GPrivate, gpointer) callconv(.c) void),
    thread_create: ?*const fn (GThreadFunc, gpointer, gulong, gboolean, gboolean, GThreadPriority, gpointer, [*c][*c]GError) callconv(.c) void = @import("std").mem.zeroes(?*const fn (GThreadFunc, gpointer, gulong, gboolean, gboolean, GThreadPriority, gpointer, [*c][*c]GError) callconv(.c) void),
    thread_yield: ?*const fn () callconv(.c) void = @import("std").mem.zeroes(?*const fn () callconv(.c) void),
    thread_join: ?*const fn (gpointer) callconv(.c) void = @import("std").mem.zeroes(?*const fn (gpointer) callconv(.c) void),
    thread_exit: ?*const fn () callconv(.c) void = @import("std").mem.zeroes(?*const fn () callconv(.c) void),
    thread_set_priority: ?*const fn (gpointer, GThreadPriority) callconv(.c) void = @import("std").mem.zeroes(?*const fn (gpointer, GThreadPriority) callconv(.c) void),
    thread_self: ?*const fn (gpointer) callconv(.c) void = @import("std").mem.zeroes(?*const fn (gpointer) callconv(.c) void),
    thread_equal: ?*const fn (gpointer, gpointer) callconv(.c) gboolean = @import("std").mem.zeroes(?*const fn (gpointer, gpointer) callconv(.c) gboolean),
};
pub const GThreadFunctions = struct__GThreadFunctions;
pub extern var g_thread_functions_for_glib_use: GThreadFunctions;
pub extern var g_thread_use_default_impl: gboolean;
pub extern var g_thread_gettime: ?*const fn () callconv(.c) guint64;
pub extern fn g_thread_create(func: GThreadFunc, data: gpointer, joinable: gboolean, @"error": [*c][*c]GError) [*c]GThread;
pub extern fn g_thread_create_full(func: GThreadFunc, data: gpointer, stack_size: gulong, joinable: gboolean, bound: gboolean, priority: GThreadPriority, @"error": [*c][*c]GError) [*c]GThread;
pub extern fn g_thread_set_priority(thread: [*c]GThread, priority: GThreadPriority) void;
pub extern fn g_thread_foreach(thread_func: GFunc, user_data: gpointer) void;
pub const struct_sched_param = extern struct {
    sched_priority: c_int = @import("std").mem.zeroes(c_int),
};
pub const __cpu_mask = c_ulong;
pub const cpu_set_t = extern struct {
    __bits: [16]__cpu_mask = @import("std").mem.zeroes([16]__cpu_mask),
};
pub extern fn __sched_cpucount(__setsize: usize, __setp: [*c]const cpu_set_t) c_int;
pub extern fn __sched_cpualloc(__count: usize) [*c]cpu_set_t;
pub extern fn __sched_cpufree(__set: [*c]cpu_set_t) void;
pub extern fn sched_setparam(__pid: __pid_t, __param: [*c]const struct_sched_param) c_int;
pub extern fn sched_getparam(__pid: __pid_t, __param: [*c]struct_sched_param) c_int;
pub extern fn sched_setscheduler(__pid: __pid_t, __policy: c_int, __param: [*c]const struct_sched_param) c_int;
pub extern fn sched_getscheduler(__pid: __pid_t) c_int;
pub extern fn sched_yield() c_int;
pub extern fn sched_get_priority_max(__algorithm: c_int) c_int;
pub extern fn sched_get_priority_min(__algorithm: c_int) c_int;
pub extern fn sched_rr_get_interval(__pid: __pid_t, __t: [*c]struct_timespec) c_int;
pub const __jmp_buf = [8]c_long;
pub const struct___jmp_buf_tag = extern struct {
    __jmpbuf: __jmp_buf = @import("std").mem.zeroes(__jmp_buf),
    __mask_was_saved: c_int = @import("std").mem.zeroes(c_int),
    __saved_mask: __sigset_t = @import("std").mem.zeroes(__sigset_t),
};
pub const PTHREAD_CREATE_JOINABLE: c_int = 0;
pub const PTHREAD_CREATE_DETACHED: c_int = 1;
const enum_unnamed_34 = c_uint;
pub const PTHREAD_MUTEX_TIMED_NP: c_int = 0;
pub const PTHREAD_MUTEX_RECURSIVE_NP: c_int = 1;
pub const PTHREAD_MUTEX_ERRORCHECK_NP: c_int = 2;
pub const PTHREAD_MUTEX_ADAPTIVE_NP: c_int = 3;
pub const PTHREAD_MUTEX_NORMAL: c_int = 0;
pub const PTHREAD_MUTEX_RECURSIVE: c_int = 1;
pub const PTHREAD_MUTEX_ERRORCHECK: c_int = 2;
pub const PTHREAD_MUTEX_DEFAULT: c_int = 0;
const enum_unnamed_35 = c_uint;
pub const PTHREAD_MUTEX_STALLED: c_int = 0;
pub const PTHREAD_MUTEX_STALLED_NP: c_int = 0;
pub const PTHREAD_MUTEX_ROBUST: c_int = 1;
pub const PTHREAD_MUTEX_ROBUST_NP: c_int = 1;
const enum_unnamed_36 = c_uint;
pub const PTHREAD_PRIO_NONE: c_int = 0;
pub const PTHREAD_PRIO_INHERIT: c_int = 1;
pub const PTHREAD_PRIO_PROTECT: c_int = 2;
const enum_unnamed_37 = c_uint;
pub const PTHREAD_RWLOCK_PREFER_READER_NP: c_int = 0;
pub const PTHREAD_RWLOCK_PREFER_WRITER_NP: c_int = 1;
pub const PTHREAD_RWLOCK_PREFER_WRITER_NONRECURSIVE_NP: c_int = 2;
pub const PTHREAD_RWLOCK_DEFAULT_NP: c_int = 0;
const enum_unnamed_38 = c_uint;
pub const PTHREAD_INHERIT_SCHED: c_int = 0;
pub const PTHREAD_EXPLICIT_SCHED: c_int = 1;
const enum_unnamed_39 = c_uint;
pub const PTHREAD_SCOPE_SYSTEM: c_int = 0;
pub const PTHREAD_SCOPE_PROCESS: c_int = 1;
const enum_unnamed_40 = c_uint;
pub const PTHREAD_PROCESS_PRIVATE: c_int = 0;
pub const PTHREAD_PROCESS_SHARED: c_int = 1;
const enum_unnamed_41 = c_uint;
pub const struct__pthread_cleanup_buffer = extern struct {
    __routine: ?*const fn (?*anyopaque) callconv(.c) void = @import("std").mem.zeroes(?*const fn (?*anyopaque) callconv(.c) void),
    __arg: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    __canceltype: c_int = @import("std").mem.zeroes(c_int),
    __prev: [*c]struct__pthread_cleanup_buffer = @import("std").mem.zeroes([*c]struct__pthread_cleanup_buffer),
};
pub const PTHREAD_CANCEL_ENABLE: c_int = 0;
pub const PTHREAD_CANCEL_DISABLE: c_int = 1;
const enum_unnamed_42 = c_uint;
pub const PTHREAD_CANCEL_DEFERRED: c_int = 0;
pub const PTHREAD_CANCEL_ASYNCHRONOUS: c_int = 1;
const enum_unnamed_43 = c_uint;
pub extern fn pthread_create(noalias __newthread: [*c]pthread_t, noalias __attr: [*c]const pthread_attr_t, __start_routine: ?*const fn (?*anyopaque) callconv(.c) ?*anyopaque, noalias __arg: ?*anyopaque) c_int;
pub extern fn pthread_exit(__retval: ?*anyopaque) noreturn;
pub extern fn pthread_join(__th: pthread_t, __thread_return: [*c]?*anyopaque) c_int;
pub extern fn pthread_detach(__th: pthread_t) c_int;
pub extern fn pthread_self() pthread_t;
pub extern fn pthread_equal(__thread1: pthread_t, __thread2: pthread_t) c_int;
pub extern fn pthread_attr_init(__attr: [*c]pthread_attr_t) c_int;
pub extern fn pthread_attr_destroy(__attr: [*c]pthread_attr_t) c_int;
pub extern fn pthread_attr_getdetachstate(__attr: [*c]const pthread_attr_t, __detachstate: [*c]c_int) c_int;
pub extern fn pthread_attr_setdetachstate(__attr: [*c]pthread_attr_t, __detachstate: c_int) c_int;
pub extern fn pthread_attr_getguardsize(__attr: [*c]const pthread_attr_t, __guardsize: [*c]usize) c_int;
pub extern fn pthread_attr_setguardsize(__attr: [*c]pthread_attr_t, __guardsize: usize) c_int;
pub extern fn pthread_attr_getschedparam(noalias __attr: [*c]const pthread_attr_t, noalias __param: [*c]struct_sched_param) c_int;
pub extern fn pthread_attr_setschedparam(noalias __attr: [*c]pthread_attr_t, noalias __param: [*c]const struct_sched_param) c_int;
pub extern fn pthread_attr_getschedpolicy(noalias __attr: [*c]const pthread_attr_t, noalias __policy: [*c]c_int) c_int;
pub extern fn pthread_attr_setschedpolicy(__attr: [*c]pthread_attr_t, __policy: c_int) c_int;
pub extern fn pthread_attr_getinheritsched(noalias __attr: [*c]const pthread_attr_t, noalias __inherit: [*c]c_int) c_int;
pub extern fn pthread_attr_setinheritsched(__attr: [*c]pthread_attr_t, __inherit: c_int) c_int;
pub extern fn pthread_attr_getscope(noalias __attr: [*c]const pthread_attr_t, noalias __scope: [*c]c_int) c_int;
pub extern fn pthread_attr_setscope(__attr: [*c]pthread_attr_t, __scope: c_int) c_int;
pub extern fn pthread_attr_getstackaddr(noalias __attr: [*c]const pthread_attr_t, noalias __stackaddr: [*c]?*anyopaque) c_int;
pub extern fn pthread_attr_setstackaddr(__attr: [*c]pthread_attr_t, __stackaddr: ?*anyopaque) c_int;
pub extern fn pthread_attr_getstacksize(noalias __attr: [*c]const pthread_attr_t, noalias __stacksize: [*c]usize) c_int;
pub extern fn pthread_attr_setstacksize(__attr: [*c]pthread_attr_t, __stacksize: usize) c_int;
pub extern fn pthread_attr_getstack(noalias __attr: [*c]const pthread_attr_t, noalias __stackaddr: [*c]?*anyopaque, noalias __stacksize: [*c]usize) c_int;
pub extern fn pthread_attr_setstack(__attr: [*c]pthread_attr_t, __stackaddr: ?*anyopaque, __stacksize: usize) c_int;
pub extern fn pthread_setschedparam(__target_thread: pthread_t, __policy: c_int, __param: [*c]const struct_sched_param) c_int;
pub extern fn pthread_getschedparam(__target_thread: pthread_t, noalias __policy: [*c]c_int, noalias __param: [*c]struct_sched_param) c_int;
pub extern fn pthread_setschedprio(__target_thread: pthread_t, __prio: c_int) c_int;
pub extern fn pthread_once(__once_control: [*c]pthread_once_t, __init_routine: ?*const fn () callconv(.c) void) c_int;
pub extern fn pthread_setcancelstate(__state: c_int, __oldstate: [*c]c_int) c_int;
pub extern fn pthread_setcanceltype(__type: c_int, __oldtype: [*c]c_int) c_int;
pub extern fn pthread_cancel(__th: pthread_t) c_int;
pub extern fn pthread_testcancel() void;
pub const struct___cancel_jmp_buf_tag = extern struct {
    __cancel_jmp_buf: __jmp_buf = @import("std").mem.zeroes(__jmp_buf),
    __mask_was_saved: c_int = @import("std").mem.zeroes(c_int),
};
pub const __pthread_unwind_buf_t = extern struct {
    __cancel_jmp_buf: [1]struct___cancel_jmp_buf_tag = @import("std").mem.zeroes([1]struct___cancel_jmp_buf_tag),
    __pad: [4]?*anyopaque = @import("std").mem.zeroes([4]?*anyopaque),
};
pub const struct___pthread_cleanup_frame = extern struct {
    __cancel_routine: ?*const fn (?*anyopaque) callconv(.c) void = @import("std").mem.zeroes(?*const fn (?*anyopaque) callconv(.c) void),
    __cancel_arg: ?*anyopaque = @import("std").mem.zeroes(?*anyopaque),
    __do_it: c_int = @import("std").mem.zeroes(c_int),
    __cancel_type: c_int = @import("std").mem.zeroes(c_int),
};
pub extern fn __pthread_register_cancel(__buf: [*c]__pthread_unwind_buf_t) void;
pub extern fn __pthread_unregister_cancel(__buf: [*c]__pthread_unwind_buf_t) void;
pub extern fn __pthread_unwind_next(__buf: [*c]__pthread_unwind_buf_t) noreturn;
pub extern fn __sigsetjmp(__env: [*c]struct___jmp_buf_tag, __savemask: c_int) c_int;
pub extern fn pthread_mutex_init(__mutex: [*c]pthread_mutex_t, __mutexattr: [*c]const pthread_mutexattr_t) c_int;
pub extern fn pthread_mutex_destroy(__mutex: [*c]pthread_mutex_t) c_int;
pub extern fn pthread_mutex_trylock(__mutex: [*c]pthread_mutex_t) c_int;
pub extern fn pthread_mutex_lock(__mutex: [*c]pthread_mutex_t) c_int;
pub extern fn pthread_mutex_timedlock(noalias __mutex: [*c]pthread_mutex_t, noalias __abstime: [*c]const struct_timespec) c_int;
pub extern fn pthread_mutex_unlock(__mutex: [*c]pthread_mutex_t) c_int;
pub extern fn pthread_mutex_getprioceiling(noalias __mutex: [*c]const pthread_mutex_t, noalias __prioceiling: [*c]c_int) c_int;
pub extern fn pthread_mutex_setprioceiling(noalias __mutex: [*c]pthread_mutex_t, __prioceiling: c_int, noalias __old_ceiling: [*c]c_int) c_int;
pub extern fn pthread_mutex_consistent(__mutex: [*c]pthread_mutex_t) c_int;
pub extern fn pthread_mutexattr_init(__attr: [*c]pthread_mutexattr_t) c_int;
pub extern fn pthread_mutexattr_destroy(__attr: [*c]pthread_mutexattr_t) c_int;
pub extern fn pthread_mutexattr_getpshared(noalias __attr: [*c]const pthread_mutexattr_t, noalias __pshared: [*c]c_int) c_int;
pub extern fn pthread_mutexattr_setpshared(__attr: [*c]pthread_mutexattr_t, __pshared: c_int) c_int;
pub extern fn pthread_mutexattr_gettype(noalias __attr: [*c]const pthread_mutexattr_t, noalias __kind: [*c]c_int) c_int;
pub extern fn pthread_mutexattr_settype(__attr: [*c]pthread_mutexattr_t, __kind: c_int) c_int;
pub extern fn pthread_mutexattr_getprotocol(noalias __attr: [*c]const pthread_mutexattr_t, noalias __protocol: [*c]c_int) c_int;
pub extern fn pthread_mutexattr_setprotocol(__attr: [*c]pthread_mutexattr_t, __protocol: c_int) c_int;
pub extern fn pthread_mutexattr_getprioceiling(noalias __attr: [*c]const pthread_mutexattr_t, noalias __prioceiling: [*c]c_int) c_int;
pub extern fn pthread_mutexattr_setprioceiling(__attr: [*c]pthread_mutexattr_t, __prioceiling: c_int) c_int;
pub extern fn pthread_mutexattr_getrobust(__attr: [*c]const pthread_mutexattr_t, __robustness: [*c]c_int) c_int;
pub extern fn pthread_mutexattr_setrobust(__attr: [*c]pthread_mutexattr_t, __robustness: c_int) c_int;
pub extern fn pthread_rwlock_init(noalias __rwlock: [*c]pthread_rwlock_t, noalias __attr: [*c]const pthread_rwlockattr_t) c_int;
pub extern fn pthread_rwlock_destroy(__rwlock: [*c]pthread_rwlock_t) c_int;
pub extern fn pthread_rwlock_rdlock(__rwlock: [*c]pthread_rwlock_t) c_int;
pub extern fn pthread_rwlock_tryrdlock(__rwlock: [*c]pthread_rwlock_t) c_int;
pub extern fn pthread_rwlock_timedrdlock(noalias __rwlock: [*c]pthread_rwlock_t, noalias __abstime: [*c]const struct_timespec) c_int;
pub extern fn pthread_rwlock_wrlock(__rwlock: [*c]pthread_rwlock_t) c_int;
pub extern fn pthread_rwlock_trywrlock(__rwlock: [*c]pthread_rwlock_t) c_int;
pub extern fn pthread_rwlock_timedwrlock(noalias __rwlock: [*c]pthread_rwlock_t, noalias __abstime: [*c]const struct_timespec) c_int;
pub extern fn pthread_rwlock_unlock(__rwlock: [*c]pthread_rwlock_t) c_int;
pub extern fn pthread_rwlockattr_init(__attr: [*c]pthread_rwlockattr_t) c_int;
pub extern fn pthread_rwlockattr_destroy(__attr: [*c]pthread_rwlockattr_t) c_int;
pub extern fn pthread_rwlockattr_getpshared(noalias __attr: [*c]const pthread_rwlockattr_t, noalias __pshared: [*c]c_int) c_int;
pub extern fn pthread_rwlockattr_setpshared(__attr: [*c]pthread_rwlockattr_t, __pshared: c_int) c_int;
pub extern fn pthread_rwlockattr_getkind_np(noalias __attr: [*c]const pthread_rwlockattr_t, noalias __pref: [*c]c_int) c_int;
pub extern fn pthread_rwlockattr_setkind_np(__attr: [*c]pthread_rwlockattr_t, __pref: c_int) c_int;
pub extern fn pthread_cond_init(noalias __cond: [*c]pthread_cond_t, noalias __cond_attr: [*c]const pthread_condattr_t) c_int;
pub extern fn pthread_cond_destroy(__cond: [*c]pthread_cond_t) c_int;
pub extern fn pthread_cond_signal(__cond: [*c]pthread_cond_t) c_int;
pub extern fn pthread_cond_broadcast(__cond: [*c]pthread_cond_t) c_int;
pub extern fn pthread_cond_wait(noalias __cond: [*c]pthread_cond_t, noalias __mutex: [*c]pthread_mutex_t) c_int;
pub extern fn pthread_cond_timedwait(noalias __cond: [*c]pthread_cond_t, noalias __mutex: [*c]pthread_mutex_t, noalias __abstime: [*c]const struct_timespec) c_int;
pub extern fn pthread_condattr_init(__attr: [*c]pthread_condattr_t) c_int;
pub extern fn pthread_condattr_destroy(__attr: [*c]pthread_condattr_t) c_int;
pub extern fn pthread_condattr_getpshared(noalias __attr: [*c]const pthread_condattr_t, noalias __pshared: [*c]c_int) c_int;
pub extern fn pthread_condattr_setpshared(__attr: [*c]pthread_condattr_t, __pshared: c_int) c_int;
pub extern fn pthread_condattr_getclock(noalias __attr: [*c]const pthread_condattr_t, noalias __clock_id: [*c]__clockid_t) c_int;
pub extern fn pthread_condattr_setclock(__attr: [*c]pthread_condattr_t, __clock_id: __clockid_t) c_int;
pub extern fn pthread_spin_init(__lock: [*c]volatile pthread_spinlock_t, __pshared: c_int) c_int;
pub extern fn pthread_spin_destroy(__lock: [*c]volatile pthread_spinlock_t) c_int;
pub extern fn pthread_spin_lock(__lock: [*c]volatile pthread_spinlock_t) c_int;
pub extern fn pthread_spin_trylock(__lock: [*c]volatile pthread_spinlock_t) c_int;
pub extern fn pthread_spin_unlock(__lock: [*c]volatile pthread_spinlock_t) c_int;
pub extern fn pthread_barrier_init(noalias __barrier: [*c]pthread_barrier_t, noalias __attr: [*c]const pthread_barrierattr_t, __count: c_uint) c_int;
pub extern fn pthread_barrier_destroy(__barrier: [*c]pthread_barrier_t) c_int;
pub extern fn pthread_barrier_wait(__barrier: [*c]pthread_barrier_t) c_int;
pub extern fn pthread_barrierattr_init(__attr: [*c]pthread_barrierattr_t) c_int;
pub extern fn pthread_barrierattr_destroy(__attr: [*c]pthread_barrierattr_t) c_int;
pub extern fn pthread_barrierattr_getpshared(noalias __attr: [*c]const pthread_barrierattr_t, noalias __pshared: [*c]c_int) c_int;
pub extern fn pthread_barrierattr_setpshared(__attr: [*c]pthread_barrierattr_t, __pshared: c_int) c_int;
pub extern fn pthread_key_create(__key: [*c]pthread_key_t, __destr_function: ?*const fn (?*anyopaque) callconv(.c) void) c_int;
pub extern fn pthread_key_delete(__key: pthread_key_t) c_int;
pub extern fn pthread_getspecific(__key: pthread_key_t) ?*anyopaque;
pub extern fn pthread_setspecific(__key: pthread_key_t, __pointer: ?*const anyopaque) c_int;
pub extern fn pthread_getcpuclockid(__thread_id: pthread_t, __clock_id: [*c]__clockid_t) c_int;
pub extern fn pthread_atfork(__prepare: ?*const fn () callconv(.c) void, __parent: ?*const fn () callconv(.c) void, __child: ?*const fn () callconv(.c) void) c_int;
pub const GStaticMutex = extern struct {
    mutex: [*c]GMutex = @import("std").mem.zeroes([*c]GMutex),
    unused: pthread_mutex_t = @import("std").mem.zeroes(pthread_mutex_t),
};
pub extern fn g_static_mutex_init(mutex: [*c]GStaticMutex) void;
pub extern fn g_static_mutex_free(mutex: [*c]GStaticMutex) void;
pub extern fn g_static_mutex_get_mutex_impl(mutex: [*c]GStaticMutex) [*c]GMutex;
const union_unnamed_44 = extern union {
    owner: pthread_t,
    dummy: gdouble,
};
pub const struct__GStaticRecMutex = extern struct {
    mutex: GStaticMutex = @import("std").mem.zeroes(GStaticMutex),
    depth: guint = @import("std").mem.zeroes(guint),
    unused: union_unnamed_44 = @import("std").mem.zeroes(union_unnamed_44),
};
pub const GStaticRecMutex = struct__GStaticRecMutex;
pub extern fn g_static_rec_mutex_init(mutex: [*c]GStaticRecMutex) void;
pub extern fn g_static_rec_mutex_lock(mutex: [*c]GStaticRecMutex) void;
pub extern fn g_static_rec_mutex_trylock(mutex: [*c]GStaticRecMutex) gboolean;
pub extern fn g_static_rec_mutex_unlock(mutex: [*c]GStaticRecMutex) void;
pub extern fn g_static_rec_mutex_lock_full(mutex: [*c]GStaticRecMutex, depth: guint) void;
pub extern fn g_static_rec_mutex_unlock_full(mutex: [*c]GStaticRecMutex) guint;
pub extern fn g_static_rec_mutex_free(mutex: [*c]GStaticRecMutex) void;
pub const struct__GStaticRWLock = extern struct {
    mutex: GStaticMutex = @import("std").mem.zeroes(GStaticMutex),
    read_cond: [*c]GCond = @import("std").mem.zeroes([*c]GCond),
    write_cond: [*c]GCond = @import("std").mem.zeroes([*c]GCond),
    read_counter: guint = @import("std").mem.zeroes(guint),
    have_writer: gboolean = @import("std").mem.zeroes(gboolean),
    want_to_read: guint = @import("std").mem.zeroes(guint),
    want_to_write: guint = @import("std").mem.zeroes(guint),
};
pub const GStaticRWLock = struct__GStaticRWLock;
pub extern fn g_static_rw_lock_init(lock: [*c]GStaticRWLock) void;
pub extern fn g_static_rw_lock_reader_lock(lock: [*c]GStaticRWLock) void;
pub extern fn g_static_rw_lock_reader_trylock(lock: [*c]GStaticRWLock) gboolean;
pub extern fn g_static_rw_lock_reader_unlock(lock: [*c]GStaticRWLock) void;
pub extern fn g_static_rw_lock_writer_lock(lock: [*c]GStaticRWLock) void;
pub extern fn g_static_rw_lock_writer_trylock(lock: [*c]GStaticRWLock) gboolean;
pub extern fn g_static_rw_lock_writer_unlock(lock: [*c]GStaticRWLock) void;
pub extern fn g_static_rw_lock_free(lock: [*c]GStaticRWLock) void;
pub extern fn g_private_new(notify: GDestroyNotify) [*c]GPrivate;
pub const struct__GStaticPrivate = extern struct {
    index: guint = @import("std").mem.zeroes(guint),
};
pub const GStaticPrivate = struct__GStaticPrivate;
pub extern fn g_static_private_init(private_key: [*c]GStaticPrivate) void;
pub extern fn g_static_private_get(private_key: [*c]GStaticPrivate) gpointer;
pub extern fn g_static_private_set(private_key: [*c]GStaticPrivate, data: gpointer, notify: GDestroyNotify) void;
pub extern fn g_static_private_free(private_key: [*c]GStaticPrivate) void;
pub extern fn g_once_init_enter_impl(location: [*c]volatile gsize) gboolean;
pub extern fn g_thread_init(vtable: gpointer) void;
pub extern fn g_thread_init_with_errorcheck_mutexes(vtable: gpointer) void;
pub extern fn g_thread_get_initialized() gboolean;
pub extern var g_threads_got_initialized: gboolean;
pub extern fn g_mutex_new() [*c]GMutex;
pub extern fn g_mutex_free(mutex: [*c]GMutex) void;
pub extern fn g_cond_new() [*c]GCond;
pub extern fn g_cond_free(cond: [*c]GCond) void;
pub extern fn g_cond_timed_wait(cond: [*c]GCond, mutex: [*c]GMutex, abs_time: [*c]GTimeVal) gboolean;
pub fn g_autoptr_cleanup_generic_gfree(arg_p: ?*anyopaque) callconv(.c) void {
    var p = arg_p;
    _ = &p;
    var pp: [*c]?*anyopaque = @as([*c]?*anyopaque, @ptrCast(@alignCast(p)));
    _ = &pp;
    g_free(pp.*);
}
pub fn g_autoptr_cleanup_gstring_free(arg_string: [*c]GString) callconv(.c) void {
    var string = arg_string;
    _ = &string;
    if (string != null) {
        _ = if (__builtin_constant_p(!(@as(c_int, 0) != 0)) != 0) if (!(@as(c_int, 0) != 0)) g_string_free(string, @intFromBool(!(@as(c_int, 0) != 0))) else g_string_free_and_steal(string) else g_string_free(string, @intFromBool(!(@as(c_int, 0) != 0)));
    }
}
pub const GAsyncQueue_autoptr = ?*GAsyncQueue;
pub const GAsyncQueue_listautoptr = [*c]GList;
pub const GAsyncQueue_slistautoptr = [*c]GSList;
pub const GAsyncQueue_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GAsyncQueue(arg__ptr: ?*GAsyncQueue) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_async_queue_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GAsyncQueue(arg__ptr: [*c]?*GAsyncQueue) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GAsyncQueue(_ptr.*);
}
pub fn glib_autoptr_destroy_GAsyncQueue(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_async_queue_unref(@as(?*GAsyncQueue, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GAsyncQueue(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GAsyncQueue);
}
pub fn glib_slistautoptr_cleanup_GAsyncQueue(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GAsyncQueue);
}
pub fn glib_queueautoptr_cleanup_GAsyncQueue(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GAsyncQueue);
    }
}
pub const GBookmarkFile_autoptr = ?*GBookmarkFile;
pub const GBookmarkFile_listautoptr = [*c]GList;
pub const GBookmarkFile_slistautoptr = [*c]GSList;
pub const GBookmarkFile_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GBookmarkFile(arg__ptr: ?*GBookmarkFile) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_bookmark_file_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GBookmarkFile(arg__ptr: [*c]?*GBookmarkFile) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GBookmarkFile(_ptr.*);
}
pub fn glib_autoptr_destroy_GBookmarkFile(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_bookmark_file_free(@as(?*GBookmarkFile, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GBookmarkFile(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GBookmarkFile);
}
pub fn glib_slistautoptr_cleanup_GBookmarkFile(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GBookmarkFile);
}
pub fn glib_queueautoptr_cleanup_GBookmarkFile(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GBookmarkFile);
    }
}
pub const GBytes_autoptr = ?*GBytes;
pub const GBytes_listautoptr = [*c]GList;
pub const GBytes_slistautoptr = [*c]GSList;
pub const GBytes_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GBytes(arg__ptr: ?*GBytes) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_bytes_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GBytes(arg__ptr: [*c]?*GBytes) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GBytes(_ptr.*);
}
pub fn glib_autoptr_destroy_GBytes(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_bytes_unref(@as(?*GBytes, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GBytes(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GBytes);
}
pub fn glib_slistautoptr_cleanup_GBytes(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GBytes);
}
pub fn glib_queueautoptr_cleanup_GBytes(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GBytes);
    }
}
pub const GChecksum_autoptr = ?*GChecksum;
pub const GChecksum_listautoptr = [*c]GList;
pub const GChecksum_slistautoptr = [*c]GSList;
pub const GChecksum_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GChecksum(arg__ptr: ?*GChecksum) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_checksum_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GChecksum(arg__ptr: [*c]?*GChecksum) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GChecksum(_ptr.*);
}
pub fn glib_autoptr_destroy_GChecksum(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_checksum_free(@as(?*GChecksum, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GChecksum(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GChecksum);
}
pub fn glib_slistautoptr_cleanup_GChecksum(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GChecksum);
}
pub fn glib_queueautoptr_cleanup_GChecksum(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GChecksum);
    }
}
pub const GDateTime_autoptr = ?*GDateTime;
pub const GDateTime_listautoptr = [*c]GList;
pub const GDateTime_slistautoptr = [*c]GSList;
pub const GDateTime_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GDateTime(arg__ptr: ?*GDateTime) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_date_time_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GDateTime(arg__ptr: [*c]?*GDateTime) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GDateTime(_ptr.*);
}
pub fn glib_autoptr_destroy_GDateTime(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_date_time_unref(@as(?*GDateTime, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GDateTime(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GDateTime);
}
pub fn glib_slistautoptr_cleanup_GDateTime(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GDateTime);
}
pub fn glib_queueautoptr_cleanup_GDateTime(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GDateTime);
    }
}
pub const GDate_autoptr = ?*GDate;
pub const GDate_listautoptr = [*c]GList;
pub const GDate_slistautoptr = [*c]GSList;
pub const GDate_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GDate(arg__ptr: ?*GDate) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_date_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GDate(arg__ptr: [*c]?*GDate) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GDate(_ptr.*);
}
pub fn glib_autoptr_destroy_GDate(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_date_free(@as(?*GDate, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GDate(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GDate);
}
pub fn glib_slistautoptr_cleanup_GDate(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GDate);
}
pub fn glib_queueautoptr_cleanup_GDate(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GDate);
    }
}
pub const GDir_autoptr = ?*GDir;
pub const GDir_listautoptr = [*c]GList;
pub const GDir_slistautoptr = [*c]GSList;
pub const GDir_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GDir(arg__ptr: ?*GDir) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_dir_close(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GDir(arg__ptr: [*c]?*GDir) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GDir(_ptr.*);
}
pub fn glib_autoptr_destroy_GDir(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_dir_close(@as(?*GDir, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GDir(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GDir);
}
pub fn glib_slistautoptr_cleanup_GDir(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GDir);
}
pub fn glib_queueautoptr_cleanup_GDir(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GDir);
    }
}
pub const GError_autoptr = [*c]GError;
pub const GError_listautoptr = [*c]GList;
pub const GError_slistautoptr = [*c]GSList;
pub const GError_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GError(arg__ptr: [*c]GError) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_error_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GError(arg__ptr: [*c][*c]GError) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GError(_ptr.*);
}
pub fn glib_autoptr_destroy_GError(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_error_free(@as([*c]GError, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GError(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GError);
}
pub fn glib_slistautoptr_cleanup_GError(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GError);
}
pub fn glib_queueautoptr_cleanup_GError(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GError);
    }
}
pub const GHashTable_autoptr = ?*GHashTable;
pub const GHashTable_listautoptr = [*c]GList;
pub const GHashTable_slistautoptr = [*c]GSList;
pub const GHashTable_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GHashTable(arg__ptr: ?*GHashTable) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_hash_table_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GHashTable(arg__ptr: [*c]?*GHashTable) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GHashTable(_ptr.*);
}
pub fn glib_autoptr_destroy_GHashTable(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_hash_table_unref(@as(?*GHashTable, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GHashTable(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GHashTable);
}
pub fn glib_slistautoptr_cleanup_GHashTable(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GHashTable);
}
pub fn glib_queueautoptr_cleanup_GHashTable(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GHashTable);
    }
}
pub const GHmac_autoptr = ?*GHmac;
pub const GHmac_listautoptr = [*c]GList;
pub const GHmac_slistautoptr = [*c]GSList;
pub const GHmac_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GHmac(arg__ptr: ?*GHmac) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_hmac_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GHmac(arg__ptr: [*c]?*GHmac) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GHmac(_ptr.*);
}
pub fn glib_autoptr_destroy_GHmac(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_hmac_unref(@as(?*GHmac, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GHmac(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GHmac);
}
pub fn glib_slistautoptr_cleanup_GHmac(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GHmac);
}
pub fn glib_queueautoptr_cleanup_GHmac(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GHmac);
    }
}
pub const GIOChannel_autoptr = ?*GIOChannel;
pub const GIOChannel_listautoptr = [*c]GList;
pub const GIOChannel_slistautoptr = [*c]GSList;
pub const GIOChannel_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GIOChannel(arg__ptr: ?*GIOChannel) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_io_channel_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GIOChannel(arg__ptr: [*c]?*GIOChannel) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GIOChannel(_ptr.*);
}
pub fn glib_autoptr_destroy_GIOChannel(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_io_channel_unref(@as(?*GIOChannel, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GIOChannel(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GIOChannel);
}
pub fn glib_slistautoptr_cleanup_GIOChannel(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GIOChannel);
}
pub fn glib_queueautoptr_cleanup_GIOChannel(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GIOChannel);
    }
}
pub const GKeyFile_autoptr = ?*GKeyFile;
pub const GKeyFile_listautoptr = [*c]GList;
pub const GKeyFile_slistautoptr = [*c]GSList;
pub const GKeyFile_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GKeyFile(arg__ptr: ?*GKeyFile) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_key_file_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GKeyFile(arg__ptr: [*c]?*GKeyFile) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GKeyFile(_ptr.*);
}
pub fn glib_autoptr_destroy_GKeyFile(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_key_file_unref(@as(?*GKeyFile, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GKeyFile(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GKeyFile);
}
pub fn glib_slistautoptr_cleanup_GKeyFile(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GKeyFile);
}
pub fn glib_queueautoptr_cleanup_GKeyFile(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GKeyFile);
    }
}
pub const GList_autoptr = [*c]GList;
pub const GList_listautoptr = [*c]GList;
pub const GList_slistautoptr = [*c]GSList;
pub const GList_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GList(arg__ptr: [*c]GList) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_list_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GList(arg__ptr: [*c][*c]GList) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GList(_ptr.*);
}
pub fn glib_autoptr_destroy_GList(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_list_free(@as([*c]GList, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GList(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GList);
}
pub fn glib_slistautoptr_cleanup_GList(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GList);
}
pub fn glib_queueautoptr_cleanup_GList(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GList);
    }
}
pub const GArray_autoptr = [*c]GArray;
pub const GArray_listautoptr = [*c]GList;
pub const GArray_slistautoptr = [*c]GSList;
pub const GArray_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GArray(arg__ptr: [*c]GArray) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_array_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GArray(arg__ptr: [*c][*c]GArray) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GArray(_ptr.*);
}
pub fn glib_autoptr_destroy_GArray(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_array_unref(@as([*c]GArray, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GArray(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GArray);
}
pub fn glib_slistautoptr_cleanup_GArray(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GArray);
}
pub fn glib_queueautoptr_cleanup_GArray(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GArray);
    }
}
pub const GPtrArray_autoptr = [*c]GPtrArray;
pub const GPtrArray_listautoptr = [*c]GList;
pub const GPtrArray_slistautoptr = [*c]GSList;
pub const GPtrArray_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GPtrArray(arg__ptr: [*c]GPtrArray) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_ptr_array_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GPtrArray(arg__ptr: [*c][*c]GPtrArray) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GPtrArray(_ptr.*);
}
pub fn glib_autoptr_destroy_GPtrArray(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_ptr_array_unref(@as([*c]GPtrArray, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GPtrArray(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GPtrArray);
}
pub fn glib_slistautoptr_cleanup_GPtrArray(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GPtrArray);
}
pub fn glib_queueautoptr_cleanup_GPtrArray(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GPtrArray);
    }
}
pub const GByteArray_autoptr = [*c]GByteArray;
pub const GByteArray_listautoptr = [*c]GList;
pub const GByteArray_slistautoptr = [*c]GSList;
pub const GByteArray_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GByteArray(arg__ptr: [*c]GByteArray) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_byte_array_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GByteArray(arg__ptr: [*c][*c]GByteArray) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GByteArray(_ptr.*);
}
pub fn glib_autoptr_destroy_GByteArray(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_byte_array_unref(@as([*c]GByteArray, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GByteArray(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GByteArray);
}
pub fn glib_slistautoptr_cleanup_GByteArray(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GByteArray);
}
pub fn glib_queueautoptr_cleanup_GByteArray(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GByteArray);
    }
}
pub const GMainContext_autoptr = ?*GMainContext;
pub const GMainContext_listautoptr = [*c]GList;
pub const GMainContext_slistautoptr = [*c]GSList;
pub const GMainContext_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GMainContext(arg__ptr: ?*GMainContext) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_main_context_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GMainContext(arg__ptr: [*c]?*GMainContext) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GMainContext(_ptr.*);
}
pub fn glib_autoptr_destroy_GMainContext(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_main_context_unref(@as(?*GMainContext, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GMainContext(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GMainContext);
}
pub fn glib_slistautoptr_cleanup_GMainContext(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GMainContext);
}
pub fn glib_queueautoptr_cleanup_GMainContext(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GMainContext);
    }
}
pub const GMainContextPusher_autoptr = ?*GMainContextPusher;
pub const GMainContextPusher_listautoptr = [*c]GList;
pub const GMainContextPusher_slistautoptr = [*c]GSList;
pub const GMainContextPusher_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GMainContextPusher(arg__ptr: ?*GMainContextPusher) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_main_context_pusher_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GMainContextPusher(arg__ptr: [*c]?*GMainContextPusher) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GMainContextPusher(_ptr.*);
}
pub fn glib_autoptr_destroy_GMainContextPusher(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_main_context_pusher_free(@as(?*GMainContextPusher, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GMainContextPusher(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GMainContextPusher);
}
pub fn glib_slistautoptr_cleanup_GMainContextPusher(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GMainContextPusher);
}
pub fn glib_queueautoptr_cleanup_GMainContextPusher(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GMainContextPusher);
    }
}
pub const GMainLoop_autoptr = ?*GMainLoop;
pub const GMainLoop_listautoptr = [*c]GList;
pub const GMainLoop_slistautoptr = [*c]GSList;
pub const GMainLoop_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GMainLoop(arg__ptr: ?*GMainLoop) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_main_loop_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GMainLoop(arg__ptr: [*c]?*GMainLoop) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GMainLoop(_ptr.*);
}
pub fn glib_autoptr_destroy_GMainLoop(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_main_loop_unref(@as(?*GMainLoop, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GMainLoop(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GMainLoop);
}
pub fn glib_slistautoptr_cleanup_GMainLoop(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GMainLoop);
}
pub fn glib_queueautoptr_cleanup_GMainLoop(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GMainLoop);
    }
}
pub const GSource_autoptr = [*c]GSource;
pub const GSource_listautoptr = [*c]GList;
pub const GSource_slistautoptr = [*c]GSList;
pub const GSource_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GSource(arg__ptr: [*c]GSource) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_source_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GSource(arg__ptr: [*c][*c]GSource) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GSource(_ptr.*);
}
pub fn glib_autoptr_destroy_GSource(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_source_unref(@as([*c]GSource, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GSource(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GSource);
}
pub fn glib_slistautoptr_cleanup_GSource(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GSource);
}
pub fn glib_queueautoptr_cleanup_GSource(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GSource);
    }
}
pub const GMappedFile_autoptr = ?*GMappedFile;
pub const GMappedFile_listautoptr = [*c]GList;
pub const GMappedFile_slistautoptr = [*c]GSList;
pub const GMappedFile_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GMappedFile(arg__ptr: ?*GMappedFile) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_mapped_file_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GMappedFile(arg__ptr: [*c]?*GMappedFile) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GMappedFile(_ptr.*);
}
pub fn glib_autoptr_destroy_GMappedFile(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_mapped_file_unref(@as(?*GMappedFile, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GMappedFile(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GMappedFile);
}
pub fn glib_slistautoptr_cleanup_GMappedFile(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GMappedFile);
}
pub fn glib_queueautoptr_cleanup_GMappedFile(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GMappedFile);
    }
}
pub const GMarkupParseContext_autoptr = ?*GMarkupParseContext;
pub const GMarkupParseContext_listautoptr = [*c]GList;
pub const GMarkupParseContext_slistautoptr = [*c]GSList;
pub const GMarkupParseContext_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GMarkupParseContext(arg__ptr: ?*GMarkupParseContext) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_markup_parse_context_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GMarkupParseContext(arg__ptr: [*c]?*GMarkupParseContext) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GMarkupParseContext(_ptr.*);
}
pub fn glib_autoptr_destroy_GMarkupParseContext(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_markup_parse_context_unref(@as(?*GMarkupParseContext, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GMarkupParseContext(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GMarkupParseContext);
}
pub fn glib_slistautoptr_cleanup_GMarkupParseContext(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GMarkupParseContext);
}
pub fn glib_queueautoptr_cleanup_GMarkupParseContext(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GMarkupParseContext);
    }
}
pub const GNode_autoptr = [*c]GNode;
pub const GNode_listautoptr = [*c]GList;
pub const GNode_slistautoptr = [*c]GSList;
pub const GNode_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GNode(arg__ptr: [*c]GNode) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_node_destroy(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GNode(arg__ptr: [*c][*c]GNode) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GNode(_ptr.*);
}
pub fn glib_autoptr_destroy_GNode(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_node_destroy(@as([*c]GNode, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GNode(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GNode);
}
pub fn glib_slistautoptr_cleanup_GNode(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GNode);
}
pub fn glib_queueautoptr_cleanup_GNode(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GNode);
    }
}
pub const GOptionContext_autoptr = ?*GOptionContext;
pub const GOptionContext_listautoptr = [*c]GList;
pub const GOptionContext_slistautoptr = [*c]GSList;
pub const GOptionContext_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GOptionContext(arg__ptr: ?*GOptionContext) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_option_context_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GOptionContext(arg__ptr: [*c]?*GOptionContext) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GOptionContext(_ptr.*);
}
pub fn glib_autoptr_destroy_GOptionContext(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_option_context_free(@as(?*GOptionContext, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GOptionContext(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GOptionContext);
}
pub fn glib_slistautoptr_cleanup_GOptionContext(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GOptionContext);
}
pub fn glib_queueautoptr_cleanup_GOptionContext(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GOptionContext);
    }
}
pub const GOptionGroup_autoptr = ?*GOptionGroup;
pub const GOptionGroup_listautoptr = [*c]GList;
pub const GOptionGroup_slistautoptr = [*c]GSList;
pub const GOptionGroup_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GOptionGroup(arg__ptr: ?*GOptionGroup) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_option_group_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GOptionGroup(arg__ptr: [*c]?*GOptionGroup) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GOptionGroup(_ptr.*);
}
pub fn glib_autoptr_destroy_GOptionGroup(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_option_group_unref(@as(?*GOptionGroup, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GOptionGroup(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GOptionGroup);
}
pub fn glib_slistautoptr_cleanup_GOptionGroup(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GOptionGroup);
}
pub fn glib_queueautoptr_cleanup_GOptionGroup(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GOptionGroup);
    }
}
pub const GPatternSpec_autoptr = ?*GPatternSpec;
pub const GPatternSpec_listautoptr = [*c]GList;
pub const GPatternSpec_slistautoptr = [*c]GSList;
pub const GPatternSpec_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GPatternSpec(arg__ptr: ?*GPatternSpec) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_pattern_spec_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GPatternSpec(arg__ptr: [*c]?*GPatternSpec) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GPatternSpec(_ptr.*);
}
pub fn glib_autoptr_destroy_GPatternSpec(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_pattern_spec_free(@as(?*GPatternSpec, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GPatternSpec(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GPatternSpec);
}
pub fn glib_slistautoptr_cleanup_GPatternSpec(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GPatternSpec);
}
pub fn glib_queueautoptr_cleanup_GPatternSpec(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GPatternSpec);
    }
}
pub const GQueue_autoptr = [*c]GQueue;
pub const GQueue_listautoptr = [*c]GList;
pub const GQueue_slistautoptr = [*c]GSList;
pub const GQueue_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GQueue(arg__ptr: [*c]GQueue) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_queue_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GQueue(arg__ptr: [*c][*c]GQueue) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GQueue(_ptr.*);
}
pub fn glib_autoptr_destroy_GQueue(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_queue_free(@as([*c]GQueue, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GQueue(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GQueue);
}
pub fn glib_slistautoptr_cleanup_GQueue(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GQueue);
}
pub fn glib_queueautoptr_cleanup_GQueue(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GQueue);
    }
}
pub fn glib_auto_cleanup_GQueue(arg__ptr: [*c]GQueue) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_queue_clear(_ptr);
}
pub const GRand_autoptr = ?*GRand;
pub const GRand_listautoptr = [*c]GList;
pub const GRand_slistautoptr = [*c]GSList;
pub const GRand_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GRand(arg__ptr: ?*GRand) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_rand_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GRand(arg__ptr: [*c]?*GRand) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GRand(_ptr.*);
}
pub fn glib_autoptr_destroy_GRand(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_rand_free(@as(?*GRand, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GRand(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GRand);
}
pub fn glib_slistautoptr_cleanup_GRand(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GRand);
}
pub fn glib_queueautoptr_cleanup_GRand(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GRand);
    }
}
pub const GRegex_autoptr = ?*GRegex;
pub const GRegex_listautoptr = [*c]GList;
pub const GRegex_slistautoptr = [*c]GSList;
pub const GRegex_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GRegex(arg__ptr: ?*GRegex) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_regex_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GRegex(arg__ptr: [*c]?*GRegex) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GRegex(_ptr.*);
}
pub fn glib_autoptr_destroy_GRegex(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_regex_unref(@as(?*GRegex, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GRegex(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GRegex);
}
pub fn glib_slistautoptr_cleanup_GRegex(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GRegex);
}
pub fn glib_queueautoptr_cleanup_GRegex(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GRegex);
    }
}
pub const GMatchInfo_autoptr = ?*GMatchInfo;
pub const GMatchInfo_listautoptr = [*c]GList;
pub const GMatchInfo_slistautoptr = [*c]GSList;
pub const GMatchInfo_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GMatchInfo(arg__ptr: ?*GMatchInfo) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_match_info_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GMatchInfo(arg__ptr: [*c]?*GMatchInfo) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GMatchInfo(_ptr.*);
}
pub fn glib_autoptr_destroy_GMatchInfo(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_match_info_unref(@as(?*GMatchInfo, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GMatchInfo(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GMatchInfo);
}
pub fn glib_slistautoptr_cleanup_GMatchInfo(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GMatchInfo);
}
pub fn glib_queueautoptr_cleanup_GMatchInfo(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GMatchInfo);
    }
}
pub const GScanner_autoptr = [*c]GScanner;
pub const GScanner_listautoptr = [*c]GList;
pub const GScanner_slistautoptr = [*c]GSList;
pub const GScanner_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GScanner(arg__ptr: [*c]GScanner) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_scanner_destroy(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GScanner(arg__ptr: [*c][*c]GScanner) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GScanner(_ptr.*);
}
pub fn glib_autoptr_destroy_GScanner(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_scanner_destroy(@as([*c]GScanner, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GScanner(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GScanner);
}
pub fn glib_slistautoptr_cleanup_GScanner(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GScanner);
}
pub fn glib_queueautoptr_cleanup_GScanner(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GScanner);
    }
}
pub const GSequence_autoptr = ?*GSequence;
pub const GSequence_listautoptr = [*c]GList;
pub const GSequence_slistautoptr = [*c]GSList;
pub const GSequence_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GSequence(arg__ptr: ?*GSequence) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_sequence_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GSequence(arg__ptr: [*c]?*GSequence) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GSequence(_ptr.*);
}
pub fn glib_autoptr_destroy_GSequence(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_sequence_free(@as(?*GSequence, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GSequence(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GSequence);
}
pub fn glib_slistautoptr_cleanup_GSequence(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GSequence);
}
pub fn glib_queueautoptr_cleanup_GSequence(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GSequence);
    }
}
pub const GSList_autoptr = [*c]GSList;
pub const GSList_listautoptr = [*c]GList;
pub const GSList_slistautoptr = [*c]GSList;
pub const GSList_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GSList(arg__ptr: [*c]GSList) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_slist_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GSList(arg__ptr: [*c][*c]GSList) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GSList(_ptr.*);
}
pub fn glib_autoptr_destroy_GSList(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_slist_free(@as([*c]GSList, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GSList(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GSList);
}
pub fn glib_slistautoptr_cleanup_GSList(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GSList);
}
pub fn glib_queueautoptr_cleanup_GSList(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GSList);
    }
}
pub const GString_autoptr = [*c]GString;
pub const GString_listautoptr = [*c]GList;
pub const GString_slistautoptr = [*c]GSList;
pub const GString_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GString(arg__ptr: [*c]GString) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_autoptr_cleanup_gstring_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GString(arg__ptr: [*c][*c]GString) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GString(_ptr.*);
}
pub fn glib_autoptr_destroy_GString(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_autoptr_cleanup_gstring_free(@as([*c]GString, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GString(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GString);
}
pub fn glib_slistautoptr_cleanup_GString(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GString);
}
pub fn glib_queueautoptr_cleanup_GString(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GString);
    }
}
pub const GStringChunk_autoptr = ?*GStringChunk;
pub const GStringChunk_listautoptr = [*c]GList;
pub const GStringChunk_slistautoptr = [*c]GSList;
pub const GStringChunk_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GStringChunk(arg__ptr: ?*GStringChunk) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_string_chunk_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GStringChunk(arg__ptr: [*c]?*GStringChunk) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GStringChunk(_ptr.*);
}
pub fn glib_autoptr_destroy_GStringChunk(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_string_chunk_free(@as(?*GStringChunk, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GStringChunk(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GStringChunk);
}
pub fn glib_slistautoptr_cleanup_GStringChunk(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GStringChunk);
}
pub fn glib_queueautoptr_cleanup_GStringChunk(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GStringChunk);
    }
}
pub const GStrvBuilder_autoptr = ?*GStrvBuilder;
pub const GStrvBuilder_listautoptr = [*c]GList;
pub const GStrvBuilder_slistautoptr = [*c]GSList;
pub const GStrvBuilder_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GStrvBuilder(arg__ptr: ?*GStrvBuilder) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_strv_builder_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GStrvBuilder(arg__ptr: [*c]?*GStrvBuilder) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GStrvBuilder(_ptr.*);
}
pub fn glib_autoptr_destroy_GStrvBuilder(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_strv_builder_unref(@as(?*GStrvBuilder, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GStrvBuilder(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GStrvBuilder);
}
pub fn glib_slistautoptr_cleanup_GStrvBuilder(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GStrvBuilder);
}
pub fn glib_queueautoptr_cleanup_GStrvBuilder(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GStrvBuilder);
    }
}
pub const GThread_autoptr = [*c]GThread;
pub const GThread_listautoptr = [*c]GList;
pub const GThread_slistautoptr = [*c]GSList;
pub const GThread_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GThread(arg__ptr: [*c]GThread) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_thread_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GThread(arg__ptr: [*c][*c]GThread) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GThread(_ptr.*);
}
pub fn glib_autoptr_destroy_GThread(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_thread_unref(@as([*c]GThread, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GThread(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GThread);
}
pub fn glib_slistautoptr_cleanup_GThread(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GThread);
}
pub fn glib_queueautoptr_cleanup_GThread(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GThread);
    }
}
pub fn glib_auto_cleanup_GMutex(arg__ptr: [*c]GMutex) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_mutex_clear(_ptr);
}
pub const GMutexLocker_autoptr = ?*GMutexLocker;
pub const GMutexLocker_listautoptr = [*c]GList;
pub const GMutexLocker_slistautoptr = [*c]GSList;
pub const GMutexLocker_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GMutexLocker(arg__ptr: ?*GMutexLocker) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_mutex_locker_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GMutexLocker(arg__ptr: [*c]?*GMutexLocker) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GMutexLocker(_ptr.*);
}
pub fn glib_autoptr_destroy_GMutexLocker(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_mutex_locker_free(@as(?*GMutexLocker, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GMutexLocker(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GMutexLocker);
}
pub fn glib_slistautoptr_cleanup_GMutexLocker(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GMutexLocker);
}
pub fn glib_queueautoptr_cleanup_GMutexLocker(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GMutexLocker);
    }
}
pub const GRecMutexLocker_autoptr = ?*GRecMutexLocker;
pub const GRecMutexLocker_listautoptr = [*c]GList;
pub const GRecMutexLocker_slistautoptr = [*c]GSList;
pub const GRecMutexLocker_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GRecMutexLocker(arg__ptr: ?*GRecMutexLocker) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_rec_mutex_locker_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GRecMutexLocker(arg__ptr: [*c]?*GRecMutexLocker) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GRecMutexLocker(_ptr.*);
}
pub fn glib_autoptr_destroy_GRecMutexLocker(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_rec_mutex_locker_free(@as(?*GRecMutexLocker, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GRecMutexLocker(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GRecMutexLocker);
}
pub fn glib_slistautoptr_cleanup_GRecMutexLocker(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GRecMutexLocker);
}
pub fn glib_queueautoptr_cleanup_GRecMutexLocker(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GRecMutexLocker);
    }
}
pub const GRWLockWriterLocker_autoptr = ?*GRWLockWriterLocker;
pub const GRWLockWriterLocker_listautoptr = [*c]GList;
pub const GRWLockWriterLocker_slistautoptr = [*c]GSList;
pub const GRWLockWriterLocker_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GRWLockWriterLocker(arg__ptr: ?*GRWLockWriterLocker) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_rw_lock_writer_locker_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GRWLockWriterLocker(arg__ptr: [*c]?*GRWLockWriterLocker) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GRWLockWriterLocker(_ptr.*);
}
pub fn glib_autoptr_destroy_GRWLockWriterLocker(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_rw_lock_writer_locker_free(@as(?*GRWLockWriterLocker, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GRWLockWriterLocker(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GRWLockWriterLocker);
}
pub fn glib_slistautoptr_cleanup_GRWLockWriterLocker(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GRWLockWriterLocker);
}
pub fn glib_queueautoptr_cleanup_GRWLockWriterLocker(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GRWLockWriterLocker);
    }
}
pub const GRWLockReaderLocker_autoptr = ?*GRWLockReaderLocker;
pub const GRWLockReaderLocker_listautoptr = [*c]GList;
pub const GRWLockReaderLocker_slistautoptr = [*c]GSList;
pub const GRWLockReaderLocker_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GRWLockReaderLocker(arg__ptr: ?*GRWLockReaderLocker) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_rw_lock_reader_locker_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GRWLockReaderLocker(arg__ptr: [*c]?*GRWLockReaderLocker) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GRWLockReaderLocker(_ptr.*);
}
pub fn glib_autoptr_destroy_GRWLockReaderLocker(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_rw_lock_reader_locker_free(@as(?*GRWLockReaderLocker, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GRWLockReaderLocker(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GRWLockReaderLocker);
}
pub fn glib_slistautoptr_cleanup_GRWLockReaderLocker(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GRWLockReaderLocker);
}
pub fn glib_queueautoptr_cleanup_GRWLockReaderLocker(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GRWLockReaderLocker);
    }
}
pub fn glib_auto_cleanup_GCond(arg__ptr: [*c]GCond) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_cond_clear(_ptr);
}
pub const GTimer_autoptr = ?*GTimer;
pub const GTimer_listautoptr = [*c]GList;
pub const GTimer_slistautoptr = [*c]GSList;
pub const GTimer_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GTimer(arg__ptr: ?*GTimer) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_timer_destroy(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GTimer(arg__ptr: [*c]?*GTimer) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GTimer(_ptr.*);
}
pub fn glib_autoptr_destroy_GTimer(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_timer_destroy(@as(?*GTimer, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GTimer(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GTimer);
}
pub fn glib_slistautoptr_cleanup_GTimer(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GTimer);
}
pub fn glib_queueautoptr_cleanup_GTimer(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GTimer);
    }
}
pub const GTimeZone_autoptr = ?*GTimeZone;
pub const GTimeZone_listautoptr = [*c]GList;
pub const GTimeZone_slistautoptr = [*c]GSList;
pub const GTimeZone_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GTimeZone(arg__ptr: ?*GTimeZone) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_time_zone_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GTimeZone(arg__ptr: [*c]?*GTimeZone) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GTimeZone(_ptr.*);
}
pub fn glib_autoptr_destroy_GTimeZone(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_time_zone_unref(@as(?*GTimeZone, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GTimeZone(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GTimeZone);
}
pub fn glib_slistautoptr_cleanup_GTimeZone(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GTimeZone);
}
pub fn glib_queueautoptr_cleanup_GTimeZone(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GTimeZone);
    }
}
pub const GTree_autoptr = ?*GTree;
pub const GTree_listautoptr = [*c]GList;
pub const GTree_slistautoptr = [*c]GSList;
pub const GTree_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GTree(arg__ptr: ?*GTree) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_tree_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GTree(arg__ptr: [*c]?*GTree) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GTree(_ptr.*);
}
pub fn glib_autoptr_destroy_GTree(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_tree_unref(@as(?*GTree, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GTree(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GTree);
}
pub fn glib_slistautoptr_cleanup_GTree(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GTree);
}
pub fn glib_queueautoptr_cleanup_GTree(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GTree);
    }
}
pub const GVariant_autoptr = ?*GVariant;
pub const GVariant_listautoptr = [*c]GList;
pub const GVariant_slistautoptr = [*c]GSList;
pub const GVariant_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GVariant(arg__ptr: ?*GVariant) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_variant_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GVariant(arg__ptr: [*c]?*GVariant) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GVariant(_ptr.*);
}
pub fn glib_autoptr_destroy_GVariant(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_variant_unref(@as(?*GVariant, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GVariant(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GVariant);
}
pub fn glib_slistautoptr_cleanup_GVariant(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GVariant);
}
pub fn glib_queueautoptr_cleanup_GVariant(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GVariant);
    }
}
pub const GVariantBuilder_autoptr = [*c]GVariantBuilder;
pub const GVariantBuilder_listautoptr = [*c]GList;
pub const GVariantBuilder_slistautoptr = [*c]GSList;
pub const GVariantBuilder_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GVariantBuilder(arg__ptr: [*c]GVariantBuilder) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_variant_builder_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GVariantBuilder(arg__ptr: [*c][*c]GVariantBuilder) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GVariantBuilder(_ptr.*);
}
pub fn glib_autoptr_destroy_GVariantBuilder(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_variant_builder_unref(@as([*c]GVariantBuilder, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GVariantBuilder(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GVariantBuilder);
}
pub fn glib_slistautoptr_cleanup_GVariantBuilder(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GVariantBuilder);
}
pub fn glib_queueautoptr_cleanup_GVariantBuilder(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GVariantBuilder);
    }
}
pub fn glib_auto_cleanup_GVariantBuilder(arg__ptr: [*c]GVariantBuilder) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_variant_builder_clear(_ptr);
}
pub const GVariantIter_autoptr = [*c]GVariantIter;
pub const GVariantIter_listautoptr = [*c]GList;
pub const GVariantIter_slistautoptr = [*c]GSList;
pub const GVariantIter_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GVariantIter(arg__ptr: [*c]GVariantIter) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_variant_iter_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GVariantIter(arg__ptr: [*c][*c]GVariantIter) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GVariantIter(_ptr.*);
}
pub fn glib_autoptr_destroy_GVariantIter(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_variant_iter_free(@as([*c]GVariantIter, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GVariantIter(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GVariantIter);
}
pub fn glib_slistautoptr_cleanup_GVariantIter(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GVariantIter);
}
pub fn glib_queueautoptr_cleanup_GVariantIter(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GVariantIter);
    }
}
pub const GVariantDict_autoptr = [*c]GVariantDict;
pub const GVariantDict_listautoptr = [*c]GList;
pub const GVariantDict_slistautoptr = [*c]GSList;
pub const GVariantDict_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GVariantDict(arg__ptr: [*c]GVariantDict) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_variant_dict_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GVariantDict(arg__ptr: [*c][*c]GVariantDict) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GVariantDict(_ptr.*);
}
pub fn glib_autoptr_destroy_GVariantDict(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_variant_dict_unref(@as([*c]GVariantDict, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GVariantDict(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GVariantDict);
}
pub fn glib_slistautoptr_cleanup_GVariantDict(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GVariantDict);
}
pub fn glib_queueautoptr_cleanup_GVariantDict(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GVariantDict);
    }
}
pub fn glib_auto_cleanup_GVariantDict(arg__ptr: [*c]GVariantDict) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_variant_dict_clear(_ptr);
}
pub const GVariantType_autoptr = ?*GVariantType;
pub const GVariantType_listautoptr = [*c]GList;
pub const GVariantType_slistautoptr = [*c]GSList;
pub const GVariantType_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GVariantType(arg__ptr: ?*GVariantType) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_variant_type_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GVariantType(arg__ptr: [*c]?*GVariantType) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GVariantType(_ptr.*);
}
pub fn glib_autoptr_destroy_GVariantType(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_variant_type_free(@as(?*GVariantType, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GVariantType(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GVariantType);
}
pub fn glib_slistautoptr_cleanup_GVariantType(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GVariantType);
}
pub fn glib_queueautoptr_cleanup_GVariantType(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GVariantType);
    }
}
pub fn glib_auto_cleanup_GStrv(arg__ptr: [*c]GStrv) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr.* != @as(GStrv, @ptrCast(@alignCast(@as(?*anyopaque, @ptrFromInt(@as(c_int, 0))))))) {
        g_strfreev(_ptr.*);
    }
}
pub const GRefString_autoptr = [*c]GRefString;
pub const GRefString_listautoptr = [*c]GList;
pub const GRefString_slistautoptr = [*c]GSList;
pub const GRefString_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GRefString(arg__ptr: [*c]GRefString) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_ref_string_release(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GRefString(arg__ptr: [*c][*c]GRefString) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GRefString(_ptr.*);
}
pub fn glib_autoptr_destroy_GRefString(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_ref_string_release(@as([*c]GRefString, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GRefString(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GRefString);
}
pub fn glib_slistautoptr_cleanup_GRefString(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GRefString);
}
pub fn glib_queueautoptr_cleanup_GRefString(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GRefString);
    }
}
pub const GUri_autoptr = ?*GUri;
pub const GUri_listautoptr = [*c]GList;
pub const GUri_slistautoptr = [*c]GSList;
pub const GUri_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GUri(arg__ptr: ?*GUri) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_uri_unref(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GUri(arg__ptr: [*c]?*GUri) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GUri(_ptr.*);
}
pub fn glib_autoptr_destroy_GUri(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_uri_unref(@as(?*GUri, @ptrCast(_ptr)));
}
pub fn glib_listautoptr_cleanup_GUri(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GUri);
}
pub fn glib_slistautoptr_cleanup_GUri(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GUri);
}
pub fn glib_queueautoptr_cleanup_GUri(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GUri);
    }
}
pub const GPathBuf_autoptr = [*c]GPathBuf;
pub const GPathBuf_listautoptr = [*c]GList;
pub const GPathBuf_slistautoptr = [*c]GSList;
pub const GPathBuf_queueautoptr = [*c]GQueue;
pub fn glib_autoptr_clear_GPathBuf(arg__ptr: [*c]GPathBuf) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    if (_ptr != null) {
        g_path_buf_free(_ptr);
    }
}
pub fn glib_autoptr_cleanup_GPathBuf(arg__ptr: [*c][*c]GPathBuf) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    glib_autoptr_clear_GPathBuf(_ptr.*);
}
pub fn glib_autoptr_destroy_GPathBuf(arg__ptr: ?*anyopaque) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_path_buf_free(@as([*c]GPathBuf, @ptrCast(@alignCast(_ptr))));
}
pub fn glib_listautoptr_cleanup_GPathBuf(arg__l: [*c][*c]GList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_list_free_full(_l.*, &glib_autoptr_destroy_GPathBuf);
}
pub fn glib_slistautoptr_cleanup_GPathBuf(arg__l: [*c][*c]GSList) callconv(.c) void {
    var _l = arg__l;
    _ = &_l;
    g_slist_free_full(_l.*, &glib_autoptr_destroy_GPathBuf);
}
pub fn glib_queueautoptr_cleanup_GPathBuf(arg__q: [*c][*c]GQueue) callconv(.c) void {
    var _q = arg__q;
    _ = &_q;
    if (_q.* != null) {
        g_queue_free_full(_q.*, &glib_autoptr_destroy_GPathBuf);
    }
}
pub fn glib_auto_cleanup_GPathBuf(arg__ptr: [*c]GPathBuf) callconv(.c) void {
    var _ptr = arg__ptr;
    _ = &_ptr;
    g_path_buf_clear(_ptr);
}
pub const __llvm__ = @as(c_int, 1);
pub const __clang__ = @as(c_int, 1);
pub const __clang_major__ = @as(c_int, 20);
pub const __clang_minor__ = @as(c_int, 1);
pub const __clang_patchlevel__ = @as(c_int, 2);
pub const __clang_version__ = "20.1.2 (https://github.com/ziglang/zig-bootstrap 7ef74e656cf8ddbd6bf891a8475892aa1afa6891)";
pub const __GNUC__ = @as(c_int, 4);
pub const __GNUC_MINOR__ = @as(c_int, 2);
pub const __GNUC_PATCHLEVEL__ = @as(c_int, 1);
pub const __GXX_ABI_VERSION = @as(c_int, 1002);
pub const __ATOMIC_RELAXED = @as(c_int, 0);
pub const __ATOMIC_CONSUME = @as(c_int, 1);
pub const __ATOMIC_ACQUIRE = @as(c_int, 2);
pub const __ATOMIC_RELEASE = @as(c_int, 3);
pub const __ATOMIC_ACQ_REL = @as(c_int, 4);
pub const __ATOMIC_SEQ_CST = @as(c_int, 5);
pub const __MEMORY_SCOPE_SYSTEM = @as(c_int, 0);
pub const __MEMORY_SCOPE_DEVICE = @as(c_int, 1);
pub const __MEMORY_SCOPE_WRKGRP = @as(c_int, 2);
pub const __MEMORY_SCOPE_WVFRNT = @as(c_int, 3);
pub const __MEMORY_SCOPE_SINGLE = @as(c_int, 4);
pub const __OPENCL_MEMORY_SCOPE_WORK_ITEM = @as(c_int, 0);
pub const __OPENCL_MEMORY_SCOPE_WORK_GROUP = @as(c_int, 1);
pub const __OPENCL_MEMORY_SCOPE_DEVICE = @as(c_int, 2);
pub const __OPENCL_MEMORY_SCOPE_ALL_SVM_DEVICES = @as(c_int, 3);
pub const __OPENCL_MEMORY_SCOPE_SUB_GROUP = @as(c_int, 4);
pub const __FPCLASS_SNAN = @as(c_int, 0x0001);
pub const __FPCLASS_QNAN = @as(c_int, 0x0002);
pub const __FPCLASS_NEGINF = @as(c_int, 0x0004);
pub const __FPCLASS_NEGNORMAL = @as(c_int, 0x0008);
pub const __FPCLASS_NEGSUBNORMAL = @as(c_int, 0x0010);
pub const __FPCLASS_NEGZERO = @as(c_int, 0x0020);
pub const __FPCLASS_POSZERO = @as(c_int, 0x0040);
pub const __FPCLASS_POSSUBNORMAL = @as(c_int, 0x0080);
pub const __FPCLASS_POSNORMAL = @as(c_int, 0x0100);
pub const __FPCLASS_POSINF = @as(c_int, 0x0200);
pub const __PRAGMA_REDEFINE_EXTNAME = @as(c_int, 1);
pub const __VERSION__ = "Clang 20.1.2 (https://github.com/ziglang/zig-bootstrap 7ef74e656cf8ddbd6bf891a8475892aa1afa6891)";
pub const __OBJC_BOOL_IS_BOOL = @as(c_int, 0);
pub const __CONSTANT_CFSTRINGS__ = @as(c_int, 1);
pub const __clang_literal_encoding__ = "UTF-8";
pub const __clang_wide_literal_encoding__ = "UTF-32";
pub const __ORDER_LITTLE_ENDIAN__ = @as(c_int, 1234);
pub const __ORDER_BIG_ENDIAN__ = @as(c_int, 4321);
pub const __ORDER_PDP_ENDIAN__ = @as(c_int, 3412);
pub const __BYTE_ORDER__ = __ORDER_LITTLE_ENDIAN__;
pub const __LITTLE_ENDIAN__ = @as(c_int, 1);
pub const _LP64 = @as(c_int, 1);
pub const __LP64__ = @as(c_int, 1);
pub const __CHAR_BIT__ = @as(c_int, 8);
pub const __BOOL_WIDTH__ = @as(c_int, 1);
pub const __SHRT_WIDTH__ = @as(c_int, 16);
pub const __INT_WIDTH__ = @as(c_int, 32);
pub const __LONG_WIDTH__ = @as(c_int, 64);
pub const __LLONG_WIDTH__ = @as(c_int, 64);
pub const __BITINT_MAXWIDTH__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 8388608, .decimal);
pub const __SCHAR_MAX__ = @as(c_int, 127);
pub const __SHRT_MAX__ = @as(c_int, 32767);
pub const __INT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __LONG_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __LONG_LONG_MAX__ = @as(c_longlong, 9223372036854775807);
pub const __WCHAR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __WCHAR_WIDTH__ = @as(c_int, 32);
pub const __WINT_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __WINT_WIDTH__ = @as(c_int, 32);
pub const __INTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTMAX_WIDTH__ = @as(c_int, 64);
pub const __SIZE_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __SIZE_WIDTH__ = @as(c_int, 64);
pub const __UINTMAX_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTMAX_WIDTH__ = @as(c_int, 64);
pub const __PTRDIFF_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __PTRDIFF_WIDTH__ = @as(c_int, 64);
pub const __INTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INTPTR_WIDTH__ = @as(c_int, 64);
pub const __UINTPTR_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINTPTR_WIDTH__ = @as(c_int, 64);
pub const __SIZEOF_DOUBLE__ = @as(c_int, 8);
pub const __SIZEOF_FLOAT__ = @as(c_int, 4);
pub const __SIZEOF_INT__ = @as(c_int, 4);
pub const __SIZEOF_LONG__ = @as(c_int, 8);
pub const __SIZEOF_LONG_DOUBLE__ = @as(c_int, 16);
pub const __SIZEOF_LONG_LONG__ = @as(c_int, 8);
pub const __SIZEOF_POINTER__ = @as(c_int, 8);
pub const __SIZEOF_SHORT__ = @as(c_int, 2);
pub const __SIZEOF_PTRDIFF_T__ = @as(c_int, 8);
pub const __SIZEOF_SIZE_T__ = @as(c_int, 8);
pub const __SIZEOF_WCHAR_T__ = @as(c_int, 4);
pub const __SIZEOF_WINT_T__ = @as(c_int, 4);
pub const __SIZEOF_INT128__ = @as(c_int, 16);
pub const __INTMAX_TYPE__ = c_long;
pub const __INTMAX_FMTd__ = "ld";
pub const __INTMAX_FMTi__ = "li";
pub const __INTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`");
// (no file):95:9
pub const __INTMAX_C = @import("std").zig.c_translation.Macros.L_SUFFIX;
pub const __UINTMAX_TYPE__ = c_ulong;
pub const __UINTMAX_FMTo__ = "lo";
pub const __UINTMAX_FMTu__ = "lu";
pub const __UINTMAX_FMTx__ = "lx";
pub const __UINTMAX_FMTX__ = "lX";
pub const __UINTMAX_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`");
// (no file):102:9
pub const __UINTMAX_C = @import("std").zig.c_translation.Macros.UL_SUFFIX;
pub const __PTRDIFF_TYPE__ = c_long;
pub const __PTRDIFF_FMTd__ = "ld";
pub const __PTRDIFF_FMTi__ = "li";
pub const __INTPTR_TYPE__ = c_long;
pub const __INTPTR_FMTd__ = "ld";
pub const __INTPTR_FMTi__ = "li";
pub const __SIZE_TYPE__ = c_ulong;
pub const __SIZE_FMTo__ = "lo";
pub const __SIZE_FMTu__ = "lu";
pub const __SIZE_FMTx__ = "lx";
pub const __SIZE_FMTX__ = "lX";
pub const __WCHAR_TYPE__ = c_int;
pub const __WINT_TYPE__ = c_uint;
pub const __SIG_ATOMIC_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __SIG_ATOMIC_WIDTH__ = @as(c_int, 32);
pub const __CHAR16_TYPE__ = c_ushort;
pub const __CHAR32_TYPE__ = c_uint;
pub const __UINTPTR_TYPE__ = c_ulong;
pub const __UINTPTR_FMTo__ = "lo";
pub const __UINTPTR_FMTu__ = "lu";
pub const __UINTPTR_FMTx__ = "lx";
pub const __UINTPTR_FMTX__ = "lX";
pub const __FLT16_DENORM_MIN__ = @as(f16, 5.9604644775390625e-8);
pub const __FLT16_NORM_MAX__ = @as(f16, 6.5504e+4);
pub const __FLT16_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT16_DIG__ = @as(c_int, 3);
pub const __FLT16_DECIMAL_DIG__ = @as(c_int, 5);
pub const __FLT16_EPSILON__ = @as(f16, 9.765625e-4);
pub const __FLT16_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT16_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT16_MANT_DIG__ = @as(c_int, 11);
pub const __FLT16_MAX_10_EXP__ = @as(c_int, 4);
pub const __FLT16_MAX_EXP__ = @as(c_int, 16);
pub const __FLT16_MAX__ = @as(f16, 6.5504e+4);
pub const __FLT16_MIN_10_EXP__ = -@as(c_int, 4);
pub const __FLT16_MIN_EXP__ = -@as(c_int, 13);
pub const __FLT16_MIN__ = @as(f16, 6.103515625e-5);
pub const __FLT_DENORM_MIN__ = @as(f32, 1.40129846e-45);
pub const __FLT_NORM_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_HAS_DENORM__ = @as(c_int, 1);
pub const __FLT_DIG__ = @as(c_int, 6);
pub const __FLT_DECIMAL_DIG__ = @as(c_int, 9);
pub const __FLT_EPSILON__ = @as(f32, 1.19209290e-7);
pub const __FLT_HAS_INFINITY__ = @as(c_int, 1);
pub const __FLT_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __FLT_MANT_DIG__ = @as(c_int, 24);
pub const __FLT_MAX_10_EXP__ = @as(c_int, 38);
pub const __FLT_MAX_EXP__ = @as(c_int, 128);
pub const __FLT_MAX__ = @as(f32, 3.40282347e+38);
pub const __FLT_MIN_10_EXP__ = -@as(c_int, 37);
pub const __FLT_MIN_EXP__ = -@as(c_int, 125);
pub const __FLT_MIN__ = @as(f32, 1.17549435e-38);
pub const __DBL_DENORM_MIN__ = @as(f64, 4.9406564584124654e-324);
pub const __DBL_NORM_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __DBL_HAS_DENORM__ = @as(c_int, 1);
pub const __DBL_DIG__ = @as(c_int, 15);
pub const __DBL_DECIMAL_DIG__ = @as(c_int, 17);
pub const __DBL_EPSILON__ = @as(f64, 2.2204460492503131e-16);
pub const __DBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __DBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __DBL_MANT_DIG__ = @as(c_int, 53);
pub const __DBL_MAX_10_EXP__ = @as(c_int, 308);
pub const __DBL_MAX_EXP__ = @as(c_int, 1024);
pub const __DBL_MAX__ = @as(f64, 1.7976931348623157e+308);
pub const __DBL_MIN_10_EXP__ = -@as(c_int, 307);
pub const __DBL_MIN_EXP__ = -@as(c_int, 1021);
pub const __DBL_MIN__ = @as(f64, 2.2250738585072014e-308);
pub const __LDBL_DENORM_MIN__ = @as(c_longdouble, 3.64519953188247460253e-4951);
pub const __LDBL_NORM_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __LDBL_HAS_DENORM__ = @as(c_int, 1);
pub const __LDBL_DIG__ = @as(c_int, 18);
pub const __LDBL_DECIMAL_DIG__ = @as(c_int, 21);
pub const __LDBL_EPSILON__ = @as(c_longdouble, 1.08420217248550443401e-19);
pub const __LDBL_HAS_INFINITY__ = @as(c_int, 1);
pub const __LDBL_HAS_QUIET_NAN__ = @as(c_int, 1);
pub const __LDBL_MANT_DIG__ = @as(c_int, 64);
pub const __LDBL_MAX_10_EXP__ = @as(c_int, 4932);
pub const __LDBL_MAX_EXP__ = @as(c_int, 16384);
pub const __LDBL_MAX__ = @as(c_longdouble, 1.18973149535723176502e+4932);
pub const __LDBL_MIN_10_EXP__ = -@as(c_int, 4931);
pub const __LDBL_MIN_EXP__ = -@as(c_int, 16381);
pub const __LDBL_MIN__ = @as(c_longdouble, 3.36210314311209350626e-4932);
pub const __POINTER_WIDTH__ = @as(c_int, 64);
pub const __BIGGEST_ALIGNMENT__ = @as(c_int, 16);
pub const __WINT_UNSIGNED__ = @as(c_int, 1);
pub const __INT8_TYPE__ = i8;
pub const __INT8_FMTd__ = "hhd";
pub const __INT8_FMTi__ = "hhi";
pub const __INT8_C_SUFFIX__ = "";
pub inline fn __INT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT16_TYPE__ = c_short;
pub const __INT16_FMTd__ = "hd";
pub const __INT16_FMTi__ = "hi";
pub const __INT16_C_SUFFIX__ = "";
pub inline fn __INT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT32_TYPE__ = c_int;
pub const __INT32_FMTd__ = "d";
pub const __INT32_FMTi__ = "i";
pub const __INT32_C_SUFFIX__ = "";
pub inline fn __INT32_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __INT64_TYPE__ = c_long;
pub const __INT64_FMTd__ = "ld";
pub const __INT64_FMTi__ = "li";
pub const __INT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `L`");
// (no file):207:9
pub const __INT64_C = @import("std").zig.c_translation.Macros.L_SUFFIX;
pub const __UINT8_TYPE__ = u8;
pub const __UINT8_FMTo__ = "hho";
pub const __UINT8_FMTu__ = "hhu";
pub const __UINT8_FMTx__ = "hhx";
pub const __UINT8_FMTX__ = "hhX";
pub const __UINT8_C_SUFFIX__ = "";
pub inline fn __UINT8_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __UINT8_MAX__ = @as(c_int, 255);
pub const __INT8_MAX__ = @as(c_int, 127);
pub const __UINT16_TYPE__ = c_ushort;
pub const __UINT16_FMTo__ = "ho";
pub const __UINT16_FMTu__ = "hu";
pub const __UINT16_FMTx__ = "hx";
pub const __UINT16_FMTX__ = "hX";
pub const __UINT16_C_SUFFIX__ = "";
pub inline fn __UINT16_C(c: anytype) @TypeOf(c) {
    _ = &c;
    return c;
}
pub const __UINT16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __INT16_MAX__ = @as(c_int, 32767);
pub const __UINT32_TYPE__ = c_uint;
pub const __UINT32_FMTo__ = "o";
pub const __UINT32_FMTu__ = "u";
pub const __UINT32_FMTx__ = "x";
pub const __UINT32_FMTX__ = "X";
pub const __UINT32_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `U`");
// (no file):232:9
pub const __UINT32_C = @import("std").zig.c_translation.Macros.U_SUFFIX;
pub const __UINT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __INT32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __UINT64_TYPE__ = c_ulong;
pub const __UINT64_FMTo__ = "lo";
pub const __UINT64_FMTu__ = "lu";
pub const __UINT64_FMTx__ = "lx";
pub const __UINT64_FMTX__ = "lX";
pub const __UINT64_C_SUFFIX__ = @compileError("unable to translate macro: undefined identifier `UL`");
// (no file):241:9
pub const __UINT64_C = @import("std").zig.c_translation.Macros.UL_SUFFIX;
pub const __UINT64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __INT64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST8_TYPE__ = i8;
pub const __INT_LEAST8_MAX__ = @as(c_int, 127);
pub const __INT_LEAST8_WIDTH__ = @as(c_int, 8);
pub const __INT_LEAST8_FMTd__ = "hhd";
pub const __INT_LEAST8_FMTi__ = "hhi";
pub const __UINT_LEAST8_TYPE__ = u8;
pub const __UINT_LEAST8_MAX__ = @as(c_int, 255);
pub const __UINT_LEAST8_FMTo__ = "hho";
pub const __UINT_LEAST8_FMTu__ = "hhu";
pub const __UINT_LEAST8_FMTx__ = "hhx";
pub const __UINT_LEAST8_FMTX__ = "hhX";
pub const __INT_LEAST16_TYPE__ = c_short;
pub const __INT_LEAST16_MAX__ = @as(c_int, 32767);
pub const __INT_LEAST16_WIDTH__ = @as(c_int, 16);
pub const __INT_LEAST16_FMTd__ = "hd";
pub const __INT_LEAST16_FMTi__ = "hi";
pub const __UINT_LEAST16_TYPE__ = c_ushort;
pub const __UINT_LEAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_LEAST16_FMTo__ = "ho";
pub const __UINT_LEAST16_FMTu__ = "hu";
pub const __UINT_LEAST16_FMTx__ = "hx";
pub const __UINT_LEAST16_FMTX__ = "hX";
pub const __INT_LEAST32_TYPE__ = c_int;
pub const __INT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_LEAST32_WIDTH__ = @as(c_int, 32);
pub const __INT_LEAST32_FMTd__ = "d";
pub const __INT_LEAST32_FMTi__ = "i";
pub const __UINT_LEAST32_TYPE__ = c_uint;
pub const __UINT_LEAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_LEAST32_FMTo__ = "o";
pub const __UINT_LEAST32_FMTu__ = "u";
pub const __UINT_LEAST32_FMTx__ = "x";
pub const __UINT_LEAST32_FMTX__ = "X";
pub const __INT_LEAST64_TYPE__ = c_long;
pub const __INT_LEAST64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_LEAST64_WIDTH__ = @as(c_int, 64);
pub const __INT_LEAST64_FMTd__ = "ld";
pub const __INT_LEAST64_FMTi__ = "li";
pub const __UINT_LEAST64_TYPE__ = c_ulong;
pub const __UINT_LEAST64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINT_LEAST64_FMTo__ = "lo";
pub const __UINT_LEAST64_FMTu__ = "lu";
pub const __UINT_LEAST64_FMTx__ = "lx";
pub const __UINT_LEAST64_FMTX__ = "lX";
pub const __INT_FAST8_TYPE__ = i8;
pub const __INT_FAST8_MAX__ = @as(c_int, 127);
pub const __INT_FAST8_WIDTH__ = @as(c_int, 8);
pub const __INT_FAST8_FMTd__ = "hhd";
pub const __INT_FAST8_FMTi__ = "hhi";
pub const __UINT_FAST8_TYPE__ = u8;
pub const __UINT_FAST8_MAX__ = @as(c_int, 255);
pub const __UINT_FAST8_FMTo__ = "hho";
pub const __UINT_FAST8_FMTu__ = "hhu";
pub const __UINT_FAST8_FMTx__ = "hhx";
pub const __UINT_FAST8_FMTX__ = "hhX";
pub const __INT_FAST16_TYPE__ = c_short;
pub const __INT_FAST16_MAX__ = @as(c_int, 32767);
pub const __INT_FAST16_WIDTH__ = @as(c_int, 16);
pub const __INT_FAST16_FMTd__ = "hd";
pub const __INT_FAST16_FMTi__ = "hi";
pub const __UINT_FAST16_TYPE__ = c_ushort;
pub const __UINT_FAST16_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65535, .decimal);
pub const __UINT_FAST16_FMTo__ = "ho";
pub const __UINT_FAST16_FMTu__ = "hu";
pub const __UINT_FAST16_FMTx__ = "hx";
pub const __UINT_FAST16_FMTX__ = "hX";
pub const __INT_FAST32_TYPE__ = c_int;
pub const __INT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const __INT_FAST32_WIDTH__ = @as(c_int, 32);
pub const __INT_FAST32_FMTd__ = "d";
pub const __INT_FAST32_FMTi__ = "i";
pub const __UINT_FAST32_TYPE__ = c_uint;
pub const __UINT_FAST32_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 4294967295, .decimal);
pub const __UINT_FAST32_FMTo__ = "o";
pub const __UINT_FAST32_FMTu__ = "u";
pub const __UINT_FAST32_FMTx__ = "x";
pub const __UINT_FAST32_FMTX__ = "X";
pub const __INT_FAST64_TYPE__ = c_long;
pub const __INT_FAST64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_long, 9223372036854775807, .decimal);
pub const __INT_FAST64_WIDTH__ = @as(c_int, 64);
pub const __INT_FAST64_FMTd__ = "ld";
pub const __INT_FAST64_FMTi__ = "li";
pub const __UINT_FAST64_TYPE__ = c_ulong;
pub const __UINT_FAST64_MAX__ = @import("std").zig.c_translation.promoteIntLiteral(c_ulong, 18446744073709551615, .decimal);
pub const __UINT_FAST64_FMTo__ = "lo";
pub const __UINT_FAST64_FMTu__ = "lu";
pub const __UINT_FAST64_FMTx__ = "lx";
pub const __UINT_FAST64_FMTX__ = "lX";
pub const __USER_LABEL_PREFIX__ = "";
pub const __FINITE_MATH_ONLY__ = @as(c_int, 0);
pub const __GNUC_STDC_INLINE__ = @as(c_int, 1);
pub const __GCC_ATOMIC_TEST_AND_SET_TRUEVAL = @as(c_int, 1);
pub const __GCC_DESTRUCTIVE_SIZE = @as(c_int, 64);
pub const __GCC_CONSTRUCTIVE_SIZE = @as(c_int, 64);
pub const __CLANG_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __CLANG_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_BOOL_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR16_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_CHAR32_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_WCHAR_T_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_SHORT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_INT_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_LLONG_LOCK_FREE = @as(c_int, 2);
pub const __GCC_ATOMIC_POINTER_LOCK_FREE = @as(c_int, 2);
pub const __NO_INLINE__ = @as(c_int, 1);
pub const __PIC__ = @as(c_int, 2);
pub const __pic__ = @as(c_int, 2);
pub const __FLT_RADIX__ = @as(c_int, 2);
pub const __DECIMAL_DIG__ = __LDBL_DECIMAL_DIG__;
pub const __ELF__ = @as(c_int, 1);
pub const __GCC_ASM_FLAG_OUTPUTS__ = @as(c_int, 1);
pub const __code_model_small__ = @as(c_int, 1);
pub const __amd64__ = @as(c_int, 1);
pub const __amd64 = @as(c_int, 1);
pub const __x86_64 = @as(c_int, 1);
pub const __x86_64__ = @as(c_int, 1);
pub const __SEG_GS = @as(c_int, 1);
pub const __SEG_FS = @as(c_int, 1);
pub const __seg_gs = @compileError("unable to translate macro: undefined identifier `address_space`");
// (no file):375:9
pub const __seg_fs = @compileError("unable to translate macro: undefined identifier `address_space`");
// (no file):376:9
pub const __corei7 = @as(c_int, 1);
pub const __corei7__ = @as(c_int, 1);
pub const __tune_corei7__ = @as(c_int, 1);
pub const __REGISTER_PREFIX__ = "";
pub const __NO_MATH_INLINES = @as(c_int, 1);
pub const __AES__ = @as(c_int, 1);
pub const __PCLMUL__ = @as(c_int, 1);
pub const __LAHF_SAHF__ = @as(c_int, 1);
pub const __LZCNT__ = @as(c_int, 1);
pub const __RDRND__ = @as(c_int, 1);
pub const __FSGSBASE__ = @as(c_int, 1);
pub const __BMI__ = @as(c_int, 1);
pub const __BMI2__ = @as(c_int, 1);
pub const __POPCNT__ = @as(c_int, 1);
pub const __PRFCHW__ = @as(c_int, 1);
pub const __RDSEED__ = @as(c_int, 1);
pub const __ADX__ = @as(c_int, 1);
pub const __MOVBE__ = @as(c_int, 1);
pub const __FMA__ = @as(c_int, 1);
pub const __F16C__ = @as(c_int, 1);
pub const __FXSR__ = @as(c_int, 1);
pub const __XSAVE__ = @as(c_int, 1);
pub const __XSAVEOPT__ = @as(c_int, 1);
pub const __XSAVEC__ = @as(c_int, 1);
pub const __XSAVES__ = @as(c_int, 1);
pub const __CLFLUSHOPT__ = @as(c_int, 1);
pub const __SGX__ = @as(c_int, 1);
pub const __INVPCID__ = @as(c_int, 1);
pub const __CRC32__ = @as(c_int, 1);
pub const __AVX2__ = @as(c_int, 1);
pub const __AVX__ = @as(c_int, 1);
pub const __SSE4_2__ = @as(c_int, 1);
pub const __SSE4_1__ = @as(c_int, 1);
pub const __SSSE3__ = @as(c_int, 1);
pub const __SSE3__ = @as(c_int, 1);
pub const __SSE2__ = @as(c_int, 1);
pub const __SSE2_MATH__ = @as(c_int, 1);
pub const __SSE__ = @as(c_int, 1);
pub const __SSE_MATH__ = @as(c_int, 1);
pub const __MMX__ = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_1 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_2 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_4 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_8 = @as(c_int, 1);
pub const __GCC_HAVE_SYNC_COMPARE_AND_SWAP_16 = @as(c_int, 1);
pub const __SIZEOF_FLOAT128__ = @as(c_int, 16);
pub const unix = @as(c_int, 1);
pub const __unix = @as(c_int, 1);
pub const __unix__ = @as(c_int, 1);
pub const linux = @as(c_int, 1);
pub const __linux = @as(c_int, 1);
pub const __linux__ = @as(c_int, 1);
pub const __gnu_linux__ = @as(c_int, 1);
pub const __FLOAT128__ = @as(c_int, 1);
pub const __STDC__ = @as(c_int, 1);
pub const __STDC_HOSTED__ = @as(c_int, 1);
pub const __STDC_VERSION__ = @as(c_long, 201710);
pub const __STDC_UTF_16__ = @as(c_int, 1);
pub const __STDC_UTF_32__ = @as(c_int, 1);
pub const __STDC_EMBED_NOT_FOUND__ = @as(c_int, 0);
pub const __STDC_EMBED_FOUND__ = @as(c_int, 1);
pub const __STDC_EMBED_EMPTY__ = @as(c_int, 2);
pub const __GLIBC_MINOR__ = @as(c_int, 42);
pub const WITH_GZFILEOP = @as(c_int, 1);
pub const __GCC_HAVE_DWARF2_CFI_ASM = @as(c_int, 1);
pub const __G_LIB_H__ = "";
pub const __GLIB_H_INSIDE__ = "";
pub const __G_ALLOCA_H__ = "";
pub const __G_TYPES_H__ = "";
pub const __GLIBCONFIG_H__ = "";
pub const __G_MACROS_H__ = "";
pub const __need_ptrdiff_t = "";
pub const __need_size_t = "";
pub const __need_wchar_t = "";
pub const __need_NULL = "";
pub const __need_max_align_t = "";
pub const __need_offsetof = "";
pub const __STDDEF_H = "";
pub const _PTRDIFF_T = "";
pub const _SIZE_T = "";
pub const _WCHAR_T = "";
pub const NULL = @import("std").zig.c_translation.cast(?*anyopaque, @as(c_int, 0));
pub const __CLANG_MAX_ALIGN_T_DEFINED = "";
pub const offsetof = @compileError("unable to translate C expr: unexpected token 'an identifier'");
// /var/mnt/eclipse/hyper-data/toolchains/asdf/installs/zig/0.15.2/lib/include/__stddef_offsetof.h:16:9
pub inline fn G_GNUC_CHECK_VERSION(major: anytype, minor: anytype) @TypeOf((__GNUC__ > major) or ((__GNUC__ == major) and (__GNUC_MINOR__ >= minor))) {
    _ = &major;
    _ = &minor;
    return (__GNUC__ > major) or ((__GNUC__ == major) and (__GNUC_MINOR__ >= minor));
}
pub const G_GNUC_EXTENSION = @compileError("unable to translate C expr: unexpected token '__extension__'");
// /usr/include/glib-2.0/glib/gmacros.h:62:9
pub inline fn G_CXX_STD_CHECK_VERSION(version: anytype) @TypeOf(@as(c_int, 0)) {
    _ = &version;
    return @as(c_int, 0);
}
pub const G_C_STD_VERSION = __STDC_VERSION__;
pub inline fn G_C_STD_CHECK_VERSION(version: anytype) @TypeOf((((((((version >= @as(c_long, 199000)) and (version <= G_C_STD_VERSION)) or ((version == @as(c_int, 89)) and (G_C_STD_VERSION >= @as(c_long, 199000)))) or ((version == @as(c_int, 90)) and (G_C_STD_VERSION >= @as(c_long, 199000)))) or ((version == @as(c_int, 99)) and (G_C_STD_VERSION >= @as(c_long, 199901)))) or ((version == @as(c_int, 11)) and (G_C_STD_VERSION >= @as(c_long, 201112)))) or ((version == @as(c_int, 17)) and (G_C_STD_VERSION >= @as(c_long, 201710)))) or (@as(c_int, 0) != 0)) {
    _ = &version;
    return (((((((version >= @as(c_long, 199000)) and (version <= G_C_STD_VERSION)) or ((version == @as(c_int, 89)) and (G_C_STD_VERSION >= @as(c_long, 199000)))) or ((version == @as(c_int, 90)) and (G_C_STD_VERSION >= @as(c_long, 199000)))) or ((version == @as(c_int, 99)) and (G_C_STD_VERSION >= @as(c_long, 199901)))) or ((version == @as(c_int, 11)) and (G_C_STD_VERSION >= @as(c_long, 201112)))) or ((version == @as(c_int, 17)) and (G_C_STD_VERSION >= @as(c_long, 201710)))) or (@as(c_int, 0) != 0);
}
pub const G_CAN_INLINE = "";
pub const G_INLINE_FUNC = @compileError("unable to translate C expr: unexpected token 'static'");
// /usr/include/glib-2.0/glib/gmacros.h:157:11
pub const g_macro__has_attribute = @compileError("unable to translate macro: undefined identifier `__has_attribute`");
// /usr/include/glib-2.0/glib/gmacros.h:167:9
pub const G_GNUC_PURE = @compileError("unable to translate macro: undefined identifier `__pure__`");
// /usr/include/glib-2.0/glib/gmacros.h:287:9
pub const G_GNUC_MALLOC = @compileError("unable to translate macro: undefined identifier `__malloc__`");
// /usr/include/glib-2.0/glib/gmacros.h:293:9
pub const G_GNUC_NO_INLINE = @compileError("unable to translate macro: undefined identifier `__noinline__`");
// /usr/include/glib-2.0/glib/gmacros.h:299:9
pub const G_GNUC_NULL_TERMINATED = @compileError("unable to translate macro: undefined identifier `__sentinel__`");
// /usr/include/glib-2.0/glib/gmacros.h:326:9
pub const g_macro__has_feature = @compileError("unable to translate macro: undefined identifier `__has_feature`");
// /usr/include/glib-2.0/glib/gmacros.h:342:9
pub const g_macro__has_builtin = __has_builtin;
pub const g_macro__has_extension = @compileError("unable to translate macro: undefined identifier `__has_extension`");
// /usr/include/glib-2.0/glib/gmacros.h:354:9
pub const G_GNUC_ALLOC_SIZE = @compileError("unable to translate macro: undefined identifier `__alloc_size__`");
// /usr/include/glib-2.0/glib/gmacros.h:403:9
pub const G_GNUC_ALLOC_SIZE2 = @compileError("unable to translate macro: undefined identifier `__alloc_size__`");
// /usr/include/glib-2.0/glib/gmacros.h:404:9
pub const G_GNUC_PRINTF = @compileError("unable to translate macro: undefined identifier `__format__`");
// /usr/include/glib-2.0/glib/gmacros.h:599:9
pub const G_GNUC_SCANF = @compileError("unable to translate macro: undefined identifier `__format__`");
// /usr/include/glib-2.0/glib/gmacros.h:601:9
pub const G_GNUC_STRFTIME = @compileError("unable to translate macro: undefined identifier `__format__`");
// /usr/include/glib-2.0/glib/gmacros.h:603:9
pub const G_GNUC_FORMAT = @compileError("unable to translate macro: undefined identifier `__format_arg__`");
// /usr/include/glib-2.0/glib/gmacros.h:618:9
pub const G_GNUC_NORETURN = @compileError("unable to translate macro: undefined identifier `__noreturn__`");
// /usr/include/glib-2.0/glib/gmacros.h:625:9
pub const G_GNUC_CONST = @compileError("unable to translate C expr: unexpected token '__attribute__'");
// /usr/include/glib-2.0/glib/gmacros.h:636:9
pub const G_GNUC_UNUSED = @compileError("unable to translate macro: undefined identifier `__unused__`");
// /usr/include/glib-2.0/glib/gmacros.h:643:9
pub const G_GNUC_NO_INSTRUMENT = @compileError("unable to translate macro: undefined identifier `__no_instrument_function__`");
// /usr/include/glib-2.0/glib/gmacros.h:650:9
pub const G_GNUC_FALLTHROUGH = @compileError("unable to translate macro: undefined identifier `fallthrough`");
// /usr/include/glib-2.0/glib/gmacros.h:685:9
pub const G_GNUC_DEPRECATED = @compileError("unable to translate macro: undefined identifier `__deprecated__`");
// /usr/include/glib-2.0/glib/gmacros.h:711:9
pub const G_GNUC_DEPRECATED_FOR = @compileError("unable to translate macro: undefined identifier `deprecated`");
// /usr/include/glib-2.0/glib/gmacros.h:740:9
pub const G_GNUC_BEGIN_IGNORE_DEPRECATIONS = @compileError("unable to translate macro: undefined identifier `_Pragma`");
// /usr/include/glib-2.0/glib/gmacros.h:767:9
pub const G_GNUC_END_IGNORE_DEPRECATIONS = @compileError("unable to translate macro: undefined identifier `_Pragma`");
// /usr/include/glib-2.0/glib/gmacros.h:770:9
pub const G_GNUC_MAY_ALIAS = @compileError("unable to translate macro: undefined identifier `may_alias`");
// /usr/include/glib-2.0/glib/gmacros.h:790:9
pub const G_GNUC_WARN_UNUSED_RESULT = @compileError("unable to translate macro: undefined identifier `warn_unused_result`");
// /usr/include/glib-2.0/glib/gmacros.h:814:9
pub const G_GNUC_FUNCTION = "" ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(G_STRFUNC);
pub const G_GNUC_PRETTY_FUNCTION = "" ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(G_STRFUNC);
pub const G_ANALYZER_ANALYZING = @as(c_int, 0);
pub const G_ANALYZER_NORETURN = "";
pub inline fn G_STRINGIFY(macro_or_string: anytype) @TypeOf(G_STRINGIFY_ARG(macro_or_string)) {
    _ = &macro_or_string;
    return G_STRINGIFY_ARG(macro_or_string);
}
pub const G_STRINGIFY_ARG = @compileError("unable to translate C expr: unexpected token '#'");
// /usr/include/glib-2.0/glib/gmacros.h:864:9
pub const G_PASTE_ARGS = @compileError("unable to translate C expr: unexpected token '##'");
// /usr/include/glib-2.0/glib/gmacros.h:866:9
pub inline fn G_PASTE(identifier1: anytype, identifier2: anytype) @TypeOf(G_PASTE_ARGS(identifier1, identifier2)) {
    _ = &identifier1;
    _ = &identifier2;
    return G_PASTE_ARGS(identifier1, identifier2);
}
pub const G_STATIC_ASSERT = @compileError("unable to translate C expr: unexpected token '_Static_assert'");
// /usr/include/glib-2.0/glib/gmacros.h:874:9
pub const G_STATIC_ASSERT_EXPR = @compileError("unable to translate C expr: expected ')' instead got '['");
// /usr/include/glib-2.0/glib/gmacros.h:882:9
pub const G_STRLOC = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gmacros.h:892:9
pub const G_STRFUNC = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gmacros.h:899:9
pub const G_BEGIN_DECLS = "";
pub const G_END_DECLS = "";
pub const FALSE = @as(c_int, 0);
pub const TRUE = !(FALSE != 0);
pub inline fn MAX(a: anytype, b: anytype) @TypeOf(if (a > b) a else b) {
    _ = &a;
    _ = &b;
    return if (a > b) a else b;
}
pub inline fn MIN(a: anytype, b: anytype) @TypeOf(if (a < b) a else b) {
    _ = &a;
    _ = &b;
    return if (a < b) a else b;
}
pub inline fn ABS(a: anytype) @TypeOf(if (a < @as(c_int, 0)) -a else a) {
    _ = &a;
    return if (a < @as(c_int, 0)) -a else a;
}
pub inline fn CLAMP(x: anytype, low: anytype, high: anytype) @TypeOf(if (x > high) high else if (x < low) low else x) {
    _ = &x;
    _ = &low;
    _ = &high;
    return if (x > high) high else if (x < low) low else x;
}
pub inline fn G_APPROX_VALUE(a: anytype, b: anytype, epsilon: anytype) @TypeOf((if (a > b) a - b else b - a) < epsilon) {
    _ = &a;
    _ = &b;
    _ = &epsilon;
    return (if (a > b) a - b else b - a) < epsilon;
}
pub const G_N_ELEMENTS = @compileError("unable to translate C expr: unexpected token '('");
// /usr/include/glib-2.0/glib/gmacros.h:957:9
pub inline fn GPOINTER_TO_SIZE(p: anytype) gsize {
    _ = &p;
    return @import("std").zig.c_translation.cast(gsize, p);
}
pub inline fn GSIZE_TO_POINTER(s: anytype) gpointer {
    _ = &s;
    return @import("std").zig.c_translation.cast(gpointer, @import("std").zig.c_translation.cast(guintptr, @import("std").zig.c_translation.cast(gsize, s)));
}
pub inline fn G_STRUCT_OFFSET(struct_type: anytype, member: anytype) glong {
    _ = &struct_type;
    _ = &member;
    return @import("std").zig.c_translation.cast(glong, offsetof(struct_type, member));
}
pub inline fn G_STRUCT_MEMBER_P(struct_p: anytype, struct_offset: anytype) gpointer {
    _ = &struct_p;
    _ = &struct_offset;
    return @import("std").zig.c_translation.cast(gpointer, @import("std").zig.c_translation.cast([*c]guint8, struct_p) + @import("std").zig.c_translation.cast(glong, struct_offset));
}
pub const G_STRUCT_MEMBER = @compileError("unable to translate C expr: unexpected token ')'");
// /usr/include/glib-2.0/glib/gmacros.h:978:9
pub const G_STMT_START = @compileError("unable to translate C expr: unexpected token 'do'");
// /usr/include/glib-2.0/glib/gmacros.h:991:9
pub const G_STMT_END = @compileError("unable to translate C expr: unexpected token 'while'");
// /usr/include/glib-2.0/glib/gmacros.h:999:9
pub const G_ALIGNOF = @compileError("unable to translate C expr: unexpected token 'an identifier'");
// /usr/include/glib-2.0/glib/gmacros.h:1027:9
pub const G_CONST_RETURN = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gmacros.h:1052:9
pub const G_NORETURN = @compileError("unable to translate macro: undefined identifier `__noreturn__`");
// /usr/include/glib-2.0/glib/gmacros.h:1084:10
pub const G_NORETURN_FUNCPTR = @compileError("unable to translate macro: undefined identifier `__noreturn__`");
// /usr/include/glib-2.0/glib/gmacros.h:1118:10
pub const G_ALWAYS_INLINE = @compileError("unable to translate macro: undefined identifier `__always_inline__`");
// /usr/include/glib-2.0/glib/gmacros.h:1161:12
pub const G_NO_INLINE = @compileError("unable to translate macro: undefined identifier `__noinline__`");
// /usr/include/glib-2.0/glib/gmacros.h:1217:12
pub inline fn G_LIKELY(expr: anytype) @TypeOf(expr) {
    _ = &expr;
    return expr;
}
pub inline fn G_UNLIKELY(expr: anytype) @TypeOf(expr) {
    _ = &expr;
    return expr;
}
pub const G_HAVE_GNUC_VISIBILITY = @as(c_int, 1);
pub const G_DEPRECATED = @compileError("unable to translate macro: undefined identifier `__deprecated__`");
// /usr/include/glib-2.0/glib/gmacros.h:1267:9
pub const G_DEPRECATED_FOR = @compileError("unable to translate macro: undefined identifier `__deprecated__`");
// /usr/include/glib-2.0/glib/gmacros.h:1277:9
pub const G_UNAVAILABLE = @compileError("unable to translate macro: undefined identifier `deprecated`");
// /usr/include/glib-2.0/glib/gmacros.h:1285:9
pub const _GLIB_GNUC_DO_PRAGMA = @compileError("unable to translate macro: undefined identifier `_Pragma`");
// /usr/include/glib-2.0/glib/gmacros.h:1301:9
pub const GLIB_DEPRECATED_MACRO = @compileError("unable to translate macro: undefined identifier `GCC`");
// /usr/include/glib-2.0/glib/gmacros.h:1302:9
pub const GLIB_DEPRECATED_MACRO_FOR = @compileError("unable to translate macro: undefined identifier `GCC`");
// /usr/include/glib-2.0/glib/gmacros.h:1303:9
pub const GLIB_UNAVAILABLE_MACRO = @compileError("unable to translate macro: undefined identifier `GCC`");
// /usr/include/glib-2.0/glib/gmacros.h:1305:9
pub const GLIB_DEPRECATED_ENUMERATOR = G_DEPRECATED;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_FOR(f: anytype) @TypeOf(G_DEPRECATED_FOR(f)) {
    _ = &f;
    return G_DEPRECATED_FOR(f);
}
pub inline fn GLIB_UNAVAILABLE_ENUMERATOR(maj: anytype, min: anytype) @TypeOf(G_UNAVAILABLE(maj, min)) {
    _ = &maj;
    _ = &min;
    return G_UNAVAILABLE(maj, min);
}
pub const GLIB_DEPRECATED_TYPE = G_DEPRECATED;
pub inline fn GLIB_DEPRECATED_TYPE_FOR(f: anytype) @TypeOf(G_DEPRECATED_FOR(f)) {
    _ = &f;
    return G_DEPRECATED_FOR(f);
}
pub inline fn GLIB_UNAVAILABLE_TYPE(maj: anytype, min: anytype) @TypeOf(G_UNAVAILABLE(maj, min)) {
    _ = &maj;
    _ = &min;
    return G_UNAVAILABLE(maj, min);
}
pub const _GLIB_AUTOPTR_FUNC_NAME = @compileError("unable to translate macro: undefined identifier `glib_autoptr_cleanup_`");
// /usr/include/glib-2.0/glib/gmacros.h:1342:9
pub const _GLIB_AUTOPTR_CLEAR_FUNC_NAME = @compileError("unable to translate macro: undefined identifier `glib_autoptr_clear_`");
// /usr/include/glib-2.0/glib/gmacros.h:1343:9
pub const _GLIB_AUTOPTR_DESTROY_FUNC_NAME = @compileError("unable to translate macro: undefined identifier `glib_autoptr_destroy_`");
// /usr/include/glib-2.0/glib/gmacros.h:1344:9
pub const _GLIB_AUTOPTR_TYPENAME = @compileError("unable to translate macro: undefined identifier `_autoptr`");
// /usr/include/glib-2.0/glib/gmacros.h:1345:9
pub const _GLIB_AUTOPTR_LIST_FUNC_NAME = @compileError("unable to translate macro: undefined identifier `glib_listautoptr_cleanup_`");
// /usr/include/glib-2.0/glib/gmacros.h:1346:9
pub const _GLIB_AUTOPTR_LIST_TYPENAME = @compileError("unable to translate macro: undefined identifier `_listautoptr`");
// /usr/include/glib-2.0/glib/gmacros.h:1347:9
pub const _GLIB_AUTOPTR_SLIST_FUNC_NAME = @compileError("unable to translate macro: undefined identifier `glib_slistautoptr_cleanup_`");
// /usr/include/glib-2.0/glib/gmacros.h:1348:9
pub const _GLIB_AUTOPTR_SLIST_TYPENAME = @compileError("unable to translate macro: undefined identifier `_slistautoptr`");
// /usr/include/glib-2.0/glib/gmacros.h:1349:9
pub const _GLIB_AUTOPTR_QUEUE_FUNC_NAME = @compileError("unable to translate macro: undefined identifier `glib_queueautoptr_cleanup_`");
// /usr/include/glib-2.0/glib/gmacros.h:1350:9
pub const _GLIB_AUTOPTR_QUEUE_TYPENAME = @compileError("unable to translate macro: undefined identifier `_queueautoptr`");
// /usr/include/glib-2.0/glib/gmacros.h:1351:9
pub const _GLIB_AUTO_FUNC_NAME = @compileError("unable to translate macro: undefined identifier `glib_auto_cleanup_`");
// /usr/include/glib-2.0/glib/gmacros.h:1352:9
pub const _GLIB_CLEANUP = @compileError("unable to translate macro: undefined identifier `cleanup`");
// /usr/include/glib-2.0/glib/gmacros.h:1353:9
pub const _GLIB_DEFINE_AUTOPTR_CLEANUP_FUNCS = @compileError("unable to translate macro: undefined identifier `_ptr`");
// /usr/include/glib-2.0/glib/gmacros.h:1354:9
pub inline fn _GLIB_DEFINE_AUTOPTR_CHAINUP(ModuleObjName: anytype, ParentName: anytype) @TypeOf(_GLIB_DEFINE_AUTOPTR_CLEANUP_FUNCS(ModuleObjName, ParentName, _GLIB_AUTOPTR_CLEAR_FUNC_NAME(ParentName))) {
    _ = &ModuleObjName;
    _ = &ParentName;
    return _GLIB_DEFINE_AUTOPTR_CLEANUP_FUNCS(ModuleObjName, ParentName, _GLIB_AUTOPTR_CLEAR_FUNC_NAME(ParentName));
}
pub inline fn G_DEFINE_AUTOPTR_CLEANUP_FUNC(TypeName: anytype, func: anytype) @TypeOf(_GLIB_DEFINE_AUTOPTR_CLEANUP_FUNCS(TypeName, TypeName, func)) {
    _ = &TypeName;
    _ = &func;
    return _GLIB_DEFINE_AUTOPTR_CLEANUP_FUNCS(TypeName, TypeName, func);
}
pub const G_DEFINE_AUTO_CLEANUP_CLEAR_FUNC = @compileError("unable to translate macro: undefined identifier `_ptr`");
// /usr/include/glib-2.0/glib/gmacros.h:1380:9
pub const G_DEFINE_AUTO_CLEANUP_FREE_FUNC = @compileError("unable to translate macro: undefined identifier `_ptr`");
// /usr/include/glib-2.0/glib/gmacros.h:1384:9
pub inline fn g_autoptr(TypeName: anytype) @TypeOf(_GLIB_CLEANUP(_GLIB_AUTOPTR_FUNC_NAME(TypeName)) ++ _GLIB_AUTOPTR_TYPENAME(TypeName)) {
    _ = &TypeName;
    return _GLIB_CLEANUP(_GLIB_AUTOPTR_FUNC_NAME(TypeName)) ++ _GLIB_AUTOPTR_TYPENAME(TypeName);
}
pub inline fn g_autolist(TypeName: anytype) @TypeOf(_GLIB_CLEANUP(_GLIB_AUTOPTR_LIST_FUNC_NAME(TypeName)) ++ _GLIB_AUTOPTR_LIST_TYPENAME(TypeName)) {
    _ = &TypeName;
    return _GLIB_CLEANUP(_GLIB_AUTOPTR_LIST_FUNC_NAME(TypeName)) ++ _GLIB_AUTOPTR_LIST_TYPENAME(TypeName);
}
pub inline fn g_autoslist(TypeName: anytype) @TypeOf(_GLIB_CLEANUP(_GLIB_AUTOPTR_SLIST_FUNC_NAME(TypeName)) ++ _GLIB_AUTOPTR_SLIST_TYPENAME(TypeName)) {
    _ = &TypeName;
    return _GLIB_CLEANUP(_GLIB_AUTOPTR_SLIST_FUNC_NAME(TypeName)) ++ _GLIB_AUTOPTR_SLIST_TYPENAME(TypeName);
}
pub inline fn g_autoqueue(TypeName: anytype) @TypeOf(_GLIB_CLEANUP(_GLIB_AUTOPTR_QUEUE_FUNC_NAME(TypeName)) ++ _GLIB_AUTOPTR_QUEUE_TYPENAME(TypeName)) {
    _ = &TypeName;
    return _GLIB_CLEANUP(_GLIB_AUTOPTR_QUEUE_FUNC_NAME(TypeName)) ++ _GLIB_AUTOPTR_QUEUE_TYPENAME(TypeName);
}
pub inline fn g_auto(TypeName: anytype) @TypeOf(_GLIB_CLEANUP(_GLIB_AUTO_FUNC_NAME(TypeName)) ++ TypeName) {
    _ = &TypeName;
    return _GLIB_CLEANUP(_GLIB_AUTO_FUNC_NAME(TypeName)) ++ TypeName;
}
pub const g_autofree = _GLIB_CLEANUP(g_autoptr_cleanup_generic_gfree);
pub const G_SIZEOF_MEMBER = @compileError("unable to translate C expr: unexpected token 'sizeof'");
// /usr/include/glib-2.0/glib/gmacros.h:1429:9
pub const __CLANG_LIMITS_H = "";
pub const _GCC_LIMITS_H_ = "";
pub const _LIBC_LIMITS_H_ = @as(c_int, 1);
pub const __GLIBC_INTERNAL_STARTING_HEADER_IMPLEMENTATION = "";
pub const _FEATURES_H = @as(c_int, 1);
pub const __KERNEL_STRICT_NAMES = "";
pub inline fn __GNUC_PREREQ(maj: anytype, min: anytype) @TypeOf(((__GNUC__ << @as(c_int, 16)) + __GNUC_MINOR__) >= ((maj << @as(c_int, 16)) + min)) {
    _ = &maj;
    _ = &min;
    return ((__GNUC__ << @as(c_int, 16)) + __GNUC_MINOR__) >= ((maj << @as(c_int, 16)) + min);
}
pub inline fn __glibc_clang_prereq(maj: anytype, min: anytype) @TypeOf(((__clang_major__ << @as(c_int, 16)) + __clang_minor__) >= ((maj << @as(c_int, 16)) + min)) {
    _ = &maj;
    _ = &min;
    return ((__clang_major__ << @as(c_int, 16)) + __clang_minor__) >= ((maj << @as(c_int, 16)) + min);
}
pub const __GLIBC_USE = @compileError("unable to translate macro: undefined identifier `__GLIBC_USE_`");
// /usr/include/features.h:191:9
pub const _DEFAULT_SOURCE = @as(c_int, 1);
pub const __GLIBC_USE_ISOC2Y = @as(c_int, 0);
pub const __GLIBC_USE_ISOC23 = @as(c_int, 0);
pub const __USE_ISOC11 = @as(c_int, 1);
pub const __USE_ISOC99 = @as(c_int, 1);
pub const __USE_ISOC95 = @as(c_int, 1);
pub const __USE_POSIX_IMPLICITLY = @as(c_int, 1);
pub const _POSIX_SOURCE = @as(c_int, 1);
pub const _POSIX_C_SOURCE = @as(c_long, 200809);
pub const __USE_POSIX = @as(c_int, 1);
pub const __USE_POSIX2 = @as(c_int, 1);
pub const __USE_POSIX199309 = @as(c_int, 1);
pub const __USE_POSIX199506 = @as(c_int, 1);
pub const __USE_XOPEN2K = @as(c_int, 1);
pub const __USE_XOPEN2K8 = @as(c_int, 1);
pub const _ATFILE_SOURCE = @as(c_int, 1);
pub const __WORDSIZE = @as(c_int, 64);
pub const __WORDSIZE_TIME64_COMPAT32 = @as(c_int, 1);
pub const __SYSCALL_WORDSIZE = @as(c_int, 64);
pub const __TIMESIZE = __WORDSIZE;
pub const __USE_TIME_BITS64 = @as(c_int, 1);
pub const __USE_MISC = @as(c_int, 1);
pub const __USE_ATFILE = @as(c_int, 1);
pub const __USE_FORTIFY_LEVEL = @as(c_int, 0);
pub const __GLIBC_USE_DEPRECATED_GETS = @as(c_int, 0);
pub const __GLIBC_USE_DEPRECATED_SCANF = @as(c_int, 0);
pub const __GLIBC_USE_C23_STRTOL = @as(c_int, 0);
pub const _STDC_PREDEF_H = @as(c_int, 1);
pub const __STDC_IEC_559__ = @as(c_int, 1);
pub const __STDC_IEC_60559_BFP__ = @as(c_long, 201404);
pub const __STDC_IEC_559_COMPLEX__ = @as(c_int, 1);
pub const __STDC_IEC_60559_COMPLEX__ = @as(c_long, 201404);
pub const __STDC_ISO_10646__ = @as(c_long, 201706);
pub const __GNU_LIBRARY__ = @as(c_int, 6);
pub const __GLIBC__ = @as(c_int, 2);
pub inline fn __GLIBC_PREREQ(maj: anytype, min: anytype) @TypeOf(((__GLIBC__ << @as(c_int, 16)) + __GLIBC_MINOR__) >= ((maj << @as(c_int, 16)) + min)) {
    _ = &maj;
    _ = &min;
    return ((__GLIBC__ << @as(c_int, 16)) + __GLIBC_MINOR__) >= ((maj << @as(c_int, 16)) + min);
}
pub const _SYS_CDEFS_H = @as(c_int, 1);
pub const __glibc_has_attribute = @compileError("unable to translate macro: undefined identifier `__has_attribute`");
// /usr/include/sys/cdefs.h:45:10
pub inline fn __glibc_has_builtin(name: anytype) @TypeOf(__has_builtin(name)) {
    _ = &name;
    return __has_builtin(name);
}
pub const __glibc_has_extension = @compileError("unable to translate macro: undefined identifier `__has_extension`");
// /usr/include/sys/cdefs.h:55:10
pub const __LEAF = "";
pub const __LEAF_ATTR = "";
pub const __THROW = @compileError("unable to translate macro: undefined identifier `__nothrow__`");
// /usr/include/sys/cdefs.h:79:11
pub const __THROWNL = @compileError("unable to translate macro: undefined identifier `__nothrow__`");
// /usr/include/sys/cdefs.h:80:11
pub const __NTH = @compileError("unable to translate macro: undefined identifier `__nothrow__`");
// /usr/include/sys/cdefs.h:81:11
pub const __NTHNL = @compileError("unable to translate macro: undefined identifier `__nothrow__`");
// /usr/include/sys/cdefs.h:82:11
pub const __COLD = @compileError("unable to translate macro: undefined identifier `__cold__`");
// /usr/include/sys/cdefs.h:102:11
pub inline fn __P(args: anytype) @TypeOf(args) {
    _ = &args;
    return args;
}
pub inline fn __PMT(args: anytype) @TypeOf(args) {
    _ = &args;
    return args;
}
pub const __CONCAT = @compileError("unable to translate C expr: unexpected token '##'");
// /usr/include/sys/cdefs.h:131:9
pub const __STRING = @compileError("unable to translate C expr: unexpected token '#'");
// /usr/include/sys/cdefs.h:132:9
pub const __ptr_t = ?*anyopaque;
pub const __BEGIN_DECLS = "";
pub const __END_DECLS = "";
pub const __attribute_overloadable__ = @compileError("unable to translate macro: undefined identifier `__overloadable__`");
// /usr/include/sys/cdefs.h:151:10
pub inline fn __bos(ptr: anytype) @TypeOf(__builtin_object_size(ptr, __USE_FORTIFY_LEVEL > @as(c_int, 1))) {
    _ = &ptr;
    return __builtin_object_size(ptr, __USE_FORTIFY_LEVEL > @as(c_int, 1));
}
pub inline fn __bos0(ptr: anytype) @TypeOf(__builtin_object_size(ptr, @as(c_int, 0))) {
    _ = &ptr;
    return __builtin_object_size(ptr, @as(c_int, 0));
}
pub inline fn __glibc_objsize0(__o: anytype) @TypeOf(__bos0(__o)) {
    _ = &__o;
    return __bos0(__o);
}
pub inline fn __glibc_objsize(__o: anytype) @TypeOf(__bos(__o)) {
    _ = &__o;
    return __bos(__o);
}
pub const __warnattr = @compileError("unable to translate C expr: unexpected token ''");
// /usr/include/sys/cdefs.h:370:10
pub const __errordecl = @compileError("unable to translate C expr: unexpected token 'extern'");
// /usr/include/sys/cdefs.h:371:10
pub const __flexarr = @compileError("unable to translate C expr: unexpected token '['");
// /usr/include/sys/cdefs.h:379:10
pub const __glibc_c99_flexarr_available = @as(c_int, 1);
pub const __REDIRECT = @compileError("unable to translate C expr: unexpected token '__asm__'");
// /usr/include/sys/cdefs.h:410:10
pub const __REDIRECT_NTH = @compileError("unable to translate C expr: unexpected token '__asm__'");
// /usr/include/sys/cdefs.h:417:11
pub const __REDIRECT_NTHNL = @compileError("unable to translate C expr: unexpected token '__asm__'");
// /usr/include/sys/cdefs.h:419:11
pub const __ASMNAME = @compileError("unable to translate C expr: unexpected token ','");
// /usr/include/sys/cdefs.h:422:10
pub inline fn __ASMNAME2(prefix: anytype, cname: anytype) @TypeOf(__STRING(prefix) ++ cname) {
    _ = &prefix;
    _ = &cname;
    return __STRING(prefix) ++ cname;
}
pub const __REDIRECT_FORTIFY = __REDIRECT;
pub const __REDIRECT_FORTIFY_NTH = __REDIRECT_NTH;
pub const __attribute_malloc__ = @compileError("unable to translate macro: undefined identifier `__malloc__`");
// /usr/include/sys/cdefs.h:452:10
pub const __attribute_alloc_size__ = @compileError("unable to translate C expr: unexpected token ''");
// /usr/include/sys/cdefs.h:463:10
pub const __attribute_alloc_align__ = @compileError("unable to translate macro: undefined identifier `__alloc_align__`");
// /usr/include/sys/cdefs.h:469:10
pub const __attribute_pure__ = @compileError("unable to translate macro: undefined identifier `__pure__`");
// /usr/include/sys/cdefs.h:479:10
pub const __attribute_const__ = @compileError("unable to translate C expr: unexpected token '__attribute__'");
// /usr/include/sys/cdefs.h:486:10
pub const __attribute_maybe_unused__ = @compileError("unable to translate macro: undefined identifier `__unused__`");
// /usr/include/sys/cdefs.h:492:10
pub const __attribute_used__ = @compileError("unable to translate macro: undefined identifier `__used__`");
// /usr/include/sys/cdefs.h:501:10
pub const __attribute_noinline__ = @compileError("unable to translate macro: undefined identifier `__noinline__`");
// /usr/include/sys/cdefs.h:502:10
pub const __attribute_deprecated__ = @compileError("unable to translate macro: undefined identifier `__deprecated__`");
// /usr/include/sys/cdefs.h:510:10
pub const __attribute_deprecated_msg__ = @compileError("unable to translate macro: undefined identifier `__deprecated__`");
// /usr/include/sys/cdefs.h:520:10
pub const __attribute_format_arg__ = @compileError("unable to translate macro: undefined identifier `__format_arg__`");
// /usr/include/sys/cdefs.h:533:10
pub const __attribute_format_strfmon__ = @compileError("unable to translate macro: undefined identifier `__format__`");
// /usr/include/sys/cdefs.h:543:10
pub const __attribute_nonnull__ = @compileError("unable to translate macro: undefined identifier `__nonnull__`");
// /usr/include/sys/cdefs.h:555:11
pub inline fn __nonnull(params: anytype) @TypeOf(__attribute_nonnull__(params)) {
    _ = &params;
    return __attribute_nonnull__(params);
}
pub const __returns_nonnull = @compileError("unable to translate macro: undefined identifier `__returns_nonnull__`");
// /usr/include/sys/cdefs.h:568:10
pub const __attribute_warn_unused_result__ = @compileError("unable to translate macro: undefined identifier `__warn_unused_result__`");
// /usr/include/sys/cdefs.h:577:10
pub const __wur = "";
pub const __always_inline = @compileError("unable to translate macro: undefined identifier `__always_inline__`");
// /usr/include/sys/cdefs.h:595:10
pub const __attribute_artificial__ = @compileError("unable to translate macro: undefined identifier `__artificial__`");
// /usr/include/sys/cdefs.h:604:10
pub const __extern_inline = @compileError("unable to translate macro: undefined identifier `__gnu_inline__`");
// /usr/include/sys/cdefs.h:622:11
pub const __extern_always_inline = @compileError("unable to translate macro: undefined identifier `__gnu_inline__`");
// /usr/include/sys/cdefs.h:623:11
pub const __fortify_function = __extern_always_inline ++ __attribute_artificial__;
pub const __restrict_arr = @compileError("unable to translate C expr: unexpected token '__restrict'");
// /usr/include/sys/cdefs.h:666:10
pub inline fn __glibc_unlikely(cond: anytype) @TypeOf(__builtin_expect(cond, @as(c_int, 0))) {
    _ = &cond;
    return __builtin_expect(cond, @as(c_int, 0));
}
pub inline fn __glibc_likely(cond: anytype) @TypeOf(__builtin_expect(cond, @as(c_int, 1))) {
    _ = &cond;
    return __builtin_expect(cond, @as(c_int, 1));
}
pub const __attribute_nonstring__ = "";
pub const __attribute_copy__ = @compileError("unable to translate C expr: unexpected token ''");
// /usr/include/sys/cdefs.h:715:10
pub const __LDOUBLE_REDIRECTS_TO_FLOAT128_ABI = @as(c_int, 0);
pub inline fn __LDBL_REDIR1(name: anytype, proto: anytype, alias: anytype) @TypeOf(name ++ proto) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return name ++ proto;
}
pub inline fn __LDBL_REDIR(name: anytype, proto: anytype) @TypeOf(name ++ proto) {
    _ = &name;
    _ = &proto;
    return name ++ proto;
}
pub inline fn __LDBL_REDIR1_NTH(name: anytype, proto: anytype, alias: anytype) @TypeOf(name ++ proto ++ __THROW) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return name ++ proto ++ __THROW;
}
pub inline fn __LDBL_REDIR_NTH(name: anytype, proto: anytype) @TypeOf(name ++ proto ++ __THROW) {
    _ = &name;
    _ = &proto;
    return name ++ proto ++ __THROW;
}
pub const __LDBL_REDIR2_DECL = @compileError("unable to translate C expr: unexpected token ''");
// /usr/include/sys/cdefs.h:792:10
pub const __LDBL_REDIR_DECL = @compileError("unable to translate C expr: unexpected token ''");
// /usr/include/sys/cdefs.h:793:10
pub inline fn __REDIRECT_LDBL(name: anytype, proto: anytype, alias: anytype) @TypeOf(__REDIRECT(name, proto, alias)) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return __REDIRECT(name, proto, alias);
}
pub inline fn __REDIRECT_NTH_LDBL(name: anytype, proto: anytype, alias: anytype) @TypeOf(__REDIRECT_NTH(name, proto, alias)) {
    _ = &name;
    _ = &proto;
    _ = &alias;
    return __REDIRECT_NTH(name, proto, alias);
}
pub const __glibc_macro_warning1 = @compileError("unable to translate macro: undefined identifier `_Pragma`");
// /usr/include/sys/cdefs.h:807:10
pub const __glibc_macro_warning = @compileError("unable to translate macro: undefined identifier `GCC`");
// /usr/include/sys/cdefs.h:808:10
pub const __HAVE_GENERIC_SELECTION = @as(c_int, 1);
pub const __fortified_attr_access = @compileError("unable to translate C expr: unexpected token ''");
// /usr/include/sys/cdefs.h:853:11
pub const __attr_access = @compileError("unable to translate C expr: unexpected token ''");
// /usr/include/sys/cdefs.h:854:11
pub const __attr_access_none = @compileError("unable to translate C expr: unexpected token ''");
// /usr/include/sys/cdefs.h:855:11
pub const __attr_dealloc = @compileError("unable to translate C expr: unexpected token ''");
// /usr/include/sys/cdefs.h:865:10
pub const __attr_dealloc_free = "";
pub const __attribute_returns_twice__ = @compileError("unable to translate macro: undefined identifier `__returns_twice__`");
// /usr/include/sys/cdefs.h:872:10
pub const __attribute_struct_may_alias__ = @compileError("unable to translate macro: undefined identifier `__may_alias__`");
// /usr/include/sys/cdefs.h:881:10
pub const __stub___compat_bdflush = "";
pub const __stub_chflags = "";
pub const __stub_fchflags = "";
pub const __stub_gtty = "";
pub const __stub_revoke = "";
pub const __stub_setlogin = "";
pub const __stub_sigreturn = "";
pub const __stub_stty = "";
pub const __GLIBC_USE_LIB_EXT2 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_BFP_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_BFP_EXT_C23 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_FUNCS_EXT_C23 = @as(c_int, 0);
pub const __GLIBC_USE_IEC_60559_TYPES_EXT = @as(c_int, 0);
pub const MB_LEN_MAX = @as(c_int, 16);
pub const LLONG_MIN = -LLONG_MAX - @as(c_int, 1);
pub const LLONG_MAX = __LONG_LONG_MAX__;
pub const ULLONG_MAX = (LLONG_MAX * @as(c_ulonglong, 2)) + @as(c_int, 1);
pub const _BITS_POSIX1_LIM_H = @as(c_int, 1);
pub const _POSIX_AIO_LISTIO_MAX = @as(c_int, 2);
pub const _POSIX_AIO_MAX = @as(c_int, 1);
pub const _POSIX_ARG_MAX = @as(c_int, 4096);
pub const _POSIX_CHILD_MAX = @as(c_int, 25);
pub const _POSIX_DELAYTIMER_MAX = @as(c_int, 32);
pub const _POSIX_HOST_NAME_MAX = @as(c_int, 255);
pub const _POSIX_LINK_MAX = @as(c_int, 8);
pub const _POSIX_LOGIN_NAME_MAX = @as(c_int, 9);
pub const _POSIX_MAX_CANON = @as(c_int, 255);
pub const _POSIX_MAX_INPUT = @as(c_int, 255);
pub const _POSIX_MQ_OPEN_MAX = @as(c_int, 8);
pub const _POSIX_MQ_PRIO_MAX = @as(c_int, 32);
pub const _POSIX_NAME_MAX = @as(c_int, 14);
pub const _POSIX_NGROUPS_MAX = @as(c_int, 8);
pub const _POSIX_OPEN_MAX = @as(c_int, 20);
pub const _POSIX_PATH_MAX = @as(c_int, 256);
pub const _POSIX_PIPE_BUF = @as(c_int, 512);
pub const _POSIX_RE_DUP_MAX = @as(c_int, 255);
pub const _POSIX_RTSIG_MAX = @as(c_int, 8);
pub const _POSIX_SEM_NSEMS_MAX = @as(c_int, 256);
pub const _POSIX_SEM_VALUE_MAX = @as(c_int, 32767);
pub const _POSIX_SIGQUEUE_MAX = @as(c_int, 32);
pub const _POSIX_SSIZE_MAX = @as(c_int, 32767);
pub const _POSIX_STREAM_MAX = @as(c_int, 8);
pub const _POSIX_SYMLINK_MAX = @as(c_int, 255);
pub const _POSIX_SYMLOOP_MAX = @as(c_int, 8);
pub const _POSIX_TIMER_MAX = @as(c_int, 32);
pub const _POSIX_TTY_NAME_MAX = @as(c_int, 9);
pub const _POSIX_TZNAME_MAX = @as(c_int, 6);
pub const _POSIX_CLOCKRES_MIN = @import("std").zig.c_translation.promoteIntLiteral(c_int, 20000000, .decimal);
pub const __undef_NR_OPEN = "";
pub const __undef_LINK_MAX = "";
pub const __undef_OPEN_MAX = "";
pub const __undef_ARG_MAX = "";
pub const _LINUX_LIMITS_H = "";
pub const NR_OPEN = @as(c_int, 1024);
pub const NGROUPS_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65536, .decimal);
pub const ARG_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 131072, .decimal);
pub const LINK_MAX = @as(c_int, 127);
pub const MAX_CANON = @as(c_int, 255);
pub const MAX_INPUT = @as(c_int, 255);
pub const NAME_MAX = @as(c_int, 255);
pub const PATH_MAX = @as(c_int, 4096);
pub const PIPE_BUF = @as(c_int, 4096);
pub const XATTR_NAME_MAX = @as(c_int, 255);
pub const XATTR_SIZE_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65536, .decimal);
pub const XATTR_LIST_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 65536, .decimal);
pub const RTSIG_MAX = @as(c_int, 32);
pub const _POSIX_THREAD_KEYS_MAX = @as(c_int, 128);
pub const PTHREAD_KEYS_MAX = @as(c_int, 1024);
pub const _POSIX_THREAD_DESTRUCTOR_ITERATIONS = @as(c_int, 4);
pub const PTHREAD_DESTRUCTOR_ITERATIONS = _POSIX_THREAD_DESTRUCTOR_ITERATIONS;
pub const _POSIX_THREAD_THREADS_MAX = @as(c_int, 64);
pub const AIO_PRIO_DELTA_MAX = @as(c_int, 20);
pub const PTHREAD_STACK_MIN = @as(c_int, 16384);
pub const DELAYTIMER_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const TTY_NAME_MAX = @as(c_int, 32);
pub const LOGIN_NAME_MAX = @as(c_int, 256);
pub const HOST_NAME_MAX = @as(c_int, 64);
pub const MQ_PRIO_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 32768, .decimal);
pub const SEM_VALUE_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const SSIZE_MAX = LONG_MAX;
pub const _BITS_POSIX2_LIM_H = @as(c_int, 1);
pub const _POSIX2_BC_BASE_MAX = @as(c_int, 99);
pub const _POSIX2_BC_DIM_MAX = @as(c_int, 2048);
pub const _POSIX2_BC_SCALE_MAX = @as(c_int, 99);
pub const _POSIX2_BC_STRING_MAX = @as(c_int, 1000);
pub const _POSIX2_COLL_WEIGHTS_MAX = @as(c_int, 2);
pub const _POSIX2_EXPR_NEST_MAX = @as(c_int, 32);
pub const _POSIX2_LINE_MAX = @as(c_int, 2048);
pub const _POSIX2_RE_DUP_MAX = @as(c_int, 255);
pub const _POSIX2_CHARCLASS_NAME_MAX = @as(c_int, 14);
pub const BC_BASE_MAX = _POSIX2_BC_BASE_MAX;
pub const BC_DIM_MAX = _POSIX2_BC_DIM_MAX;
pub const BC_SCALE_MAX = _POSIX2_BC_SCALE_MAX;
pub const BC_STRING_MAX = _POSIX2_BC_STRING_MAX;
pub const COLL_WEIGHTS_MAX = @as(c_int, 255);
pub const EXPR_NEST_MAX = _POSIX2_EXPR_NEST_MAX;
pub const LINE_MAX = _POSIX2_LINE_MAX;
pub const CHARCLASS_NAME_MAX = @as(c_int, 2048);
pub const RE_DUP_MAX = @as(c_int, 0x7fff);
pub const SCHAR_MAX = __SCHAR_MAX__;
pub const SHRT_MAX = __SHRT_MAX__;
pub const INT_MAX = __INT_MAX__;
pub const LONG_MAX = __LONG_MAX__;
pub const SCHAR_MIN = -__SCHAR_MAX__ - @as(c_int, 1);
pub const SHRT_MIN = -__SHRT_MAX__ - @as(c_int, 1);
pub const INT_MIN = -__INT_MAX__ - @as(c_int, 1);
pub const LONG_MIN = -__LONG_MAX__ - @as(c_long, 1);
pub const UCHAR_MAX = (__SCHAR_MAX__ * @as(c_int, 2)) + @as(c_int, 1);
pub const USHRT_MAX = (__SHRT_MAX__ * @as(c_int, 2)) + @as(c_int, 1);
pub const UINT_MAX = (__INT_MAX__ * @as(c_uint, 2)) + @as(c_uint, 1);
pub const ULONG_MAX = (__LONG_MAX__ * @as(c_ulong, 2)) + @as(c_ulong, 1);
pub const CHAR_BIT = __CHAR_BIT__;
pub const CHAR_MIN = SCHAR_MIN;
pub const CHAR_MAX = __SCHAR_MAX__;
pub const __CLANG_FLOAT_H = "";
pub const FLT_EVAL_METHOD = @compileError("unable to translate macro: undefined identifier `__FLT_EVAL_METHOD__`");
// /var/mnt/eclipse/hyper-data/toolchains/asdf/installs/zig/0.15.2/lib/include/float.h:107:9
pub const FLT_ROUNDS = @compileError("unable to translate macro: undefined identifier `__builtin_flt_rounds`");
// /var/mnt/eclipse/hyper-data/toolchains/asdf/installs/zig/0.15.2/lib/include/float.h:109:9
pub const FLT_RADIX = __FLT_RADIX__;
pub const FLT_MANT_DIG = __FLT_MANT_DIG__;
pub const DBL_MANT_DIG = __DBL_MANT_DIG__;
pub const LDBL_MANT_DIG = __LDBL_MANT_DIG__;
pub const DECIMAL_DIG = __DECIMAL_DIG__;
pub const FLT_DIG = __FLT_DIG__;
pub const DBL_DIG = __DBL_DIG__;
pub const LDBL_DIG = __LDBL_DIG__;
pub const FLT_MIN_EXP = __FLT_MIN_EXP__;
pub const DBL_MIN_EXP = __DBL_MIN_EXP__;
pub const LDBL_MIN_EXP = __LDBL_MIN_EXP__;
pub const FLT_MIN_10_EXP = __FLT_MIN_10_EXP__;
pub const DBL_MIN_10_EXP = __DBL_MIN_10_EXP__;
pub const LDBL_MIN_10_EXP = __LDBL_MIN_10_EXP__;
pub const FLT_MAX_EXP = __FLT_MAX_EXP__;
pub const DBL_MAX_EXP = __DBL_MAX_EXP__;
pub const LDBL_MAX_EXP = __LDBL_MAX_EXP__;
pub const FLT_MAX_10_EXP = __FLT_MAX_10_EXP__;
pub const DBL_MAX_10_EXP = __DBL_MAX_10_EXP__;
pub const LDBL_MAX_10_EXP = __LDBL_MAX_10_EXP__;
pub const FLT_MAX = __FLT_MAX__;
pub const DBL_MAX = __DBL_MAX__;
pub const LDBL_MAX = __LDBL_MAX__;
pub const FLT_EPSILON = __FLT_EPSILON__;
pub const DBL_EPSILON = __DBL_EPSILON__;
pub const LDBL_EPSILON = __LDBL_EPSILON__;
pub const FLT_MIN = __FLT_MIN__;
pub const DBL_MIN = __DBL_MIN__;
pub const LDBL_MIN = __LDBL_MIN__;
pub const FLT_TRUE_MIN = __FLT_DENORM_MIN__;
pub const DBL_TRUE_MIN = __DBL_DENORM_MIN__;
pub const LDBL_TRUE_MIN = __LDBL_DENORM_MIN__;
pub const FLT_DECIMAL_DIG = __FLT_DECIMAL_DIG__;
pub const DBL_DECIMAL_DIG = __DBL_DECIMAL_DIG__;
pub const LDBL_DECIMAL_DIG = __LDBL_DECIMAL_DIG__;
pub const FLT_HAS_SUBNORM = __FLT_HAS_DENORM__;
pub const DBL_HAS_SUBNORM = __DBL_HAS_DENORM__;
pub const LDBL_HAS_SUBNORM = __LDBL_HAS_DENORM__;
pub const INFINITY = __builtin_inff();
pub const NAN = __builtin_nanf("");
pub const FLT_NORM_MAX = __FLT_NORM_MAX__;
pub const DBL_NORM_MAX = __DBL_NORM_MAX__;
pub const LDBL_NORM_MAX = __LDBL_NORM_MAX__;
pub const GLIB_HAVE_ALLOCA_H = "";
pub const GLIB_USING_SYSTEM_PRINTF = "";
pub const G_MINFLOAT = FLT_MIN;
pub const G_MAXFLOAT = FLT_MAX;
pub const G_MINDOUBLE = DBL_MIN;
pub const G_MAXDOUBLE = DBL_MAX;
pub const G_MINSHORT = SHRT_MIN;
pub const G_MAXSHORT = SHRT_MAX;
pub const G_MAXUSHORT = USHRT_MAX;
pub const G_MININT = INT_MIN;
pub const G_MAXINT = INT_MAX;
pub const G_MAXUINT = UINT_MAX;
pub const G_MINLONG = LONG_MIN;
pub const G_MAXLONG = LONG_MAX;
pub const G_MAXULONG = ULONG_MAX;
pub const G_GINT16_MODIFIER = "h";
pub const G_GINT16_FORMAT = "hi";
pub const G_GUINT16_FORMAT = "hu";
pub const G_GINT32_MODIFIER = "";
pub const G_GINT32_FORMAT = "i";
pub const G_GUINT32_FORMAT = "u";
pub const G_HAVE_GINT64 = @as(c_int, 1);
pub const G_GINT64_CONSTANT = @import("std").zig.c_translation.Macros.L_SUFFIX;
pub const G_GUINT64_CONSTANT = @import("std").zig.c_translation.Macros.UL_SUFFIX;
pub const G_GINT64_MODIFIER = "l";
pub const G_GINT64_FORMAT = "li";
pub const G_GUINT64_FORMAT = "lu";
pub const GLIB_SIZEOF_VOID_P = @as(c_int, 8);
pub const GLIB_SIZEOF_LONG = @as(c_int, 8);
pub const GLIB_SIZEOF_SIZE_T = @as(c_int, 8);
pub const GLIB_SIZEOF_SSIZE_T = @as(c_int, 8);
pub const G_GSIZE_MODIFIER = "l";
pub const G_GSSIZE_MODIFIER = "l";
pub const G_GSIZE_FORMAT = "lu";
pub const G_GSSIZE_FORMAT = "li";
pub const G_MAXSIZE = G_MAXULONG;
pub const G_MINSSIZE = G_MINLONG;
pub const G_MAXSSIZE = G_MAXLONG;
pub const G_MINOFFSET = G_MININT64;
pub const G_MAXOFFSET = G_MAXINT64;
pub const G_GOFFSET_MODIFIER = G_GINT64_MODIFIER;
pub const G_GOFFSET_FORMAT = G_GINT64_FORMAT;
pub inline fn G_GOFFSET_CONSTANT(val: anytype) @TypeOf(G_GINT64_CONSTANT(val)) {
    _ = &val;
    return G_GINT64_CONSTANT(val);
}
pub const G_POLLFD_FORMAT = "%d";
pub inline fn GPOINTER_TO_INT(p: anytype) gint {
    _ = &p;
    return @import("std").zig.c_translation.cast(gint, @import("std").zig.c_translation.cast(glong, p));
}
pub inline fn GPOINTER_TO_UINT(p: anytype) guint {
    _ = &p;
    return @import("std").zig.c_translation.cast(guint, @import("std").zig.c_translation.cast(gulong, p));
}
pub inline fn GINT_TO_POINTER(i: anytype) gpointer {
    _ = &i;
    return @import("std").zig.c_translation.cast(gpointer, @import("std").zig.c_translation.cast(glong, i));
}
pub inline fn GUINT_TO_POINTER(u: anytype) gpointer {
    _ = &u;
    return @import("std").zig.c_translation.cast(gpointer, @import("std").zig.c_translation.cast(gulong, u));
}
pub const G_GINTPTR_MODIFIER = "l";
pub const G_GINTPTR_FORMAT = "li";
pub const G_GUINTPTR_FORMAT = "lu";
pub const GLIB_MAJOR_VERSION = @as(c_int, 2);
pub const GLIB_MINOR_VERSION = @as(c_int, 86);
pub const GLIB_MICRO_VERSION = @as(c_int, 4);
pub const G_OS_UNIX = "";
pub const G_VA_COPY = va_copy;
pub const G_VA_COPY_AS_ARRAY = @as(c_int, 1);
pub const G_HAVE_ISO_VARARGS = @as(c_int, 1);
pub const G_HAVE_GROWING_STACK = @as(c_int, 0);
pub const G_HAVE_GNUC_VARARGS = @as(c_int, 1);
pub const G_GNUC_INTERNAL = @compileError("unable to translate macro: undefined identifier `visibility`");
// /usr/lib64/glib-2.0/include/glibconfig.h:147:9
pub const G_THREADS_ENABLED = "";
pub const G_THREADS_IMPL_POSIX = "";
pub const G_ATOMIC_LOCK_FREE = "";
pub inline fn GINT16_TO_LE(val: anytype) gint16 {
    _ = &val;
    return @import("std").zig.c_translation.cast(gint16, val);
}
pub inline fn GUINT16_TO_LE(val: anytype) guint16 {
    _ = &val;
    return @import("std").zig.c_translation.cast(guint16, val);
}
pub inline fn GINT16_TO_BE(val: anytype) gint16 {
    _ = &val;
    return @import("std").zig.c_translation.cast(gint16, GUINT16_SWAP_LE_BE(val));
}
pub inline fn GUINT16_TO_BE(val: anytype) @TypeOf(GUINT16_SWAP_LE_BE(val)) {
    _ = &val;
    return GUINT16_SWAP_LE_BE(val);
}
pub inline fn GINT32_TO_LE(val: anytype) gint32 {
    _ = &val;
    return @import("std").zig.c_translation.cast(gint32, val);
}
pub inline fn GUINT32_TO_LE(val: anytype) guint32 {
    _ = &val;
    return @import("std").zig.c_translation.cast(guint32, val);
}
pub inline fn GINT32_TO_BE(val: anytype) gint32 {
    _ = &val;
    return @import("std").zig.c_translation.cast(gint32, GUINT32_SWAP_LE_BE(val));
}
pub inline fn GUINT32_TO_BE(val: anytype) @TypeOf(GUINT32_SWAP_LE_BE(val)) {
    _ = &val;
    return GUINT32_SWAP_LE_BE(val);
}
pub inline fn GINT64_TO_LE(val: anytype) gint64 {
    _ = &val;
    return @import("std").zig.c_translation.cast(gint64, val);
}
pub inline fn GUINT64_TO_LE(val: anytype) guint64 {
    _ = &val;
    return @import("std").zig.c_translation.cast(guint64, val);
}
pub inline fn GINT64_TO_BE(val: anytype) gint64 {
    _ = &val;
    return @import("std").zig.c_translation.cast(gint64, GUINT64_SWAP_LE_BE(val));
}
pub inline fn GUINT64_TO_BE(val: anytype) @TypeOf(GUINT64_SWAP_LE_BE(val)) {
    _ = &val;
    return GUINT64_SWAP_LE_BE(val);
}
pub inline fn GLONG_TO_LE(val: anytype) glong {
    _ = &val;
    return @import("std").zig.c_translation.cast(glong, GINT64_TO_LE(val));
}
pub inline fn GULONG_TO_LE(val: anytype) gulong {
    _ = &val;
    return @import("std").zig.c_translation.cast(gulong, GUINT64_TO_LE(val));
}
pub inline fn GLONG_TO_BE(val: anytype) glong {
    _ = &val;
    return @import("std").zig.c_translation.cast(glong, GINT64_TO_BE(val));
}
pub inline fn GULONG_TO_BE(val: anytype) gulong {
    _ = &val;
    return @import("std").zig.c_translation.cast(gulong, GUINT64_TO_BE(val));
}
pub inline fn GINT_TO_LE(val: anytype) gint {
    _ = &val;
    return @import("std").zig.c_translation.cast(gint, GINT32_TO_LE(val));
}
pub inline fn GUINT_TO_LE(val: anytype) guint {
    _ = &val;
    return @import("std").zig.c_translation.cast(guint, GUINT32_TO_LE(val));
}
pub inline fn GINT_TO_BE(val: anytype) gint {
    _ = &val;
    return @import("std").zig.c_translation.cast(gint, GINT32_TO_BE(val));
}
pub inline fn GUINT_TO_BE(val: anytype) guint {
    _ = &val;
    return @import("std").zig.c_translation.cast(guint, GUINT32_TO_BE(val));
}
pub inline fn GSIZE_TO_LE(val: anytype) gsize {
    _ = &val;
    return @import("std").zig.c_translation.cast(gsize, GUINT64_TO_LE(val));
}
pub inline fn GSSIZE_TO_LE(val: anytype) gssize {
    _ = &val;
    return @import("std").zig.c_translation.cast(gssize, GINT64_TO_LE(val));
}
pub inline fn GSIZE_TO_BE(val: anytype) gsize {
    _ = &val;
    return @import("std").zig.c_translation.cast(gsize, GUINT64_TO_BE(val));
}
pub inline fn GSSIZE_TO_BE(val: anytype) gssize {
    _ = &val;
    return @import("std").zig.c_translation.cast(gssize, GINT64_TO_BE(val));
}
pub const G_BYTE_ORDER = G_LITTLE_ENDIAN;
pub const GLIB_SYSDEF_POLLIN = @compileError("unable to translate C expr: unexpected token '='");
// /usr/lib64/glib-2.0/include/glibconfig.h:186:9
pub const GLIB_SYSDEF_POLLOUT = @compileError("unable to translate C expr: unexpected token '='");
// /usr/lib64/glib-2.0/include/glibconfig.h:187:9
pub const GLIB_SYSDEF_POLLPRI = @compileError("unable to translate C expr: unexpected token '='");
// /usr/lib64/glib-2.0/include/glibconfig.h:188:9
pub const GLIB_SYSDEF_POLLHUP = @compileError("unable to translate C expr: unexpected token '='");
// /usr/lib64/glib-2.0/include/glibconfig.h:189:9
pub const GLIB_SYSDEF_POLLERR = @compileError("unable to translate C expr: unexpected token '='");
// /usr/lib64/glib-2.0/include/glibconfig.h:190:9
pub const GLIB_SYSDEF_POLLNVAL = @compileError("unable to translate C expr: unexpected token '='");
// /usr/lib64/glib-2.0/include/glibconfig.h:191:9
pub const G_MODULE_SUFFIX = "so";
pub const G_PID_FORMAT = "i";
pub const GLIB_SYSDEF_AF_UNIX = @as(c_int, 1);
pub const GLIB_SYSDEF_AF_INET = @as(c_int, 2);
pub const GLIB_SYSDEF_AF_INET6 = @as(c_int, 10);
pub const GLIB_SYSDEF_MSG_OOB = @as(c_int, 1);
pub const GLIB_SYSDEF_MSG_PEEK = @as(c_int, 2);
pub const GLIB_SYSDEF_MSG_DONTROUTE = @as(c_int, 4);
pub const G_DIR_SEPARATOR = '/';
pub const G_DIR_SEPARATOR_S = "/";
pub const G_SEARCHPATH_SEPARATOR = ':';
pub const G_SEARCHPATH_SEPARATOR_S = ":";
pub const __G_VERSION_MACROS_H__ = "";
pub inline fn G_ENCODE_VERSION(major: anytype, minor: anytype) @TypeOf((major << @as(c_int, 16)) | (minor << @as(c_int, 8))) {
    _ = &major;
    _ = &minor;
    return (major << @as(c_int, 16)) | (minor << @as(c_int, 8));
}
pub const GLIB_VERSION_2_2 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 2));
pub const GLIB_VERSION_2_4 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 4));
pub const GLIB_VERSION_2_6 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 6));
pub const GLIB_VERSION_2_8 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 8));
pub const GLIB_VERSION_2_10 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 10));
pub const GLIB_VERSION_2_12 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 12));
pub const GLIB_VERSION_2_14 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 14));
pub const GLIB_VERSION_2_16 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 16));
pub const GLIB_VERSION_2_18 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 18));
pub const GLIB_VERSION_2_20 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 20));
pub const GLIB_VERSION_2_22 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 22));
pub const GLIB_VERSION_2_24 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 24));
pub const GLIB_VERSION_2_26 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 26));
pub const GLIB_VERSION_2_28 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 28));
pub const GLIB_VERSION_2_30 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 30));
pub const GLIB_VERSION_2_32 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 32));
pub const GLIB_VERSION_2_34 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 34));
pub const GLIB_VERSION_2_36 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 36));
pub const GLIB_VERSION_2_38 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 38));
pub const GLIB_VERSION_2_40 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 40));
pub const GLIB_VERSION_2_42 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 42));
pub const GLIB_VERSION_2_44 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 44));
pub const GLIB_VERSION_2_46 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 46));
pub const GLIB_VERSION_2_48 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 48));
pub const GLIB_VERSION_2_50 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 50));
pub const GLIB_VERSION_2_52 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 52));
pub const GLIB_VERSION_2_54 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 54));
pub const GLIB_VERSION_2_56 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 56));
pub const GLIB_VERSION_2_58 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 58));
pub const GLIB_VERSION_2_60 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 60));
pub const GLIB_VERSION_2_62 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 62));
pub const GLIB_VERSION_2_64 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 64));
pub const GLIB_VERSION_2_66 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 66));
pub const GLIB_VERSION_2_68 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 68));
pub const GLIB_VERSION_2_70 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 70));
pub const GLIB_VERSION_2_72 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 72));
pub const GLIB_VERSION_2_74 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 74));
pub const GLIB_VERSION_2_76 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 76));
pub const GLIB_VERSION_2_78 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 78));
pub const GLIB_VERSION_2_80 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 80));
pub const GLIB_VERSION_2_82 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 82));
pub const GLIB_VERSION_2_84 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 84));
pub const GLIB_VERSION_2_86 = G_ENCODE_VERSION(@as(c_int, 2), @as(c_int, 86));
pub const GLIB_VERSION_CUR_STABLE = G_ENCODE_VERSION(GLIB_MAJOR_VERSION, GLIB_MINOR_VERSION);
pub const GLIB_VERSION_PREV_STABLE = G_ENCODE_VERSION(GLIB_MAJOR_VERSION, GLIB_MINOR_VERSION - @as(c_int, 2));
pub const GLIB_VERSION_MIN_REQUIRED = GLIB_VERSION_CUR_STABLE;
pub const GLIB_VERSION_MAX_ALLOWED = GLIB_VERSION_CUR_STABLE;
pub const _GLIB_EXPORT = @compileError("unable to translate macro: undefined identifier `visibility`");
// /usr/include/glib-2.0/glib/glib-visibility.h:7:11
pub const _GLIB_IMPORT = "";
pub const _GLIB_API = "";
pub const _GLIB_EXTERN = @compileError("unable to translate C expr: unexpected token 'extern'");
// /usr/include/glib-2.0/glib/glib-visibility.h:19:9
pub const GLIB_VAR = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_IN_ALL = _GLIB_EXTERN;
pub const GLIB_DEPRECATED = G_DEPRECATED ++ _GLIB_EXTERN;
pub inline fn GLIB_DEPRECATED_FOR(f: anytype) @TypeOf(G_DEPRECATED_FOR(f) ++ _GLIB_EXTERN) {
    _ = &f;
    return G_DEPRECATED_FOR(f) ++ _GLIB_EXTERN;
}
pub inline fn GLIB_UNAVAILABLE(maj: anytype, min: anytype) @TypeOf(G_UNAVAILABLE(maj, min) ++ _GLIB_EXTERN) {
    _ = &maj;
    _ = &min;
    return G_UNAVAILABLE(maj, min) ++ _GLIB_EXTERN;
}
pub inline fn GLIB_UNAVAILABLE_STATIC_INLINE(maj: anytype, min: anytype) @TypeOf(G_UNAVAILABLE(maj, min)) {
    _ = &maj;
    _ = &min;
    return G_UNAVAILABLE(maj, min);
}
pub const GLIB_DEPRECATED_IN_2_26 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_26_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_26 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_26_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_26 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_26_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_26 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_26_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_26 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_26 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_26 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_26 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_26 = "";
pub const GLIB_DEPRECATED_IN_2_28 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_28_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_28 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_28_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_28 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_28_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_28 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_28_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_28 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_28 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_28 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_28 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_28 = "";
pub const GLIB_DEPRECATED_IN_2_30 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_30_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_30 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_30_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_30 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_30_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_30 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_30_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_30 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_30 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_30 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_30 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_30 = "";
pub const GLIB_DEPRECATED_IN_2_32 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_32_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_32 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_32_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_32 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_32_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_32 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_32_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_32 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_32 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_32 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_32 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_32 = "";
pub const GLIB_DEPRECATED_IN_2_34 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_34_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_34 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_34_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_34 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_34_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_34 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_34_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_34 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_34 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_34 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_34 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_34 = "";
pub const GLIB_DEPRECATED_IN_2_36 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_36_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_36 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_36_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_36 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_36_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_36 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_36_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_36 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_36 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_36 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_36 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_36 = "";
pub const GLIB_DEPRECATED_IN_2_38 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_38_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_38 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_38_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_38 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_38_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_38 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_38_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_38 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_38 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_38 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_38 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_38 = "";
pub const GLIB_DEPRECATED_IN_2_40 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_40_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_40 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_40_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_40 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_40_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_40 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_40_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_40 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_40 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_40 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_40 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_40 = "";
pub const GLIB_DEPRECATED_IN_2_42 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_42_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_42 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_42_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_42 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_42_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_42 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_42_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_42 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_42 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_42 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_42 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_42 = "";
pub const GLIB_DEPRECATED_IN_2_44 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_44_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_44 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_44_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_44 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_44_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_44 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_44_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_44 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_44 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_44 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_44 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_44 = "";
pub const GLIB_DEPRECATED_IN_2_46 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_46_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_46 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_46_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_46 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_46_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_46 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_46_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_46 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_46 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_46 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_46 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_46 = "";
pub const GLIB_DEPRECATED_IN_2_48 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_48_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_48 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_48_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_48 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_48_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_48 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_48_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_48 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_48 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_48 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_48 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_48 = "";
pub const GLIB_DEPRECATED_IN_2_50 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_50_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_50 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_50_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_50 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_50_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_50 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_50_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_50 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_50 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_50 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_50 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_50 = "";
pub const GLIB_DEPRECATED_IN_2_52 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_52_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_52 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_52_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_52 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_52_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_52 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_52_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_52 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_52 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_52 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_52 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_52 = "";
pub const GLIB_DEPRECATED_IN_2_54 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_54_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_54 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_54_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_54 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_54_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_54 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_54_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_54 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_54 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_54 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_54 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_54 = "";
pub const GLIB_DEPRECATED_IN_2_56 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_56_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_56 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_56_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_56 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_56_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_56 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_56_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_56 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_56 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_56 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_56 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_56 = "";
pub const GLIB_DEPRECATED_IN_2_58 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_58_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_58 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_58_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_58 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_58_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_58 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_58_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_58 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_58 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_58 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_58 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_58 = "";
pub const GLIB_DEPRECATED_IN_2_60 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_60_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_60 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_60_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_60 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_60_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_60 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_60_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_60 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_60 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_60 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_60 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_60 = "";
pub const GLIB_DEPRECATED_IN_2_62 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_62_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_62 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_62_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_62 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_62_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_62 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_62_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_62 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_62 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_62 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_62 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_62 = "";
pub const GLIB_DEPRECATED_IN_2_64 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_64_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_64 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_64_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_64 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_64_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_64 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_64_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_64 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_64 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_64 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_64 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_64 = "";
pub const GLIB_DEPRECATED_IN_2_66 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_66_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_66 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_66_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_66 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_66_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_66 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_66_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_66 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_66 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_66 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_66 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_66 = "";
pub const GLIB_DEPRECATED_IN_2_68 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_68_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_68 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_68_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_68 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_68_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_68 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_68_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_68 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_68 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_68 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_68 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_68 = "";
pub const GLIB_DEPRECATED_IN_2_70 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_70_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_70 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_70_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_70 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_70_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_70 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_70_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_70 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_70 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_70 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_70 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_70 = "";
pub const GLIB_DEPRECATED_IN_2_72 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_72_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_72 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_72_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_72 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_72_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_72 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_72_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_72 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_72 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_72 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_72 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_72 = "";
pub const GLIB_DEPRECATED_IN_2_74 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_74_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_74 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_74_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_74 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_74_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_74 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_74_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_74 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_74 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_74 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_74 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_74 = "";
pub const GLIB_DEPRECATED_IN_2_76 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_76_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_76 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_76_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_76 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_76_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_76 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_76_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_76 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_76 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_76 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_76 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_76 = "";
pub const GLIB_DEPRECATED_IN_2_78 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_78_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_78 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_78_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_78 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_78_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_78 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_78_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_78 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_78 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_78 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_78 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_78 = "";
pub const GLIB_DEPRECATED_IN_2_80 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_80_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_80 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_80_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_80 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_80_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_80 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_80_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_80 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_80 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_80 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_80 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_80 = "";
pub const GLIB_DEPRECATED_IN_2_82 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_82_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_82 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_82_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_82 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_82_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_82 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_82_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_82 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_82 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_82 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_82 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_82 = "";
pub const GLIB_DEPRECATED_IN_2_84 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_84_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_84 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_84_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_84 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_84_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_84 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_84_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_84 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_84 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_84 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_84 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_84 = "";
pub const GLIB_DEPRECATED_IN_2_86 = GLIB_DEPRECATED;
pub inline fn GLIB_DEPRECATED_IN_2_86_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_FOR(f);
}
pub const GLIB_DEPRECATED_MACRO_IN_2_86 = GLIB_DEPRECATED_MACRO;
pub inline fn GLIB_DEPRECATED_MACRO_IN_2_86_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_MACRO_FOR(f);
}
pub const GLIB_DEPRECATED_ENUMERATOR_IN_2_86 = GLIB_DEPRECATED_ENUMERATOR;
pub inline fn GLIB_DEPRECATED_ENUMERATOR_IN_2_86_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_ENUMERATOR_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_ENUMERATOR_FOR(f);
}
pub const GLIB_DEPRECATED_TYPE_IN_2_86 = GLIB_DEPRECATED_TYPE;
pub inline fn GLIB_DEPRECATED_TYPE_IN_2_86_FOR(f: anytype) @TypeOf(GLIB_DEPRECATED_TYPE_FOR(f)) {
    _ = &f;
    return GLIB_DEPRECATED_TYPE_FOR(f);
}
pub const GLIB_AVAILABLE_IN_2_86 = _GLIB_EXTERN;
pub const GLIB_AVAILABLE_STATIC_INLINE_IN_2_86 = "";
pub const GLIB_AVAILABLE_MACRO_IN_2_86 = "";
pub const GLIB_AVAILABLE_ENUMERATOR_IN_2_86 = "";
pub const GLIB_AVAILABLE_TYPE_IN_2_86 = "";
pub const _TIME_H = @as(c_int, 1);
pub const _BITS_TIME_H = @as(c_int, 1);
pub const _BITS_TYPES_H = @as(c_int, 1);
pub const __S16_TYPE = c_short;
pub const __U16_TYPE = c_ushort;
pub const __S32_TYPE = c_int;
pub const __U32_TYPE = c_uint;
pub const __SLONGWORD_TYPE = c_long;
pub const __ULONGWORD_TYPE = c_ulong;
pub const __SQUAD_TYPE = c_long;
pub const __UQUAD_TYPE = c_ulong;
pub const __SWORD_TYPE = c_long;
pub const __UWORD_TYPE = c_ulong;
pub const __SLONG32_TYPE = c_int;
pub const __ULONG32_TYPE = c_uint;
pub const __S64_TYPE = c_long;
pub const __U64_TYPE = c_ulong;
pub const __STD_TYPE = @compileError("unable to translate C expr: unexpected token 'typedef'");
// /usr/include/bits/types.h:137:10
pub const _BITS_TYPESIZES_H = @as(c_int, 1);
pub const __SYSCALL_SLONG_TYPE = __SLONGWORD_TYPE;
pub const __SYSCALL_ULONG_TYPE = __ULONGWORD_TYPE;
pub const __DEV_T_TYPE = __UQUAD_TYPE;
pub const __UID_T_TYPE = __U32_TYPE;
pub const __GID_T_TYPE = __U32_TYPE;
pub const __INO_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __INO64_T_TYPE = __UQUAD_TYPE;
pub const __MODE_T_TYPE = __U32_TYPE;
pub const __NLINK_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSWORD_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __OFF_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __OFF64_T_TYPE = __SQUAD_TYPE;
pub const __PID_T_TYPE = __S32_TYPE;
pub const __RLIM_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __RLIM64_T_TYPE = __UQUAD_TYPE;
pub const __BLKCNT_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __BLKCNT64_T_TYPE = __SQUAD_TYPE;
pub const __FSBLKCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSBLKCNT64_T_TYPE = __UQUAD_TYPE;
pub const __FSFILCNT_T_TYPE = __SYSCALL_ULONG_TYPE;
pub const __FSFILCNT64_T_TYPE = __UQUAD_TYPE;
pub const __ID_T_TYPE = __U32_TYPE;
pub const __CLOCK_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __TIME_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __USECONDS_T_TYPE = __U32_TYPE;
pub const __SUSECONDS_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __SUSECONDS64_T_TYPE = __SQUAD_TYPE;
pub const __DADDR_T_TYPE = __S32_TYPE;
pub const __KEY_T_TYPE = __S32_TYPE;
pub const __CLOCKID_T_TYPE = __S32_TYPE;
pub const __TIMER_T_TYPE = ?*anyopaque;
pub const __BLKSIZE_T_TYPE = __SYSCALL_SLONG_TYPE;
pub const __FSID_T_TYPE = @compileError("unable to translate macro: undefined identifier `__val`");
// /usr/include/bits/typesizes.h:73:9
pub const __SSIZE_T_TYPE = __SWORD_TYPE;
pub const __CPU_MASK_TYPE = __SYSCALL_ULONG_TYPE;
pub const __OFF_T_MATCHES_OFF64_T = @as(c_int, 1);
pub const __INO_T_MATCHES_INO64_T = @as(c_int, 1);
pub const __RLIM_T_MATCHES_RLIM64_T = @as(c_int, 1);
pub const __STATFS_MATCHES_STATFS64 = @as(c_int, 1);
pub const __KERNEL_OLD_TIMEVAL_MATCHES_TIMEVAL64 = @as(c_int, 1);
pub const __FD_SETSIZE = @as(c_int, 1024);
pub const _BITS_TIME64_H = @as(c_int, 1);
pub const __TIME64_T_TYPE = __TIME_T_TYPE;
pub const CLOCKS_PER_SEC = @import("std").zig.c_translation.cast(__clock_t, @import("std").zig.c_translation.promoteIntLiteral(c_int, 1000000, .decimal));
pub const CLOCK_REALTIME = @as(c_int, 0);
pub const CLOCK_MONOTONIC = @as(c_int, 1);
pub const CLOCK_PROCESS_CPUTIME_ID = @as(c_int, 2);
pub const CLOCK_THREAD_CPUTIME_ID = @as(c_int, 3);
pub const CLOCK_MONOTONIC_RAW = @as(c_int, 4);
pub const CLOCK_REALTIME_COARSE = @as(c_int, 5);
pub const CLOCK_MONOTONIC_COARSE = @as(c_int, 6);
pub const CLOCK_BOOTTIME = @as(c_int, 7);
pub const CLOCK_REALTIME_ALARM = @as(c_int, 8);
pub const CLOCK_BOOTTIME_ALARM = @as(c_int, 9);
pub const CLOCK_TAI = @as(c_int, 11);
pub const TIMER_ABSTIME = @as(c_int, 1);
pub const __clock_t_defined = @as(c_int, 1);
pub const __time_t_defined = @as(c_int, 1);
pub const __struct_tm_defined = @as(c_int, 1);
pub const _STRUCT_TIMESPEC = @as(c_int, 1);
pub const _BITS_ENDIAN_H = @as(c_int, 1);
pub const __LITTLE_ENDIAN = @as(c_int, 1234);
pub const __BIG_ENDIAN = @as(c_int, 4321);
pub const __PDP_ENDIAN = @as(c_int, 3412);
pub const _BITS_ENDIANNESS_H = @as(c_int, 1);
pub const __BYTE_ORDER = __LITTLE_ENDIAN;
pub const __FLOAT_WORD_ORDER = __BYTE_ORDER;
pub inline fn __LONG_LONG_PAIR(HI: anytype, LO: anytype) @TypeOf(HI) {
    _ = &HI;
    _ = &LO;
    return blk: {
        _ = &LO;
        break :blk HI;
    };
}
pub const __clockid_t_defined = @as(c_int, 1);
pub const __timer_t_defined = @as(c_int, 1);
pub const __itimerspec_defined = @as(c_int, 1);
pub const __pid_t_defined = "";
pub const _BITS_TYPES_LOCALE_T_H = @as(c_int, 1);
pub const _BITS_TYPES___LOCALE_T_H = @as(c_int, 1);
pub const TIME_UTC = @as(c_int, 1);
pub inline fn __isleap(year: anytype) @TypeOf((@import("std").zig.c_translation.MacroArithmetic.rem(year, @as(c_int, 4)) == @as(c_int, 0)) and ((@import("std").zig.c_translation.MacroArithmetic.rem(year, @as(c_int, 100)) != @as(c_int, 0)) or (@import("std").zig.c_translation.MacroArithmetic.rem(year, @as(c_int, 400)) == @as(c_int, 0)))) {
    _ = &year;
    return (@import("std").zig.c_translation.MacroArithmetic.rem(year, @as(c_int, 4)) == @as(c_int, 0)) and ((@import("std").zig.c_translation.MacroArithmetic.rem(year, @as(c_int, 100)) != @as(c_int, 0)) or (@import("std").zig.c_translation.MacroArithmetic.rem(year, @as(c_int, 400)) == @as(c_int, 0)));
}
pub const G_MININT8 = @import("std").zig.c_translation.cast(gint8, -G_MAXINT8 - @as(c_int, 1));
pub const G_MAXINT8 = @import("std").zig.c_translation.cast(gint8, @as(c_int, 0x7f));
pub const G_MAXUINT8 = @import("std").zig.c_translation.cast(guint8, @as(c_int, 0xff));
pub const G_MININT16 = @import("std").zig.c_translation.cast(gint16, -G_MAXINT16 - @as(c_int, 1));
pub const G_MAXINT16 = @import("std").zig.c_translation.cast(gint16, @as(c_int, 0x7fff));
pub const G_MAXUINT16 = @import("std").zig.c_translation.cast(guint16, @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xffff, .hex));
pub const G_MININT32 = @import("std").zig.c_translation.cast(gint32, -G_MAXINT32 - @as(c_int, 1));
pub const G_MAXINT32 = @import("std").zig.c_translation.cast(gint32, @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7fffffff, .hex));
pub const G_MAXUINT32 = @import("std").zig.c_translation.cast(guint32, @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xffffffff, .hex));
pub const G_MININT64 = @import("std").zig.c_translation.cast(gint64, -G_MAXINT64 - G_GINT64_CONSTANT(@as(c_int, 1)));
pub const G_MAXINT64 = G_GINT64_CONSTANT(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0x7fffffffffffffff, .hex));
pub const G_MAXUINT64 = G_GUINT64_CONSTANT(@import("std").zig.c_translation.promoteIntLiteral(c_int, 0xffffffffffffffff, .hex));
pub const G_E = @as(f64, 2.7182818284590452353602874713526624977572470937000);
pub const G_LN2 = @as(f64, 0.69314718055994530941723212145817656807550013436026);
pub const G_LN10 = @as(f64, 2.3025850929940456840179914546843642076011014886288);
pub const G_PI = @as(f64, 3.1415926535897932384626433832795028841971693993751);
pub const G_PI_2 = @as(f64, 1.5707963267948966192313216916397514420985846996876);
pub const G_PI_4 = @as(f64, 0.78539816339744830961566084581987572104929234984378);
pub const G_SQRT2 = @as(f64, 1.4142135623730950488016887242096980785696718753769);
pub const G_LITTLE_ENDIAN = @as(c_int, 1234);
pub const G_BIG_ENDIAN = @as(c_int, 4321);
pub const G_PDP_ENDIAN = @as(c_int, 3412);
pub inline fn GUINT16_SWAP_LE_BE_CONSTANT(val: anytype) guint16 {
    _ = &val;
    return @import("std").zig.c_translation.cast(guint16, @import("std").zig.c_translation.cast(guint16, @import("std").zig.c_translation.cast(guint16, val) >> @as(c_int, 8)) | @import("std").zig.c_translation.cast(guint16, @import("std").zig.c_translation.cast(guint16, val) << @as(c_int, 8)));
}
pub inline fn GUINT32_SWAP_LE_BE_CONSTANT(val: anytype) guint32 {
    _ = &val;
    return @import("std").zig.c_translation.cast(guint32, ((((@import("std").zig.c_translation.cast(guint32, val) & @import("std").zig.c_translation.cast(guint32, @as(c_uint, 0x000000ff))) << @as(c_int, 24)) | ((@import("std").zig.c_translation.cast(guint32, val) & @import("std").zig.c_translation.cast(guint32, @as(c_uint, 0x0000ff00))) << @as(c_int, 8))) | ((@import("std").zig.c_translation.cast(guint32, val) & @import("std").zig.c_translation.cast(guint32, @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x00ff0000, .hex))) >> @as(c_int, 8))) | ((@import("std").zig.c_translation.cast(guint32, val) & @import("std").zig.c_translation.cast(guint32, @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xff000000, .hex))) >> @as(c_int, 24)));
}
pub inline fn GUINT64_SWAP_LE_BE_CONSTANT(val: anytype) guint64 {
    _ = &val;
    return @import("std").zig.c_translation.cast(guint64, ((((((((@import("std").zig.c_translation.cast(guint64, val) & @import("std").zig.c_translation.cast(guint64, G_GINT64_CONSTANT(@as(c_uint, 0x00000000000000ff)))) << @as(c_int, 56)) | ((@import("std").zig.c_translation.cast(guint64, val) & @import("std").zig.c_translation.cast(guint64, G_GINT64_CONSTANT(@as(c_uint, 0x000000000000ff00)))) << @as(c_int, 40))) | ((@import("std").zig.c_translation.cast(guint64, val) & @import("std").zig.c_translation.cast(guint64, G_GINT64_CONSTANT(@import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x0000000000ff0000, .hex)))) << @as(c_int, 24))) | ((@import("std").zig.c_translation.cast(guint64, val) & @import("std").zig.c_translation.cast(guint64, G_GINT64_CONSTANT(@import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x00000000ff000000, .hex)))) << @as(c_int, 8))) | ((@import("std").zig.c_translation.cast(guint64, val) & @import("std").zig.c_translation.cast(guint64, G_GINT64_CONSTANT(@import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x000000ff00000000, .hex)))) >> @as(c_int, 8))) | ((@import("std").zig.c_translation.cast(guint64, val) & @import("std").zig.c_translation.cast(guint64, G_GINT64_CONSTANT(@import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x0000ff0000000000, .hex)))) >> @as(c_int, 24))) | ((@import("std").zig.c_translation.cast(guint64, val) & @import("std").zig.c_translation.cast(guint64, G_GINT64_CONSTANT(@import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x00ff000000000000, .hex)))) >> @as(c_int, 40))) | ((@import("std").zig.c_translation.cast(guint64, val) & @import("std").zig.c_translation.cast(guint64, G_GINT64_CONSTANT(@import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xff00000000000000, .hex)))) >> @as(c_int, 56)));
}
pub inline fn GUINT16_SWAP_LE_BE(val: anytype) @TypeOf(GUINT16_SWAP_LE_BE_CONSTANT(val)) {
    _ = &val;
    return GUINT16_SWAP_LE_BE_CONSTANT(val);
}
pub inline fn GUINT32_SWAP_LE_BE(val: anytype) @TypeOf(GUINT32_SWAP_LE_BE_CONSTANT(val)) {
    _ = &val;
    return GUINT32_SWAP_LE_BE_CONSTANT(val);
}
pub inline fn GUINT64_SWAP_LE_BE(val: anytype) @TypeOf(GUINT64_SWAP_LE_BE_CONSTANT(val)) {
    _ = &val;
    return GUINT64_SWAP_LE_BE_CONSTANT(val);
}
pub inline fn GUINT16_SWAP_LE_PDP(val: anytype) guint16 {
    _ = &val;
    return @import("std").zig.c_translation.cast(guint16, val);
}
pub inline fn GUINT16_SWAP_BE_PDP(val: anytype) @TypeOf(GUINT16_SWAP_LE_BE(val)) {
    _ = &val;
    return GUINT16_SWAP_LE_BE(val);
}
pub inline fn GUINT32_SWAP_LE_PDP(val: anytype) guint32 {
    _ = &val;
    return @import("std").zig.c_translation.cast(guint32, ((@import("std").zig.c_translation.cast(guint32, val) & @import("std").zig.c_translation.cast(guint32, @as(c_uint, 0x0000ffff))) << @as(c_int, 16)) | ((@import("std").zig.c_translation.cast(guint32, val) & @import("std").zig.c_translation.cast(guint32, @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xffff0000, .hex))) >> @as(c_int, 16)));
}
pub inline fn GUINT32_SWAP_BE_PDP(val: anytype) guint32 {
    _ = &val;
    return @import("std").zig.c_translation.cast(guint32, ((@import("std").zig.c_translation.cast(guint32, val) & @import("std").zig.c_translation.cast(guint32, @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x00ff00ff, .hex))) << @as(c_int, 8)) | ((@import("std").zig.c_translation.cast(guint32, val) & @import("std").zig.c_translation.cast(guint32, @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xff00ff00, .hex))) >> @as(c_int, 8)));
}
pub inline fn GINT16_FROM_LE(val: anytype) @TypeOf(GINT16_TO_LE(val)) {
    _ = &val;
    return GINT16_TO_LE(val);
}
pub inline fn GUINT16_FROM_LE(val: anytype) @TypeOf(GUINT16_TO_LE(val)) {
    _ = &val;
    return GUINT16_TO_LE(val);
}
pub inline fn GINT16_FROM_BE(val: anytype) @TypeOf(GINT16_TO_BE(val)) {
    _ = &val;
    return GINT16_TO_BE(val);
}
pub inline fn GUINT16_FROM_BE(val: anytype) @TypeOf(GUINT16_TO_BE(val)) {
    _ = &val;
    return GUINT16_TO_BE(val);
}
pub inline fn GINT32_FROM_LE(val: anytype) @TypeOf(GINT32_TO_LE(val)) {
    _ = &val;
    return GINT32_TO_LE(val);
}
pub inline fn GUINT32_FROM_LE(val: anytype) @TypeOf(GUINT32_TO_LE(val)) {
    _ = &val;
    return GUINT32_TO_LE(val);
}
pub inline fn GINT32_FROM_BE(val: anytype) @TypeOf(GINT32_TO_BE(val)) {
    _ = &val;
    return GINT32_TO_BE(val);
}
pub inline fn GUINT32_FROM_BE(val: anytype) @TypeOf(GUINT32_TO_BE(val)) {
    _ = &val;
    return GUINT32_TO_BE(val);
}
pub inline fn GINT64_FROM_LE(val: anytype) @TypeOf(GINT64_TO_LE(val)) {
    _ = &val;
    return GINT64_TO_LE(val);
}
pub inline fn GUINT64_FROM_LE(val: anytype) @TypeOf(GUINT64_TO_LE(val)) {
    _ = &val;
    return GUINT64_TO_LE(val);
}
pub inline fn GINT64_FROM_BE(val: anytype) @TypeOf(GINT64_TO_BE(val)) {
    _ = &val;
    return GINT64_TO_BE(val);
}
pub inline fn GUINT64_FROM_BE(val: anytype) @TypeOf(GUINT64_TO_BE(val)) {
    _ = &val;
    return GUINT64_TO_BE(val);
}
pub inline fn GLONG_FROM_LE(val: anytype) @TypeOf(GLONG_TO_LE(val)) {
    _ = &val;
    return GLONG_TO_LE(val);
}
pub inline fn GULONG_FROM_LE(val: anytype) @TypeOf(GULONG_TO_LE(val)) {
    _ = &val;
    return GULONG_TO_LE(val);
}
pub inline fn GLONG_FROM_BE(val: anytype) @TypeOf(GLONG_TO_BE(val)) {
    _ = &val;
    return GLONG_TO_BE(val);
}
pub inline fn GULONG_FROM_BE(val: anytype) @TypeOf(GULONG_TO_BE(val)) {
    _ = &val;
    return GULONG_TO_BE(val);
}
pub inline fn GINT_FROM_LE(val: anytype) @TypeOf(GINT_TO_LE(val)) {
    _ = &val;
    return GINT_TO_LE(val);
}
pub inline fn GUINT_FROM_LE(val: anytype) @TypeOf(GUINT_TO_LE(val)) {
    _ = &val;
    return GUINT_TO_LE(val);
}
pub inline fn GINT_FROM_BE(val: anytype) @TypeOf(GINT_TO_BE(val)) {
    _ = &val;
    return GINT_TO_BE(val);
}
pub inline fn GUINT_FROM_BE(val: anytype) @TypeOf(GUINT_TO_BE(val)) {
    _ = &val;
    return GUINT_TO_BE(val);
}
pub inline fn GSIZE_FROM_LE(val: anytype) @TypeOf(GSIZE_TO_LE(val)) {
    _ = &val;
    return GSIZE_TO_LE(val);
}
pub inline fn GSSIZE_FROM_LE(val: anytype) @TypeOf(GSSIZE_TO_LE(val)) {
    _ = &val;
    return GSSIZE_TO_LE(val);
}
pub inline fn GSIZE_FROM_BE(val: anytype) @TypeOf(GSIZE_TO_BE(val)) {
    _ = &val;
    return GSIZE_TO_BE(val);
}
pub inline fn GSSIZE_FROM_BE(val: anytype) @TypeOf(GSSIZE_TO_BE(val)) {
    _ = &val;
    return GSSIZE_TO_BE(val);
}
pub inline fn g_ntohl(val: anytype) @TypeOf(GUINT32_FROM_BE(val)) {
    _ = &val;
    return GUINT32_FROM_BE(val);
}
pub inline fn g_ntohs(val: anytype) @TypeOf(GUINT16_FROM_BE(val)) {
    _ = &val;
    return GUINT16_FROM_BE(val);
}
pub inline fn g_htonl(val: anytype) @TypeOf(GUINT32_TO_BE(val)) {
    _ = &val;
    return GUINT32_TO_BE(val);
}
pub inline fn g_htons(val: anytype) @TypeOf(GUINT16_TO_BE(val)) {
    _ = &val;
    return GUINT16_TO_BE(val);
}
pub const _GLIB_HAVE_BUILTIN_OVERFLOW_CHECKS = "";
pub const g_uint_checked_add = @compileError("unable to translate macro: undefined identifier `__builtin_add_overflow`");
// /usr/include/glib-2.0/glib/gtypes.h:461:9
pub inline fn g_uint_checked_mul(dest: anytype, a: anytype, b: anytype) @TypeOf(!(__builtin_mul_overflow(a, b, dest) != 0)) {
    _ = &dest;
    _ = &a;
    _ = &b;
    return !(__builtin_mul_overflow(a, b, dest) != 0);
}
pub const g_uint64_checked_add = @compileError("unable to translate macro: undefined identifier `__builtin_add_overflow`");
// /usr/include/glib-2.0/glib/gtypes.h:466:9
pub inline fn g_uint64_checked_mul(dest: anytype, a: anytype, b: anytype) @TypeOf(!(__builtin_mul_overflow(a, b, dest) != 0)) {
    _ = &dest;
    _ = &a;
    _ = &b;
    return !(__builtin_mul_overflow(a, b, dest) != 0);
}
pub const g_size_checked_add = @compileError("unable to translate macro: undefined identifier `__builtin_add_overflow`");
// /usr/include/glib-2.0/glib/gtypes.h:471:9
pub inline fn g_size_checked_mul(dest: anytype, a: anytype, b: anytype) @TypeOf(!(__builtin_mul_overflow(a, b, dest) != 0)) {
    _ = &dest;
    _ = &a;
    _ = &b;
    return !(__builtin_mul_overflow(a, b, dest) != 0);
}
pub const G_IEEE754_FLOAT_BIAS = @as(c_int, 127);
pub const G_IEEE754_DOUBLE_BIAS = @as(c_int, 1023);
pub const G_LOG_2_BASE_10 = @as(f64, 0.30102999566398119521);
pub const _STRING_H = @as(c_int, 1);
pub const _STRINGS_H = @as(c_int, 1);
pub inline fn g_alloca(size: anytype) @TypeOf(alloca(size)) {
    _ = &size;
    return alloca(size);
}
pub inline fn g_alloca0(size: anytype) @TypeOf(if (size == @as(c_int, 0)) NULL else memset(g_alloca(size), @as(c_int, 0), size)) {
    _ = &size;
    return if (size == @as(c_int, 0)) NULL else memset(g_alloca(size), @as(c_int, 0), size);
}
pub const g_newa = @compileError("unable to translate C expr: unexpected token ')'");
// /usr/include/glib-2.0/glib/galloca.h:131:9
pub const g_newa0 = @compileError("unable to translate C expr: unexpected token ')'");
// /usr/include/glib-2.0/glib/galloca.h:145:9
pub const __G_ARRAY_H__ = "";
pub inline fn g_array_append_val(a: anytype, v: anytype) @TypeOf(g_array_append_vals(a, &v, @as(c_int, 1))) {
    _ = &a;
    _ = &v;
    return g_array_append_vals(a, &v, @as(c_int, 1));
}
pub inline fn g_array_prepend_val(a: anytype, v: anytype) @TypeOf(g_array_prepend_vals(a, &v, @as(c_int, 1))) {
    _ = &a;
    _ = &v;
    return g_array_prepend_vals(a, &v, @as(c_int, 1));
}
pub inline fn g_array_insert_val(a: anytype, i: anytype, v: anytype) @TypeOf(g_array_insert_vals(a, i, &v, @as(c_int, 1))) {
    _ = &a;
    _ = &i;
    _ = &v;
    return g_array_insert_vals(a, i, &v, @as(c_int, 1));
}
pub const g_array_index = @compileError("unable to translate C expr: unexpected token ')'");
// /usr/include/glib-2.0/glib/garray.h:69:9
pub inline fn g_ptr_array_index(array: anytype, index_: anytype) @TypeOf(array.*.pdata[@as(usize, @intCast(index_))]) {
    _ = &array;
    _ = &index_;
    return array.*.pdata[@as(usize, @intCast(index_))];
}
pub const __G_ASYNCQUEUE_H__ = "";
pub const __G_THREAD_H__ = "";
pub const __G_ATOMIC_H__ = "";
pub const __GLIB_TYPEOF_H__ = "";
pub const glib_typeof = @compileError("unable to translate C expr: unexpected token '__typeof__'");
// /usr/include/glib-2.0/glib/glib-typeof.h:39:9
pub const __G_ERROR_H__ = "";
pub const __need___va_list = "";
pub const __need_va_list = "";
pub const __need_va_arg = "";
pub const __need___va_copy = "";
pub const __need_va_copy = "";
pub const __STDARG_H = "";
pub const __GNUC_VA_LIST = "";
pub const _VA_LIST = "";
pub const va_start = @compileError("unable to translate macro: undefined identifier `__builtin_va_start`");
// /var/mnt/eclipse/hyper-data/toolchains/asdf/installs/zig/0.15.2/lib/include/__stdarg_va_arg.h:17:9
pub const va_end = @compileError("unable to translate macro: undefined identifier `__builtin_va_end`");
// /var/mnt/eclipse/hyper-data/toolchains/asdf/installs/zig/0.15.2/lib/include/__stdarg_va_arg.h:19:9
pub const va_arg = @compileError("unable to translate C expr: unexpected token 'an identifier'");
// /var/mnt/eclipse/hyper-data/toolchains/asdf/installs/zig/0.15.2/lib/include/__stdarg_va_arg.h:20:9
pub const __va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`");
// /var/mnt/eclipse/hyper-data/toolchains/asdf/installs/zig/0.15.2/lib/include/__stdarg___va_copy.h:11:9
pub const va_copy = @compileError("unable to translate macro: undefined identifier `__builtin_va_copy`");
// /var/mnt/eclipse/hyper-data/toolchains/asdf/installs/zig/0.15.2/lib/include/__stdarg_va_copy.h:11:9
pub const __G_QUARK_H__ = "";
pub const G_DEFINE_QUARK = @compileError("unable to translate macro: undefined identifier `_quark`");
// /usr/include/glib-2.0/glib/gquark.h:51:9
pub const G_DEFINE_EXTENDED_ERROR = @compileError("unable to translate macro: undefined identifier `Private`");
// /usr/include/glib-2.0/glib/gerror.h:74:9
pub const __G_UTILS_H__ = "";
pub const G_OS_INFO_KEY_NAME = "NAME";
pub const G_OS_INFO_KEY_PRETTY_NAME = "PRETTY_NAME";
pub const G_OS_INFO_KEY_VERSION = "VERSION";
pub const G_OS_INFO_KEY_VERSION_CODENAME = "VERSION_CODENAME";
pub const G_OS_INFO_KEY_VERSION_ID = "VERSION_ID";
pub const G_OS_INFO_KEY_ID = "ID";
pub const G_OS_INFO_KEY_HOME_URL = "HOME_URL";
pub const G_OS_INFO_KEY_DOCUMENTATION_URL = "DOCUMENTATION_URL";
pub const G_OS_INFO_KEY_SUPPORT_URL = "SUPPORT_URL";
pub const G_OS_INFO_KEY_BUG_REPORT_URL = "BUG_REPORT_URL";
pub const G_OS_INFO_KEY_PRIVACY_POLICY_URL = "PRIVACY_POLICY_URL";
pub inline fn g_ATEXIT(proc: anytype) @TypeOf(atexit(proc) ++ GLIB_DEPRECATED_MACRO_IN_2_32) {
    _ = &proc;
    return atexit(proc) ++ GLIB_DEPRECATED_MACRO_IN_2_32;
}
pub const g_memmove = @compileError("unable to translate C expr: expected ',' or '}' instead got ';'");
// /usr/include/glib-2.0/glib/gutils.h:314:9
pub inline fn ATEXIT(proc: anytype) @TypeOf(g_ATEXIT(proc) ++ GLIB_DEPRECATED_MACRO_IN_2_32) {
    _ = &proc;
    return g_ATEXIT(proc) ++ GLIB_DEPRECATED_MACRO_IN_2_32;
}
pub const _STDLIB_H = @as(c_int, 1);
pub const WNOHANG = @as(c_int, 1);
pub const WUNTRACED = @as(c_int, 2);
pub const WSTOPPED = @as(c_int, 2);
pub const WEXITED = @as(c_int, 4);
pub const WCONTINUED = @as(c_int, 8);
pub const WNOWAIT = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x01000000, .hex);
pub const __WNOTHREAD = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x20000000, .hex);
pub const __WALL = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x40000000, .hex);
pub const __WCLONE = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x80000000, .hex);
pub inline fn __WEXITSTATUS(status: anytype) @TypeOf((status & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xff00, .hex)) >> @as(c_int, 8)) {
    _ = &status;
    return (status & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xff00, .hex)) >> @as(c_int, 8);
}
pub inline fn __WTERMSIG(status: anytype) @TypeOf(status & @as(c_int, 0x7f)) {
    _ = &status;
    return status & @as(c_int, 0x7f);
}
pub inline fn __WSTOPSIG(status: anytype) @TypeOf(__WEXITSTATUS(status)) {
    _ = &status;
    return __WEXITSTATUS(status);
}
pub inline fn __WIFEXITED(status: anytype) @TypeOf(__WTERMSIG(status) == @as(c_int, 0)) {
    _ = &status;
    return __WTERMSIG(status) == @as(c_int, 0);
}
pub inline fn __WIFSIGNALED(status: anytype) @TypeOf((@import("std").zig.c_translation.cast(i8, (status & @as(c_int, 0x7f)) + @as(c_int, 1)) >> @as(c_int, 1)) > @as(c_int, 0)) {
    _ = &status;
    return (@import("std").zig.c_translation.cast(i8, (status & @as(c_int, 0x7f)) + @as(c_int, 1)) >> @as(c_int, 1)) > @as(c_int, 0);
}
pub inline fn __WIFSTOPPED(status: anytype) @TypeOf((status & @as(c_int, 0xff)) == @as(c_int, 0x7f)) {
    _ = &status;
    return (status & @as(c_int, 0xff)) == @as(c_int, 0x7f);
}
pub inline fn __WIFCONTINUED(status: anytype) @TypeOf(status == __W_CONTINUED) {
    _ = &status;
    return status == __W_CONTINUED;
}
pub inline fn __WCOREDUMP(status: anytype) @TypeOf(status & __WCOREFLAG) {
    _ = &status;
    return status & __WCOREFLAG;
}
pub inline fn __W_EXITCODE(ret: anytype, sig: anytype) @TypeOf((ret << @as(c_int, 8)) | sig) {
    _ = &ret;
    _ = &sig;
    return (ret << @as(c_int, 8)) | sig;
}
pub inline fn __W_STOPCODE(sig: anytype) @TypeOf((sig << @as(c_int, 8)) | @as(c_int, 0x7f)) {
    _ = &sig;
    return (sig << @as(c_int, 8)) | @as(c_int, 0x7f);
}
pub const __W_CONTINUED = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0xffff, .hex);
pub const __WCOREFLAG = @as(c_int, 0x80);
pub inline fn WEXITSTATUS(status: anytype) @TypeOf(__WEXITSTATUS(status)) {
    _ = &status;
    return __WEXITSTATUS(status);
}
pub inline fn WTERMSIG(status: anytype) @TypeOf(__WTERMSIG(status)) {
    _ = &status;
    return __WTERMSIG(status);
}
pub inline fn WSTOPSIG(status: anytype) @TypeOf(__WSTOPSIG(status)) {
    _ = &status;
    return __WSTOPSIG(status);
}
pub inline fn WIFEXITED(status: anytype) @TypeOf(__WIFEXITED(status)) {
    _ = &status;
    return __WIFEXITED(status);
}
pub inline fn WIFSIGNALED(status: anytype) @TypeOf(__WIFSIGNALED(status)) {
    _ = &status;
    return __WIFSIGNALED(status);
}
pub inline fn WIFSTOPPED(status: anytype) @TypeOf(__WIFSTOPPED(status)) {
    _ = &status;
    return __WIFSTOPPED(status);
}
pub inline fn WIFCONTINUED(status: anytype) @TypeOf(__WIFCONTINUED(status)) {
    _ = &status;
    return __WIFCONTINUED(status);
}
pub const _BITS_FLOATN_H = "";
pub const __HAVE_FLOAT128 = @as(c_int, 1);
pub const __HAVE_DISTINCT_FLOAT128 = @as(c_int, 1);
pub const __HAVE_FLOAT64X = @as(c_int, 1);
pub const __HAVE_FLOAT64X_LONG_DOUBLE = @as(c_int, 1);
pub const __f128 = @compileError("unable to translate macro: undefined identifier `q`");
// /usr/include/bits/floatn.h:70:12
pub const __CFLOAT128 = __cfloat128;
pub const __builtin_signbitf128 = @compileError("unable to translate macro: undefined identifier `__signbitf128`");
// /usr/include/bits/floatn.h:124:12
pub const _BITS_FLOATN_COMMON_H = "";
pub const __HAVE_FLOAT16 = @as(c_int, 0);
pub const __HAVE_FLOAT32 = @as(c_int, 1);
pub const __HAVE_FLOAT64 = @as(c_int, 1);
pub const __HAVE_FLOAT32X = @as(c_int, 1);
pub const __HAVE_FLOAT128X = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT16 = __HAVE_FLOAT16;
pub const __HAVE_DISTINCT_FLOAT32 = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT64 = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT32X = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT64X = @as(c_int, 0);
pub const __HAVE_DISTINCT_FLOAT128X = __HAVE_FLOAT128X;
pub const __HAVE_FLOAT128_UNLIKE_LDBL = (__HAVE_DISTINCT_FLOAT128 != 0) and (__LDBL_MANT_DIG__ != @as(c_int, 113));
pub const __HAVE_FLOATN_NOT_TYPEDEF = @as(c_int, 0);
pub const __f32 = @import("std").zig.c_translation.Macros.F_SUFFIX;
pub inline fn __f64(x: anytype) @TypeOf(x) {
    _ = &x;
    return x;
}
pub inline fn __f32x(x: anytype) @TypeOf(x) {
    _ = &x;
    return x;
}
pub const __f64x = @import("std").zig.c_translation.Macros.L_SUFFIX;
pub const __CFLOAT32 = @compileError("unable to translate: TODO _Complex");
// /usr/include/bits/floatn-common.h:149:12
pub const __CFLOAT64 = @compileError("unable to translate: TODO _Complex");
// /usr/include/bits/floatn-common.h:160:13
pub const __CFLOAT32X = @compileError("unable to translate: TODO _Complex");
// /usr/include/bits/floatn-common.h:169:12
pub const __CFLOAT64X = @compileError("unable to translate: TODO _Complex");
// /usr/include/bits/floatn-common.h:178:13
pub inline fn __builtin_huge_valf32() @TypeOf(__builtin_huge_valf()) {
    return __builtin_huge_valf();
}
pub inline fn __builtin_inff32() @TypeOf(__builtin_inff()) {
    return __builtin_inff();
}
pub inline fn __builtin_nanf32(x: anytype) @TypeOf(__builtin_nanf(x)) {
    _ = &x;
    return __builtin_nanf(x);
}
pub const __builtin_nansf32 = @compileError("unable to translate macro: undefined identifier `__builtin_nansf`");
// /usr/include/bits/floatn-common.h:221:12
pub const __builtin_huge_valf64 = @compileError("unable to translate macro: undefined identifier `__builtin_huge_val`");
// /usr/include/bits/floatn-common.h:255:13
pub const __builtin_inff64 = @compileError("unable to translate macro: undefined identifier `__builtin_inf`");
// /usr/include/bits/floatn-common.h:256:13
pub const __builtin_nanf64 = @compileError("unable to translate macro: undefined identifier `__builtin_nan`");
// /usr/include/bits/floatn-common.h:257:13
pub const __builtin_nansf64 = @compileError("unable to translate macro: undefined identifier `__builtin_nans`");
// /usr/include/bits/floatn-common.h:258:13
pub const __builtin_huge_valf32x = @compileError("unable to translate macro: undefined identifier `__builtin_huge_val`");
// /usr/include/bits/floatn-common.h:272:12
pub const __builtin_inff32x = @compileError("unable to translate macro: undefined identifier `__builtin_inf`");
// /usr/include/bits/floatn-common.h:273:12
pub const __builtin_nanf32x = @compileError("unable to translate macro: undefined identifier `__builtin_nan`");
// /usr/include/bits/floatn-common.h:274:12
pub const __builtin_nansf32x = @compileError("unable to translate macro: undefined identifier `__builtin_nans`");
// /usr/include/bits/floatn-common.h:275:12
pub const __builtin_huge_valf64x = @compileError("unable to translate macro: undefined identifier `__builtin_huge_vall`");
// /usr/include/bits/floatn-common.h:289:13
pub const __builtin_inff64x = @compileError("unable to translate macro: undefined identifier `__builtin_infl`");
// /usr/include/bits/floatn-common.h:290:13
pub const __builtin_nanf64x = @compileError("unable to translate macro: undefined identifier `__builtin_nanl`");
// /usr/include/bits/floatn-common.h:291:13
pub const __builtin_nansf64x = @compileError("unable to translate macro: undefined identifier `__builtin_nansl`");
// /usr/include/bits/floatn-common.h:292:13
pub const __ldiv_t_defined = @as(c_int, 1);
pub const __lldiv_t_defined = @as(c_int, 1);
pub const RAND_MAX = @import("std").zig.c_translation.promoteIntLiteral(c_int, 2147483647, .decimal);
pub const EXIT_FAILURE = @as(c_int, 1);
pub const EXIT_SUCCESS = @as(c_int, 0);
pub const MB_CUR_MAX = __ctype_get_mb_cur_max();
pub const _SYS_TYPES_H = @as(c_int, 1);
pub const __u_char_defined = "";
pub const __ino_t_defined = "";
pub const __dev_t_defined = "";
pub const __gid_t_defined = "";
pub const __mode_t_defined = "";
pub const __nlink_t_defined = "";
pub const __uid_t_defined = "";
pub const __off_t_defined = "";
pub const __id_t_defined = "";
pub const __ssize_t_defined = "";
pub const __daddr_t_defined = "";
pub const __key_t_defined = "";
pub const _BITS_STDINT_INTN_H = @as(c_int, 1);
pub const __BIT_TYPES_DEFINED__ = @as(c_int, 1);
pub const _ENDIAN_H = @as(c_int, 1);
pub const LITTLE_ENDIAN = __LITTLE_ENDIAN;
pub const BIG_ENDIAN = __BIG_ENDIAN;
pub const PDP_ENDIAN = __PDP_ENDIAN;
pub const BYTE_ORDER = __BYTE_ORDER;
pub const _BITS_BYTESWAP_H = @as(c_int, 1);
pub inline fn __bswap_constant_16(x: anytype) __uint16_t {
    _ = &x;
    return @import("std").zig.c_translation.cast(__uint16_t, ((x >> @as(c_int, 8)) & @as(c_int, 0xff)) | ((x & @as(c_int, 0xff)) << @as(c_int, 8)));
}
pub inline fn __bswap_constant_32(x: anytype) @TypeOf(((((x & @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xff000000, .hex)) >> @as(c_int, 24)) | ((x & @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x00ff0000, .hex)) >> @as(c_int, 8))) | ((x & @as(c_uint, 0x0000ff00)) << @as(c_int, 8))) | ((x & @as(c_uint, 0x000000ff)) << @as(c_int, 24))) {
    _ = &x;
    return ((((x & @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0xff000000, .hex)) >> @as(c_int, 24)) | ((x & @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x00ff0000, .hex)) >> @as(c_int, 8))) | ((x & @as(c_uint, 0x0000ff00)) << @as(c_int, 8))) | ((x & @as(c_uint, 0x000000ff)) << @as(c_int, 24));
}
pub inline fn __bswap_constant_64(x: anytype) @TypeOf(((((((((x & @as(c_ulonglong, 0xff00000000000000)) >> @as(c_int, 56)) | ((x & @as(c_ulonglong, 0x00ff000000000000)) >> @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x0000ff0000000000)) >> @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000ff00000000)) >> @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x00000000ff000000)) << @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x0000000000ff0000)) << @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000000000ff00)) << @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x00000000000000ff)) << @as(c_int, 56))) {
    _ = &x;
    return ((((((((x & @as(c_ulonglong, 0xff00000000000000)) >> @as(c_int, 56)) | ((x & @as(c_ulonglong, 0x00ff000000000000)) >> @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x0000ff0000000000)) >> @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000ff00000000)) >> @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x00000000ff000000)) << @as(c_int, 8))) | ((x & @as(c_ulonglong, 0x0000000000ff0000)) << @as(c_int, 24))) | ((x & @as(c_ulonglong, 0x000000000000ff00)) << @as(c_int, 40))) | ((x & @as(c_ulonglong, 0x00000000000000ff)) << @as(c_int, 56));
}
pub const _BITS_UINTN_IDENTITY_H = @as(c_int, 1);
pub inline fn htobe16(x: anytype) @TypeOf(__bswap_16(x)) {
    _ = &x;
    return __bswap_16(x);
}
pub inline fn htole16(x: anytype) @TypeOf(__uint16_identity(x)) {
    _ = &x;
    return __uint16_identity(x);
}
pub inline fn be16toh(x: anytype) @TypeOf(__bswap_16(x)) {
    _ = &x;
    return __bswap_16(x);
}
pub inline fn le16toh(x: anytype) @TypeOf(__uint16_identity(x)) {
    _ = &x;
    return __uint16_identity(x);
}
pub inline fn htobe32(x: anytype) @TypeOf(__bswap_32(x)) {
    _ = &x;
    return __bswap_32(x);
}
pub inline fn htole32(x: anytype) @TypeOf(__uint32_identity(x)) {
    _ = &x;
    return __uint32_identity(x);
}
pub inline fn be32toh(x: anytype) @TypeOf(__bswap_32(x)) {
    _ = &x;
    return __bswap_32(x);
}
pub inline fn le32toh(x: anytype) @TypeOf(__uint32_identity(x)) {
    _ = &x;
    return __uint32_identity(x);
}
pub inline fn htobe64(x: anytype) @TypeOf(__bswap_64(x)) {
    _ = &x;
    return __bswap_64(x);
}
pub inline fn htole64(x: anytype) @TypeOf(__uint64_identity(x)) {
    _ = &x;
    return __uint64_identity(x);
}
pub inline fn be64toh(x: anytype) @TypeOf(__bswap_64(x)) {
    _ = &x;
    return __bswap_64(x);
}
pub inline fn le64toh(x: anytype) @TypeOf(__uint64_identity(x)) {
    _ = &x;
    return __uint64_identity(x);
}
pub const _SYS_SELECT_H = @as(c_int, 1);
pub const __FD_ZERO = @compileError("unable to translate macro: undefined identifier `__i`");
// /usr/include/bits/select.h:25:9
pub const __FD_SET = @compileError("unable to translate C expr: expected ')' instead got '|='");
// /usr/include/bits/select.h:32:9
pub const __FD_CLR = @compileError("unable to translate C expr: expected ')' instead got '&='");
// /usr/include/bits/select.h:34:9
pub inline fn __FD_ISSET(d: anytype, s: anytype) @TypeOf((__FDS_BITS(s)[@as(usize, @intCast(__FD_ELT(d)))] & __FD_MASK(d)) != @as(c_int, 0)) {
    _ = &d;
    _ = &s;
    return (__FDS_BITS(s)[@as(usize, @intCast(__FD_ELT(d)))] & __FD_MASK(d)) != @as(c_int, 0);
}
pub const __sigset_t_defined = @as(c_int, 1);
pub const ____sigset_t_defined = "";
pub const _SIGSET_NWORDS = @import("std").zig.c_translation.MacroArithmetic.div(@as(c_int, 1024), @as(c_int, 8) * @import("std").zig.c_translation.sizeof(c_ulong));
pub const __timeval_defined = @as(c_int, 1);
pub const __suseconds_t_defined = "";
pub const __NFDBITS = @as(c_int, 8) * @import("std").zig.c_translation.cast(c_int, @import("std").zig.c_translation.sizeof(__fd_mask));
pub inline fn __FD_ELT(d: anytype) @TypeOf(@import("std").zig.c_translation.MacroArithmetic.div(d, __NFDBITS)) {
    _ = &d;
    return @import("std").zig.c_translation.MacroArithmetic.div(d, __NFDBITS);
}
pub inline fn __FD_MASK(d: anytype) __fd_mask {
    _ = &d;
    return @import("std").zig.c_translation.cast(__fd_mask, @as(c_ulong, 1) << @import("std").zig.c_translation.MacroArithmetic.rem(d, __NFDBITS));
}
pub inline fn __FDS_BITS(set: anytype) @TypeOf(set.*.__fds_bits) {
    _ = &set;
    return set.*.__fds_bits;
}
pub const FD_SETSIZE = __FD_SETSIZE;
pub const NFDBITS = __NFDBITS;
pub inline fn FD_SET(fd: anytype, fdsetp: anytype) @TypeOf(__FD_SET(fd, fdsetp)) {
    _ = &fd;
    _ = &fdsetp;
    return __FD_SET(fd, fdsetp);
}
pub inline fn FD_CLR(fd: anytype, fdsetp: anytype) @TypeOf(__FD_CLR(fd, fdsetp)) {
    _ = &fd;
    _ = &fdsetp;
    return __FD_CLR(fd, fdsetp);
}
pub inline fn FD_ISSET(fd: anytype, fdsetp: anytype) @TypeOf(__FD_ISSET(fd, fdsetp)) {
    _ = &fd;
    _ = &fdsetp;
    return __FD_ISSET(fd, fdsetp);
}
pub inline fn FD_ZERO(fdsetp: anytype) @TypeOf(__FD_ZERO(fdsetp)) {
    _ = &fdsetp;
    return __FD_ZERO(fdsetp);
}
pub const __blksize_t_defined = "";
pub const __blkcnt_t_defined = "";
pub const __fsblkcnt_t_defined = "";
pub const __fsfilcnt_t_defined = "";
pub const _BITS_PTHREADTYPES_COMMON_H = @as(c_int, 1);
pub const _THREAD_SHARED_TYPES_H = @as(c_int, 1);
pub const _BITS_PTHREADTYPES_ARCH_H = @as(c_int, 1);
pub const __SIZEOF_PTHREAD_MUTEX_T = @as(c_int, 40);
pub const __SIZEOF_PTHREAD_ATTR_T = @as(c_int, 56);
pub const __SIZEOF_PTHREAD_RWLOCK_T = @as(c_int, 56);
pub const __SIZEOF_PTHREAD_BARRIER_T = @as(c_int, 32);
pub const __SIZEOF_PTHREAD_MUTEXATTR_T = @as(c_int, 4);
pub const __SIZEOF_PTHREAD_COND_T = @as(c_int, 48);
pub const __SIZEOF_PTHREAD_CONDATTR_T = @as(c_int, 4);
pub const __SIZEOF_PTHREAD_RWLOCKATTR_T = @as(c_int, 8);
pub const __SIZEOF_PTHREAD_BARRIERATTR_T = @as(c_int, 4);
pub const __LOCK_ALIGNMENT = "";
pub const __ONCE_ALIGNMENT = "";
pub const _BITS_ATOMIC_WIDE_COUNTER_H = "";
pub const _THREAD_MUTEX_INTERNAL_H = @as(c_int, 1);
pub const __PTHREAD_MUTEX_HAVE_PREV = @as(c_int, 1);
pub const __PTHREAD_MUTEX_INITIALIZER = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/bits/struct_mutex.h:56:10
pub const _RWLOCK_INTERNAL_H = "";
pub const __PTHREAD_RWLOCK_ELISION_EXTRA = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/bits/struct_rwlock.h:40:11
pub inline fn __PTHREAD_RWLOCK_INITIALIZER(__flags: anytype) @TypeOf(__flags) {
    _ = &__flags;
    return blk: {
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = @as(c_int, 0);
        _ = &__PTHREAD_RWLOCK_ELISION_EXTRA;
        _ = @as(c_int, 0);
        break :blk __flags;
    };
}
pub const __ONCE_FLAG_INIT = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/bits/thread-shared-types.h:114:9
pub const __have_pthread_attr_t = @as(c_int, 1);
pub const _ALLOCA_H = @as(c_int, 1);
pub const __COMPAR_FN_T = "";
pub inline fn g_abort() @TypeOf(abort()) {
    return abort();
}
pub inline fn G_WIN32_DLLMAIN_FOR_DLL_NAME(static: anytype, dll_name: anytype) @TypeOf(GLIB_DEPRECATED_MACRO_IN_2_26) {
    _ = &static;
    _ = &dll_name;
    return GLIB_DEPRECATED_MACRO_IN_2_26;
}
pub const G_THREAD_ERROR = g_thread_error_quark();
pub const G_PRIVATE_INIT = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/glib-2.0/glib/gthread.h:88:9
pub const G_ONCE_INIT = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/glib-2.0/glib/gthread.h:104:9
pub const G_LOCK_NAME = @compileError("unable to translate macro: undefined identifier `g__`");
// /usr/include/glib-2.0/glib/gthread.h:111:9
pub const G_LOCK_DEFINE_STATIC = @compileError("unable to translate C expr: unexpected token 'static'");
// /usr/include/glib-2.0/glib/gthread.h:112:9
pub inline fn G_LOCK_DEFINE(name: anytype) @TypeOf(GMutex ++ G_LOCK_NAME(name)) {
    _ = &name;
    return GMutex ++ G_LOCK_NAME(name);
}
pub const G_LOCK_EXTERN = @compileError("unable to translate C expr: unexpected token 'extern'");
// /usr/include/glib-2.0/glib/gthread.h:114:9
pub inline fn G_LOCK(name: anytype) @TypeOf(g_mutex_lock(&G_LOCK_NAME(name))) {
    _ = &name;
    return g_mutex_lock(&G_LOCK_NAME(name));
}
pub inline fn G_UNLOCK(name: anytype) @TypeOf(g_mutex_unlock(&G_LOCK_NAME(name))) {
    _ = &name;
    return g_mutex_unlock(&G_LOCK_NAME(name));
}
pub inline fn G_TRYLOCK(name: anytype) @TypeOf(g_mutex_trylock(&G_LOCK_NAME(name))) {
    _ = &name;
    return g_mutex_trylock(&G_LOCK_NAME(name));
}
pub const G_AUTO_LOCK = @compileError("unable to translate macro: undefined identifier `g__`");
// /usr/include/glib-2.0/glib/gthread.h:143:9
pub const g_once = @compileError("unable to translate macro: undefined identifier `__atomic_load_n`");
// /usr/include/glib-2.0/glib/gthread.h:261:10
pub const G_MUTEX_AUTO_LOCK = @compileError("unable to translate C expr: unexpected token '='");
// /usr/include/glib-2.0/glib/gthread.h:429:9
pub const G_REC_MUTEX_AUTO_LOCK = @compileError("unable to translate C expr: unexpected token '='");
// /usr/include/glib-2.0/glib/gthread.h:555:9
pub const G_RW_LOCK_WRITER_AUTO_LOCK = @compileError("unable to translate C expr: unexpected token '='");
// /usr/include/glib-2.0/glib/gthread.h:713:9
pub const G_RW_LOCK_READER_AUTO_LOCK = @compileError("unable to translate C expr: unexpected token '='");
// /usr/include/glib-2.0/glib/gthread.h:811:9
pub const __G_BACKTRACE_H__ = "";
pub const _SIGNAL_H = "";
pub const _BITS_SIGNUM_GENERIC_H = @as(c_int, 1);
pub const SIG_ERR = @import("std").zig.c_translation.cast(__sighandler_t, -@as(c_int, 1));
pub const SIG_DFL = @import("std").zig.c_translation.cast(__sighandler_t, @as(c_int, 0));
pub const SIG_IGN = @import("std").zig.c_translation.cast(__sighandler_t, @as(c_int, 1));
pub const SIGINT = @as(c_int, 2);
pub const SIGILL = @as(c_int, 4);
pub const SIGABRT = @as(c_int, 6);
pub const SIGFPE = @as(c_int, 8);
pub const SIGSEGV = @as(c_int, 11);
pub const SIGTERM = @as(c_int, 15);
pub const SIGHUP = @as(c_int, 1);
pub const SIGQUIT = @as(c_int, 3);
pub const SIGTRAP = @as(c_int, 5);
pub const SIGKILL = @as(c_int, 9);
pub const SIGPIPE = @as(c_int, 13);
pub const SIGALRM = @as(c_int, 14);
pub const SIGIO = SIGPOLL;
pub const SIGIOT = SIGABRT;
pub const SIGCLD = SIGCHLD;
pub const _BITS_SIGNUM_ARCH_H = @as(c_int, 1);
pub const SIGSTKFLT = @as(c_int, 16);
pub const SIGPWR = @as(c_int, 30);
pub const SIGBUS = @as(c_int, 7);
pub const SIGSYS = @as(c_int, 31);
pub const SIGURG = @as(c_int, 23);
pub const SIGSTOP = @as(c_int, 19);
pub const SIGTSTP = @as(c_int, 20);
pub const SIGCONT = @as(c_int, 18);
pub const SIGCHLD = @as(c_int, 17);
pub const SIGTTIN = @as(c_int, 21);
pub const SIGTTOU = @as(c_int, 22);
pub const SIGPOLL = @as(c_int, 29);
pub const SIGXFSZ = @as(c_int, 25);
pub const SIGXCPU = @as(c_int, 24);
pub const SIGVTALRM = @as(c_int, 26);
pub const SIGPROF = @as(c_int, 27);
pub const SIGUSR1 = @as(c_int, 10);
pub const SIGUSR2 = @as(c_int, 12);
pub const SIGWINCH = @as(c_int, 28);
pub const __SIGRTMIN = @as(c_int, 32);
pub const __SIGRTMAX = @as(c_int, 64);
pub const _NSIG = __SIGRTMAX + @as(c_int, 1);
pub const __sig_atomic_t_defined = @as(c_int, 1);
pub const __siginfo_t_defined = @as(c_int, 1);
pub const ____sigval_t_defined = "";
pub const __SI_MAX_SIZE = @as(c_int, 128);
pub const __SI_PAD_SIZE = @import("std").zig.c_translation.MacroArithmetic.div(__SI_MAX_SIZE, @import("std").zig.c_translation.sizeof(c_int)) - @as(c_int, 4);
pub const _BITS_SIGINFO_ARCH_H = @as(c_int, 1);
pub const __SI_ALIGNMENT = "";
pub const __SI_BAND_TYPE = c_long;
pub const __SI_CLOCK_T = __clock_t;
pub const __SI_ERRNO_THEN_CODE = @as(c_int, 1);
pub const __SI_HAVE_SIGSYS = @as(c_int, 1);
pub const __SI_SIGFAULT_ADDL = "";
pub const si_pid = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:128:9
pub const si_uid = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:129:9
pub const si_timerid = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:130:9
pub const si_overrun = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:131:9
pub const si_status = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:132:9
pub const si_utime = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:133:9
pub const si_stime = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:134:9
pub const si_value = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:135:9
pub const si_int = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:136:9
pub const si_ptr = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:137:9
pub const si_addr = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:138:9
pub const si_addr_lsb = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:139:9
pub const si_lower = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:140:9
pub const si_upper = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:141:9
pub const si_pkey = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:142:9
pub const si_band = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:143:9
pub const si_fd = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:144:9
pub const si_call_addr = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:146:10
pub const si_syscall = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:147:10
pub const si_arch = @compileError("unable to translate macro: undefined identifier `_sifields`");
// /usr/include/bits/types/siginfo_t.h:148:10
pub const _BITS_SIGINFO_CONSTS_H = @as(c_int, 1);
pub const __SI_ASYNCIO_AFTER_SIGIO = @as(c_int, 1);
pub const __sigval_t_defined = "";
pub const __sigevent_t_defined = @as(c_int, 1);
pub const __SIGEV_MAX_SIZE = @as(c_int, 64);
pub const __SIGEV_PAD_SIZE = @import("std").zig.c_translation.MacroArithmetic.div(__SIGEV_MAX_SIZE, @import("std").zig.c_translation.sizeof(c_int)) - @as(c_int, 4);
pub const sigev_notify_function = @compileError("unable to translate macro: undefined identifier `_sigev_un`");
// /usr/include/bits/types/sigevent_t.h:45:9
pub const sigev_notify_attributes = @compileError("unable to translate macro: undefined identifier `_sigev_un`");
// /usr/include/bits/types/sigevent_t.h:46:9
pub const _BITS_SIGEVENT_CONSTS_H = @as(c_int, 1);
pub inline fn sigmask(sig: anytype) @TypeOf(__glibc_macro_warning("sigmask is deprecated")(@import("std").zig.c_translation.cast(c_int, @as(c_uint, 1) << (sig - @as(c_int, 1))))) {
    _ = &sig;
    return __glibc_macro_warning("sigmask is deprecated")(@import("std").zig.c_translation.cast(c_int, @as(c_uint, 1) << (sig - @as(c_int, 1))));
}
pub const NSIG = _NSIG;
pub const _BITS_SIGACTION_H = @as(c_int, 1);
pub const sa_handler = @compileError("unable to translate macro: undefined identifier `__sigaction_handler`");
// /usr/include/bits/sigaction.h:39:10
pub const sa_sigaction = @compileError("unable to translate macro: undefined identifier `__sigaction_handler`");
// /usr/include/bits/sigaction.h:40:10
pub const SA_NOCLDSTOP = @as(c_int, 1);
pub const SA_NOCLDWAIT = @as(c_int, 2);
pub const SA_SIGINFO = @as(c_int, 4);
pub const SA_ONSTACK = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x08000000, .hex);
pub const SA_RESTART = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x10000000, .hex);
pub const SA_NODEFER = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x40000000, .hex);
pub const SA_RESETHAND = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x80000000, .hex);
pub const SA_INTERRUPT = @import("std").zig.c_translation.promoteIntLiteral(c_int, 0x20000000, .hex);
pub const SA_NOMASK = SA_NODEFER;
pub const SA_ONESHOT = SA_RESETHAND;
pub const SA_STACK = SA_ONSTACK;
pub const SIG_BLOCK = @as(c_int, 0);
pub const SIG_UNBLOCK = @as(c_int, 1);
pub const SIG_SETMASK = @as(c_int, 2);
pub const _BITS_SIGCONTEXT_H = @as(c_int, 1);
pub const FP_XSTATE_MAGIC1 = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x46505853, .hex);
pub const FP_XSTATE_MAGIC2 = @import("std").zig.c_translation.promoteIntLiteral(c_uint, 0x46505845, .hex);
pub const FP_XSTATE_MAGIC2_SIZE = @import("std").zig.c_translation.sizeof(FP_XSTATE_MAGIC2);
pub const __stack_t_defined = @as(c_int, 1);
pub const _SYS_UCONTEXT_H = @as(c_int, 1);
pub inline fn __ctx(fld: anytype) @TypeOf(fld) {
    _ = &fld;
    return fld;
}
pub const __NGREG = @as(c_int, 23);
pub const NGREG = __NGREG;
pub const _BITS_SIGSTACK_H = @as(c_int, 1);
pub const MINSIGSTKSZ = @as(c_int, 2048);
pub const SIGSTKSZ = @as(c_int, 8192);
pub const _BITS_SS_FLAGS_H = @as(c_int, 1);
pub const __sigstack_defined = @as(c_int, 1);
pub const _BITS_SIGTHREAD_H = @as(c_int, 1);
pub const SIGRTMIN = __libc_current_sigrtmin();
pub const SIGRTMAX = __libc_current_sigrtmax();
pub const G_BREAKPOINT = @compileError("unable to translate C expr: unexpected token '__asm__'");
// /usr/include/glib-2.0/glib/gbacktrace.h:59:11
pub const __G_BASE64_H__ = "";
pub const __G_BITLOCK_H__ = "";
pub const __G_BOOKMARK_FILE_H__ = "";
pub const __G_DATE_TIME_H__ = "";
pub const __G_TIME_ZONE_H__ = "";
pub const G_TIME_SPAN_DAY = G_GINT64_CONSTANT(@import("std").zig.c_translation.promoteIntLiteral(c_int, 86400000000, .decimal));
pub const G_TIME_SPAN_HOUR = G_GINT64_CONSTANT(@import("std").zig.c_translation.promoteIntLiteral(c_int, 3600000000, .decimal));
pub const G_TIME_SPAN_MINUTE = G_GINT64_CONSTANT(@import("std").zig.c_translation.promoteIntLiteral(c_int, 60000000, .decimal));
pub const G_TIME_SPAN_SECOND = G_GINT64_CONSTANT(@import("std").zig.c_translation.promoteIntLiteral(c_int, 1000000, .decimal));
pub const G_TIME_SPAN_MILLISECOND = G_GINT64_CONSTANT(@as(c_int, 1000));
pub const G_BOOKMARK_FILE_ERROR = g_bookmark_file_error_quark();
pub const __G_BYTES_H__ = "";
pub const __G_CHARSET_H__ = "";
pub const __G_CHECKSUM_H__ = "";
pub const __G_CONVERT_H__ = "";
pub const G_CONVERT_ERROR = g_convert_error_quark();
pub const __G_DATASET_H__ = "";
pub const G_DATALIST_FLAGS_MASK = @as(c_int, 0x3);
pub inline fn g_datalist_id_set_data(dl: anytype, q: anytype, d: anytype) @TypeOf(g_datalist_id_set_data_full(dl, q, d, NULL)) {
    _ = &dl;
    _ = &q;
    _ = &d;
    return g_datalist_id_set_data_full(dl, q, d, NULL);
}
pub inline fn g_datalist_id_remove_data(dl: anytype, q: anytype) @TypeOf(g_datalist_id_set_data(dl, q, NULL)) {
    _ = &dl;
    _ = &q;
    return g_datalist_id_set_data(dl, q, NULL);
}
pub inline fn g_datalist_set_data_full(dl: anytype, k: anytype, d: anytype, f: anytype) @TypeOf(g_datalist_id_set_data_full(dl, g_quark_from_string(k), d, f)) {
    _ = &dl;
    _ = &k;
    _ = &d;
    _ = &f;
    return g_datalist_id_set_data_full(dl, g_quark_from_string(k), d, f);
}
pub inline fn g_datalist_remove_no_notify(dl: anytype, k: anytype) @TypeOf(g_datalist_id_remove_no_notify(dl, g_quark_try_string(k))) {
    _ = &dl;
    _ = &k;
    return g_datalist_id_remove_no_notify(dl, g_quark_try_string(k));
}
pub inline fn g_datalist_set_data(dl: anytype, k: anytype, d: anytype) @TypeOf(g_datalist_set_data_full(dl, k, d, NULL)) {
    _ = &dl;
    _ = &k;
    _ = &d;
    return g_datalist_set_data_full(dl, k, d, NULL);
}
pub inline fn g_datalist_remove_data(dl: anytype, k: anytype) @TypeOf(g_datalist_id_set_data(dl, g_quark_try_string(k), NULL)) {
    _ = &dl;
    _ = &k;
    return g_datalist_id_set_data(dl, g_quark_try_string(k), NULL);
}
pub inline fn g_dataset_id_set_data(l: anytype, k: anytype, d: anytype) @TypeOf(g_dataset_id_set_data_full(l, k, d, NULL)) {
    _ = &l;
    _ = &k;
    _ = &d;
    return g_dataset_id_set_data_full(l, k, d, NULL);
}
pub inline fn g_dataset_id_remove_data(l: anytype, k: anytype) @TypeOf(g_dataset_id_set_data(l, k, NULL)) {
    _ = &l;
    _ = &k;
    return g_dataset_id_set_data(l, k, NULL);
}
pub inline fn g_dataset_get_data(l: anytype, k: anytype) @TypeOf(g_dataset_id_get_data(l, g_quark_try_string(k))) {
    _ = &l;
    _ = &k;
    return g_dataset_id_get_data(l, g_quark_try_string(k));
}
pub inline fn g_dataset_set_data_full(l: anytype, k: anytype, d: anytype, f: anytype) @TypeOf(g_dataset_id_set_data_full(l, g_quark_from_string(k), d, f)) {
    _ = &l;
    _ = &k;
    _ = &d;
    _ = &f;
    return g_dataset_id_set_data_full(l, g_quark_from_string(k), d, f);
}
pub inline fn g_dataset_remove_no_notify(l: anytype, k: anytype) @TypeOf(g_dataset_id_remove_no_notify(l, g_quark_try_string(k))) {
    _ = &l;
    _ = &k;
    return g_dataset_id_remove_no_notify(l, g_quark_try_string(k));
}
pub inline fn g_dataset_set_data(l: anytype, k: anytype, d: anytype) @TypeOf(g_dataset_set_data_full(l, k, d, NULL)) {
    _ = &l;
    _ = &k;
    _ = &d;
    return g_dataset_set_data_full(l, k, d, NULL);
}
pub inline fn g_dataset_remove_data(l: anytype, k: anytype) @TypeOf(g_dataset_id_set_data(l, g_quark_try_string(k), NULL)) {
    _ = &l;
    _ = &k;
    return g_dataset_id_set_data(l, g_quark_try_string(k), NULL);
}
pub const __G_DATE_H__ = "";
pub const G_DATE_BAD_JULIAN = @as(c_uint, 0);
pub const G_DATE_BAD_DAY = @as(c_uint, 0);
pub const G_DATE_BAD_YEAR = @as(c_uint, 0);
pub const g_date_weekday = g_date_get_weekday ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_date_get_weekday);
pub const g_date_month = g_date_get_month ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_date_get_month);
pub const g_date_year = g_date_get_year ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_date_get_year);
pub const g_date_day = g_date_get_day ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_date_get_day);
pub const g_date_julian = g_date_get_julian ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_date_get_julian);
pub const g_date_day_of_year = g_date_get_day_of_year ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_date_get_day_of_year);
pub const g_date_monday_week_of_year = g_date_get_monday_week_of_year ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_date_get_monday_week_of_year);
pub const g_date_sunday_week_of_year = g_date_get_sunday_week_of_year ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_date_get_sunday_week_of_year);
pub const g_date_days_in_month = g_date_get_days_in_month ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_date_get_days_in_month);
pub const g_date_monday_weeks_in_year = g_date_get_monday_weeks_in_year ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_date_get_monday_weeks_in_year);
pub const g_date_sunday_weeks_in_year = g_date_get_sunday_weeks_in_year ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_date_get_sunday_weeks_in_year);
pub const __G_DIR_H__ = "";
pub const _DIRENT_H = @as(c_int, 1);
pub const d_fileno = @compileError("unable to translate macro: undefined identifier `d_ino`");
// /usr/include/bits/dirent.h:47:9
pub const _DIRENT_HAVE_D_RECLEN = "";
pub const _DIRENT_HAVE_D_OFF = "";
pub const _DIRENT_HAVE_D_TYPE = "";
pub const _DIRENT_MATCHES_DIRENT64 = @as(c_int, 1);
pub inline fn _D_EXACT_NAMLEN(d: anytype) @TypeOf(strlen(d.*.d_name)) {
    _ = &d;
    return strlen(d.*.d_name);
}
pub inline fn _D_ALLOC_NAMLEN(d: anytype) @TypeOf((@import("std").zig.c_translation.cast([*c]u8, d) + d.*.d_reclen) - (&d.*.d_name[@as(usize, @intCast(@as(c_int, 0)))])) {
    _ = &d;
    return (@import("std").zig.c_translation.cast([*c]u8, d) + d.*.d_reclen) - (&d.*.d_name[@as(usize, @intCast(@as(c_int, 0)))]);
}
pub inline fn IFTODT(mode: anytype) @TypeOf((mode & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0o170000, .octal)) >> @as(c_int, 12)) {
    _ = &mode;
    return (mode & @import("std").zig.c_translation.promoteIntLiteral(c_int, 0o170000, .octal)) >> @as(c_int, 12);
}
pub inline fn DTTOIF(dirtype: anytype) @TypeOf(dirtype << @as(c_int, 12)) {
    _ = &dirtype;
    return dirtype << @as(c_int, 12);
}
pub const MAXNAMLEN = NAME_MAX;
pub const __G_ENVIRON_H__ = "";
pub const __G_FILEUTILS_H__ = "";
pub const G_FILE_ERROR = g_file_error_quark();
pub inline fn G_IS_DIR_SEPARATOR(c: anytype) @TypeOf(c == G_DIR_SEPARATOR) {
    _ = &c;
    return c == G_DIR_SEPARATOR;
}
pub const g_dirname = g_path_get_dirname ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_path_get_dirname);
pub const __G_GETTEXT_H__ = "";
pub const __G_HASH_H__ = "";
pub const __G_LIST_H__ = "";
pub const __G_MEM_H__ = "";
pub const G_MEM_ALIGN = GLIB_SIZEOF_LONG;
pub const _G_NEW = @compileError("unable to translate macro: undefined identifier `g_`");
// /usr/include/glib-2.0/glib/gmem.h:295:9
pub const _G_RENEW = @compileError("unable to translate macro: undefined identifier `g_`");
// /usr/include/glib-2.0/glib/gmem.h:297:9
pub inline fn g_new(struct_type: anytype, n_structs: anytype) @TypeOf(_G_NEW(struct_type, n_structs, malloc)) {
    _ = &struct_type;
    _ = &n_structs;
    return _G_NEW(struct_type, n_structs, malloc);
}
pub const g_new0 = @compileError("unable to translate macro: undefined identifier `malloc0`");
// /usr/include/glib-2.0/glib/gmem.h:335:9
pub inline fn g_renew(struct_type: anytype, mem: anytype, n_structs: anytype) @TypeOf(_G_RENEW(struct_type, mem, n_structs, realloc)) {
    _ = &struct_type;
    _ = &mem;
    _ = &n_structs;
    return _G_RENEW(struct_type, mem, n_structs, realloc);
}
pub const g_try_new = @compileError("unable to translate macro: undefined identifier `try_malloc`");
// /usr/include/glib-2.0/glib/gmem.h:363:9
pub const g_try_new0 = @compileError("unable to translate macro: undefined identifier `try_malloc0`");
// /usr/include/glib-2.0/glib/gmem.h:378:9
pub const g_try_renew = @compileError("unable to translate macro: undefined identifier `try_realloc`");
// /usr/include/glib-2.0/glib/gmem.h:394:9
pub const __G_NODE_H__ = "";
pub inline fn G_NODE_IS_ROOT(node: anytype) @TypeOf(((@import("std").zig.c_translation.cast([*c]GNode, node).*.parent == NULL) and (@import("std").zig.c_translation.cast([*c]GNode, node).*.prev == NULL)) and (@import("std").zig.c_translation.cast([*c]GNode, node).*.next == NULL)) {
    _ = &node;
    return ((@import("std").zig.c_translation.cast([*c]GNode, node).*.parent == NULL) and (@import("std").zig.c_translation.cast([*c]GNode, node).*.prev == NULL)) and (@import("std").zig.c_translation.cast([*c]GNode, node).*.next == NULL);
}
pub inline fn G_NODE_IS_LEAF(node: anytype) @TypeOf(@import("std").zig.c_translation.cast([*c]GNode, node).*.children == NULL) {
    _ = &node;
    return @import("std").zig.c_translation.cast([*c]GNode, node).*.children == NULL;
}
pub inline fn g_node_append(parent: anytype, node: anytype) @TypeOf(g_node_insert_before(parent, NULL, node)) {
    _ = &parent;
    _ = &node;
    return g_node_insert_before(parent, NULL, node);
}
pub inline fn g_node_insert_data(parent: anytype, position: anytype, data: anytype) @TypeOf(g_node_insert(parent, position, g_node_new(data))) {
    _ = &parent;
    _ = &position;
    _ = &data;
    return g_node_insert(parent, position, g_node_new(data));
}
pub inline fn g_node_insert_data_after(parent: anytype, sibling: anytype, data: anytype) @TypeOf(g_node_insert_after(parent, sibling, g_node_new(data))) {
    _ = &parent;
    _ = &sibling;
    _ = &data;
    return g_node_insert_after(parent, sibling, g_node_new(data));
}
pub inline fn g_node_insert_data_before(parent: anytype, sibling: anytype, data: anytype) @TypeOf(g_node_insert_before(parent, sibling, g_node_new(data))) {
    _ = &parent;
    _ = &sibling;
    _ = &data;
    return g_node_insert_before(parent, sibling, g_node_new(data));
}
pub inline fn g_node_prepend_data(parent: anytype, data: anytype) @TypeOf(g_node_prepend(parent, g_node_new(data))) {
    _ = &parent;
    _ = &data;
    return g_node_prepend(parent, g_node_new(data));
}
pub inline fn g_node_append_data(parent: anytype, data: anytype) @TypeOf(g_node_insert_before(parent, NULL, g_node_new(data))) {
    _ = &parent;
    _ = &data;
    return g_node_insert_before(parent, NULL, g_node_new(data));
}
pub inline fn g_node_prev_sibling(node: anytype) @TypeOf(if (node != 0) @import("std").zig.c_translation.cast([*c]GNode, node).*.prev else NULL) {
    _ = &node;
    return if (node != 0) @import("std").zig.c_translation.cast([*c]GNode, node).*.prev else NULL;
}
pub inline fn g_node_next_sibling(node: anytype) @TypeOf(if (node != 0) @import("std").zig.c_translation.cast([*c]GNode, node).*.next else NULL) {
    _ = &node;
    return if (node != 0) @import("std").zig.c_translation.cast([*c]GNode, node).*.next else NULL;
}
pub inline fn g_node_first_child(node: anytype) @TypeOf(if (node != 0) @import("std").zig.c_translation.cast([*c]GNode, node).*.children else NULL) {
    _ = &node;
    return if (node != 0) @import("std").zig.c_translation.cast([*c]GNode, node).*.children else NULL;
}
pub const g_list_free1 = g_list_free_1;
pub inline fn g_list_previous(list: anytype) @TypeOf(if (list != 0) @import("std").zig.c_translation.cast([*c]GList, list).*.prev else NULL) {
    _ = &list;
    return if (list != 0) @import("std").zig.c_translation.cast([*c]GList, list).*.prev else NULL;
}
pub inline fn g_list_next(list: anytype) @TypeOf(if (list != 0) @import("std").zig.c_translation.cast([*c]GList, list).*.next else NULL) {
    _ = &list;
    return if (list != 0) @import("std").zig.c_translation.cast([*c]GList, list).*.next else NULL;
}
pub inline fn g_hash_table_freeze(hash_table: anytype) @TypeOf(@import("std").zig.c_translation.cast(anyopaque, @as(c_int, 0)) ++ GLIB_DEPRECATED_MACRO_IN_2_26) {
    _ = &hash_table;
    return @import("std").zig.c_translation.cast(anyopaque, @as(c_int, 0)) ++ GLIB_DEPRECATED_MACRO_IN_2_26;
}
pub inline fn g_hash_table_thaw(hash_table: anytype) @TypeOf(@import("std").zig.c_translation.cast(anyopaque, @as(c_int, 0)) ++ GLIB_DEPRECATED_MACRO_IN_2_26) {
    _ = &hash_table;
    return @import("std").zig.c_translation.cast(anyopaque, @as(c_int, 0)) ++ GLIB_DEPRECATED_MACRO_IN_2_26;
}
pub const __G_HMAC_H__ = "";
pub const __G_HOOK_H__ = "";
pub const G_HOOK_FLAG_USER_SHIFT = @as(c_int, 4);
pub inline fn G_HOOK(hook: anytype) [*c]GHook {
    _ = &hook;
    return @import("std").zig.c_translation.cast([*c]GHook, hook);
}
pub inline fn G_HOOK_FLAGS(hook: anytype) @TypeOf(G_HOOK(hook).*.flags) {
    _ = &hook;
    return G_HOOK(hook).*.flags;
}
pub inline fn G_HOOK_ACTIVE(hook: anytype) @TypeOf((G_HOOK_FLAGS(hook) & G_HOOK_FLAG_ACTIVE) != @as(c_int, 0)) {
    _ = &hook;
    return (G_HOOK_FLAGS(hook) & G_HOOK_FLAG_ACTIVE) != @as(c_int, 0);
}
pub inline fn G_HOOK_IN_CALL(hook: anytype) @TypeOf((G_HOOK_FLAGS(hook) & G_HOOK_FLAG_IN_CALL) != @as(c_int, 0)) {
    _ = &hook;
    return (G_HOOK_FLAGS(hook) & G_HOOK_FLAG_IN_CALL) != @as(c_int, 0);
}
pub inline fn G_HOOK_IS_VALID(hook: anytype) @TypeOf((G_HOOK(hook).*.hook_id != @as(c_int, 0)) and ((G_HOOK_FLAGS(hook) & G_HOOK_FLAG_ACTIVE) != 0)) {
    _ = &hook;
    return (G_HOOK(hook).*.hook_id != @as(c_int, 0)) and ((G_HOOK_FLAGS(hook) & G_HOOK_FLAG_ACTIVE) != 0);
}
pub inline fn G_HOOK_IS_UNLINKED(hook: anytype) @TypeOf((((G_HOOK(hook).*.next == NULL) and (G_HOOK(hook).*.prev == NULL)) and (G_HOOK(hook).*.hook_id == @as(c_int, 0))) and (G_HOOK(hook).*.ref_count == @as(c_int, 0))) {
    _ = &hook;
    return (((G_HOOK(hook).*.next == NULL) and (G_HOOK(hook).*.prev == NULL)) and (G_HOOK(hook).*.hook_id == @as(c_int, 0))) and (G_HOOK(hook).*.ref_count == @as(c_int, 0));
}
pub inline fn g_hook_append(hook_list: anytype, hook: anytype) @TypeOf(g_hook_insert_before(hook_list, NULL, hook)) {
    _ = &hook_list;
    _ = &hook;
    return g_hook_insert_before(hook_list, NULL, hook);
}
pub const __G_HOST_UTILS_H__ = "";
pub const __G_IOCHANNEL_H__ = "";
pub const __G_MAIN_H__ = "";
pub const __G_POLL_H__ = "";
pub const __G_SLIST_H__ = "";
pub const g_slist_free1 = g_slist_free_1;
pub inline fn g_slist_next(slist: anytype) @TypeOf(if (slist != 0) @import("std").zig.c_translation.cast([*c]GSList, slist).*.next else NULL) {
    _ = &slist;
    return if (slist != 0) @import("std").zig.c_translation.cast([*c]GSList, slist).*.next else NULL;
}
pub const G_SOURCE_FUNC = @compileError("unable to translate C expr: expected ')' instead got '('");
// /usr/include/glib-2.0/glib/gmain.h:233:9
pub const G_PRIORITY_HIGH = -@as(c_int, 100);
pub const G_PRIORITY_DEFAULT = @as(c_int, 0);
pub const G_PRIORITY_HIGH_IDLE = @as(c_int, 100);
pub const G_PRIORITY_DEFAULT_IDLE = @as(c_int, 200);
pub const G_PRIORITY_LOW = @as(c_int, 300);
pub const G_SOURCE_REMOVE = FALSE;
pub const G_SOURCE_CONTINUE = TRUE;
pub const __G_STRING_H__ = "";
pub const __G_UNICODE_H__ = "";
pub const G_UNICODE_COMBINING_MARK = G_UNICODE_SPACING_MARK ++ GLIB_DEPRECATED_MACRO_IN_2_30_FOR(G_UNICODE_SPACING_MARK);
pub const G_UNICHAR_MAX_DECOMPOSITION_LENGTH = @as(c_int, 18);
pub const g_utf8_next_char = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gunicode.h:825:9
pub const __G_STRFUNCS_H__ = "";
pub inline fn g_ascii_isalnum(c: anytype) @TypeOf((g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_ALNUM) != @as(c_int, 0)) {
    _ = &c;
    return (g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_ALNUM) != @as(c_int, 0);
}
pub inline fn g_ascii_isalpha(c: anytype) @TypeOf((g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_ALPHA) != @as(c_int, 0)) {
    _ = &c;
    return (g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_ALPHA) != @as(c_int, 0);
}
pub inline fn g_ascii_iscntrl(c: anytype) @TypeOf((g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_CNTRL) != @as(c_int, 0)) {
    _ = &c;
    return (g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_CNTRL) != @as(c_int, 0);
}
pub inline fn g_ascii_isdigit(c: anytype) @TypeOf((g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_DIGIT) != @as(c_int, 0)) {
    _ = &c;
    return (g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_DIGIT) != @as(c_int, 0);
}
pub inline fn g_ascii_isgraph(c: anytype) @TypeOf((g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_GRAPH) != @as(c_int, 0)) {
    _ = &c;
    return (g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_GRAPH) != @as(c_int, 0);
}
pub inline fn g_ascii_islower(c: anytype) @TypeOf((g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_LOWER) != @as(c_int, 0)) {
    _ = &c;
    return (g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_LOWER) != @as(c_int, 0);
}
pub inline fn g_ascii_isprint(c: anytype) @TypeOf((g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_PRINT) != @as(c_int, 0)) {
    _ = &c;
    return (g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_PRINT) != @as(c_int, 0);
}
pub inline fn g_ascii_ispunct(c: anytype) @TypeOf((g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_PUNCT) != @as(c_int, 0)) {
    _ = &c;
    return (g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_PUNCT) != @as(c_int, 0);
}
pub inline fn g_ascii_isspace(c: anytype) @TypeOf((g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_SPACE) != @as(c_int, 0)) {
    _ = &c;
    return (g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_SPACE) != @as(c_int, 0);
}
pub inline fn g_ascii_isupper(c: anytype) @TypeOf((g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_UPPER) != @as(c_int, 0)) {
    _ = &c;
    return (g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_UPPER) != @as(c_int, 0);
}
pub inline fn g_ascii_isxdigit(c: anytype) @TypeOf((g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_XDIGIT) != @as(c_int, 0)) {
    _ = &c;
    return (g_ascii_table[@as(usize, @intCast(@import("std").zig.c_translation.cast(guchar, c)))] & G_ASCII_XDIGIT) != @as(c_int, 0);
}
pub const G_STR_DELIMITERS = "_-|> <.";
pub inline fn _G_STR_NONNULL(x: anytype) @TypeOf(x + @intFromBool(!(x != 0))) {
    _ = &x;
    return x + @intFromBool(!(x != 0));
}
pub const G_ASCII_DTOSTR_BUF_SIZE = @as(c_int, 29) + @as(c_int, 10);
pub inline fn g_strstrip(string: anytype) @TypeOf(g_strchomp(g_strchug(string))) {
    _ = &string;
    return g_strchomp(g_strchug(string));
}
pub const G_NUMBER_PARSER_ERROR = g_number_parser_error_quark();
pub const g_string_sprintf = g_string_printf ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_string_printf);
pub const g_string_sprintfa = g_string_append_printf ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_string_append_printf);
pub const G_IO_CHANNEL_ERROR = g_io_channel_error_quark();
pub const __G_KEY_FILE_H__ = "";
pub const G_KEY_FILE_ERROR = g_key_file_error_quark();
pub const G_KEY_FILE_DESKTOP_GROUP = "Desktop Entry";
pub const G_KEY_FILE_DESKTOP_KEY_TYPE = "Type";
pub const G_KEY_FILE_DESKTOP_KEY_VERSION = "Version";
pub const G_KEY_FILE_DESKTOP_KEY_NAME = "Name";
pub const G_KEY_FILE_DESKTOP_KEY_GENERIC_NAME = "GenericName";
pub const G_KEY_FILE_DESKTOP_KEY_NO_DISPLAY = "NoDisplay";
pub const G_KEY_FILE_DESKTOP_KEY_COMMENT = "Comment";
pub const G_KEY_FILE_DESKTOP_KEY_ICON = "Icon";
pub const G_KEY_FILE_DESKTOP_KEY_HIDDEN = "Hidden";
pub const G_KEY_FILE_DESKTOP_KEY_ONLY_SHOW_IN = "OnlyShowIn";
pub const G_KEY_FILE_DESKTOP_KEY_NOT_SHOW_IN = "NotShowIn";
pub const G_KEY_FILE_DESKTOP_KEY_TRY_EXEC = "TryExec";
pub const G_KEY_FILE_DESKTOP_KEY_EXEC = "Exec";
pub const G_KEY_FILE_DESKTOP_KEY_PATH = "Path";
pub const G_KEY_FILE_DESKTOP_KEY_TERMINAL = "Terminal";
pub const G_KEY_FILE_DESKTOP_KEY_MIME_TYPE = "MimeType";
pub const G_KEY_FILE_DESKTOP_KEY_CATEGORIES = "Categories";
pub const G_KEY_FILE_DESKTOP_KEY_STARTUP_NOTIFY = "StartupNotify";
pub const G_KEY_FILE_DESKTOP_KEY_STARTUP_WM_CLASS = "StartupWMClass";
pub const G_KEY_FILE_DESKTOP_KEY_URL = "URL";
pub const G_KEY_FILE_DESKTOP_KEY_DBUS_ACTIVATABLE = "DBusActivatable";
pub const G_KEY_FILE_DESKTOP_KEY_ACTIONS = "Actions";
pub const G_KEY_FILE_DESKTOP_TYPE_APPLICATION = "Application";
pub const G_KEY_FILE_DESKTOP_TYPE_LINK = "Link";
pub const G_KEY_FILE_DESKTOP_TYPE_DIRECTORY = "Directory";
pub const __G_MAPPED_FILE_H__ = "";
pub const __G_MARKUP_H__ = "";
pub const G_MARKUP_ERROR = g_markup_error_quark();
pub const __G_MESSAGES_H__ = "";
pub const __G_VARIANT_H__ = "";
pub const __G_VARIANT_TYPE_H__ = "";
pub const G_VARIANT_TYPE_BOOLEAN = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:41:9
pub const G_VARIANT_TYPE_BYTE = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:48:9
pub const G_VARIANT_TYPE_INT16 = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:55:9
pub const G_VARIANT_TYPE_UINT16 = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:64:9
pub const G_VARIANT_TYPE_INT32 = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:72:9
pub const G_VARIANT_TYPE_UINT32 = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:81:9
pub const G_VARIANT_TYPE_INT64 = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:89:9
pub const G_VARIANT_TYPE_UINT64 = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:100:9
pub const G_VARIANT_TYPE_DOUBLE = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:113:9
pub const G_VARIANT_TYPE_STRING = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:122:9
pub const G_VARIANT_TYPE_OBJECT_PATH = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:137:9
pub const G_VARIANT_TYPE_SIGNATURE = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:152:9
pub const G_VARIANT_TYPE_VARIANT = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:160:9
pub const G_VARIANT_TYPE_HANDLE = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:172:9
pub const G_VARIANT_TYPE_UNIT = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:181:9
pub const G_VARIANT_TYPE_ANY = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:189:9
pub const G_VARIANT_TYPE_BASIC = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:197:9
pub const G_VARIANT_TYPE_MAYBE = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:204:9
pub const G_VARIANT_TYPE_ARRAY = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:211:9
pub const G_VARIANT_TYPE_TUPLE = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:219:9
pub const G_VARIANT_TYPE_DICT_ENTRY = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:227:9
pub const G_VARIANT_TYPE_DICTIONARY = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:236:9
pub const G_VARIANT_TYPE_STRING_ARRAY = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:243:9
pub const G_VARIANT_TYPE_OBJECT_PATH_ARRAY = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:250:9
pub const G_VARIANT_TYPE_BYTESTRING = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:262:9
pub const G_VARIANT_TYPE_BYTESTRING_ARRAY = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:269:9
pub const G_VARIANT_TYPE_VARDICT = @compileError("unable to translate C expr: unexpected token 'const'");
// /usr/include/glib-2.0/glib/gvarianttype.h:279:9
pub inline fn G_VARIANT_TYPE(type_string: anytype) @TypeOf(g_variant_type_checked_(type_string)) {
    _ = &type_string;
    return g_variant_type_checked_(type_string);
}
pub const G_VARIANT_PARSE_ERROR = g_variant_parse_error_quark();
pub const G_VARIANT_BUILDER_INIT = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/glib-2.0/glib/gvariant.h:369:9
pub const G_VARIANT_BUILDER_INIT_UNSET = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/glib-2.0/glib/gvariant.h:405:9
pub const G_VARIANT_DICT_INIT = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/glib-2.0/glib/gvariant.h:527:9
pub const G_LOG_LEVEL_USER_SHIFT = @as(c_int, 8);
pub const G_LOG_FATAL_MASK = G_LOG_FLAG_RECURSION | G_LOG_LEVEL_ERROR;
pub const G_DEBUG_HERE = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gmessages.h:280:9
pub const G_LOG_DOMAIN = @import("std").zig.c_translation.cast([*c]gchar, @as(c_int, 0));
pub const g_error = @compileError("unable to translate C expr: expected ')' instead got '...'");
// /usr/include/glib-2.0/glib/gmessages.h:353:9
pub const g_message = @compileError("unable to translate C expr: expected ')' instead got '...'");
// /usr/include/glib-2.0/glib/gmessages.h:359:9
pub const g_critical = @compileError("unable to translate C expr: expected ')' instead got '...'");
// /usr/include/glib-2.0/glib/gmessages.h:362:9
pub const g_warning = @compileError("unable to translate C expr: expected ')' instead got '...'");
// /usr/include/glib-2.0/glib/gmessages.h:365:9
pub const g_info = @compileError("unable to translate C expr: expected ')' instead got '...'");
// /usr/include/glib-2.0/glib/gmessages.h:368:9
pub const g_debug = @compileError("unable to translate C expr: expected ')' instead got '...'");
// /usr/include/glib-2.0/glib/gmessages.h:371:9
pub const g_warning_once = @compileError("unable to translate C expr: expected ')' instead got '...'");
// /usr/include/glib-2.0/glib/gmessages.h:500:9
pub const g_warn_if_reached = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gmessages.h:547:9
pub const g_warn_if_fail = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gmessages.h:563:9
pub const g_return_if_fail = @compileError("unable to translate C expr: unexpected token 'if'");
// /usr/include/glib-2.0/glib/gmessages.h:652:9
pub const g_return_val_if_fail = @compileError("unable to translate C expr: unexpected token 'if'");
// /usr/include/glib-2.0/glib/gmessages.h:665:9
pub const g_return_if_reached = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gmessages.h:678:9
pub const g_return_val_if_reached = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gmessages.h:689:9
pub const __G_OPTION_H__ = "";
pub const G_OPTION_ERROR = g_option_error_quark();
pub const G_OPTION_REMAINING = "";
pub const G_OPTION_ENTRY_NULL = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/glib-2.0/glib/goption.h:327:9
pub const G_PATH_BUF_INIT = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/glib-2.0/glib/gpathbuf.h:40:9
pub const __G_PATTERN_H__ = "";
pub const __G_PRIMES_H__ = "";
pub const __G_QSORT_H__ = "";
pub const __G_QUEUE_H__ = "";
pub const G_QUEUE_INIT = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/glib-2.0/glib/gqueue.h:70:9
pub const __G_RAND_H__ = "";
pub inline fn g_rand_boolean(rand_: anytype) @TypeOf((g_rand_int(rand_) & (@as(c_int, 1) << @as(c_int, 15))) != @as(c_int, 0)) {
    _ = &rand_;
    return (g_rand_int(rand_) & (@as(c_int, 1) << @as(c_int, 15))) != @as(c_int, 0);
}
pub inline fn g_random_boolean() @TypeOf((g_random_int() & (@as(c_int, 1) << @as(c_int, 15))) != @as(c_int, 0)) {
    return (g_random_int() & (@as(c_int, 1) << @as(c_int, 15))) != @as(c_int, 0);
}
pub const g_rc_box_new = @compileError("unable to translate C expr: unexpected token ')'");
// /usr/include/glib-2.0/glib/grcbox.h:68:9
pub const g_rc_box_new0 = @compileError("unable to translate C expr: unexpected token ')'");
// /usr/include/glib-2.0/glib/grcbox.h:70:9
pub const g_atomic_rc_box_new = @compileError("unable to translate C expr: unexpected token ')'");
// /usr/include/glib-2.0/glib/grcbox.h:72:9
pub const g_atomic_rc_box_new0 = @compileError("unable to translate C expr: unexpected token ')'");
// /usr/include/glib-2.0/glib/grcbox.h:74:9
pub const __GREFCOUNT_H__ = "";
pub const G_REF_COUNT_INIT = -@as(c_int, 1);
pub const G_ATOMIC_REF_COUNT_INIT = @as(c_int, 1);
pub const __G_REGEX_H__ = "";
pub const G_REGEX_ERROR = g_regex_error_quark();
pub const __G_SCANNER_H__ = "";
pub const G_CSET_A_2_Z = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
pub const G_CSET_a_2_z = "abcdefghijklmnopqrstuvwxyz";
pub const G_CSET_DIGITS = "0123456789";
pub const G_CSET_LATINC = "\xc0\xc1\xc2\xc3\xc4\xc5\xc6" ++ "\xc7\xc8\xc9\xca\xcb\xcc\xcd\xce\xcf\xd0" ++ "\xd1\xd2\xd3\xd4\xd5\xd6" ++ "\xd8\xd9\xda\xdb\xdc\xdd\xde";
pub const G_CSET_LATINS = "\xdf\xe0\xe1\xe2\xe3\xe4\xe5\xe6" ++ "\xe7\xe8\xe9\xea\xeb\xec\xed\xee\xef\xf0" ++ "\xf1\xf2\xf3\xf4\xf5\xf6" ++ "\xf8\xf9\xfa\xfb\xfc\xfd\xfe\xff";
pub const g_scanner_add_symbol = @compileError("unable to translate C expr: expected ',' or '}' instead got ';'");
// /usr/include/glib-2.0/glib/gscanner.h:284:10
pub const g_scanner_remove_symbol = @compileError("unable to translate C expr: expected ',' or '}' instead got ';'");
// /usr/include/glib-2.0/glib/gscanner.h:287:10
pub const g_scanner_foreach_symbol = @compileError("unable to translate C expr: expected ',' or '}' instead got ';'");
// /usr/include/glib-2.0/glib/gscanner.h:290:10
pub inline fn g_scanner_freeze_symbol_table(scanner: anytype) @TypeOf(@import("std").zig.c_translation.cast(anyopaque, @as(c_int, 0)) ++ GLIB_DEPRECATED_MACRO_IN_2_26) {
    _ = &scanner;
    return @import("std").zig.c_translation.cast(anyopaque, @as(c_int, 0)) ++ GLIB_DEPRECATED_MACRO_IN_2_26;
}
pub inline fn g_scanner_thaw_symbol_table(scanner: anytype) @TypeOf(@import("std").zig.c_translation.cast(anyopaque, @as(c_int, 0)) ++ GLIB_DEPRECATED_MACRO_IN_2_26) {
    _ = &scanner;
    return @import("std").zig.c_translation.cast(anyopaque, @as(c_int, 0)) ++ GLIB_DEPRECATED_MACRO_IN_2_26;
}
pub const __G_SEQUENCE_H__ = "";
pub const __G_SHELL_H__ = "";
pub const G_SHELL_ERROR = g_shell_error_quark();
pub const __G_SLICE_H__ = "";
pub const g_slice_new = @compileError("unable to translate C expr: unexpected token ')'");
// /usr/include/glib-2.0/glib/gslice.h:48:10
pub const g_slice_new0 = @compileError("unable to translate C expr: unexpected token ')'");
// /usr/include/glib-2.0/glib/gslice.h:62:11
pub const g_slice_dup = @compileError("unable to translate C expr: unexpected token ')'");
// /usr/include/glib-2.0/glib/gslice.h:78:9
pub const g_slice_free = @compileError("unable to translate C expr: unexpected token 'if'");
// /usr/include/glib-2.0/glib/gslice.h:81:9
pub const g_slice_free_chain = @compileError("unable to translate C expr: unexpected token 'if'");
// /usr/include/glib-2.0/glib/gslice.h:86:9
pub const __G_SPAWN_H__ = "";
pub const G_SPAWN_ERROR = g_spawn_error_quark();
pub const G_SPAWN_EXIT_ERROR = g_spawn_exit_error_quark();
pub const __G_STRINGCHUNK_H__ = "";
pub const __G_STRVBUILDER_H__ = "";
pub const __G_TEST_UTILS_H__ = "";
pub const _ERRNO_H = @as(c_int, 1);
pub const _BITS_ERRNO_H = @as(c_int, 1);
pub const _ASM_GENERIC_ERRNO_H = "";
pub const _ASM_GENERIC_ERRNO_BASE_H = "";
pub const EPERM = @as(c_int, 1);
pub const ENOENT = @as(c_int, 2);
pub const ESRCH = @as(c_int, 3);
pub const EINTR = @as(c_int, 4);
pub const EIO = @as(c_int, 5);
pub const ENXIO = @as(c_int, 6);
pub const E2BIG = @as(c_int, 7);
pub const ENOEXEC = @as(c_int, 8);
pub const EBADF = @as(c_int, 9);
pub const ECHILD = @as(c_int, 10);
pub const EAGAIN = @as(c_int, 11);
pub const ENOMEM = @as(c_int, 12);
pub const EACCES = @as(c_int, 13);
pub const EFAULT = @as(c_int, 14);
pub const ENOTBLK = @as(c_int, 15);
pub const EBUSY = @as(c_int, 16);
pub const EEXIST = @as(c_int, 17);
pub const EXDEV = @as(c_int, 18);
pub const ENODEV = @as(c_int, 19);
pub const ENOTDIR = @as(c_int, 20);
pub const EISDIR = @as(c_int, 21);
pub const EINVAL = @as(c_int, 22);
pub const ENFILE = @as(c_int, 23);
pub const EMFILE = @as(c_int, 24);
pub const ENOTTY = @as(c_int, 25);
pub const ETXTBSY = @as(c_int, 26);
pub const EFBIG = @as(c_int, 27);
pub const ENOSPC = @as(c_int, 28);
pub const ESPIPE = @as(c_int, 29);
pub const EROFS = @as(c_int, 30);
pub const EMLINK = @as(c_int, 31);
pub const EPIPE = @as(c_int, 32);
pub const EDOM = @as(c_int, 33);
pub const ERANGE = @as(c_int, 34);
pub const EDEADLK = @as(c_int, 35);
pub const ENAMETOOLONG = @as(c_int, 36);
pub const ENOLCK = @as(c_int, 37);
pub const ENOSYS = @as(c_int, 38);
pub const ENOTEMPTY = @as(c_int, 39);
pub const ELOOP = @as(c_int, 40);
pub const EWOULDBLOCK = EAGAIN;
pub const ENOMSG = @as(c_int, 42);
pub const EIDRM = @as(c_int, 43);
pub const ECHRNG = @as(c_int, 44);
pub const EL2NSYNC = @as(c_int, 45);
pub const EL3HLT = @as(c_int, 46);
pub const EL3RST = @as(c_int, 47);
pub const ELNRNG = @as(c_int, 48);
pub const EUNATCH = @as(c_int, 49);
pub const ENOCSI = @as(c_int, 50);
pub const EL2HLT = @as(c_int, 51);
pub const EBADE = @as(c_int, 52);
pub const EBADR = @as(c_int, 53);
pub const EXFULL = @as(c_int, 54);
pub const ENOANO = @as(c_int, 55);
pub const EBADRQC = @as(c_int, 56);
pub const EBADSLT = @as(c_int, 57);
pub const EDEADLOCK = EDEADLK;
pub const EBFONT = @as(c_int, 59);
pub const ENOSTR = @as(c_int, 60);
pub const ENODATA = @as(c_int, 61);
pub const ETIME = @as(c_int, 62);
pub const ENOSR = @as(c_int, 63);
pub const ENONET = @as(c_int, 64);
pub const ENOPKG = @as(c_int, 65);
pub const EREMOTE = @as(c_int, 66);
pub const ENOLINK = @as(c_int, 67);
pub const EADV = @as(c_int, 68);
pub const ESRMNT = @as(c_int, 69);
pub const ECOMM = @as(c_int, 70);
pub const EPROTO = @as(c_int, 71);
pub const EMULTIHOP = @as(c_int, 72);
pub const EDOTDOT = @as(c_int, 73);
pub const EBADMSG = @as(c_int, 74);
pub const EOVERFLOW = @as(c_int, 75);
pub const ENOTUNIQ = @as(c_int, 76);
pub const EBADFD = @as(c_int, 77);
pub const EREMCHG = @as(c_int, 78);
pub const ELIBACC = @as(c_int, 79);
pub const ELIBBAD = @as(c_int, 80);
pub const ELIBSCN = @as(c_int, 81);
pub const ELIBMAX = @as(c_int, 82);
pub const ELIBEXEC = @as(c_int, 83);
pub const EILSEQ = @as(c_int, 84);
pub const ERESTART = @as(c_int, 85);
pub const ESTRPIPE = @as(c_int, 86);
pub const EUSERS = @as(c_int, 87);
pub const ENOTSOCK = @as(c_int, 88);
pub const EDESTADDRREQ = @as(c_int, 89);
pub const EMSGSIZE = @as(c_int, 90);
pub const EPROTOTYPE = @as(c_int, 91);
pub const ENOPROTOOPT = @as(c_int, 92);
pub const EPROTONOSUPPORT = @as(c_int, 93);
pub const ESOCKTNOSUPPORT = @as(c_int, 94);
pub const EOPNOTSUPP = @as(c_int, 95);
pub const EPFNOSUPPORT = @as(c_int, 96);
pub const EAFNOSUPPORT = @as(c_int, 97);
pub const EADDRINUSE = @as(c_int, 98);
pub const EADDRNOTAVAIL = @as(c_int, 99);
pub const ENETDOWN = @as(c_int, 100);
pub const ENETUNREACH = @as(c_int, 101);
pub const ENETRESET = @as(c_int, 102);
pub const ECONNABORTED = @as(c_int, 103);
pub const ECONNRESET = @as(c_int, 104);
pub const ENOBUFS = @as(c_int, 105);
pub const EISCONN = @as(c_int, 106);
pub const ENOTCONN = @as(c_int, 107);
pub const ESHUTDOWN = @as(c_int, 108);
pub const ETOOMANYREFS = @as(c_int, 109);
pub const ETIMEDOUT = @as(c_int, 110);
pub const ECONNREFUSED = @as(c_int, 111);
pub const EHOSTDOWN = @as(c_int, 112);
pub const EHOSTUNREACH = @as(c_int, 113);
pub const EALREADY = @as(c_int, 114);
pub const EINPROGRESS = @as(c_int, 115);
pub const ESTALE = @as(c_int, 116);
pub const EUCLEAN = @as(c_int, 117);
pub const ENOTNAM = @as(c_int, 118);
pub const ENAVAIL = @as(c_int, 119);
pub const EISNAM = @as(c_int, 120);
pub const EREMOTEIO = @as(c_int, 121);
pub const EDQUOT = @as(c_int, 122);
pub const ENOMEDIUM = @as(c_int, 123);
pub const EMEDIUMTYPE = @as(c_int, 124);
pub const ECANCELED = @as(c_int, 125);
pub const ENOKEY = @as(c_int, 126);
pub const EKEYEXPIRED = @as(c_int, 127);
pub const EKEYREVOKED = @as(c_int, 128);
pub const EKEYREJECTED = @as(c_int, 129);
pub const EOWNERDEAD = @as(c_int, 130);
pub const ENOTRECOVERABLE = @as(c_int, 131);
pub const ERFKILL = @as(c_int, 132);
pub const EHWPOISON = @as(c_int, 133);
pub const ENOTSUP = EOPNOTSUPP;
pub const errno = __errno_location().*;
pub const g_assert_cmpstr = @compileError("unable to translate macro: undefined identifier `__s1`");
// /usr/include/glib-2.0/glib/gtestutils.h:46:9
pub const g_assert_cmpint = @compileError("unable to translate macro: undefined identifier `__n1`");
// /usr/include/glib-2.0/glib/gtestutils.h:53:9
pub const g_assert_cmpuint = @compileError("unable to translate macro: undefined identifier `__n1`");
// /usr/include/glib-2.0/glib/gtestutils.h:59:9
pub const g_assert_cmphex = @compileError("unable to translate macro: undefined identifier `__n1`");
// /usr/include/glib-2.0/glib/gtestutils.h:65:9
pub const g_assert_cmpfloat = @compileError("unable to translate macro: undefined identifier `__n1`");
// /usr/include/glib-2.0/glib/gtestutils.h:91:9
pub const g_assert_cmpfloat_with_epsilon = @compileError("unable to translate macro: undefined identifier `__n1`");
// /usr/include/glib-2.0/glib/gtestutils.h:97:9
pub const g_assert_cmpmem = @compileError("unable to translate macro: undefined identifier `__m1`");
// /usr/include/glib-2.0/glib/gtestutils.h:105:9
pub const g_assert_cmpvariant = @compileError("unable to translate macro: undefined identifier `__v1`");
// /usr/include/glib-2.0/glib/gtestutils.h:141:9
pub const g_assert_cmpstrv = @compileError("unable to translate macro: undefined identifier `__strv1`");
// /usr/include/glib-2.0/glib/gtestutils.h:158:9
pub const g_assert_no_errno = @compileError("unable to translate macro: undefined identifier `__ret`");
// /usr/include/glib-2.0/glib/gtestutils.h:203:9
pub const g_assert_no_error = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:217:9
pub const g_assert_error = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:222:9
pub const g_assert_true = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:227:9
pub const g_assert_false = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:232:9
pub const g_assert_null = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:250:9
pub const g_assert_nonnull = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:254:9
pub const g_assert_not_reached = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:274:9
pub const g_assert = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:275:9
pub const G_TEST_OPTION_ISOLATE_DIRS = "isolate_dirs";
pub const G_TEST_OPTION_NO_PRGNAME = "no_g_set_prgname";
pub const G_TEST_OPTION_NONFATAL_ASSERTIONS = "nonfatal-assertions";
pub inline fn g_test_initialized() @TypeOf(g_test_config_vars.*.test_initialized) {
    return g_test_config_vars.*.test_initialized;
}
pub inline fn g_test_quick() @TypeOf(g_test_config_vars.*.test_quick) {
    return g_test_config_vars.*.test_quick;
}
pub inline fn g_test_slow() @TypeOf(!(g_test_config_vars.*.test_quick != 0)) {
    return !(g_test_config_vars.*.test_quick != 0);
}
pub inline fn g_test_thorough() @TypeOf(!(g_test_config_vars.*.test_quick != 0)) {
    return !(g_test_config_vars.*.test_quick != 0);
}
pub inline fn g_test_perf() @TypeOf(g_test_config_vars.*.test_perf) {
    return g_test_config_vars.*.test_perf;
}
pub inline fn g_test_verbose() @TypeOf(g_test_config_vars.*.test_verbose) {
    return g_test_config_vars.*.test_verbose;
}
pub inline fn g_test_quiet() @TypeOf(g_test_config_vars.*.test_quiet) {
    return g_test_config_vars.*.test_quiet;
}
pub inline fn g_test_undefined() @TypeOf(g_test_config_vars.*.test_undefined) {
    return g_test_config_vars.*.test_undefined;
}
pub const g_test_add = @compileError("unable to translate macro: undefined identifier `add_vtable`");
// /usr/include/glib-2.0/glib/gtestutils.h:463:9
pub const g_test_queue_unref = @compileError("unable to translate macro: undefined identifier `g_object_unref`");
// /usr/include/glib-2.0/glib/gtestutils.h:499:9
pub const g_test_trap_assert_passed = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:560:10
pub const g_test_trap_assert_failed = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:561:10
pub const g_test_trap_assert_stdout = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:562:10
pub const g_test_trap_assert_stdout_unmatched = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:563:10
pub const g_test_trap_assert_stderr = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:564:10
pub const g_test_trap_assert_stderr_unmatched = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:565:10
pub inline fn g_test_rand_bit() @TypeOf(@as(c_int, 0) != (g_test_rand_int() & (@as(c_int, 1) << @as(c_int, 15)))) {
    return @as(c_int, 0) != (g_test_rand_int() & (@as(c_int, 1) << @as(c_int, 15)));
}
pub const g_test_assert_expected_messages = @compileError("unable to translate macro: undefined identifier `__FILE__`");
// /usr/include/glib-2.0/glib/gtestutils.h:796:9
pub const __G_THREADPOOL_H__ = "";
pub const __G_TIMER_H__ = "";
pub const G_USEC_PER_SEC = @import("std").zig.c_translation.promoteIntLiteral(c_int, 1000000, .decimal);
pub const __G_TRASH_STACK_H__ = "";
pub const __G_TREE_H__ = "";
pub const G_URI_ERROR = g_uri_error_quark();
pub const G_URI_RESERVED_CHARS_GENERIC_DELIMITERS = ":/?#[]@";
pub const G_URI_RESERVED_CHARS_SUBCOMPONENT_DELIMITERS = "!$&'()*+,;=";
pub const G_URI_RESERVED_CHARS_ALLOWED_IN_PATH_ELEMENT = G_URI_RESERVED_CHARS_SUBCOMPONENT_DELIMITERS ++ ":@";
pub const G_URI_RESERVED_CHARS_ALLOWED_IN_PATH = G_URI_RESERVED_CHARS_ALLOWED_IN_PATH_ELEMENT ++ "/";
pub const G_URI_RESERVED_CHARS_ALLOWED_IN_USERINFO = G_URI_RESERVED_CHARS_SUBCOMPONENT_DELIMITERS ++ ":";
pub const __G_UUID_H__ = "";
pub const __G_VERSION_H__ = "";
pub inline fn GLIB_CHECK_VERSION(major: anytype, minor: anytype, micro: anytype) @TypeOf(((GLIB_MAJOR_VERSION > major) or ((GLIB_MAJOR_VERSION == major) and (GLIB_MINOR_VERSION > minor))) or (((GLIB_MAJOR_VERSION == major) and (GLIB_MINOR_VERSION == minor)) and (GLIB_MICRO_VERSION >= micro))) {
    _ = &major;
    _ = &minor;
    _ = &micro;
    return ((GLIB_MAJOR_VERSION > major) or ((GLIB_MAJOR_VERSION == major) and (GLIB_MINOR_VERSION > minor))) or (((GLIB_MAJOR_VERSION == major) and (GLIB_MINOR_VERSION == minor)) and (GLIB_MICRO_VERSION >= micro));
}
pub const __G_ALLOCATOR_H__ = "";
pub const G_ALLOC_ONLY = @as(c_int, 1);
pub const G_ALLOC_AND_FREE = @as(c_int, 2);
pub const G_ALLOCATOR_LIST = @as(c_int, 1);
pub const G_ALLOCATOR_SLIST = @as(c_int, 2);
pub const G_ALLOCATOR_NODE = @as(c_int, 3);
pub const g_chunk_new = @compileError("unable to translate C expr: unexpected token ')'");
// /usr/include/glib-2.0/glib/deprecated/gallocator.h:36:9
pub const g_chunk_new0 = @compileError("unable to translate C expr: unexpected token ')'");
// /usr/include/glib-2.0/glib/deprecated/gallocator.h:37:9
pub inline fn g_chunk_free(mem: anytype, mem_chunk: anytype) @TypeOf(g_mem_chunk_free(mem_chunk, mem)) {
    _ = &mem;
    _ = &mem_chunk;
    return g_mem_chunk_free(mem_chunk, mem);
}
pub inline fn g_mem_chunk_create(@"type": anytype, x: anytype, y: anytype) @TypeOf(g_mem_chunk_new(NULL, @import("std").zig.c_translation.sizeof(@"type"), @as(c_int, 0), @as(c_int, 0))) {
    _ = &@"type";
    _ = &x;
    _ = &y;
    return g_mem_chunk_new(NULL, @import("std").zig.c_translation.sizeof(@"type"), @as(c_int, 0), @as(c_int, 0));
}
pub const __G_CACHE_H__ = "";
pub const __G_COMPLETION_H__ = "";
pub const __G_DEPRECATED_MAIN_H__ = "";
pub inline fn g_main_new(is_running: anytype) @TypeOf(g_main_loop_new(NULL, is_running) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_loop_new)) {
    _ = &is_running;
    return g_main_loop_new(NULL, is_running) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_loop_new);
}
pub inline fn g_main_run(loop: anytype) @TypeOf(g_main_loop_run(loop) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_loop_run)) {
    _ = &loop;
    return g_main_loop_run(loop) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_loop_run);
}
pub inline fn g_main_quit(loop: anytype) @TypeOf(g_main_loop_quit(loop) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_loop_quit)) {
    _ = &loop;
    return g_main_loop_quit(loop) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_loop_quit);
}
pub inline fn g_main_destroy(loop: anytype) @TypeOf(g_main_loop_unref(loop) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_loop_unref)) {
    _ = &loop;
    return g_main_loop_unref(loop) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_loop_unref);
}
pub inline fn g_main_is_running(loop: anytype) @TypeOf(g_main_loop_is_running(loop) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_loop_is_running)) {
    _ = &loop;
    return g_main_loop_is_running(loop) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_loop_is_running);
}
pub inline fn g_main_iteration(may_block: anytype) @TypeOf(g_main_context_iteration(NULL, may_block) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_context_iteration)) {
    _ = &may_block;
    return g_main_context_iteration(NULL, may_block) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_context_iteration);
}
pub inline fn g_main_pending() @TypeOf(g_main_context_pending(NULL) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_context_pending)) {
    return g_main_context_pending(NULL) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_context_pending);
}
pub inline fn g_main_set_poll_func(func: anytype) @TypeOf(g_main_context_set_poll_func(NULL, func) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_context_set_poll_func)) {
    _ = &func;
    return g_main_context_set_poll_func(NULL, func) ++ GLIB_DEPRECATED_MACRO_IN_2_26_FOR(g_main_context_set_poll_func);
}
pub const __G_REL_H__ = "";
pub const __G_DEPRECATED_THREAD_H__ = "";
pub const _PTHREAD_H = @as(c_int, 1);
pub const _SCHED_H = @as(c_int, 1);
pub const _BITS_SCHED_H = @as(c_int, 1);
pub const SCHED_OTHER = @as(c_int, 0);
pub const SCHED_FIFO = @as(c_int, 1);
pub const SCHED_RR = @as(c_int, 2);
pub const _BITS_TYPES_STRUCT_SCHED_PARAM = @as(c_int, 1);
pub const _BITS_CPU_SET_H = @as(c_int, 1);
pub const __CPU_SETSIZE = @as(c_int, 1024);
pub const __NCPUBITS = @as(c_int, 8) * @import("std").zig.c_translation.sizeof(__cpu_mask);
pub inline fn __CPUELT(cpu: anytype) @TypeOf(@import("std").zig.c_translation.MacroArithmetic.div(cpu, __NCPUBITS)) {
    _ = &cpu;
    return @import("std").zig.c_translation.MacroArithmetic.div(cpu, __NCPUBITS);
}
pub inline fn __CPUMASK(cpu: anytype) @TypeOf(@import("std").zig.c_translation.cast(__cpu_mask, @as(c_int, 1)) << @import("std").zig.c_translation.MacroArithmetic.rem(cpu, __NCPUBITS)) {
    _ = &cpu;
    return @import("std").zig.c_translation.cast(__cpu_mask, @as(c_int, 1)) << @import("std").zig.c_translation.MacroArithmetic.rem(cpu, __NCPUBITS);
}
pub const __CPU_ZERO_S = @compileError("unable to translate C expr: unexpected token 'do'");
// /usr/include/bits/cpu-set.h:46:10
pub const __CPU_SET_S = @compileError("unable to translate macro: undefined identifier `__cpu`");
// /usr/include/bits/cpu-set.h:58:9
pub const __CPU_CLR_S = @compileError("unable to translate macro: undefined identifier `__cpu`");
// /usr/include/bits/cpu-set.h:65:9
pub const __CPU_ISSET_S = @compileError("unable to translate macro: undefined identifier `__cpu`");
// /usr/include/bits/cpu-set.h:72:9
pub inline fn __CPU_COUNT_S(setsize: anytype, cpusetp: anytype) @TypeOf(__sched_cpucount(setsize, cpusetp)) {
    _ = &setsize;
    _ = &cpusetp;
    return __sched_cpucount(setsize, cpusetp);
}
pub const __CPU_EQUAL_S = @compileError("unable to translate macro: undefined identifier `__builtin_memcmp`");
// /usr/include/bits/cpu-set.h:84:10
pub const __CPU_OP_S = @compileError("unable to translate macro: undefined identifier `__dest`");
// /usr/include/bits/cpu-set.h:99:9
pub inline fn __CPU_ALLOC_SIZE(count: anytype) @TypeOf(@import("std").zig.c_translation.MacroArithmetic.div((count + __NCPUBITS) - @as(c_int, 1), __NCPUBITS) * @import("std").zig.c_translation.sizeof(__cpu_mask)) {
    _ = &count;
    return @import("std").zig.c_translation.MacroArithmetic.div((count + __NCPUBITS) - @as(c_int, 1), __NCPUBITS) * @import("std").zig.c_translation.sizeof(__cpu_mask);
}
pub inline fn __CPU_ALLOC(count: anytype) @TypeOf(__sched_cpualloc(count)) {
    _ = &count;
    return __sched_cpualloc(count);
}
pub inline fn __CPU_FREE(cpuset: anytype) @TypeOf(__sched_cpufree(cpuset)) {
    _ = &cpuset;
    return __sched_cpufree(cpuset);
}
pub const __sched_priority = @compileError("unable to translate macro: undefined identifier `sched_priority`");
// /usr/include/sched.h:48:9
pub const _BITS_SETJMP_H = @as(c_int, 1);
pub const __jmp_buf_tag_defined = @as(c_int, 1);
pub const PTHREAD_MUTEX_INITIALIZER = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/pthread.h:90:9
pub const PTHREAD_RWLOCK_INITIALIZER = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/pthread.h:114:10
pub const PTHREAD_COND_INITIALIZER = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/pthread.h:155:9
pub const PTHREAD_CANCELED = @import("std").zig.c_translation.cast(?*anyopaque, -@as(c_int, 1));
pub const PTHREAD_ONCE_INIT = @as(c_int, 0);
pub const PTHREAD_BARRIER_SERIAL_THREAD = -@as(c_int, 1);
pub const __cleanup_fct_attribute = "";
pub const pthread_cleanup_push = @compileError("unable to translate macro: undefined identifier `__cancel_buf`");
// /usr/include/pthread.h:681:10
pub const pthread_cleanup_pop = @compileError("unable to translate macro: undefined identifier `__cancel_buf`");
// /usr/include/pthread.h:702:10
pub inline fn __sigsetjmp_cancel(env: anytype, savemask: anytype) @TypeOf(__sigsetjmp(@import("std").zig.c_translation.cast([*c]struct___jmp_buf_tag, @import("std").zig.c_translation.cast(?*anyopaque, env)), savemask)) {
    _ = &env;
    _ = &savemask;
    return __sigsetjmp(@import("std").zig.c_translation.cast([*c]struct___jmp_buf_tag, @import("std").zig.c_translation.cast(?*anyopaque, env)), savemask);
}
pub const g_static_mutex_get_mutex = g_static_mutex_get_mutex_impl ++ GLIB_DEPRECATED_MACRO_IN_2_32;
pub const G_STATIC_MUTEX_INIT = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/glib-2.0/glib/deprecated/gthread.h:131:9
pub inline fn g_static_mutex_lock(mutex: anytype) @TypeOf(g_mutex_lock(g_static_mutex_get_mutex(mutex)) ++ GLIB_DEPRECATED_MACRO_IN_2_32_FOR(g_mutex_lock)) {
    _ = &mutex;
    return g_mutex_lock(g_static_mutex_get_mutex(mutex)) ++ GLIB_DEPRECATED_MACRO_IN_2_32_FOR(g_mutex_lock);
}
pub inline fn g_static_mutex_trylock(mutex: anytype) @TypeOf(g_mutex_trylock(g_static_mutex_get_mutex(mutex)) ++ GLIB_DEPRECATED_MACRO_IN_2_32_FOR(g_mutex_trylock)) {
    _ = &mutex;
    return g_mutex_trylock(g_static_mutex_get_mutex(mutex)) ++ GLIB_DEPRECATED_MACRO_IN_2_32_FOR(g_mutex_trylock);
}
pub inline fn g_static_mutex_unlock(mutex: anytype) @TypeOf(g_mutex_unlock(g_static_mutex_get_mutex(mutex)) ++ GLIB_DEPRECATED_MACRO_IN_2_32_FOR(g_mutex_unlock)) {
    _ = &mutex;
    return g_mutex_unlock(g_static_mutex_get_mutex(mutex)) ++ GLIB_DEPRECATED_MACRO_IN_2_32_FOR(g_mutex_unlock);
}
pub const G_STATIC_REC_MUTEX_INIT = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/glib-2.0/glib/deprecated/gthread.h:180:9
pub const G_STATIC_RW_LOCK_INIT = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/glib-2.0/glib/deprecated/gthread.h:216:9
pub const G_STATIC_PRIVATE_INIT = @compileError("unable to translate C expr: unexpected token '{'");
// /usr/include/glib-2.0/glib/deprecated/gthread.h:252:9
pub inline fn g_thread_supported() @TypeOf(@as(c_int, 1) ++ GLIB_DEPRECATED_MACRO_IN_2_32) {
    return @as(c_int, 1) ++ GLIB_DEPRECATED_MACRO_IN_2_32;
}
pub const tm = struct_tm;
pub const timespec = struct_timespec;
pub const itimerspec = struct_itimerspec;
pub const sigval = union_sigval;
pub const sigevent = struct_sigevent;
pub const __locale_struct = struct___locale_struct;
pub const _GDoubleIEEE754 = union__GDoubleIEEE754;
pub const _GFloatIEEE754 = union__GFloatIEEE754;
pub const _GTimeVal = struct__GTimeVal;
pub const _GBytes = struct__GBytes;
pub const _GArray = struct__GArray;
pub const _GByteArray = struct__GByteArray;
pub const _GPtrArray = struct__GPtrArray;
pub const _GError = struct__GError;
pub const _GDebugKey = struct__GDebugKey;
pub const timeval = struct_timeval;
pub const __pthread_internal_list = struct___pthread_internal_list;
pub const __pthread_internal_slist = struct___pthread_internal_slist;
pub const __pthread_mutex_s = struct___pthread_mutex_s;
pub const __pthread_rwlock_arch_t = struct___pthread_rwlock_arch_t;
pub const __pthread_cond_s = struct___pthread_cond_s;
pub const random_data = struct_random_data;
pub const drand48_data = struct_drand48_data;
pub const _GThread = struct__GThread;
pub const _GMutex = union__GMutex;
pub const _GRecMutex = struct__GRecMutex;
pub const _GRWLock = struct__GRWLock;
pub const _GCond = struct__GCond;
pub const _GPrivate = struct__GPrivate;
pub const _GOnce = struct__GOnce;
pub const _GAsyncQueue = struct__GAsyncQueue;
pub const _fpx_sw_bytes = struct__fpx_sw_bytes;
pub const _fpreg = struct__fpreg;
pub const _fpxreg = struct__fpxreg;
pub const _xmmreg = struct__xmmreg;
pub const _fpstate = struct__fpstate;
pub const sigcontext = struct_sigcontext;
pub const _xsave_hdr = struct__xsave_hdr;
pub const _ymmh_state = struct__ymmh_state;
pub const _xstate = struct__xstate;
pub const _libc_fpxreg = struct__libc_fpxreg;
pub const _libc_xmmreg = struct__libc_xmmreg;
pub const _libc_fpstate = struct__libc_fpstate;
pub const _GTimeZone = struct__GTimeZone;
pub const _GDateTime = struct__GDateTime;
pub const _GBookmarkFile = struct__GBookmarkFile;
pub const _GChecksum = struct__GChecksum;
pub const _GIConv = struct__GIConv;
pub const _GData = struct__GData;
pub const _GDate = struct__GDate;
pub const dirent = struct_dirent;
pub const __dirstream = struct___dirstream;
pub const _GDir = struct__GDir;
pub const _GMemVTable = struct__GMemVTable;
pub const _GNode = struct__GNode;
pub const _GList = struct__GList;
pub const _GHashTable = struct__GHashTable;
pub const _GHashTableIter = struct__GHashTableIter;
pub const _GHmac = struct__GHmac;
pub const _GHook = struct__GHook;
pub const _GHookList = struct__GHookList;
pub const _GPollFD = struct__GPollFD;
pub const _GSList = struct__GSList;
pub const _GMainContext = struct__GMainContext;
pub const _GMainLoop = struct__GMainLoop;
pub const _GSourceCallbackFuncs = struct__GSourceCallbackFuncs;
pub const _GSourceFuncs = struct__GSourceFuncs;
pub const _GSourcePrivate = struct__GSourcePrivate;
pub const _GSource = struct__GSource;
pub const _GString = struct__GString;
pub const _GIOFuncs = struct__GIOFuncs;
pub const _GIOChannel = struct__GIOChannel;
pub const _GKeyFile = struct__GKeyFile;
pub const _GMappedFile = struct__GMappedFile;
pub const _GMarkupParseContext = struct__GMarkupParseContext;
pub const _GMarkupParser = struct__GMarkupParser;
pub const _GVariantType = struct__GVariantType;
pub const _GVariant = struct__GVariant;
pub const _GVariantIter = struct__GVariantIter;
pub const _GVariantBuilder = struct__GVariantBuilder;
pub const _GVariantDict = struct__GVariantDict;
pub const _GLogField = struct__GLogField;
pub const _GOptionContext = struct__GOptionContext;
pub const _GOptionGroup = struct__GOptionGroup;
pub const _GOptionEntry = struct__GOptionEntry;
pub const _GPathBuf = struct__GPathBuf;
pub const _GPatternSpec = struct__GPatternSpec;
pub const _GQueue = struct__GQueue;
pub const _GRand = struct__GRand;
pub const _GRegex = struct__GRegex;
pub const _GMatchInfo = struct__GMatchInfo;
pub const _GScannerConfig = struct__GScannerConfig;
pub const _GTokenValue = union__GTokenValue;
pub const _GScanner = struct__GScanner;
pub const _GSequence = struct__GSequence;
pub const _GSequenceNode = struct__GSequenceNode;
pub const _GStringChunk = struct__GStringChunk;
pub const _GStrvBuilder = struct__GStrvBuilder;
pub const _GThreadPool = struct__GThreadPool;
pub const _GTimer = struct__GTimer;
pub const _GTrashStack = struct__GTrashStack;
pub const _GTree = struct__GTree;
pub const _GTreeNode = struct__GTreeNode;
pub const _GUri = struct__GUri;
pub const _GUriParamsIter = struct__GUriParamsIter;
pub const _GAllocator = struct__GAllocator;
pub const _GMemChunk = struct__GMemChunk;
pub const _GCache = struct__GCache;
pub const _GCompletion = struct__GCompletion;
pub const _GRelation = struct__GRelation;
pub const _GTuples = struct__GTuples;
pub const _GThreadFunctions = struct__GThreadFunctions;
pub const sched_param = struct_sched_param;
pub const __jmp_buf_tag = struct___jmp_buf_tag;
pub const _pthread_cleanup_buffer = struct__pthread_cleanup_buffer;
pub const __cancel_jmp_buf_tag = struct___cancel_jmp_buf_tag;
pub const __pthread_cleanup_frame = struct___pthread_cleanup_frame;
pub const _GStaticRecMutex = struct__GStaticRecMutex;
pub const _GStaticRWLock = struct__GStaticRWLock;
pub const _GStaticPrivate = struct__GStaticPrivate;
