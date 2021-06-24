@echo off

set rootdir=%cd%
set logdir=%rootdir%\install_log

if not exist %logdir% (
    mkdir %logdir%
)

set config=%1
if [%config%]==[] set config=Release

rem make sure we have 64-bit build toolset
if not defined VisualStudioVersion (
    echo MSVC variables not defined - make sure to run from "x64 Native Tools Command Prompt"
    exit /b 1
)

rem get version number and year
for /f "tokens=1 delims=." %%a in ("%VisualStudioVersion%") do set vsver=%%a
if "%vsver%"=="12" set vsyear=2013
if "%vsver%"=="15" set vsyear=2017
if "%vsver%"=="16" set vsyear=2019

if not defined vsyear (
    echo Error: Visual Studio version %vsver% not supported
    exit /b 1
)

echo Using Visual Studio %vsyear% (%VisualStudioVersion%)
echo.
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

if not exist plugins (
    mkdir plugins
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
call :download_repo_plugin_folder "OpenEphysHDF5Lib"        open-ephys-plugins  OpenEphysHDF5Lib          master      || exit /b 1
call :download_repo_plugin_folder "Network Events"        open-ephys-plugins  NetworkEvents          master      || exit /b 1
call :download_repo_plugin_folder "Event Broadcaster"        open-ephys-plugins  EventBroadcaster          master      || exit /b 1
call :download_repo_plugin_folder "KWIK Format"        open-ephys-plugins  KWIKFormat          master      || exit /b 1
call :download_repo "OpenEphysFFTW library" tne-lab             OpenEphysFFTW       cmake-gui   || exit /b 1
call :download_repo "Phase Calculator"      tne-lab             phase-calculator    cmake-gui   || exit /b 1
call :download_repo "Crossing Detector"     tne-lab             crossing-detector   master      || exit /b 1
call :download_repo "Sample Math"           tne-lab             sample-math         cmake-gui   || exit /b 1
call :download_repo "Mean Spike Rate"       tne-lab             mean-spike-rate     cmake-gui   || exit /b 1
call :download_repo "ICA"                   tne-lab             ica-plugin          cmake-gui   || exit /b 1
call :download_repo "Coherence"             tne-lab             Coherence-Spectrogram-Viewer    master      || exit /b 1
if defined CONDA_HOME (
    call :download_repo "PythonPlugin"      tne-lab             PythonPlugin        cmake_build || exit /b 1          
)

echo Building GUI and dependencies...

rem              Name                       Folder containing CMakeLists.txt    Solution name               Project name
rem --------------------------------------------------------------------------------------------------------------------------------
call :build_repo "Open Ephys GUI"           plugin-GUI                          open-ephys-GUI              ALL_BUILD   || exit /b 1
call :build_repo_plugin_repo "OpenEphysHDF5Lib"        OpenEphysHDF5Lib        OE_COMMONLIB_OpenEphysHDF5    INSTALL  || exit /b 1
call :build_repo_plugin_repo "Network Events"        NetworkEvents          OE_PLUGIN_NetworkEvents    INSTALL  || exit /b 1
call :build_repo_plugin_repo "Event Broadcaster"        EventBroadcaster          OE_PLUGIN_EventBroadcaster   INSTALL    || exit /b 1
call :build_repo_plugin_repo "KWIK Format"        KWIKFormat          OE_PLUGIN_KWIKFormat    INSTALL  || exit /b 1
call :build_repo "OpenEphysFFTW library"    OpenEphysFFTW\OpenEphysFFTW         OE_COMMONLIB_OpenEphysFFTW  INSTALL     || exit /b 1
call :build_repo "Phase Calculator"         phase-calculator\PhaseCalculator    OE_PLUGIN_PhaseCalculator   INSTALL     || exit /b 1
call :build_repo "Crossing Detector"        crossing-detector\CrossingDetector  OE_PLUGIN_CrossingDetector  INSTALL     || exit /b 1
call :build_repo "Sample Math"              sample-math\SampleMath              OE_PLUGIN_SampleMath        INSTALL     || exit /b 1
call :build_repo "Mean Spike Rate"          mean-spike-rate\MeanSpikeRate       OE_PLUGIN_MeanSpikeRate     INSTALL     || exit /b 1
call :build_repo "ICA"                      ica-plugin\ICA                      OE_PLUGIN_ICA               INSTALL     || exit /b 1
call :build_repo "Coherence"                Coherence-Spectrogram-Viewer\CoherenceSpectrogramViewer    OE_PLUGIN_CoherenceSpectrogramViewer   INSTALL     || exit /b 1

rem make links to the executable
PowerShell -ExecutionPolicy RemoteSigned "$s=(New-Object -COM WScript.Shell).CreateShortcut('%rootdir%\open-ephys (%config%).lnk');$s.TargetPath='%rootdir%\plugin-GUI\Build\%config%\open-ephys.exe';$s.Save()"
PowerShell -ExecutionPolicy RemoteSigned "$s=(New-Object -COM WScript.Shell).CreateShortcut('%userprofile%\Desktop\open-ephys (%config%).lnk');$s.TargetPath='%rootdir%\plugin-GUI\Build\%config%\open-ephys.exe';$s.Save()"

if defined CONDA_HOME (
    echo PythonPlugin can not be auto built in Windows. Follow instructions at https://github.com/tne-lab/PythonPlugin/tree/cmake_build to build in Windows.
)

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

:download_repo_plugin_folder
cd plugins
if not exist %~3 (
    echo.
    echo Downloading %~1...
    echo.
    echo %~2
    echo %~3
    
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
cmake -G "Visual Studio %vsver% %vsyear%" -A x64 ..
if errorlevel 1 (
    cd %rootdir%
    echo CMake failed to configure %~1
    exit /b 1
)
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

:build_repo_plugin_repo
cd %rootdir%\plugins\%~2\Build
cmake -G "Visual Studio %vsver% %vsyear%" -A x64 ..
if errorlevel 1 (
    cd %rootdir%
    echo CMake failed to configure %~1
    exit /b 1
)
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