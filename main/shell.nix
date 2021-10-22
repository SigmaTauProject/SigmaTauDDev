{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
	
	buildInputs = [
		pkgs.dmd
		pkgs.dub
		pkgs.SDL2
	];
	
	LD_LIBRARY_PATH = "";
}