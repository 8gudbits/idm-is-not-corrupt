'───────────────────────────────────────────────────────
'  Internet Download Manager Is Not Corrupt — Watchdog
'───────────────────────────────────────────────────────
Option Explicit

'───────────────[ Constants ]───────────────
Const VERSION        = "1.1.0"
Const IDM_PROCESS    = "IDMan.exe"
Const IDM_ARGS       = "/onboot /s"
Const DEFAULT_PATH   = "C:\Program Files (x86)\Internet Download Manager\IDMan.exe"
Const CONFIG_FILE    = "idman-path.txt"
Const LOG_FILE       = "idm-inc-watchdog.log"
Const POLL_INTERVAL  = 3000 ' milliseconds
Const WINDOW_STATE   = 0 ' 0 = hidden, 1 = normal, 2 = minimized, 3 = maximized

'───────────────[ Titles to Watch ]───────────────
Dim Titles
Titles = Array( _
    "IDM is corrupt", _
    "New version of Internet Download Manager is available", _
    "Internet Download Manager" _
)

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
    Dim matchedTitle, i
    matchedTitle = ""

    For i = LBound(Titles) To UBound(Titles)
        If CheckWindow(Titles(i)) Then
            matchedTitle = Titles(i)
            Exit For
        End If
    Next

    If matchedTitle <> "" Then
        KillAndRestartIDM matchedTitle
    End If

    WScript.Sleep POLL_INTERVAL
Loop

'───────────────[ Functions ]───────────────
Function CheckWindow(title)
    Dim tempFile, cmd, line, result
    tempFile = fso.GetSpecialFolder(2) & "\idmtasklist.csv"
    cmd = "cmd /c tasklist /FI ""WINDOWTITLE eq " & title & """ /FO CSV > """ & tempFile & """"
    shell.Run cmd, WINDOW_STATE, True

    result = False
    If fso.FileExists(tempFile) Then
        Dim reader
        Set reader = fso.OpenTextFile(tempFile, 1)
        Do Until reader.AtEndOfStream
            line = Trim(reader.ReadLine)
            ' Only count as a match if it's not header or INFO
            If Len(line) > 0 And InStr(line, "Image Name") = 0 And InStr(line, "INFO:") = 0 Then
                result = True
                Exit Do
            End If
        Loop
        reader.Close
        fso.DeleteFile tempFile
    End If
    CheckWindow = result
End Function

Sub KillAndRestartIDM(triggerTitle)
    Dim killCmd, launchCmd, logPath, logFile, timestamp
    killCmd   = "cmd /c taskkill /f /im " & IDM_PROCESS
    launchCmd = """" & idmanPath & """ " & IDM_ARGS
    shell.Run killCmd, WINDOW_STATE, True
    shell.Run launchCmd, WINDOW_STATE, False

    logPath = fso.GetAbsolutePathName(LOG_FILE)
    timestamp = Now
    Set logFile = fso.OpenTextFile(logPath, 8, True)
    logFile.WriteLine "[" & timestamp & "] Killed IDM popup window with title: " & triggerTitle
    logFile.Close
End Sub

