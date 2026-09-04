; RSAM installer definition.
; Copyright (c) 2026 Daniel Riggi (riggi89).
; Distributed under the project license; see LICENSE.md and NOTICE.md.

#define MyAppVersion GetEnv("RSAM_VERSION")
#define SourceRoot GetEnv("RSAM_SOURCE_ROOT")
#define InstallerLicense GetEnv("RSAM_INSTALLER_LICENSE")
#define MyAppArchitecture GetEnv("RSAM_ARCHITECTURE")

#if MyAppArchitecture == "x64"
    #define RuntimeIdentifier "win-x64"
    #define AllowedArchitectures "x64compatible"
#elif MyAppArchitecture == "x86"
    #define RuntimeIdentifier "win-x86"
    #define AllowedArchitectures "x86compatible"
#else
    #error Unsupported or missing RSAM_ARCHITECTURE value
#endif

[Setup]
AppId={{F99429D7-C0F7-43A8-9368-407534934825}
AppName=RSAM
AppVersion={#MyAppVersion}
AppVerName=RSAM {#MyAppVersion}
AppPublisher=Daniel Riggi (riggi89)
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany=Daniel Riggi (riggi89)
VersionInfoDescription=RSAM {#MyAppArchitecture} Installer
VersionInfoProductName=RSAM - Riggi's Steam Achievement Manager

SetupIconFile={#SourceRoot}\src\RSAM.App\Assets\RSAM-AppIcon.ico
UninstallDisplayIcon={app}\RSAM.exe

DefaultDirName={localappdata}\Programs\RSAM
DefaultGroupName=RSAM
DisableProgramGroupPage=yes
PrivilegesRequired=lowest

ArchitecturesAllowed={#AllowedArchitectures}

#if MyAppArchitecture == "x64"
ArchitecturesInstallIn64BitMode=x64compatible
#endif

MinVersion=10.0.17763
LicenseFile={#InstallerLicense}

OutputDir={#SourceRoot}\artifacts\installer
OutputBaseFilename=RSAM_{#MyAppVersion}-{#RuntimeIdentifier}-Setup

Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern dynamic

CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; \
    Description: "{cm:CreateDesktopIcon}"; \
    GroupDescription: "{cm:AdditionalIcons}"; \
    Flags: unchecked

[Files]
Source: "{#SourceRoot}\artifacts\publish\{#RuntimeIdentifier}\*"; \
    DestDir: "{app}"; \
    Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\RSAM"; \
    Filename: "{app}\RSAM.exe"; \
    WorkingDir: "{app}"

Name: "{autodesktop}\RSAM"; \
    Filename: "{app}\RSAM.exe"; \
    WorkingDir: "{app}"; \
    Tasks: desktopicon

[Run]
Filename: "{app}\RSAM.exe"; \
    WorkingDir: "{app}"; \
    Description: "{cm:LaunchProgram,RSAM}"; \
    Flags: nowait postinstall skipifsilent