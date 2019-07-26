#!/bin/sh

if [ "$(id -u)" -eq 0 ]; then
    echo "Error: should not be run as root"
    exit 1
fi

# authenticate now, if necessary
sudo whoami > /dev/null

# determine build configuration
config=$1
if [ ! "$config" ]; then
    config=Release
fi

rootdir=$(pwd)
logdir=$rootdir/install_log

if [ ! -d "$logdir" ]; then
    mkdir "$logdir"
fi

echo Downloading GUI and dependencies...


download_repo() {
    if [ ! -d "$3" ]; then
	echo
	echo Downloading "$1"...
	echo
	
	if ! git clone https://github.com/"$2"/"$3"; then
	    echo Error downloading "$1"
	    exit 1
	fi
    fi

    cd "$3" || exit 1
    git checkout "$4"
    git pull
    cd "$rootdir" || exit 1
}

#	      Name			Organization		Repository		Branch
# -------------------------------------------------------------------------------------------------
download_repo "Open Ephys GUI" 		tne-lab 		plugin-GUI		low-latency
download_repo "ZeroMQ plugins" 		open-ephys-plugins 	ZMQPlugins		master
download_repo "HDF5 plugins" 		open-ephys-plugins 	HDF5Plugins		master
download_repo "OpenEphysFFTW library"	tne-lab			OpenEphysFFTW		cmake-gui
download_repo "Phase Calculator"	tne-lab			phase-calculator	cmake-gui
download_repo "Crossing Detector"	tne-lab			crossing-detector	cmake-gui
download_repo "Sample Math"		tne-lab			sample-math		cmake-gui
download_repo "Mean Spike Rate"		tne-lab			mean-spike-rate		cmake-gui
download_repo "ICA"			tne-lab			ica-plugin		cmake-gui


echo Installing GUI dependencies...

sudo plugin-GUI/Resources/Scripts/install_linux_dependencies.sh || exit 1
sudo cp -u plugin-GUI/Resources/Scripts/40-open-ephys.rules /etc/udev/rules.d || exit 1
sudo udevadm control --reload-rules || exit 1

# check if we need to install zeromq
if ! dpkg-query -W libzmq3-dev > /dev/null 2>&1; then
    echo Installing ZeroMQ...
    sudo add-apt-repository -y ppa:chris-lea/zeromq
    sudo apt-get update
    sudo apt-get -y install libzmq3-dbg libzmq3-dev libzmq3
fi

# check if we need to install HDF5
if [ ! -d /usr/local/hdf5 ]; then
    echo Installing HDF5...
    wget -qO hdf5.tar.gz https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.20/src/hdf5-1.8.20.tar.gz || exit 1
    tar xzf hdf5.tar.gz || exit 1

    cd hdf5-1.8.20 || exit 1
    ./configure --prefix=/usr/local/hdf5 --enable-cxx || exit 1
    make && make check || exit 1
    sudo make install && sudo make check-install || exit 1

    cd "$rootdir" || exit 1
fi

echo Building GUI and dependencies...

build_repo() {
    
    cd "$rootdir"/"$2"/Build || exit 1

    if ! cmake -G "Unix Makefiles" -DCMAKE_BUILD_TYPE="$config" ..; then
	echo CMake failed to configure "$1"
	cd "$rootdir" || exit 1
	exit 1
    fi

    repo_name=$(echo "$2" | grep -o '^[^/]*')
    logfile="$repo_name"_build.log
    echo
    echo Building "$1"...
    echo
    if ! make > "$logdir"/"$logfile" 2>&1; then
	echo Building "$1" failed, see install_log/"$logfile"
	cd "$rootdir" || exit 1
	exit 1
    fi

    cd "$rootdir" || exit 1
}

install_repo() {
    build_repo "$1" "$2"

    cd "$rootdir"/"$2"/Build || exit 1

    if ! make install; then
	echo Installing "$1" failed
	cd "$rootdir" || exit 1
	exit 1
    fi

    cd "$rootdir" || exit 1
}

#          Name				Folder containing CMakeLists.txt
# ----------------------------------------------------------------------
build_repo   "Open Ephys GUI"		plugin-GUI
install_repo "ZeroMQ plugins"		ZMQPlugins
# skip HDF5 plugins for now - broken on Ubuntu 18 at least
#install_repo "HDF5 plugins"		HDF5Plugins
install_repo "OpenEphysFFTW library"	OpenEphysFFTW/OpenEphysFFTW
install_repo "Phase Calculator"		phase-calculator/PhaseCalculator
install_repo "Crossing Detector"		crossing-detector/CrossingDetector
install_repo "Sample Math"		sample-math/SampleMath
install_repo "Mean Spike Rate"		mean-spike-rate/MeanSpikeRate
install_repo "ICA"			ica-plugin/ICA

echo Making links...

ln -s plugin-GUI/Build/"$config"/open-ephys "open-ephys ($config)" || exit 1
ln -s plugin-GUI/Build/"$config"/open-ephys "$HOME/Desktop/open-ephys ($config)" || exit 1
