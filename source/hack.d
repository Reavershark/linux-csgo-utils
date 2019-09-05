module hack;

import memory;
import draw;

import std.stdio : writeln;
import std.conv : to;

struct QAngle {
	float x; // Pitch
	float y; // Yaw
	float z; // Roll
}

void recoilCrossHair(Handle handle, Draw draw, ulong localPlayer)
{
    ulong angleAddr = localPlayer + 0x3700 + 0x74;
    QAngle angle = handle.read!QAngle(angleAddr);
    //writeln("Pitch/Yaw: ", angle.x, " ", angle.y);
    
    draw.drawCrossHair(to!int(angle.y*20), to!int(angle.x*-20));
}
