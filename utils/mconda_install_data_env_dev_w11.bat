@echo off
setlocal

:: User variable download, install directories python version and base packages
set "DIR_DOWNLOAD=%userprofile%\Downloads\pgerhard"
set "VENV_PYTHON_VER=3.11"
set VENV_PKGS_CONDA=pandas seaborn matplotlib numpy
set VENV_PKGS_PIP=ydata-profiling black

:: Related installation variable
set "DIR_INSTALL=%DIR_DOWNLOAD%\Miniconda3"
set "MINICONDA_EXE=miniconda3-latest.exe"
set "VENV_NAME=venv-%VENV_PYTHON_VER%"

:: Create dirs
if not exist "%DIR_DOWNLOAD%" mkdir "%DIR_DOWNLOAD%"
cd /d "%DIR_DOWNLOAD%"

:: Download Miniconda
echo Downloading Miniconda installer...
curl -L -o "%MINICONDA_EXE%" "https://repo.continuum.io/miniconda/Miniconda3-latest-Windows-x86_64.exe"
if not exist "%DIR_INSTALL%" mkdir "%DIR_INSTALL%"

:: Install Miniconda in silent mode
echo Installing Miniconda to: %DIR_INSTALL%

if exist "%DIR_INSTALL%" (
    echo Removing existing directory "%DIR_INSTALL%"...
    rmdir /s /q "%DIR_INSTALL%"
)

start /wait "" "%MINICONDA_EXE%" ^
    /InstallationType=JustMe ^
    /RegisterPython=0 ^
    /AddToPath=1 ^
    /S ^
    /D=%DIR_INSTALL%

:: Add required Miniconda paths to current PATH
echo Adding Miniconda paths to current session...
set "CONDA_PATHS=%DIR_INSTALL%;%DIR_INSTALL%\Library\mingw-w64\bin;%DIR_INSTALL%\Library\usr\bin;%DIR_INSTALL%\Library\bin;%DIR_INSTALL%\Scripts"

for %%P in (%CONDA_PATHS%) do (
    echo %PATH% | findstr /I /C:"%%P;" >nul
    if errorlevel 1 (
        set "PATH=%%P;%PATH%"
    )
)

:: Check if conda is now available
echo Checking for 'conda'...
where conda >nul 2>&1
if %ERRORLEVEL%==0 (
    echo Conda is available!
) else (
    echo Conda not found. Try restarting the terminal manually.
    pause
    exit /b 1
)

:: Accept TOS for base channel
call conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main
call conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r
call conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/msys2

:: Create conda env with python desired python version
call conda create -y -p "%DIR_DOWNLOAD%\%VENV_NAME%" python="%VENV_PYTHON_VER%"

:: Activate conda env
call conda activate "%DIR_DOWNLOAD%\%VENV_NAME%"

:: Install packages
call conda install -y -c conda-forge python="%VENV_PYTHON_VER%" %VENV_PKGS_CONDA%
call pip install %VENV_PKGS_PIP%


:: Setup vscode settings to link Conda environment and black formatter
if not exist .vscode mkdir .vscode
set "PYTHON_PATH=%DIR_DOWNLOAD%\%VENV_NAME%\python.exe"
(
  echo {
  echo   "python.pythonPath": "%PYTHON_PATH%",
  echo   "python.formatting.provider": "black",
  echo   "editor.formatOnSave": true
  echo }
) > .vscode\settings.json

echo.
echo Environment created and packages installed successfully!
echo To activate the environment later, run:
echo     conda activate "%DIR_DOWNLOAD%\%VENV_NAME%"

:: Create working directory directory
set "GITHUB_DIR=%DIR_DOWNLOAD%\github"
if not exist "%GITHUB_DIR%" mkdir "%GITHUB_DIR%"
cd /d "%GITHUB_DIR%"

:: Download and apply custom VSCode keybindings
curl -L -o "%DIR_DOWNLOAD%\keybinds.json" ^
    "https://raw.githubusercontent.com/p-gerhard/data-boilerplates/refs/heads/main/vscode/keybinds.json"

:: Backup existing keybindings if backup does NOT already exist
if exist "%APPDATA%\Code\User\keybindings.json" (
    if not exist "%APPDATA%\Code\User\keybindings_backup.json" (
        echo Backing up existing keybindings...
        copy /Y "%APPDATA%\Code\User\keybindings.json" "%APPDATA%\Code\User\keybindings_backup.json"
    ) else (
        echo Backup already exists, skipping backup.
    )
)

:: Replace current VSCode keybindings
copy /Y "%DIR_DOWNLOAD%\keybinds.json" "%APPDATA%\Code\User\keybindings.json"

:: Download Python script into the GitHub directory
curl -L -o "%GITHUB_DIR%\eda_ydata_profiling.py" ^
    "https://raw.githubusercontent.com/p-gerhard/data-boilerplates/refs/heads/main/eda_ydata_profiling.py"

:: Open VSCode in this folder
code .

endlocal
pause
