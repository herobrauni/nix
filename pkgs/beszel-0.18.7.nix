{
  buildGoModule,
  lib,
  fetchFromGitHub,
  buildNpmPackage,
}:
buildGoModule rec {
  pname = "beszel";
  version = "0.18.7";

  src = fetchFromGitHub {
    owner = "henrygd";
    repo = "beszel";
    tag = "v${version}";
    hash = "sha256-pVZ1ru9++BypZ3EwoE8clqJowXj1/CMiJxKaC+UY9VE=";
  };

  webui = buildNpmPackage {
    inherit pname version src;

    npmFlags = [ "--legacy-peer-deps" ];

    buildPhase = ''
      runHook preBuild

      npx lingui extract --overwrite
      npx lingui compile
      node --max_old_space_size=1024000 ./node_modules/vite/bin/vite.js build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r dist/* $out

      runHook postInstall
    '';

    sourceRoot = "${src.name}/internal/site";

    npmDepsHash = "sha256-mYAD8FrQwa+F/VgGxFpe8vqucfZaM0PmY+gJJqw1IKk=";
  };

  vendorHash = "sha256-TVpZbK9V9/GqpVFcjF7QGD5XJJHzRgjVXZOImHQTR1k=";

  preBuild = ''
    mkdir -p internal/site/dist
    cp -r ${webui}/* internal/site/dist
  '';

  doCheck = false;

  postInstall = ''
    mv $out/bin/agent $out/bin/beszel-agent
    mv $out/bin/hub $out/bin/beszel-hub
  '';

  meta = {
    homepage = "https://github.com/henrygd/beszel";
    changelog = "https://github.com/henrygd/beszel/releases/tag/v${version}";
    description = "Lightweight server monitoring hub with historical data, docker stats, and alerts";
    license = lib.licenses.mit;
  };
}
