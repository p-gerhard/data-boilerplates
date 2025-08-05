@echo off
cd /d "%~dp0"
call venv\Scripts\activate.bat

echo.
echo Virtual environment activated.
echo ----------------------------------------
echo To install packages from requirements.txt:
echo     pip install -r requirements.txt
echo.
echo To run a Python script:
echo     python your_script.py
echo ----------------------------------------
echo.

cmd
