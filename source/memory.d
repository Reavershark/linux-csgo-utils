module memory;

import std.algorithm;
import std.conv : to;
import std.format;
import std.string : lastIndexOf;
import std.process;
import std.stdio : File;
import std.range : split;
import std.string : fromStringz;

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

struct MemoryRegion {
	// Memory
	ulong start = 0;
	ulong end = 0;

	// Permissions
	bool readable;
	bool writable;
	bool executable;
	bool sharedMemory;

	// File data
	ulong offset;
	ushort deviceMajor;
	ushort deviceMinor;
	ulong inodeFileNumber;
	string pathname;
	string filename;
};

class Process
{
    private pid_t pid;

    this(pid_t pid)
    {
        this.pid = pid;
    }
}

class Handle : Process
{
    this(Args...)(Args args)
    {
        super(args);
    }

    T read(T, A)(A address) {

        size_t size = T.sizeof;

        T[1] buffer;

        iovec[1] local;
        iovec[1] remote;
    
        local[0].iov_base = cast(void*) buffer;
        local[0].iov_len = size;
        remote[0].iov_base = cast(void*) address;
        remote[0].iov_len = size;
    
        process_vm_readv(pid, local.ptr, 1, remote.ptr, 1, 0);

        return buffer[0];
    }

    bool read(void* address, void* buffer, size_t size)
    {
		iovec[1] local;
		iovec[1] remote;

		local[0].iov_base = buffer;
		local[0].iov_len = size;
		remote[0].iov_base = address;
		remote[0].iov_len = size;

		return (process_vm_readv(pid, local.ptr, 1, remote.ptr, 1, 0) == size);
    }

    string readString(A)(A address)
    {
        const ulong size = 256;
        char[size] strz;
        strz = read!(char[size])(address);
        string str = to!string(fromStringz(strz.ptr));
        return str;
    }

	ulong find(MemoryRegion region, string data, string pattern)
    {
		char[0x1000] buffer;

		size_t len = pattern.length;
		size_t chunksize = buffer.sizeof;
		size_t totalsize = region.end - region.start;
		size_t chunknum = 0;
		size_t matches = 0;

		while (totalsize) {
			size_t readsize = (totalsize < chunksize) ? totalsize : chunksize;
			size_t readaddr = region.start + (chunksize * chunknum);

            buffer = 0;

			if (read(cast(void*) readaddr, cast(void*) buffer, readsize)) {
				for (size_t b = 0; b < readsize; b++) {
					for (size_t t = b; t < readsize; t++) {
						if (buffer[t] != data[matches] && pattern[matches] == 'x') {
							matches = 0;
							break;
						}
						matches++;

						if (matches == len) {
							return cast(char*) (readaddr + t - matches + 1);
						}
					}
				}
			}

			totalsize -= readsize;
			chunknum++;
		}

		return 0;
    }

    ulong GetAbsoluteAddress(void* address, int offset, int size) {
        int code = 0;
    
        if (read(cast(char*) (cast(ulong) address + offset), &code, uint.sizeof)) {
            return code + cast(ulong) address + size;
        }
    
        return 0;
    }

}

class Maps : Process
{
    private MemoryRegion[] regions;

    this(Args...)(Args args)
    {
        super(args);
        parseMaps();
    }

    MemoryRegion[] getRegions()
    {
        return regions.dup;
    }

    MemoryRegion getFileMap(string targetFilename)
    {
        MemoryRegion targetRegion;
        foreach(region; regions)
        {
            if (region.filename == targetFilename)
            {
                targetRegion = region;
                break;
            }
        }
        return targetRegion;
    }

    private void parseMaps()
    {
        regions = [];

        auto maps = File("/proc/" ~ to!string(pid) ~ "/maps", "r");
        foreach(line; maps.byLine().map!split)
        {
            MemoryRegion region;
            auto hexSpec = singleSpec("%x");

            // 1st column
            string[] memorySpace = cast(string[]) line[0].split("-");
            region.start = memorySpace[0].unformatValue!ulong(hexSpec);
            region.end = memorySpace[1].unformatValue!ulong(hexSpec);

            // 2nd column
            string permissions = line[1].idup;
            region.readable = (permissions[0] == 'r');
            region.writable = (permissions[1] == 'w');
            region.executable = (permissions[2] == 'x');
            region.sharedMemory = (permissions[3] != '-');

            // 3rd column
            region.offset = line[2].unformatValue!ulong(hexSpec);

            // 4th column
            string[] device = cast(string[]) line[3].split(":");
            region.deviceMajor = device[0].unformatValue!ushort(hexSpec);
            region.deviceMinor = device[1].unformatValue!ushort(hexSpec);

            // 5th column
            region.inodeFileNumber = to!ulong(line[4]);

            // 6th column
            if (line.length > 5)
            {
                if (region.inodeFileNumber == 0)
                {
                    // [heap], [stack]...
                    region.filename = to!string(line[5]);
                }
                else
                {
                    // Add back spaces
                    string fullpath;
                    bool first = true;
                    foreach(word; line[5 .. $])
                    {
                        if (!first)
                            fullpath ~= " " ~ word;
                        else
                        {
                            first = false;
                            fullpath ~= word;
                        }

                    }
                    
                    long index = lastIndexOf(fullpath, '/') + 1;
                    region.pathname = to!string(fullpath[0 .. index]);
                    region.filename = to!string(fullpath[index .. $]);
                }
            }
            regions ~= region;
        }
    }
}
