# 👾 dcl-godot-tests

## Prerequisites

*   Node (version >= 12, optimal 14)

    In case of using Linux or MacOS, use NVM (Node Version Manager) to control your node version.

```
$ curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
$ export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
$ nvm install 14
$ nvm use 14
```

*   Godot Engine with Dynamic GLTF Loader module

    Run the following commands to get the engine and the module, and compile the editor

```
$ git clone https://github.com/godotengine/godot.git
$ cd godot
$ git checkout 3.3
$ cd modules
$ git clone https://github.com/you-win/godot-dynamic-gltf-loader.git
$ mv godot-dynamic-gltf-loader/dynamic-gltf-loader .
$ rm -rf godot-dynamic-gltf-loader
$ scons tools=yes -j8 -u
```

Why do we need this? Godot can't load GLTF models at runtime. For that, we need to expose the module that loads those resources to be used at runtime. Coming up in version 4!

[https://github.com/godotengine/godot-proposals/issues/3273#issuecomment-917664431](https://github.com/godotengine/godot-proposals/issues/3273#issuecomment-917664431)

## Getting started

### Install the CLI <a href="install-the-cli" id="install-the-cli"></a>

#### To get started, install the Command Line Interface (CLI).

The CLI allows you to compile and preview your scene locally.

To install the CLI, run the following command in your command line tool of choice:

```
$ npm install -g decentraland@latest
```

Read [Installation guide](https://docs.decentraland.org/development-guide/installation-guide/) for more details about installing the CLI.

### Updating the CLI

If you need to update the CLI, remove it first

```
$ npm rm decentraland -g
$ npm install -g decentraland@latest
```

### Install and initialize Decentraland ECS

1. Create a folder
2. Enter it and run the following commands in your command line tool of choice:

```
$ npm i decentraland-ecs@latest
$ dcl init
```

## Preview a scene

To preview a scene run the following command on the scene’s main folder

```
$ dcl start
```

A browser will open on an URL like this, to preview the scene

[http://localhost:8000/?SCENE\_DEBUG\_PANEL\&position=0%2C0\&realm=localhost-stub](http://localhost:8000/?SCENE\_DEBUG\_PANEL\&position=0%2C0\&realm=localhost-stub)

NOTE: Pay special attention to the `position` query string in the URL. That's where the scene is!

## Parameters of the preview command

You can add the following flags to the `dcl start` command to change its behavior

* `--port` to assign a specific port to run the scene. Otherwise it will use whatever port is available. Default 8000
* `--no-debug` Disable the debug panel, that shows scene and performance stats
* `--no-browser` to prevent the preview from opening a new browser tab.
* `--w` or `--no-watch` to not open watch for filesystem changes and avoid hot-reload
* `--c` or `--ci` To run the parcel previewer on a remote unix server
* `--web3` Connects preview to browser wallet to use the associated avatar and account
* `--skip-version-checks` Avoids checking if the scene’s ECS library version matches your CLI version, and launches the preview anyway

## Connect with Godot

To connect the browser and Godot, you need to add a websocket server address to the browser

1. Start the godot project in `wsocktest/`. This will open a websocket server on port **9080** (see server.gd)
2.  Reload the browser adding a **ws** parameter to the URL query string, specifying the websocket server address to like this

    [http://localhost:8000/?SCENE\_DEBUG\_PANEL\&position=0%2C0\&realm=localhost-stub\&ws=ws://localhost:9080](http://localhost:8000/?SCENE\_DEBUG\_PANEL\&position=0%2C0\&realm=localhost-stub\&ws=ws://localhost:9080)

#### Alternative debug query string parameters

[http://localhost:8000/?DEBUG\_MESSAGES\&DEBUG\_MODE\&FORCE\_SEND\_MESSAGE\&DEBUG\_REDUX\&TRACE\_RENDERER=350\&SCENE\_DEBUG\_PANEL\&position=0%2C0\&realm=localhost-stub\&ws=ws://localhost:9080](http://localhost:8000/?DEBUG\_MESSAGES\&DEBUG\_MODE\&FORCE\_SEND\_MESSAGE\&DEBUG\_REDUX\&TRACE\_RENDERER=350\&SCENE\_DEBUG\_PANEL\&position=0%2C0\&realm=localhost-stub\&ws=ws://localhost:9080)

## Test Scenes

Check this test scenes. Just download and `dcl start` them!

[https://github.com/decentraland/kernel/blob/main/public/test-scenes/](https://github.com/decentraland/kernel/blob/main/public/test-scenes/)

## Other documents of interest

[https://github.com/menduz/text-renderer](https://github.com/menduz/text-renderer)

[https://diagrams.menduz.com/#/notebook/2l3t8FEx6Yc4GyDvkdDe4EQKf2L2/-MhVIlsuYfNVGtyiUN13](https://diagrams.menduz.com/#/notebook/2l3t8FEx6Yc4GyDvkdDe4EQKf2L2/-MhVIlsuYfNVGtyiUN13)

[https://github.com/decentraland/unity-renderer/blob/614a2bb65abef3093049545ad1d83c64050b3e58/unity-renderer/Assets/Scripts/MainScripts/DCL/WebInterface/Interface.cs#L85](https://github.com/decentraland/unity-renderer/blob/614a2bb65abef3093049545ad1d83c64050b3e58/unity-renderer/Assets/Scripts/MainScripts/DCL/WebInterface/Interface.cs#L85)

[https://github.com/decentraland/kernel/blob/main/packages/shared/proto/engineinterface.proto](https://github.com/decentraland/kernel/blob/main/packages/shared/proto/engineinterface.proto)

[https://github.com/decentraland/kernel/blob/fbe6def4caea5c883ec2cbbec246e02aced16145/packages/unity-interface/protobufMessagesBridge.ts#L72](https://github.com/decentraland/kernel/blob/fbe6def4caea5c883ec2cbbec246e02aced16145/packages/unity-interface/protobufMessagesBridge.ts#L72)
