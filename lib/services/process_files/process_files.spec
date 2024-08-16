# -*- mode: python ; coding: utf-8 -*-


a = Analysis(
    ['process_files.py'],
    pathex=[],
    binaries=[],
    datas=[('Tesseract-OCR/tesseract.exe', 'Tesseract-OCR'), ('Tesseract-OCR/tessdata', 'Tesseract-OCR/tessdata')],
    hiddenimports=[],
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    noarchive=False,
    optimize=0,
)
pyz = PYZ(a.pure)

exe = EXE(
    pyz,
    a.scripts,
    a.binaries,
    a.datas,
    [],
    name='process_files',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    upx_exclude=[],
    runtime_tmpdir=None,
    console=True,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
)
