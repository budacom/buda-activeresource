# Buda Active Resource

Add customizations to [ActiveResource](https://github.com/rails/activeresource) objects to work properly in Buda.com arquitecure.

Features include:
- Integration with [Enumerize](https://github.com/brainspec/enumerize)
- Integration with `Money`
- Connectiones patch
- other minor tweaks

## Releasing

Releases are automated with [release-please](https://github.com/googleapis/release-please).

1. Merge PRs to `main` using [Conventional Commits](https://www.conventionalcommits.org/) (e.g. `feat:`, `fix:`, `chore:`).
2. Release Please opens a release PR that bumps `lib/buda_active_resource/version.rb`, updates `CHANGELOG.md`, and syncs `.release-please-manifest.json`.
3. Merge the release PR to create a GitHub release and tag (e.g. `1.1.0`).

Consumers can install from the tagged source for now. Registry publishing (RubyGems, GitHub Packages, or Google Artifact Registry) can be added later.

To trigger a release check manually, run the **Release Please** workflow from the Actions tab.
