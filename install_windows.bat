@echo off

set rootdir=%cd%
set logdir=%rootdir%\install_log

if not exist %logdir% (
    mkdir %logdir%
)

set config=%1
if [%config%]==[] set config=Release

rem prepare 64-bit build toolset
if not defined INCLUDE (
    call "%ProgramFiles(x86)%\Microsoft Visual Studio 12.0\VC\vcvarsall.bat" amd64
    
    if errorlevel 1 (
    echo.
    echo Could not prepare Visual Studio compiler - do you have Visual Studio 2013 installed?
    exit /b 1
    )
)

echo Downloading GUI and dependencies...

if not exist asiosdk (
    echo.
    echo Downloading ASIO...
    echo.
    PowerShell -ExecutionPolicy RemoteSigned -File download_asio.ps1
    
    if errorlevel 1 (
        echo Error downloading ASIO
        exit /b 1
    )
    
    echo Make sure to install ASIO4ALL to use ASIO.
)

rem for ICA
echo.
echo Checking for installed Eigen3...
reg query HKCU\Software\Kitware\CMake\Packages\Eigen3

if errorlevel 1 (
    echo.
    echo Downloading and installing Eigen...
    echo.

    git clone https://github.com/eigenteam/eigen-git-mirror
    cd eigen-git-mirror
    git checkout 3.3.7
    mkdir Build
    cd Build
    cmake ..
    cd %rootdir%
)

rem                 Name                    Organization        Repository          Branch
rem --------------------------------------------------------------------------------------------------------
call :download_repo "Open Ephys GUI"        tne-lab             plugin-GUI          low-latency || exit /b 1
call :download_repo "ZeroMQ plugins"        open-ephys-plugins  ZMQPlugins          master      || exit /b 1
call :download_repo "HDF5 plugins"          open-ephys-plugins  HDF5Plugins         master      || exit /b 1
call :download_repo "OpenEphysFFTW library" tne-lab             OpenEphysFFTW       cmake-gui   || exit /b 1
call :download_repo "Phase Calculator"      tne-lab             phase-calculator    cmake-gui   || exit /b 1
call :download_repo "Crossing Detector"     tne-lab             crossing-detector   cmake-gui   || exit /b 1
call :download_repo "Sample Math"           tne-lab             sample-math         cmake-gui   || exit /b 1
call :download_repo "Mean Spike Rate"       tne-lab             mean-spike-rate     cmake-gui   || exit /b 1
call :download_repo "ICA"                   tne-lab             ica-plugin          cmake-gui   || exit /b 1


echo Building GUI and dependencies...

rem              Name                       Folder containing CMakeLists.txt    Solution name               Project name
rem --------------------------------------------------------------------------------------------------------------------------------
call :build_repo "Open Ephys GUI"           plugin-GUI                          open-ephys-GUI              ALL_BUILD   || exit /b 1
call :build_repo "ZeroMQ plugins"           ZMQPlugins                          OE_ZMQ                      INSTALL     || exit /b 1
call :build_repo "HDF5 plugins"             HDF5Plugins                         OE_HDF5                     INSTALL     || exit /b 1
call :build_repo "OpenEphysFFTW library"    OpenEphysFFTW\OpenEphysFFTW         OE_COMMONLIB_OpenEphysFFTW  INSTALL     || exit /b 1
call :build_repo "Phase Calculator"         phase-calculator\PhaseCalculator    OE_PLUGIN_PhaseCalculator   INSTALL     || exit /b 1
call :build_repo "Crossing Detector"        crossing-detector\CrossingDetector  OE_PLUGIN_CrossingDetector  INSTALL     || exit /b 1
call :build_repo "Sample Math"              sample-math\SampleMath              OE_PLUGIN_SampleMath        INSTALL     || exit /b 1
call :build_repo "Mean Spike Rate"          mean-spike-rate\MeanSpikeRate       OE_PLUGIN_MeanSpikeRate     INSTALL     || exit /b 1
call :build_repo "ICA"                      ica-plugin\ICA                      OE_PLUGIN_ICA               INSTALL     || exit /b 1

rem make links to the executable
PowerShell -ExecutionPolicy RemoteSigned "$s=(New-Object -COM WScript.Shell).CreateShortcut('%rootdir%\open-ephys (%config%).lnk');$s.TargetPath='%rootdir%\plugin-GUI\Build\%config%\open-ephys.exe';$s.Save()"
PowerShell -ExecutionPolicy RemoteSigned "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Desktop\open-ephys (%config%).lnk');$s.TargetPath='%rootdir%\plugin-GUI\Build\%config%\open-ephys.exe';$s.Save()"

exit /b 0

:download_repo
if not exist %~3 (
    echo.
    echo Downloading %~1...
    echo.
    
    git clone https://github.com/%~2/%~3
    
    if errorlevel 1 (
        echo Error downloading %~1
        exit /b 1
    )
)

cd %~3
git checkout %~4
git pull

cd %rootdir%
exit /b 0


:build_repo
cd %rootdir%\%~2\Build
cmake -G "Visual Studio 12 2013" -A x64 ..
if errorlevel 1 (
    cd %rootdir%
    echo CMake failed to configure %~1
    exit /b 1

set logfile=%~3_build.log
if exist %logdir%\%logfile% del %logdir%\%logfile%
echo.
echo Building %~1...
echo.
devenv %~3.sln /build %config% /project %~4 /out %logdir%\%logfile%
if errorlevel 1 (
    cd %rootdir%
    echo Build failed, see install_log/%logfile%
    exit /b 1
)

cd %rootdir%
exit /b 0