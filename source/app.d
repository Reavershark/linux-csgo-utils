import std.stdio;
import memory;
import netvars;

import std.string : fromStringz;
import std.conv : to;

void main()
{
    int pid = pidof("csgo_linux64");
    Maps maps = new Maps(pid);
    Handle handle = new Handle(pid);

    MemoryRegion client = maps.getFileMap("client_panorama_client.so");
    MemoryRegion engine = maps.getFileMap("engine_client.so");
    
    write("client: 0x");
    writefln!("%x")(client.start);
    write("engine: 0x");
    writefln!("%x")(engine.start);

    ulong clientStateCode = handle.find(client,
            "\x44\x89\xEA\xB8\x01\x00\x00\x00\x44\x89\xE9\xC1\xFA\x05\xD3\xE0\x48\x63\xD2\x41\x09\x04\x91\x48\x8B\x05\x00\x00\x00\x00\x8B\x53\x14\x48\x8B\x00\x48\x85\xC0\x75\x1B\xE9",
            "xxxxxxxxxxxxxxxxxxxxxxxxxx????xxxxxxxxxxxx");

    ulong clientStateAddress = handle.GetAbsoluteAddress(cast(void*) (clientStateCode + 23), 3, 7);

    // Follow 2 pointers
    handle.read(cast(void*) clientStateAddress, &clientStateAddress, (void*).sizeof);
    handle.read(cast(void*) clientStateAddress, &clientStateAddress, (void*).sizeof);
    write("clientStateAddress : 0x");
    writefln!("%x")(clientStateAddress);

    Netvars.dump(handle, clientStateAddress);
}
