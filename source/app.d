import std.conv;
import std.stdio;
import std.process;
import std.string;
import offsets;

ulong pidof(string name)
{
    auto pipes = pipeProcess(["pidof", name], Redirect.stdout);
    scope(exit) wait(pipes.pid);

    // Only return first match
    ulong pid = to!long(pipes.stdout.readln.split("\n")[0].split(" ")[0]);
    return pid;
}

void main()
{
    auto offsets = new Offsets("data/csgo.json");
    writeln(pidof("pidof"));
}
