# Compilation, Distribution, and Installation

This guide reflects the current state of how to compile, distribute, and install
the KDE-based traits used in the x-ray root crown analysis pipeline. These traits
were also implemented by Ni Jiang in Python2 (later ported to Python3),
but due to performance limitations imposed by third-party libraries, the
original MATLAB implementation are included here as a standalone tool that
is integrated as a dependency for the rootCrownImageAnalysis3D module as part
of the unnamed pipeline Python package.

## Compilation

A MATLAB compilation project file is included in this repo—`kde_traits.prj`.
In order to compile the project, open it with the MATLAB Compiler app. Details
can be found in the official docs [here](https://www.mathworks.com/help/compiler/).

For compilation, the default settings were used for everything except for the
type of installation. CentOS 8 does not currently support a network-based
installation, so the MATLAB runtime must be included during packaging.

## Distribution

Because the MATLAB runtime is included, the installer is quite large (~1 GB).
Therefore, I decided to store the installer on the Topp lab's alloted space on
the cluster at the Center. Make sure to compress the files into a single
archive file. I recommend using bzip2 format and upload it to `stargate.datasci.danforthcenter.org:/shares/ctopp_share/data/repos/kde_traits.tar.bz`—overwrite
as needed.

## Installation

Follow the provided commands below to install the application. The MATLAB
installer expects a graphical desktop environment. If not, you may need to
run the installer with additional flags. Check the official documentation for
guidance.

```bash
# RUN AS ROOT FOR SYSTEM-WIDE INSTALL
# Download package from the Center's Data Science infrastructure and extract
rsync -rvuP --stats stargate.datasci.danforthcenter.org:/shares/ctopp_share/data/repos/kde_traits.tar.bz2 . && \
tar -jxvf kde_traits.tar.bz2 && \
./kde_traits/for_redistribution/standalone_installer.install

# There is a known issue with (re)loading the libmwcoder_types.so file
# This is the workaround. It causes the system's instance to be used instead.
mkdir -pv /usr/local/MATLAB/MATLAB_Runtime/v94/bin/glnxa64/exclude
mv -v /usr/local/MATLAB/MATLAB_Runtime/v94/bin/glnxa64/libmwcoder_types.so /usr/local/MATLAB/MATLAB_Runtime/v94/bin/glnxa64/exclude

# Set up environment and execution script
printf 'export MR="/usr/local/MATLAB/MATLAB_Runtime/v94"' > /etc/profile.d/kde-traits.sh
printf '#!/usr/bin/env bash\n/usr/local/kde_traits/application/run_kde_traits.sh "$MR" "${@:1}"' > "/usr/local/kde_traits/application/kde-traits.sh"
chmod +x "/usr/local/kde_traits/application/kde-traits.sh"
ln -sv /usr/local/kde_traits/application/kde-traits.sh /usr/local/bin/kde-traits
```

## Usage

Once installed, you will either need to relogin or load set the `MR` environment
variable with the `/etc/profile.d/kde-traits.sh` file. If you choose the latter,
include `source /etc/profile.d/kde-traits.sh` before running the application.

### Example application execution

```bash
# Example call
# kde-traits /path/to/folder/containing/binary/images/ <slice_thickness> <sampling>
kde-traits /data/threshold_images/10000_1_109um 0.109 2
```
