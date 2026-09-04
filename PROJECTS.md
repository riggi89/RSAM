# RSAM projects

All project documentation is intentionally kept in the repository root. Source project folders contain code and project files only.

## RSAM.App

WinUI 3 host and presentation layer.

- `Composition/Navigation` – shell/navigation identifiers and future module registration.
- `Presentation/Controls` – reusable WinUI controls such as `SettingsRow`.
- `Presentation/Views` – `ShellPage`, `ManagerPage`, `SettingsPage` and `ChangelogPage`.
- `Presentation/ViewModels` – WinUI-specific view models.
- `Resources/Styles` – shared shell colors and styles.
- `MainWindow.xaml` – window chrome and custom TitleBar. It hosts `ShellPage` below the TitleBar.

`RSAM.App` references `RSAM.Core` only. Native Steam interop stays behind the Core layer.

## RSAM.Core

Application/domain layer independent of WinUI.

- `Infrastructure/SteamSchema` – Valve KeyValue/schema parsing retained from the SAM-derived implementation.
- `Interfaces` – contracts shared with the application shell.
- `Localization` – German/English localization service and JSON resources.
- `Models` – game, achievement and persisted settings models.
- `Search` – reusable global-search provider implementations.
- `Services` – game catalog and Steam achievement/stat orchestration.
- `Stats` – statistics domain definitions and editable stat model.
- `Storage` – JSON settings persistence.

`RSAM.Core` references `RSAM.API`; it does not reference WinUI.

## RSAM.API

Native x86/x64 Steam client bridge used by RSAM. This layer is derived from Steam Achievement Manager by Rick (Gibbed); it loads the Steam client module that matches the RSAM worker architecture.

- `Callbacks` – Steam callback payload handling.
- `Client` – Steam client bootstrap and initialization failures.
- `Common` – common callback/native string helpers.
- `Interfaces` – marshalled native Steam interface tables.
- `Native` – vtable wrapper infrastructure.
- `Properties` – reserved for project-specific metadata/source-generation configuration.
- `Types` – Steam callback/result/value types.
- `Wrappers` – managed wrappers around native Steam interfaces.

See `LICENSE.md` and `NOTICE.md` in the repository root for attribution and licensing details.

## Presentation folders

`RSAM.App/Presentation/Views` contains the central `ShellPage` and cached content pages. `RSAM.App/Presentation/Shell` contains the contracts/models used by pages to contribute toolbar actions, search context, back navigation and status text. `RSAM.App/Presentation/ViewModels` remains reserved for future WinUI-specific view models; domain models stay in `RSAM.Core/Models`.

## RSAM 1.0.23 state/localization notes

- `RSAM.Core` owns the full `AppSettings` schema and German/English localization dictionaries.
- `RSAM.App` restores and persists window placement, shell state and global-search context state. Page and selected-game detail state are not restored.
- Public Core services keep Steam IPC out of the WinUI process. Hidden one-operation workers initialize the native Steam client with the required App ID and return serialized catalog/stat data.
- The selected Tile/List/Table game-library layout is stored in settings schema version 7 without restoring a previously selected game page.
- All favorite game App IDs are stored in the independent `%LOCALAPPDATA%\RSAM\favorites.json` file and shared by all three game-library views.
- `SettingsPage` can open `%LOCALAPPDATA%\RSAM\settings.json` directly through the default Windows JSON/text editor.
- `ChangelogPage` renders the English root `CHANGELOG.md` as its single embedded source; Changelog content is intentionally excluded from localization resources.
- `DialogService` owns and serializes all WinUI `ContentDialog` display, including confirmation and three-choice reset dialogs.
- `ShellPage` refreshes the Steam process status every three seconds and renders it in the lower-left status bar without blocking the UI thread.
- Source headers distinguish original RSAM code from files copied or substantially derived from Rick's Steam Achievement Manager.
- The NavigationView pane spans the complete shell area above the status bar; the page toolbar belongs only to its content column.
- Catalog and game-data loading messages always reach the status bar; the global InfoBar is used only for refreshes explicitly started with Reload buttons.
- Build and displayed versions use the three-part `1.x.x` format.
- `LICENSE.md` in the repository root is the single shipped project license; `RSAM.API` no longer carries a duplicate license or the unused `Pink.ico` asset.
- The solution and PowerShell scripts build/publish x86 and x64, the Inno Setup definition combines both into one unsigned per-user installer, and the GitHub workflow publishes release assets for version tags.
- The TableView game-library mode is display-only; all column manipulation is disabled and one row click opens the selected game's Achievements tab.
- Installer publishing validates the complete WinUI/.NET runtime payload and startup failures are recorded in `%LOCALAPPDATA%\RSAM\Logs\startup.log` before the shell is created.
- `set-version.ps1` synchronizes the three-part source version, displayed-version fallback and the required four-part Windows manifest version; release notes remain a deliberate manual update.
- README screenshots are stored under `docs/images` and cover the Tile, List, TableView, favorites-only and Settings layouts.
- The application project generates `resources.pri` explicitly and copies it to unpackaged publish output; the publish script also recovers `RSAM.pri` from architecture-specific intermediate output when required.
