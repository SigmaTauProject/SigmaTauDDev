{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
	
	buildInputs = [
		pkgs.glfw
		pkgs.vulkan-loader
		pkgs.vulkan-tools
		pkgs.vulkan-loader.dev
		pkgs.vulkan-tools
		pkgs.dmd
		pkgs.dub
		pkgs.openssl
	];
	
	LD_LIBRARY_PATH = "${pkgs.glfw}/lib;${pkgs.vulkan-loader}/lib;${pkgs.vulkan-tools}/lib";
	
}