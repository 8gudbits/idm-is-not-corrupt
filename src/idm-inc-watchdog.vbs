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
Const LOG_FILE       = "idm-inc-watchdog.log"
Const POLL_INTERVAL  = 3000 ' milliseconds
Const WINDOW_STATE   = 0 ' 0 = hidden, 1 = normal, 2 = minimized, 3 = maximized

'───────────────[ Initialize Objects ]───────────────
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

'───────────────[ Monitoring Loop ]───────────────
Do
    Dim tempFile, cmd, line, found
    tempFile = fso.GetSpecialFolder(2) & "\idmtasklist.csv"
    cmd = "cmd /c tasklist /FI ""WINDOWTITLE eq " & WINDOW_TITLE & """ /FO CSV > """ & tempFile & """"
    shell.Run cmd, WINDOW_STATE, True

    found = False
    If fso.FileExists(tempFile) Then
        Dim reader
        Set reader = fso.OpenTextFile(tempFile, 1)

        Do Until reader.AtEndOfStream
            line = Trim(reader.ReadLine)
            If InStr(line, IDM_PROCESS) > 0 Then
                found = True
                Exit Do
            End If
        Loop
        reader.Close
        fso.DeleteFile tempFile
    End If

    If found Then
        Dim killCmd, launchCmd
        killCmd   = "cmd /c taskkill /f /im " & IDM_PROCESS
        launchCmd = """" & idmanPath & """ " & IDM_ARGS

        shell.Run killCmd, WINDOW_STATE, True
        shell.Run launchCmd, WINDOW_STATE, False

        '───────────────[ Log Event ]───────────────
        Dim logPath, logFile, timestamp
        logPath = fso.GetAbsolutePathName(LOG_FILE)
        timestamp = Now
        Set logFile = fso.OpenTextFile(logPath, 8, True)
        logFile.WriteLine "[" & timestamp & "] Killed IDM is corrupt window."
        logFile.Close
    End If

    WScript.Sleep POLL_INTERVAL
Loop

