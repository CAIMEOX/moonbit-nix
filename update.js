import axios from "axios";
import crypto from "crypto";
import { writeFileSync, rmSync } from "fs";

const fileList = {
  "core.zip": { url: "https://cli.moonbitlang.com/core.zip" },
  moon: { url: "https://cli.moonbitlang.com/ubuntu_x86/moon" },
  moonc: { url: "https://cli.moonbitlang.com/ubuntu_x86/moonc" },
  moonfmt: { url: "https://cli.moonbitlang.com/ubuntu_x86/moonfmt" },
  moonrun: { url: "https://cli.moonbitlang.com/ubuntu_x86/moonrun" },
  moondoc: { url: "https://cli.moonbitlang.com/ubuntu_x86/moondoc" },
  mooninfo: { url: "https://cli.moonbitlang.com/ubuntu_x86/mooninfo" },
};

async function getFiles() {
  for (const name in fileList) {
    const hash = crypto.createHash("sha256");
    const fileData = (await axios.get(fileList[name].url)).data;
    hash.update(fileData);
    fileList[name].hash = "sha256-" + hash.digest("hex");
    writeFileSync(name, fileData);
  }
}

function unwrapHash(name) {
  return fileList[name].hash;
}

function generateNixFile() {
  writeFileSync(
    `{ stdenv, fetchurl, fetchzip, lib }:
let cli = "https://cli.moonbitlang.com";
in stdenv.mkDerivation {
  pname = "moonbit";
  version = "0.1.0.20240415";
  src = fetchzip {
    url = "\${cli}/core.zip";
    hash = "${unwrapHash("core.zip")}";
  };
  srcs = [
    (fetchurl {
      url = "\${cli}/ubuntu_x86/moon";
      hash = "${unwrapHash("moon")}";
    })
    (fetchurl {
      url = "\${cli}/ubuntu_x86/moonc";
      hash = "${unwrapHash("moonc")}";
    })
    (fetchurl {
      url = "\${cli}/ubuntu_x86/moonfmt";
      hash = "${unwrapHash("moonfmt")}";
    })
    (fetchurl {
      url = "\${cli}/ubuntu_x86/moonrun";
      hash = "${unwrapHash("moonrun")}";
    })
    (fetchurl {
      url = "\${cli}/ubuntu_x86/moondoc";
      hash = "${unwrapHash("moondoc")}"
    })
    (fetchurl {
      url = "\${cli}/ubuntu_x86/mooninfo";
      hash = "${unwrapHash("mooninfo")}";
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
      install -m755 -D ''\${bins[$i]} $out/bin/''\${moonbins[$i]}
    done
  '';
  meta = with lib; {
    homepage = "https://www.moonbitlang.com";
    name = "moonbit";
    description =
      "Intelligent developer platform for Cloud and Edge using WASM";
    platforms = platforms.linux;
    maintainers = [ "CAIMEO", "Lampese" ];
  };
}
`
  );
}

function deleteCache() {
  for (const name in fileList) rmSync(name);
}

getFiles().then(generateNixFile).then(deleteCache);
