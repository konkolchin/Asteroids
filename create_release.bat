@echo off
echo ========================================
echo    Asteroids Game - Create Release
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

REM Check if Visual Studio is available
if not exist "x64\Release\GameTemplate.exe" (
    echo ERROR: GameTemplate.exe not found!
    echo Please build the project in Visual Studio first:
    echo 1. Open GameTemplate.sln in Visual Studio
    echo 2. Select Release configuration
    echo 3. Build the solution (Ctrl+Shift+B)
    echo.
    pause
    exit /b 1
)

echo Found compiled game! Creating release package...
echo.

REM Create release directory
if exist "Release" rmdir /s /q "Release"
mkdir "Release"

REM Copy executable and required files
echo Copying game files...
copy "x64\Release\GameTemplate.exe" "Release\"
if exist "x64\Release\GameTemplate.pdb" copy "x64\Release\GameTemplate.pdb" "Release\"
copy "README.md" "Release\"

REM Create a simple run script
echo @echo off > "Release\Run_Asteroids.bat"
echo echo Starting Asteroids Game... >> "Release\Run_Asteroids.bat"
echo GameTemplate.exe >> "Release\Run_Asteroids.bat"
echo pause >> "Release\Run_Asteroids.bat"

echo.
echo ========================================
echo    Release Package Created!
echo ========================================
echo.
echo Files in Release folder:
dir "Release" /b
echo.
echo To create a GitHub Release:
echo 1. Go to: https://github.com/konkolchin/Asteroids/releases
echo 2. Click "Create a new release"
echo 3. Tag version: v1.0.0
echo 4. Release title: Asteroids Game v1.0.0
echo 5. Upload Release folder as zip file
echo.
echo Or use GitHub CLI (if installed):
echo gh release create v1.0.0 "Release\*" --title "Asteroids Game v1.0.0" --notes "Classic Asteroids game implementation"
echo.

REM Ask if user wants to create zip
set /p create_zip="Create ZIP file for easy sharing? (y/n): "
if /i "%create_zip%"=="y" (
    echo Creating ZIP file...
    powershell -command "Compress-Archive -Path 'Release\*' -DestinationPath 'Asteroids-Game-v1.0.0.zip' -Force"
    if %errorlevel% equ 0 (
        echo ZIP file created: Asteroids-Game-v1.0.0.zip
    ) else (
        echo Failed to create ZIP file. Please create manually.
    )
)

echo.
echo Press any key to exit...
pause >nul
