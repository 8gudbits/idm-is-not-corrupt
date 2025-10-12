'──────────────────────────────────────────────────────────
'  Internet Download Manager Is Not Corrupt — For Taskbar
'──────────────────────────────────────────────────────────
Option Explicit

'───────────────[ Constants ]───────────────
Const IDM_PROCESS    = "IDMan.exe"
Const IDM_ARGS       = "/onboot"
Const DEFAULT_PATH   = "C:\Program Files (x86)\Internet Download Manager\IDMan.exe"
Const CONFIG_FILE    = "idman-path.txt"
Const WINDOW_STATE   = 0 ' Hidden window

'───────────────[ Objects ]───────────────
Dim shell, fso
Set shell = CreateObject("WScript.Shell")
Set fso   = CreateObject("Scripting.FileSystemObject")

'───────────────[ Resolve Executable Path ]───────────────
Dim configPath, idmanPath, file
configPath = fso.GetAbsolutePathName(CONFIG_FILE)

If Not fso.FileExists(configPath) Then
    Set file = fso.CreateTextFile(configPath, True)
    file.WriteLine DEFAULT_PATH
    file.Close
End If

Set file = fso.OpenTextFile(configPath, 1)
idmanPath = Trim(file.ReadLine)
file.Close

'───────────────[ Kill Existing Process ]───────────────
Dim killCmd
killCmd = "cmd /c taskkill /f /im " & IDM_PROCESS
shell.Run killCmd, WINDOW_STATE, True

'───────────────[ Relaunch IDM Silently ]───────────────
Dim launchCmd
launchCmd = """" & idmanPath & """ " & IDM_ARGS
shell.Run launchCmd, WINDOW_STATE, False

