module memory;

import std.algorithm;
import std.container.array;
import std.conv;
import std.process;
import std.string;
import std.stdio;

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

    struct MemoryRegion {
    	// Memory
    	ulong start;
    	ulong end;
    
    	// Permissions
    	bool readable;
    	bool writable;
    	bool executable;
    	bool sharedMemory;
    
    	// File data
    	ulong offset;
    	char deviceMajor;
    	char deviceMinor;
    	ulong inodeFileNumber;
    	string pathname;
    	string filename;
    
    	ulong client_start;
    
    	//void* find(Handle handle, const char* data, const char* pattern);
    };

    public bool read(void* address, void* buffer, size_t size) {
        iovec[1] local;
        iovec[1] remote;
    
        local[0].iov_base = buffer;
        local[0].iov_len = size;
        remote[0].iov_base = address;
        remote[0].iov_len = size;
    
        return (process_vm_readv(pid, local.ptr, 1, remote.ptr, 1, 0) == size);
    }

    this(pid_t pid)
    {
        this.pid = pid;
        parseMaps();
    }

    void parseMaps() {
        Array!MemoryRegion regions;
        regions.clear();
    
        auto maps = File("/proc/" ~ to!string(pid) ~ "/maps", "r");

        writeln(maps.byLine().map!split.map!(a => a.length).fold!(min, max));
    
        foreach(line; maps.byLine().map!split) {
            string memorySpace, permissions, offset, device, inode, pathname;
            memorySpace = line[0].dup;
            permissions = line[1].dup;
            offset = line[2].dup;
            device = line[3].dup;
            inode = line[4].dup;
            pathname = line[4].dup;

            MemoryRegion region;
    
            /*
            if (iss >> memorySpace >> permissions >> offset >> device >> inode) {
                std::string pathname;
    
                for (size_t ls = 0, i = 0; i < line.length(); i++) {
                    if (line.substr(i, 1).compare(" ") == 0) {
                        ls++;
    
                        if (ls == 5) {
                            size_t begin = line.substr(i, line.size()).find_first_not_of(' ');
    
                            if (begin != -1) {
                                pathname = line.substr(begin + i, line.size());
                            } else {
                                pathname.clear();
                            }
                        }
                    }
                }
    
                MapModuleMemoryRegion region;
    
                size_t memorySplit = memorySpace.find_first_of('-');
                size_t deviceSplit = device.find_first_of(':');
    
                std::stringstream ss;
    
                if (memorySplit != -1) {
                    ss << std::hex << memorySpace.substr(0, memorySplit);
                    ss >> region.start;
                    ss.clear();
                    ss << std::hex << memorySpace.substr(memorySplit + 1, memorySpace.size());
                    ss >> region.end;
                    ss.clear();
                }
    
                if (deviceSplit != -1) {
                    ss << std::hex << device.substr(0, deviceSplit);
                    ss >> region.deviceMajor;
                    ss.clear();
                    ss << std::hex << device.substr(deviceSplit + 1, device.size());
                    ss >> region.deviceMinor;
                    ss.clear();
                }
    
                ss << std::hex << offset;
                ss >> region.offset;
                ss.clear();
                ss << inode;
                ss >> region.inodeFileNumber;
    
                region.readable = (permissions[0] == 'r');
                region.writable = (permissions[1] == 'w');
                region.executable = (permissions[2] == 'x');
                region.shared = (permissions[3] != '-');
    
                if (!pathname.empty()) {
                    region.pathname = pathname;
    
                    size_t fileNameSplit = pathname.find_last_of('/');
    
                    if (fileNameSplit != -1) {
                        region.filename = pathname.substr(fileNameSplit + 1, pathname.size());
                    }
                }
    
                regions.push_back(region);
            }
            */
        }
    }
}
