# Cube Warper v1.15 server files (unofficial)

The owner was too slow releasing a v1.15 server pack, so I let Claude make one.

**[Download it from the releases page.](../../releases/latest)** Once an official v1.15 server pack is out, use that instead.

## How it works

A GitHub Action runs [`build.sh`](build.sh), which:

1. Downloads the public v1.14 server pack from CurseForge.
2. Removes the 10 outdated mods.
3. Downloads the 13 new and updated mods from CurseForge.
4. Copies the changed configs, quests and KubeJS scripts from the public v1.15 client pack.
5. Checks every changed file against its SHA-1 checksum and publishes the zip as a GitHub release.

All files are public. The changes were found by comparing the v1.14 and v1.15 packs from CurseForge and checking them against the [public Cube Warper repo](https://github.com/Appocryptha/Cube-Warper). Mods that only matter on the client are left out, as in the official v1.14 server pack.

## Running it

Unzip it, set `eula=true` in `eula.txt`, then run `run.sh` or `run.bat`. Players need v1.15 of the modpack to join.
