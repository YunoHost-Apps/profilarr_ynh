## Mise à jour de Profilarr v1 vers v2

Profilarr v2 est une réécriture complète par les développeurs d'origine
(nouveau backend, nouveau moteur de base de données). **La base de données
de la v1 n'est pas compatible avec la v2 et il n'existe aucun chemin de
migration** - ceci est confirmé par les développeurs d'origine, ce n'est pas
une limitation de ce paquet YunoHost.

Si vous effectuez une mise à jour depuis une version 1.x, ce paquet va
**réinitialiser toutes les données de Profilarr** : base de données liée,
formats personnalisés, profils de qualité, configuration des instances
arr, tout. Vous devrez refaire l'assistant de configuration de Profilarr
après la mise à jour et reconfigurer vos connexions Radarr/Sonarr depuis
zéro.

Si vous n'êtes pas prêt à perdre ces données, ne mettez pas à jour
maintenant.
