using Microsoft.UI.Xaml;
using Microsoft.UI.Xaml.Controls;

namespace TubaWinUi3.Controls;

public sealed partial class ToolPageHeader : UserControl
{
    public static readonly DependencyProperty TitleProperty = DependencyProperty.Register(
        nameof(Title), typeof(string), typeof(ToolPageHeader), new PropertyMetadata("", OnTextChanged));
    public static readonly DependencyProperty SubtitleProperty = DependencyProperty.Register(
        nameof(Subtitle), typeof(string), typeof(ToolPageHeader), new PropertyMetadata("", OnTextChanged));
    public static readonly DependencyProperty GlyphProperty = DependencyProperty.Register(
        nameof(Glyph), typeof(string), typeof(ToolPageHeader), new PropertyMetadata("", OnTextChanged));

    public string Title { get => (string)GetValue(TitleProperty); set => SetValue(TitleProperty, value); }
    public string Subtitle { get => (string)GetValue(SubtitleProperty); set => SetValue(SubtitleProperty, value); }
    public string Glyph { get => (string)GetValue(GlyphProperty); set => SetValue(GlyphProperty, value); }

    public ToolPageHeader()
    {
        InitializeComponent();
        UpdateText();
    }

    private static void OnTextChanged(DependencyObject sender, DependencyPropertyChangedEventArgs e) =>
        ((ToolPageHeader)sender).UpdateText();

    private void UpdateText()
    {
        if (HeaderTitle is null) return;
        HeaderTitle.Text = Title;
        HeaderSubtitle.Text = Subtitle;
        HeaderIcon.Glyph = Glyph;
    }
}
