{ lib, stdenv, fetchurl }:

let
  version = "0.39.1";

  # sha256 values from:
  # https://github.com/Infisical/agent-vault/releases/download/v${version}/checksums.txt
  platforms = {
    x86_64-linux = {
      os = "linux"; arch = "amd64";
      sha256 = "746b18407eec0cadd2c3da918a929c5b071e48536eb12588fa1803896d246991";
    };
    aarch64-linux = {
      os = "linux"; arch = "arm64";
      sha256 = "9f10237807aee914d87f229e7fc92b36814927b24bb8c2dcb3933f0502024712";
    };
    x86_64-darwin = {
      os = "darwin"; arch = "amd64";
      sha256 = "43f0517b931b079a2c5f3543d5824c30290efc42622a561a3c7894c2cb6ad7fe";
    };
    aarch64-darwin = {
      os = "darwin"; arch = "arm64";
      sha256 = "6cb8c758e915a1575221e04cd1610b06f7218500bd15d30f29565d1930826f44";
    };
  };

  plat = platforms.${stdenv.hostPlatform.system}
    or (throw "agent-vault: unsupported system ${stdenv.hostPlatform.system}");
in
stdenv.mkDerivation {
  pname = "agent-vault";
  inherit version;

  src = fetchurl {
    url = "https://github.com/Infisical/agent-vault/releases/download/v${version}/agent-vault_${version}_${plat.os}_${plat.arch}.tar.gz";
    sha256 = plat.sha256;
  };

  # The tarball has no wrapping directory (binary + LICENSE + README sit at
  # its root), so stdenv's directory-autodetecting unpackPhase has nothing
  # to cd into. Build in place instead.
  sourceRoot = ".";

  # Static, stripped Go binary — no patching/dynamic linking needed.
  installPhase = ''
    runHook preInstall
    install -Dm755 agent-vault $out/bin/agent-vault
    runHook postInstall
  '';

  meta = with lib; {
    description = "Local credential-broker proxy for AI coding agents (Infisical)";
    homepage = "https://github.com/Infisical/agent-vault";
    license = licenses.mit; # "MIT Expat" per upstream LICENSE
    platforms = builtins.attrNames platforms;
    mainProgram = "agent-vault";
  };
}
