@echo off
cd /d "%~dp0"
set REPO=https://github.com/mharris-clarkson/Math-Visualizations.git
set BRANCH=main

rem First time on this computer: connect the folder to GitHub (files untouched)
if not exist ".git" (
    git init -b %BRANCH% || goto :err
    git remote add origin %REPO% || goto :err
    echo Connected this folder to GitHub.
)

rem Catch up with the last push from either computer (files untouched)
git fetch origin || goto :err
git reset -q origin/%BRANCH% || goto :err
echo.
echo Ready. Now review, commit and push in GitHub Desktop.
goto :end
:err
echo.
echo Something went wrong - your files were not changed. Read the message above.
:end
pause