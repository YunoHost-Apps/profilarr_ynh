## Upgrading from Profilarr v1 to v2

Profilarr v2 is a complete rewrite by upstream (new backend, new database
engine). **The v1 database is not compatible with v2 and there is no
migration path** - this is confirmed by upstream, not a limitation of this
YunoHost package.

If you upgrade from a 1.x version, this package will **reset all of
Profilarr's data**: linked database, custom formats, quality profiles, arr
instance configuration, everything. You will need to go through Profilarr's
setup wizard again after the upgrade and reconfigure your Radarr/Sonarr
connections from scratch.

If you are not ready to lose this data, do not upgrade yet.
