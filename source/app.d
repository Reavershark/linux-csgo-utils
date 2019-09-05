import std.stdio;
import core.thread;

import netvars;
import address;
import memory;
import draw;

import std.conv : to;

void main()
{
    /*
    int pid = pidof("csgo_linux64");
    Handle handle = new Handle(pid);
    Addresses addresses = new Addresses(pid);

    ulong clientState = addresses.getClientState(handle);
    write("clientState: 0x");
    writefln!("%x")(clientState);

    //Netvars.dump(handle, clientState);

    ulong localPlayerPtr = addresses.getLocalPlayerPtr(handle);
    write("localPlayer: 0x");
    writefln!("%x")(localPlayerPtr);

    while (true)
    {
        ulong localPlayer = handle.read!ulong(localPlayerPtr);

        // Recoil angle
        ulong angleAddr = localPlayer + 0x3700 + 0x74;
	    QAngle angle = handle.read!QAngle(angleAddr);

        //handle.write(angleAddr, &angle, QAngle.sizeof);
        writeln("Pitch/Yaw: ", angle.x, " ", angle.y);

        Thread.sleep(dur!("msecs")(50));
    }
    */

    Draw draw = new Draw();
}

struct QAngle {
	float x; // Pitch
	float y; // Yaw
	float z; // Roll
}
