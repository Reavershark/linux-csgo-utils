import std.conv;
import std.stdio;
import std.process;
import std.string;
import offsets;

import core.sys.posix.sys.types;
import core.sys.posix.sys.uio;
import uio_ext;

pid_t pidof(string name)
{
    auto pipes = pipeProcess(["pidof", name], Redirect.stdout);
    scope(exit) wait(pipes.pid);

    // Only return first match
    pid_t pid = to!pid_t(pipes.stdout.readln.split("\n")[0].split(" ")[0]);
    return pid;
}

bool Read(pid_t pid, void* address, void* buffer, size_t size) {
	iovec[1] local;
	iovec[1] remote;

	local[0].iov_base = buffer;
	local[0].iov_len = size;
	remote[0].iov_base = address;
	remote[0].iov_len = size;

	return (process_vm_readv(pid, local.ptr, 1, remote.ptr, 1, 0) == size);
}


void main()
{
    auto offsets = new Offsets("data/csgo.json");

    char[1024] buf;
    Read(pidof("vim"), cast(char*) 0x7f9f9b2ee000, buf.ptr, 1024);
    writeln(buf);
}
