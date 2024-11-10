[Setup]
AppName=Stratix Launcher
AppPublisher=Stratix
UninstallDisplayName=Stratix
AppVersion=${project.version}
AppSupportURL=https://stratix.me/
DefaultDirName={localappdata}\Stratix

; ~30 mb for the repo the launcher downloads
ExtraDiskSpaceRequired=30000000
ArchitecturesAllowed=x86 x64
PrivilegesRequired=lowest

WizardSmallImageFile=${basedir}/innosetup/app_small.bmp
WizardImageFile=${basedir}/innosetup/left.bmp
SetupIconFile=${basedir}/innosetup/app.ico
UninstallDisplayIcon={app}\Stratix.exe

Compression=lzma2
SolidCompression=yes

OutputDir=${basedir}
OutputBaseFilename=StratixSetup32

[Tasks]
Name: DesktopIcon; Description: "Create a &desktop icon";

[Files]
Source: "${basedir}\build\win-x86\Stratix.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "${basedir}\build\win-x86\Stratix.jar"; DestDir: "{app}"
Source: "${basedir}\build\win-x86\launcher_x86.dll"; DestDir: "{app}"; Flags: ignoreversion
Source: "${basedir}\build\win-x86\config.json"; DestDir: "{app}"
Source: "${basedir}\build\win-x86\jre\*"; DestDir: "{app}\jre"; Flags: recursesubdirs

[Icons]
; start menu
Name: "{userprograms}\Stratix\Stratix"; Filename: "{app}\Stratix.exe"
Name: "{userprograms}\Stratix\Stratix (configure)"; Filename: "{app}\Stratix.exe"; Parameters: "--configure"
Name: "{userprograms}\Stratix\Stratix (safe mode)"; Filename: "{app}\Stratix.exe"; Parameters: "--safe-mode"
Name: "{userdesktop}\Stratix"; Filename: "{app}\Stratix.exe"; Tasks: DesktopIcon

[Run]
Filename: "{app}\Stratix.exe"; Parameters: "--postinstall"; Flags: nowait
Filename: "{app}\Stratix.exe"; Description: "&Open Stratix"; Flags: postinstall skipifsilent nowait

[InstallDelete]
; Delete the old jvm so it doesn't try to load old stuff with the new vm and crash
Type: filesandordirs; Name: "{app}\jre"
; previous shortcut
Type: files; Name: "{userprograms}\Stratix.lnk"

[UninstallDelete]
Type: filesandordirs; Name: "{%USERPROFILE}\.stratix\repository2"
; includes install_id, settings, etc
Type: filesandordirs; Name: "{app}"

[Code]
#include "upgrade.pas"
#include "usernamecheck.pas"
#include "dircheck.pas"