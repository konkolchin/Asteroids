@echo off
echo ========================================
echo    Asteroids Game - GitHub Upload
echo ========================================
echo.

REM Check if git is installed
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git is not installed or not in PATH!
    echo Please install Git from: https://git-scm.com/download/win
    echo.
    pause
    exit /b 1
)

echo Git found! Proceeding with upload...
echo.

REM Configure git user (if not already configured)
echo Configuring git user...
git config user.name "konkolchin" 2>nul
git config user.email "konkolchin@users.noreply.github.com" 2>nul
echo.

REM Initialize git repository if not already initialized
if not exist ".git" (
    echo Initializing git repository...
    git init
    echo.
)

REM Add all files to staging
echo Adding files to git...
git add .
echo.

REM Check if there are changes to commit
git diff --cached --quiet
if %errorlevel% equ 0 (
    echo No changes to commit. Repository is up to date.
    echo.
) else (
    echo Committing changes...
    git commit -m "Initial commit: Asteroids game implementation"
    echo.
)

REM Check if we have any commits
git rev-parse --verify HEAD >nul 2>&1
if %errorlevel% neq 0 (
    echo No commits found. Creating initial commit...
    git commit -m "Initial commit: Asteroids game implementation"
    echo.
)

REM Set remote origin to the specified GitHub repository
echo Setting up remote repository...
git remote remove origin 2>nul
git remote add origin https://github.com/konkolchin/Asteroids.git
echo.

REM Push to GitHub
echo Pushing to GitHub...
git branch -M main

REM Try to push, if fails, create repository first
git push -u origin main 2>nul
if %errorlevel% neq 0 (
    echo.
    echo Repository might not exist yet. Please:
    echo 1. Go to https://github.com/new
    echo 2. Create repository named "Asteroids"
    echo 3. Make it private (optional)
    echo 4. DON'T initialize with README, .gitignore, or license
    echo 5. Run this script again
    echo.
    echo Or run: git push -u origin main
    echo.
) else (
    echo Push successful!
)

REM Check if push was successful
git ls-remote origin >nul 2>&1
if %errorlevel% equ 0 (
    echo.
    echo ========================================
    echo    SUCCESS! Game uploaded to GitHub
    echo ========================================
    echo.
    echo Repository URL: https://github.com/konkolchin/Asteroids
    echo.
    echo You can now:
    echo 1. Share the repository with friends
    echo 2. Create releases with compiled .exe files
    echo 3. Collaborate on the code
    echo.
) else (
    echo.
    echo ========================================
    echo    Repository setup complete!
    echo ========================================
    echo.
    echo Next steps:
    echo 1. Create repository on GitHub: https://github.com/new
    echo 2. Name it "Asteroids"
    echo 3. Make it private (optional)
    echo 4. DON'T initialize with README, .gitignore, or license
    echo 5. Run this script again or manually push:
    echo    git push -u origin main
    echo.
)

echo Press any key to exit...
pause >nul
