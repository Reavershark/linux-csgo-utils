module memory;

import std.algorithm;
import std.conv : to;
import std.format;
import std.string : lastIndexOf;
import std.process;
import std.stdio;
import std.range;

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

class Handle
{
    private pid_t pid;
    private MemoryRegion[] regions;

    public struct MemoryRegion {
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
    
    	//void* find(Handle handle, const char* data, const char* pattern);
    };

    this(pid_t pid)
    {
        this.pid = pid;
        parseMaps();
    }

    public MemoryRegion[] getRegions()
    {
        return regions.dup;
    }

    public bool read(void* address, void* buffer, size_t size) {
        iovec[1] local;
        iovec[1] remote;
    
        local[0].iov_base = buffer;
        local[0].iov_len = size;
        remote[0].iov_base = address;
        remote[0].iov_len = size;
    
        return (process_vm_readv(pid, local.ptr, 1, remote.ptr, 1, 0) == size);
    }

    private void parseMaps()
    {
        regions = [];

        auto maps = File("/proc/" ~ to!string(pid) ~ "/maps", "r");
        foreach(lineStr; maps.byLine())
        {
            auto line = lineStr.split;
            MemoryRegion* region = new MemoryRegion;
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
                    long index = lastIndexOf(line[5], '/') + 1;
                    region.pathname = to!string(line[5][0 .. index]);
                    region.filename = to!string(line[5][index .. $]);
                }
            }
            regions = regions ~ *region;
        }
    }
}
