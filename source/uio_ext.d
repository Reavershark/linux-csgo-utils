module uio_ext;

import core.stdc.config;
public import core.sys.posix.sys.types; // for ssize_t and pid_t
import core.sys.posix.sys.uio;

extern (C):

ssize_t process_vm_readv (
    pid_t __pid,
    const(iovec)* __lvec,
    c_ulong __liovcnt,
    const(iovec)* __rvec,
    c_ulong __riovcnt,
    c_ulong __flags);

ssize_t process_vm_writev (
    pid_t __pid,
    const(iovec)* __lvec,
    c_ulong __liovcnt,
    const(iovec)* __rvec,
    c_ulong __riovcnt,
    c_ulong __flags);

/* Flags for preadv2/pwritev2.  */
enum RWF_HIPRI = 0x00000001; /* High priority request.  */
enum RWF_DSYNC = 0x00000002; /* per-IO O_DSYNC.  */
enum RWF_SYNC = 0x00000004; /* per-IO O_SYNC.  */
enum RWF_NOWAIT = 0x00000008; /* per-IO nonblocking mode.  */
enum RWF_APPEND = 0x00000010; /* per-IO O_APPEND.  */
