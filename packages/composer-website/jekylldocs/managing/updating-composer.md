---
layout: default
title: Updating Hyperledger Composer
category: tasks
section: managing
sidebar: sidebars/managing.md
excerpt: To [update Hyperledger Composer](./updating-composer.html) to a new version, the Hyperledger Composer components must be uninstalled and reinstalled using npm.
index-order: 7
---

# Updating {{site.data.conrefs.composer_full}}

After deploying {{site.data.conrefs.composer_full}} you may wish to upgrade to a new version. To update your installed version of {{site.data.conrefs.composer_full}} you must uninstall the client, admin, and runtime CLI components and reinstall them by using npm.

## Procedure

1. Uninstall the {{site.data.conrefs.composer_full}} components by using the following commands:

        npm uninstall -g composer-cli
        npm uninstall -g composer-rest-server
        npm uninstall -g generator-fabric-composer

2. Install the latest version of the {{site.data.conrefs.composer_full}} components by using the following commands:

        npm install -g composer-cli
        npm install -g composer-rest-server
        npm install -g generator-fabric-composer


## What next?

- [Defining a business network](../business-network/bnd-create.html)
- [Modeling language](../reference/cto_language.html)
- [Managing your solution](./managingindex.html)
