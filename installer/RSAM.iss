; RSAM original installer definition.
; Copyright (c) 2026 Daniel Riggi (riggi89).
; Distributed under the project license; see LICENSE.md and NOTICE.md.

#define MyAppVersion GetEnv("RSAM_VERSION")
#define SourceRoot GetEnv("RSAM_SOURCE_ROOT")
#define InstallerLicense GetEnv("RSAM_INSTALLER_LICENSE")

[Setup]
AppId={{F99429D7-C0F7-43A8-9368-407534934825}
AppName=RSAM
AppVersion={#MyAppVersion}
AppVerName=RSAM {#MyAppVersion}
AppPublisher=Daniel Riggi (riggi89)
VersionInfoVersion={#MyAppVersion}
VersionInfoCompany=Daniel Riggi (riggi89)
VersionInfoDescription=RSAM Installer
VersionInfoProductName=RSAM - Riggi's Steam Achievement Manager
DefaultDirName={localappdata}\Programs\RSAM
DefaultGroupName=RSAM
DisableProgramGroupPage=yes
PrivilegesRequired=lowest
ArchitecturesAllowed=x86compatible
ArchitecturesInstallIn64BitMode=x64compatible
MinVersion=10.0.17763
LicenseFile={#InstallerLicense}
OutputDir={#SourceRoot}\artifacts\installer
OutputBaseFilename=RSAM_{#MyAppVersion}-Setup
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern dynamic
UninstallDisplayIcon={app}\RSAM.exe
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "german"; MessagesFile: "compiler:Languages\German.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceRoot}\artifacts\publish\win-x64\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Check: IsWin64
Source: "{#SourceRoot}\artifacts\publish\win-x86\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Check: not IsWin64

[Icons]
Name: "{autoprograms}\RSAM"; Filename: "{app}\RSAM.exe"; WorkingDir: "{app}"
Name: "{autodesktop}\RSAM"; Filename: "{app}\RSAM.exe"; WorkingDir: "{app}"; Tasks: desktopicon

[Run]
Filename: "{app}\RSAM.exe"; WorkingDir: "{app}"; Description: "{cm:LaunchProgram,RSAM}"; Flags: nowait postinstall skipifsilent
