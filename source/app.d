import std.stdio;
import std.container.array;
import offsets;
import memory;

void main()
{
    auto offsets = new Offsets("data/csgo.json");

    int pid = pidof("csgo_linux64");
    Handle handle = new Handle(pid);

    MemoryRegion clientRegion;
    foreach(region; handle.getRegions())
    {
        if (region.filename == "client_panorama_client.so")
        {
            clientRegion = region;
            break;
        }
    }
    writeln(clientRegion);
}
