{ lib, stdenv, buildNpmPackage, fetchurl, nodejs_22, jq, autoPatchelfHook }:

# Cloudflare's unified CLI (technical preview). Not in nixpkgs yet; packaged
# from the prebuilt npm tarball.
#
# To bump the version:
#   1. Update `version` and `src.hash` (the tarball's `dist.integrity` from
#      https://registry.npmjs.org/cf/<version>).
#   2. Regenerate package-lock.json from the tarball's package.json with
#      devDependencies and scripts removed (as postPatch does):
#        jq 'del(.devDependencies, .scripts)' package/package.json > package.json
#        npm install --package-lock-only --ignore-scripts
#   3. Set npmDepsHash to lib.fakeHash, build, and copy the hash from the error.
buildNpmPackage (finalAttrs: {
  pname = "cf";
  version = "1.0.0-beta.18";
  nodejs = nodejs_22;

  src = fetchurl {
    url = "https://registry.npmjs.org/cf/-/cf-${finalAttrs.version}.tgz";
    hash = "sha512-SG9NqB6xEZf/WZm6+E2v0OIY5JA0b9DUgl1VOOlF0D5Y+Nk5PyhHonJOd6K2/g6f261h+Z0FwTEK69c9bfIq4g==";
  };

  # The tarball ships dist/ prebuilt and no lockfile. Its devDependencies are
  # only for building dist/ (one is a pkg.pr.new URL), so drop them to match
  # the lockfile generated here. jq is called by path: the npm deps fetcher
  # runs postPatch too, without nativeBuildInputs.
  postPatch = ''
    ${lib.getExe jq} 'del(.devDependencies, .scripts)' package.json > package.json.new
    mv package.json.new package.json
    cp ${./package-lock.json} package-lock.json
  '';

  npmDepsHash = "sha256-1zIPeRM2emlCmoGS2ABRQV6lmIqu6LMVrrFWurP0SR0=";
  dontNpmBuild = true;

  # workerd (via miniflare) and sharp ship prebuilt glibc binaries.
  nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ stdenv.cc.cc.lib ];

  meta = {
    description = "Cloudflare's unified CLI (technical preview)";
    homepage = "https://github.com/cloudflare/cf";
    license = with lib.licenses; [ mit asl20 ];
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "cf";
  };
})
