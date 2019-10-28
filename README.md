# Welcome to the Simple UFS Weather App

Let's start with a disclaimer.

## Disclaimer

This is unofficial, unsupported, untested and undocumented UFS Weather App.
For official, supported, tested and documented UFS Weather App look elsewhere.
For example [here](https://github.com/ufs-community/ufs-mrweather-app).

By cloning, forking or downloading anything from this repository I assume you know what you are doing.

## What is in this repository

The purpose of this repository is to store my personal scripts I use to build UFS 
Weather model in a simple and portable way. Emphasis is on providing faily simple
building of all dependencies and model itself on a workstation type of computer
(desktop/laptop) using GNU compilers.

That's all. 

## Quick start

#### Build

Run:

```shell
./get.sh
```

to download preprocessor, model, post processor and all dependencies.

Run:

```shell
./build.sh <gnu|intel>
```

to build (almost) everything.

This build script expects compilers (C, C++ and Fortran) and MPI library to be
installed and available. Some basic development tools are also required,
like standard unix tools, git, gmake, cmake, python2.7, perl. Either install
required packages using you distribution package manger (yum/dnf, apt, apk, etc.),
or load appropriate modules (if you are on a system that uses
[environment modules](https://modules.readthedocs.io)).

There's also an option to build MPI library [[MPICH](https://www.mpich.org/)(v3.3.1)
and [OpenMPI](https://www.open-mpi.org/)(v4.0.2)] locally, run
`libs/mpilibs/build.sh` script, and update your `PATH` to point to locally
built library (for example `libs/mpilibs/local/mpich3/bin`).


####  Test your build

1. Clone the repository containing pre-generated input data for global
C96 configuration. Initial date: 2016-10-03 00Z

```shell
git clone https://github.com/DusanJovic-NOAA/ufs-test-data
```

2. Run the model executable on 8 tasks:

```shell
cd ufs-test-data
mpiexec -np 8 <path>/simple-ufs/bin/ufs_model`
```

This will run global C96 grid configuration. If the run is successful
you'll find a number of output files named `dynf???.nc` (dynamics variables)
and `phyf???.nc` (physics variables) in the run directory.

###### *** Good luck! ***
