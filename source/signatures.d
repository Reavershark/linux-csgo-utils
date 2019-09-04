module signatures;

struct Signature
{
    string data;
    string pattern;
    ulong sigOffset = 0;
}

class Signatures
{
    Signature[string] signatures;

    this()
    {
        populate();
    }

    Signature getSignature(string name)
    {
        return signatures[name];
    }

    private void populate()
    {
        signatures["clientState"] = Signature(
                "\x44\x89\xEA\xB8\x01\x00\x00\x00\x44\x89\xE9\xC1\xFA\x05\xD3\xE0\x48\x63\xD2\x41\x09\x04\x91\x48\x8B\x05\x00\x00\x00\x00\x8B\x53\x14\x48\x8B\x00\x48\x85\xC0\x75\x1B\xE9",
                "xxxxxxxxxxxxxxxxxxxxxxxxxx????xxxxxxxxxxxx",
                0);
        signatures["localPlayer"] = Signature(
                "\x48\x89\xe5\x74\x0e\x48\x8d\x05\x00\x00\x00\x00",
                "xxxxxxxx????",
                7);
    }
}
