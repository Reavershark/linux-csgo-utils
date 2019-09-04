module address;

import memory;
import signatures;

class Addresses
{
    private Signatures signatures;
    private Maps maps;

    this(int pid)
    {
        signatures = new Signatures();
        maps = new Maps(pid);
    }

    ulong getClientState(Handle handle)
    {
        Signature sig = signatures.getSignature("clientState");
        MemoryRegion clientRegion = maps.getFileMap("client_panorama_client.so");

        ulong clientStateAddress = handle.find(clientRegion, sig);
        clientStateAddress = handle.GetAbsoluteAddress(cast(void*) (clientStateAddress + 23), 3, 7);
        
        // Follow 2 pointers
        clientStateAddress = handle.read!ulong(clientStateAddress);
        clientStateAddress = handle.read!ulong(clientStateAddress);
        return clientStateAddress;
    }

    ulong getLocalPlayerPtr(Handle handle)
    {
        Signature sig = signatures.getSignature("localPlayer");
        MemoryRegion clientRegion = maps.getFileMap("client_panorama_client.so");

        ulong localPlayer = handle.find(clientRegion, sig);
        localPlayer = handle.read!int(localPlayer + 1) + localPlayer + 5;

        return localPlayer;
    }
}
