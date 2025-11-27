# Sibelius-MusicXML-AutoExporter
An AutoHotkey v2 automation tool for batch-exporting hundreds or thousands of Sibelius `.sib` files into **uncompressed MusicXML (.musicxml)** format — fully automatically, without manual clicking.

This tool is designed for:
- Music AI dataset preparation  
- Harmony analysis datasets  
- Music college research labs  
- Large-scale Sibelius project conversion  
- Anyone who needs massive `.sib → .musicxml` conversion

---

## ✨ Features

- Recursively scans folders for **all `.sib` files**
- Exports **uncompressed (.musicxml)** format automatically
- Launches Sibelius and navigates the export panel
- Automatically clicks:
  - *Uncompressed MusicXML* button  
  - *Export* button  
- Automatically enters the output path  
- Automatically presses *Enter* to save  
- Creates per-file `output/` folder for exported XML
- Displays realtime GUI:
  - Current file
  - Success / Failed / Skipped
  - Log messages
  - Progress bar

---

## 🖥 Requirements

- **Windows 10 / 11**
- **AutoHotkey v2**  
  Download: https://www.autohotkey.com/
- **Sibelius Ultimate**
- 1080p screen resolution (different resolutions require re-calibration)

---

## 📦 Installation

### 1. Install AutoHotkey v2
Download and install from official website.

### 2. Clone this repository

```bash
git clone https://github.com/yourname/SibeliusXMLBatchExporter.git

| Key    | Action             |
| ------ | ------------------ |
| **F1** | Start batch export |
| **F2** | Pause              |
| **F3** | Resume             |
| **F4** | Stop               |



Important Notes

1. Run script as Administrator

Otherwise Windows UAC will block Sibelius actions.

2. Do not use your mouse during export

The tool uses mouse automation—any accidental movement breaks the workflow.

3. Use fixed screen resolution

1080p recommended.

4. Sibelius theme/zoom/layout differences

If your UI differs, you must recalibrate click coordinates.


