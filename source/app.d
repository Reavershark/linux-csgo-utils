import std.stdio;
import memory;
import netvars;

import std.string : fromStringz;
import std.conv : to;

MemoryRegion searchFileMap(string targetFilename, Handle handle)
{
    MemoryRegion targetRegion;
    foreach(region; handle.getRegions())
    {
        if (region.filename == targetFilename)
        {
            targetRegion = region;
            break;
        }
    }
    return targetRegion;
}

void main()
{
    int pid = pidof("csgo_linux64");
    Handle handle = new Handle(pid);

    MemoryRegion client = searchFileMap("client_panorama_client.so", handle);
    MemoryRegion engine = searchFileMap("engine_client.so", handle);
    
    write("client: 0x");
    writefln!("%x")(client.start);
    write("engine: 0x");
    writefln!("%x")(engine.start);

    ulong clientStateCode = client.find(handle,
            "\x44\x89\xEA\xB8\x01\x00\x00\x00\x44\x89\xE9\xC1\xFA\x05\xD3\xE0\x48\x63\xD2\x41\x09\x04\x91\x48\x8B\x05\x00\x00\x00\x00\x8B\x53\x14\x48\x8B\x00\x48\x85\xC0\x75\x1B\xE9",
            "xxxxxxxxxxxxxxxxxxxxxxxxxx????xxxxxxxxxxxx");

    ulong clientStateAddress = handle.GetAbsoluteAddress(cast(void*) (clientStateCode + 23), 3, 7);

    // Follow 2 pointers
    handle.read(cast(void*) clientStateAddress, &clientStateAddress, (void*).sizeof);
    handle.read(cast(void*) clientStateAddress, &clientStateAddress, (void*).sizeof);
    write("clientStateAddress : 0x");
    writefln!("%x")(clientStateAddress);

    ClientClass currentClass = handle.read!ClientClass(clientStateAddress);
    //writeln(fromStringz(handle.read!(char[256])(cast(ulong)currentClass.m_pNetworkName).ptr));

    while(currentClass.m_pNext) {
        if(!currentClass.m_pNetworkName)
            break;

        char[256] networkNamez;
        networkNamez = handle.read!(char[256])(cast(ulong)currentClass.m_pNetworkName);
        string networkName = to!string(fromStringz(networkNamez.ptr));
        writeln(networkName, " (", currentClass.m_ClassID, "):");

        RecvTable table = handle.read!RecvTable(cast(ulong)currentClass.m_pRecvTable);
        writeln("Count: ", table.m_nProps);

        char[256] tableNamez;
        tableNamez = handle.read!(char[256])(cast(ulong)table.m_pNetTableName);
        string tableName = to!string(fromStringz(tableNamez.ptr));
        writeln("Table: ", tableName);

        writeln("Props: ", handle.read!RecvProp(cast(ulong)table.m_pProps).m_nElements);
        writeln();

        currentClass = handle.read!ClientClass(cast(ulong)currentClass.m_pNext);
    }
}
