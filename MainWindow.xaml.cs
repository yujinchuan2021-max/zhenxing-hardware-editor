using Microsoft.UI;
using Microsoft.UI.Windowing;
using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;
using Windows.Graphics;

namespace TubaWinUi3;

public sealed partial class MainWindow : Window
{
    public MainWindow()
    {
        InitializeComponent();
        // The standalone title bar already identifies the editor.
        if (EditorPage.FindName("PageHeader") is FrameworkElement pageHeader)
            pageHeader.Visibility = Visibility.Collapsed;
        var handle = WinRT.Interop.WindowNative.GetWindowHandle(this);
        var window = AppWindow.GetFromWindowId(Win32Interop.GetWindowIdFromWindow(handle));
        window.Resize(new SizeInt32(1120, 900));
        window.SetIcon(Path.Combine(AppContext.BaseDirectory, "Assets", "AppIcon.ico"));
    }

    private void ThemePicker_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (RootGrid is null || sender is not ComboBox picker) return;
        RootGrid.RequestedTheme = picker.SelectedIndex switch
        {
            1 => ElementTheme.Light,
            2 => ElementTheme.Dark,
            _ => ElementTheme.Default
        };
    }
}
