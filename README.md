# Operational Group Fileset - Track File Distribution Test

This repository contains the TG BOS Operational Group Track File Distribution Test structure (Track File Bundling).

## Structure

Each GEO division has its own folder named with the format: `GEO#_<MD5_HASH>`

Each folder contains:
- A `.fileset` file (named with the MD5 hash of the fileset content)
- The corresponding `.subdiv` track file

## GEO Divisions

- **GEO1**: NS.06764.80025.subdiv
- **GEO2**: NS.06341.80049.subdiv
- **GEO3**: NS.05730.80094.subdiv
- **GEO4**: NS.05420.80042.subdiv
- **GEO5**: NS.07060.80053.subdiv
- **GEO6**: NS.07050.80035.subdiv
- **GEO7**: NS.09043.70999.subdiv
- **GEO9**: NS.01920.80009.subdiv
- **GEO10**: NS.02460.80047.subdiv
- **GEO11**: NS.01521.80045.subdiv

## Fileset Format

Each `.fileset` file contains:
```
name "GEO# auto fileset"
vers "01"
rrid "NS"
repo "track"
file "<filename>.subdiv" size=<size> md5=<md5_hash>
```

## Permissions

All directories and files have 777 (drwxrwxrwx) permissions.

## Setup Process

1. Each `.fileset` file is created with the division name, version, rrid, and repo information
2. The MD5 hash of the `.fileset` file content is calculated
3. A folder is created with the name `GEO#_<MD5_HASH>`
4. The `.fileset` file is placed in the folder and renamed to `<MD5_HASH>.fileset`
5. The corresponding `.subdiv` file is added to the folder
6. File size and MD5 are calculated and added to the `.fileset` file
7. The `.fileset` file is recalculated and the folder is renamed with the new MD5 hash

