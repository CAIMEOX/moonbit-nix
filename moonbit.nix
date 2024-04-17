{ stdenv, pkgs, fetchurl, fetchzip, lib }:
let cli = "https://cli.moonbitlang.com";
in stdenv.mkDerivation {
  pname = "moonbit";
  version = "0.1.0.20240415";
  src = fetchzip {
    url = "${cli}/core.zip";
    hash = "sha256-ky5VD5gAuU9IOTOKRx3pLodg0zRqCmIq90Q5rvYCgIQ=";
  };
  srcs = [
    (fetchurl {
      url = "${cli}/ubuntu_x86/moon";
      hash = "sha256-8k92he/PEWXA3/lMQ84yH4wYCX93uFiYnjfcy7fGhwQ=";
    })
    (fetchurl {
      url = "${cli}/ubuntu_x86/moonc";
      hash = "sha256-r8S6GVfz4w6mhNbKW2sjcIZ1+Vhsxs/0pNV6QwRHcYk=";
    })
    (fetchurl {
      url = "${cli}/ubuntu_x86/moonfmt";
      hash = "sha256-pPj5cuzRqZVDDRVqeUh6cBZJW1JIGRcwI/+TqxRrUdc=";
    })
    (fetchurl {
      url = "${cli}/ubuntu_x86/moonrun";
      hash = "sha256-U4QgJ9osFPK8zqqAP9CidgQ+FHqyBSv/i7zm7mlVxQ8=";
    })
    (fetchurl {
      url = "${cli}/ubuntu_x86/moondoc";
      hash = "sha256-Ey+X+Cz9pBC9/e1vDIAl9H69tivve5Bui3fU164rWb0=";
    })
    (fetchurl {
      url = "${cli}/ubuntu_x86/mooninfo";
      hash = "sha256-BBT3Lx7kIYnn9WjwT5sSt2BrRiLKpimj/wSXt1z5xhE=";
    })
  ];
  preFixup = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/*'';
  doCheck = false;
  sourceRoot = ".";
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/lib
    cp -r $src $out/lib/core
    mkdir -p $out/bin
    read -ra bins <<< "$srcs"
    moonbins=(moon moonc moonfmt moonrun moondoc mooninfo)
    for i in {0..5}; do
      install -m755 -D ''${bins[$i]} $out/bin/''${moonbins[$i]}
    done
  '';
  meta = with lib; {
    homepage = "https://www.moonbitlang.com";
    name = "moonbit";
    description =
      "Intelligent developer platform for Cloud and Edge using WASM";
    platforms = platforms.linux;
    maintainers = [ "CAIMEO" ];
  };
}
