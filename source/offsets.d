module offsets;

import std.file : readText;
import std.datetime.systime: SysTime, unixTimeToStdTime;
import std.json;

class Offsets
{
private:
    JSONValue signatures;
    JSONValue netvars;
    ulong timestamp;

    JSONValue readOffsets(string path)
    {
        return parseJSON(readText(path));
    }

public:
    string getTimestamp()
    {
        auto time = SysTime(unixTimeToStdTime(timestamp));
        return time.toString();
    }

    ulong getSignature(string name)
    {
        return signatures[name].integer;
    }

    ulong getNetvar(string name)
    {
        return netvars[name].integer;
    }

    this(string path)
    {
        auto j = readOffsets(path);
        timestamp = j["timestamp"].integer;
        signatures = j["signatures"];
        netvars = j["netvars"];
    }
}
