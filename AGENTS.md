# 枕星配置修改器 development

This directory is the standalone WinUI 3 application, version 0.1.0. Build with
the .NET 10 SDK selected by `global.json`. The app is unpackaged and ships its
.NET and Windows App SDK runtimes in the portable directory.

Keep this repository independent from the full 枕星图吧AI助手. Its shared editor
sources retain the `TubaWinUi3` namespace for upstream attribution. Changes to
the model catalog must retain official manufacturer source links and the date
on which the list was verified. Model presets are display names, not a hardware
compatibility database.

Run the source-linked tests in `tests/ZhenxingHardwareEditor.Tests.csproj` for
service changes. They use synthetic devices and temporary configuration paths.
Do not launch the administrator application or change registry / device fields
as an implicit test. Use a temporary `ZXAI_DATA_ROOT` for any explicitly
authorized application test. Do not delete the user's backup or profile data.

Preserve `LICENSE` and `NOTICE`, the GPL-3.0 license, and the attribution to
枕星图吧AI助手 and TubaWinUi3. Do not commit generated output from `artifacts`,
`bin`, `obj`, or `TestResults`.
