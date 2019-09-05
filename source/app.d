import std.stdio;
import core.thread;

import netvars;
import address;
import memory;
import draw;
import hack;

import std.conv : to;

void main()
{
    int pid = pidof("csgo_linux64");
    Handle handle = new Handle(pid);
    Addresses addresses = new Addresses(pid);

    ulong clientState = 0;
    while (clientState == 0)
    {
        clientState = addresses.getClientState(handle);
        Thread.sleep(dur!("msecs")(1));
    }
    write("clientState: 0x");
    writefln!("%x")(clientState);

    //Netvars.dump(handle, clientState);

    ulong localPlayerPtr = addresses.getLocalPlayerPtr(handle);
    write("localPlayer: 0x");
    writefln!("%x")(localPlayerPtr);

    Draw draw = new Draw();
    new Thread({draw.init();}).start();

    while(!draw.initialized)
    {
        Thread.sleep(dur!("usecs")(1));
    }
    while(true)
    {
        ulong localPlayer = handle.read!ulong(localPlayerPtr);
        draw.start();
        if (localPlayer)
        {
            recoilCrossHair(handle, draw, localPlayer);
        }
        draw.end();
        Thread.sleep(dur!("nsecs")(1_000_000_000/60));
    }
    //draw.close();
}

