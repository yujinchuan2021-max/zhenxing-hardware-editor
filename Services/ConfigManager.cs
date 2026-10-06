namespace TubaWinUi3.Services;

internal static class ConfigManager
{
    public static string GetDataDir()
    {
        var isolatedRoot = Environment.GetEnvironmentVariable("ZXAI_DATA_ROOT");
        var directory = string.IsNullOrWhiteSpace(isolatedRoot)
            ? Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "ZhenxingHardwareEditor")
            : Path.GetFullPath(isolatedRoot);
        Directory.CreateDirectory(directory);
        return directory;
    }
}
