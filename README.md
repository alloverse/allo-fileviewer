# allo-fileviewer

A basic pdf- and image viewer for use within an Alloverse Place. Drag & drop files from your desktop to the App to view them inside Alloverse.

# Develop and run

## Linux

1. `apt install libcairo2 cmake luajit llvm`
2. `git submodule update --init --recursive`
3. `./allo/assist run alloplace://nevyn.places.alloverse.com`

## Mac

Run in `arch -x86_64` mode on Apple Silicon

1. `brew install cairo poppler`
2. `git submodule update --init --recursive`
3. `./allo/assist run alloplace://nevyn.places.alloverse.com`

#Docker

Run without extra params connects to nevyns place

`docker run -it allo-whiteboard`

Run with allo url to connect to specific place

`docker run -it allo-whiteboard alloplace://nevyn.places.alloverse.com`
