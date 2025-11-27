#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode 2

; ====== 鼠标坐标（你确认过）======
uncompressedX := 1118   ; 未压缩按钮
uncompressedY := 385
exportBtnX := 960        ; 导出按钮（一次点击）
exportBtnY := 664

; ====== 路径配置 ======
baseDir := "C:\Users\Drift king\Desktop\四部和声"
sibExe := "C:\Program Files\Avid\Sibelius\Sibelius.exe"
maxRetry := 3
logFile := A_ScriptDir "\sib_export_log.txt"

; ====== 状态变量 ======
global totalFiles := 0
global successCount := 0
global failCount := 0
global skipCount := 0
global isPaused := false
global isStopped := false

; ====== GUI ======
myGui := Gui("+AlwaysOnTop", "SIB 批量 MusicXML 导出器")
myGui.Add("Text",, "当前文件：")
txtFile := myGui.Add("Text", "w400")
progress := myGui.Add("Progress", "w400 h20 Range0-100")
txtStat := myGui.Add("Text", "w400", "成功：0 | 失败：0 | 跳过：0")
txtLast := myGui.Add("Text", "w400 cBlue", "最新日志：等待开始…")
myGui.Show()

; ====== 日志函数 ======
WriteLog(text) {
    global logFile, txtLast
    timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
    FileAppend(timestamp "  " text "`n", logFile, "UTF-8")
    txtLast.Value := "最新日志：" text
}

UpdateStat() {
    global txtStat, successCount, failCount, skipCount
    txtStat.Value := "成功：" successCount " | 失败：" failCount " | 跳过：" skipCount
}

CountSibFiles(path) {
    count := 0
    Loop Files path "\*", "FD" {
        if (A_LoopFileAttrib ~= "D")
            count += CountSibFiles(A_LoopFileFullPath)
        else if (A_LoopFileExt = "sib")
            count++
    }
    return count
}

; ====== 批处理控制 ======
StartBatch() {
    global successCount, failCount, skipCount, totalFiles, isPaused, isStopped, baseDir

    MsgBox "开始批量导出"

    successCount := 0
    failCount := 0
    skipCount := 0
    isPaused := false
    isStopped := false

    totalFiles := CountSibFiles(baseDir)
    progress.Value := 0

    WriteLog("==== 批处理开始 ====")
    ExportFolder(baseDir)
    WriteLog("==== 批处理结束 ====")

    MsgBox "完成！成功：" successCount " 失败：" failCount " 跳过：" skipCount
}

PauseBatch() {
    global isPaused
    isPaused := true
    MsgBox "已暂停（按 F3 继续）"
}

ResumeBatch() {
    global isPaused
    isPaused := false
    MsgBox "继续执行"
}

StopBatch() {
    global isStopped
    isStopped := true
    MsgBox "脚本已停止"
}

; ====== 遍历文件夹 ======
ExportFolder(path) {
    global isPaused, isStopped

    Loop Files path "\*", "FD" {
        if (isStopped)
            ExitApp()

        while (isPaused)
            Sleep 200

        if (A_LoopFileAttrib ~= "D") {
            ExportFolder(A_LoopFileFullPath)
            continue
        }

        if (A_LoopFileExt = "sib") {
            ProcessSibFile(A_LoopFileFullPath)
        }
    }
}

; ====== 处理单个 .sib 文件 ======
ProcessSibFile(fullPath) {
    global successCount, failCount, skipCount, totalFiles, maxRetry, progress, txtFile

    SplitPath fullPath, &fileName, &dir

    txtFile.Value := fileName
    progress.Value := Floor((successCount + failCount + skipCount) * 100 / totalFiles)

    outputDir := dir "\output"
    DirCreate(outputDir)

    ; 自动使用运行目录，不手动输入文件名
    if FileExist(outputDir "\" StrReplace(fileName, ".sib", ".musicxml")) {
        skipCount++
        WriteLog("[跳过] 已存在：" fileName)
        UpdateStat()
        return
    }

    Loop maxRetry {
        attempt := A_Index
        WriteLog("[开始] " fileName "（尝试 " attempt "）")

        if (TryConvert(fullPath)) {
            successCount++
            WriteLog("[成功] " fileName)
            UpdateStat()
            return
        }

        WriteLog("[失败] " fileName "（尝试 " attempt "）")
    }

    failCount++
    WriteLog("[放弃] " fileName)
    UpdateStat()
}

; ====== 核心：导出一首 Sib 文件 ======
TryConvert(fullPath) {
    global sibExe, uncompressedX, uncompressedY, exportBtnX, exportBtnY

    ; 启动 Sibelius
    Run '"' sibExe '" "' fullPath '"'
    if !WinWait("Sibelius",, 10)
        return false

    Sleep 3500  ; ★★★ 按你要求：等待 3.5 秒

    ; 打开 MusicXML 导出面板
    Send "^!m"
    Sleep 1500

    ; 选未压缩
    MouseMove uncompressedX, uncompressedY, 0
    Sleep 100
    Click
    Sleep 300

    ; 点击导出按钮（一次）
    MouseMove exportBtnX, exportBtnY, 0
    Sleep 200
    Click
    Sleep 1500

    ; 等保存窗口
    if !WinWaitActive("ahk_class #32770",, 5)
        return false

    ; ★★★ 不输入文件名，直接保存
    Sleep 300
    Send "{Enter}"
    Sleep 2500

    ; ★★★ 不再按 “否(N)”（你要求的）
    ; Sibelius 若询问保存更改，让系统自动处理

    ; 强制关闭 Sibelius，不会报错
    ProcessClose("Sibelius.exe")
    Sleep 500

    return true
}

; ====== 快捷键 ======
F1::StartBatch()
F2::PauseBatch()
F3::ResumeBatch()
F4::StopBatch()
