import std.stdio;
import offsets;
import memory;

void main()
{
    auto offsets = new Offsets("data/csgo.json");
    auto address = 0x020d0000 + offsets.getSignature("dwClientState") + offsets.getSignature("dwClientState_Map");

    int pid = pidof("vim");
    Handle handle = new Handle(pid);

    char[1024] buf;
    handle.read(cast(char*) 0x7fb890ea0f10, buf.ptr, 1024);
    writeln(buf);
}
