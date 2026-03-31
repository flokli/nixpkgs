{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchYarnDeps,
  yarnConfigHook,
  yarnBuildHook,
  yarnInstallHook,
  nodejs,
  buildGo125Module,
  runCommand,
  versionCheckHook,
  nix-update-script,
}:

# vendor/github.com/bytedance/sonic/internal/rt/stubs.go:33:22: undefined: GoMapIterator
buildGo125Module (finalAttrs: {
  pname = "signoz";
  version = "0.117.1";

  src = fetchFromGitHub {
    owner = "SigNoz";
    repo = "signoz";
    tag = "v${finalAttrs.version}";
    hash = "sha256-y9FFtpvVKk1dRRM52hpEcA6IVh2Aqu/by1kFkeFS+Tg=";
  };

  vendorHash = "sha256-z6WdVvDvFsbQ1apEr+jHFPB+mLLZj3jeUUX92atTuUk=";

  # The upstream Dockerfile copies the frontend artifacts to /etc/signoz/web,
  # Similarly, default email templates are copied to /root/templates.
  # These will both almost never work, so change the defaults to point to our
  # store paths instead.
  postPatch = ''
    substituteInPlace pkg/web/config.go \
      --replace-fail '"/etc/signoz/web"' '"${finalAttrs.frontend}"'
    substituteInPlace pkg/emailing/config.go \
      --replace-fail '"/root/templates"' '"${finalAttrs.email-templates}"'
  '';

  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${finalAttrs.src}/frontend/yarn.lock";
    hash = "sha256-ALo8MRzOSDCdBGZHUz2Zz4vFISiEQnVPnzNDa0ISBvk=";
  };

  frontend = stdenv.mkDerivation (finalAttrsFE: {
    pname = "signoz-frontend";
    version = finalAttrs.version;

    src = "${finalAttrs.src}/frontend";

    inherit (finalAttrs) yarnOfflineCache;

    nativeBuildInputs = [
      yarnConfigHook
      yarnBuildHook
      yarnInstallHook
      # Needed for executing package.json scripts
      nodejs
    ];

    # This creates i18n-translations-hash.json, needed during the build.
    preBuild = ''
      yarn i18n:generate-hash
    '';

    installPhase = ''
      mkdir -p $out
      cp -R ./build/. $out/
    '';
  });

  email-templates = runCommand "email-templates" { } ''
    mkdir -p $out
    cp ${finalAttrs.src}/templates/email/* $out/
  '';

  subPackages = [ "cmd/community" ];

  ldflags = [
    "-s"
    "-w"
    # See Makefile
    "-X github.com/SigNoz/signoz/pkg/version.version=${finalAttrs.version}"
    "-X github.com/SigNoz/signoz/pkg/version.hash=${finalAttrs.version}"
    "-X github.com/SigNoz/signoz/pkg/version.time=1970-01-01T00:00:00Z"
    "-X github.com/SigNoz/signoz/pkg/version.branch=main"
    "-X github.com/SigNoz/signoz/pkg/version.variant=community"
  ];

  tags = [
    "timetzdata"
  ];

  # Fix binary name
  postInstall = ''
    mv $out/bin/community $out/bin/signoz
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgramArg = "-v";

  passthru = {
    inherit (finalAttrs) frontend;
    # TODO
    # tests = {
    #   inherit (nixosTests) signoz;
    # };
    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "v(.+)"
      ];
    };
    # For nix-update to be able to find and update the hash.
    inherit (finalAttrs) yarnOfflineCache;
  };

  meta = {
    description = "Traces, metrics, and logs in a unified, OpenTelemetry-native platform.";
    longDescription = ''
      All your logs, metrics, and traces in one place. Monitor your application,
      spot issues before they occur and troubleshoot downtime quickly with rich
      context. SigNoz is a cost-effective open-source alternative to Datadog and
      New Relic.
    '';
    homepage = "https://signoz.io";
    changelog = "https://github.com/SigNoz/signoz/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit; # We only build the community variant
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [
      flokli
    ];
    mainProgram = "signoz";
  };
})
