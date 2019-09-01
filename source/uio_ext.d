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
