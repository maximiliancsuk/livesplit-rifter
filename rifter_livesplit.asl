state("Rifter")
{
}

startup
{
	print("startup");
	Action<string> DebugOutput = (text) => {
		print("[Rifter Autosplitter] "+text);
	};
	vars.DebugOutput = DebugOutput;

     vars.scanTarget = new SigScanTarget(0,
        "1F 2F 2F 4F 4F 4F",
        "00",
        "AF BF CF DF EF FF"
    );

	print("startup end");
}

init
{
	print("init");
    var ptr = IntPtr.Zero;

    foreach (var page in game.MemoryPages(true)) {
            var scanner = new SignatureScanner(game, page.BaseAddress, (int)page.RegionSize);

            if (ptr == IntPtr.Zero) {
                ptr = scanner.Scan(vars.scanTarget);
            } else {
                break;
            }
    }

    if (ptr == IntPtr.Zero) {
        // Waiting for the game to have booted up. This is a pretty ugly work
        // around, but we don't really know when the game is booted or where the
        // struct will be, so to reduce the amount of searching we are doing, we
        // sleep a bit between every attempt.
	    print("waiting");
        Thread.Sleep(1000);
        throw new Exception();
    }

    vars.data = new MemoryWatcher<byte>(ptr + 0x06);

    vars.watchers = new MemoryWatcherList() {
        vars.data
    };

	print("init end");
}

exit
{
}

update
{
    vars.watchers.UpdateAll(game);

    //print("Data: " + vars.data.Current.ToString());

}

start
{
    return vars.data.Current == 1 && vars.data.Old == 0;
}

split
{
    return vars.data.Current != vars.data.Old && vars.data.Old != 0;
}

isLoading
{
}
