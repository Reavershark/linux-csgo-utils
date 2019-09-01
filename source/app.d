import std.stdio;
import std.container.array;
import offsets;
import memory;

void main()
{
    auto offsets = new Offsets("data/csgo.json");

    int pid = pidof("vim");
    Handle handle = new Handle(pid);

    //foreach(region; handle.getRegions())
    //{
    //    writeln(region.pathname);
    //}
}
