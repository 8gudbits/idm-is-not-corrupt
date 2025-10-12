'───────────────────────────────────────────────────────
'  Internet Download Manager Is Not Corrupt — Watchdog
'───────────────────────────────────────────────────────
Option Explicit

'───────────────[ Constants ]───────────────
Const WINDOW_TITLE   = "IDM is corrupt"
Const IDM_PROCESS    = "IDMan.exe"
Const IDM_ARGS       = "/onboot"
Const DEFAULT_PATH   = "C:\Program Files (x86)\Internet Download Manager\IDMan.exe"
Const CONFIG_FILE    = "idman-path.txt"
Const POLL_INTERVAL  = 3000 ' milliseconds
Const WINDOW_STATE   = 0 ' Hidden window

'───────────────[ Objects ]───────────────
Dim shell, wmi, fso
Set shell = CreateObject("WScript.Shell")
Set wmi   = GetObject("winmgmts:")
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

'───────────────[ Monitoring Loop ]───────────────
Do
    Dim proc, p
    Set proc = wmi.ExecQuery("Select * from Win32_Process")

    For Each p In proc
        If InStr(1, p.CommandLine, WINDOW_TITLE, vbTextCompare) > 0 Then
            Dim killCmd, launchCmd
            killCmd   = "cmd /c taskkill /f /im " & IDM_PROCESS
            launchCmd = """" & idmanPath & """ " & IDM_ARGS

            shell.Run killCmd, WINDOW_STATE, True
            shell.Run launchCmd, WINDOW_STATE, False
            Exit For
        End If
    Next

    WScript.Sleep POLL_INTERVAL
Loop

