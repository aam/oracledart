Bring Oracle to Dart
===

To Use
---

This extension requires Oracle Instant Client being present on the machine.
It is being tested with version instantclient-basic-nt-12.1.0.1.0.

To Build
---

- Put https://github.com/aam/oracledart/blob/master/.gclient into locally created folder and execute "gclient sync"
- Execute tools/build.py

Automated testing
---

Automated test is running at http://buildbot.aprelev.com:8009/waterfall.

Tests are automatically executed on three platforms: Windows, Ubuntu and Mac on every commit into dart bleeding_edge branch and every commit into OracleDart git repository.
