{ stdenv, pkgs, fetchurl, fetchgit, lib }:
let cli = "https://cli.moonbitlang.com";
in stdenv.mkDerivation {
  pname = "moonbit";
  version = "0.1.0";
  src = fetchgit {
    url = "https://github.com/moonbitlang/core";
    hash = "sha256-KFhRRLHw12UlRemr+zWoHFw/qfusP1OUXnGj8ApKYac=";
  };
  srcs = [
    (fetchurl {
      url = "${cli}/ubuntu_x86/moon";
      name = "moon";
      hash = "sha256-8k92he/PEWXA3/lMQ84yH4wYCX93uFiYnjfcy7fGhwQ=";
    })
    (fetchurl {
      url = "${cli}/ubuntu_x86/moonc";
      name = "moonc";
      hash = "sha256-r8S6GVfz4w6mhNbKW2sjcIZ1+Vhsxs/0pNV6QwRHcYk=";
    })
    (fetchurl {
      url = "${cli}/ubuntu_x86/moonfmt";
      name = "moonfmt";
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
  buildInputs = [ pkgs.gcc stdenv.cc pkgs.glibc ];
  preFixup = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" $out/bin/*'';
  doCheck = false;
  sourceRoot = ".";
  dontUnpack = true;
  installPhase = ''
    cat env-vars
    runHook preInstall
    mkdir -p $out/lib
    mkdir -p $out/bin
    read -ra array <<< "$srcs"
    cp -r ''${src} $out/lib/core
    install -m755 -D ''${array[0]} $out/bin/moon
    install -m755 -D ''${array[1]} $out/bin/moonc
    install -m755 -D ''${array[2]} $out/bin/moonfmt
    install -m755 -D ''${array[3]} $out/bin/moonrun
    install -m755 -D ''${array[4]} $out/bin/moondoc
    install -m755 -D ''${array[5]} $out/bin/mooninfo
    runHook postInstall
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
