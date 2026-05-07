{ ... }:
{
  # IPv6-only hosts cannot reach GitHub's IPv4-only endpoints directly.
  # Daniel Winzen's proxy publishes IPv6 addresses for the GitHub hostnames
  # below, letting normal github:/https://github.com URLs keep working.
  # Source: https://danwin1210.de/github-ipv6-proxy.php
  den.aspects.github-ipv6-proxy = {
    nixos.networking.hosts = {
      "2a01:4f8:c010:d56::2" = [ "github.com" ];
      "2a01:4f8:c010:d56::3" = [ "api.github.com" ];
      "2a01:4f8:c010:d56::4" = [ "codeload.github.com" ];
      "2a01:4f8:c010:d56::6" = [ "ghcr.io" ];
      "2a01:4f8:c010:d56::7" = [
        "pkg.github.com"
        "npm.pkg.github.com"
        "maven.pkg.github.com"
        "nuget.pkg.github.com"
        "rubygems.pkg.github.com"
      ];
      "2a01:4f8:c010:d56::8" = [ "uploads.github.com" ];
      "2606:50c0:8000::133" = [
        "objects.githubusercontent.com"
        "www.objects.githubusercontent.com"
        "release-assets.githubusercontent.com"
        "gist.githubusercontent.com"
        "repository-images.githubusercontent.com"
        "camo.githubusercontent.com"
        "private-user-images.githubusercontent.com"
        "avatars0.githubusercontent.com"
        "avatars1.githubusercontent.com"
        "avatars2.githubusercontent.com"
        "avatars3.githubusercontent.com"
        "cloud.githubusercontent.com"
        "desktop.githubusercontent.com"
        "support.github.com"
      ];
      "2606:50c0:8000::154" = [
        "support-assets.githubassets.com"
        "github.githubassets.com"
        "opengraph.githubassets.com"
        "github-registry-files.githubusercontent.com"
        "github-cloud.githubusercontent.com"
      ];
    };
  };
}
