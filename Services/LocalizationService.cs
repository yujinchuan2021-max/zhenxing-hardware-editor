using System.Globalization;

namespace TubaWinUi3.Services;

internal static class LocalizationService
{
    public const string EnglishLanguage = "en-US";
    public static string CurrentLanguage { get; } = CultureInfo.CurrentUICulture.Name.StartsWith("en", StringComparison.OrdinalIgnoreCase)
        ? EnglishLanguage
        : "zh-CN";
}
