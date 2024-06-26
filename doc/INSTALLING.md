# installation

## dart installation

> **WARNING**: if not otherwise specified, never execute anything as root user,
>
> if you do, be prepared for a hell of pain!
> **you are warned!**
>
### Installation of the flutter framework by source

```bash
$ cd projects # or wherever you store your stuff
$ git clone https://github.com/flutter/flutter.git
$ export PATH=$PATH:`pwd`/flutter/bin # to enable dart locally in the actual shell
$ flutter doctor # check that the installation is working
$ dart --version # check that the dart interpreter is working
```

### Installing dart from image on a raspberry pi (arm64)

```bash
$ cd projects # or wherever you store your stuff
$ wget https://storage.googleapis.com/dart-archive/channels/stable/release/2.14.2/sdk/dartsdk-linux-arm64-release.zip
$ unzip dartsdk-linux-arm64-release.zip 
$ rm dartsdk-linux-arm64-release.zip 
$ dart-sdk/bin/dart --version # check that the dart interpreter is working
$ export PATH=$PATH:`pwd`/dart-sdk/bin # to enable dart locally in the actual shell
$ export CHROME_EXECUTABLE=`which chromium` # to allow web dev, using, linux usually present, chromium instead of chrome 
```

### Installing dart on an android tablet (arm64)

you will need a working termux environment:  https://play.google.com/store/apps/details?id=com.termux

once up and  running, hit

```bash
pkg install dart
```

and you are good
You probably want to install also vim (+dart plugins), git and you other usual tools.

### Installing dart on a linux tablet (arm64)

Follow the instructions of getting flutter through git above, if you are running a JingPad with broken
OpenGL implementation, you need to disable the OpenGl rendering and forcing , slow, software rendering by:


```bash
unset LD_LIBRARY_PATH
```

## installation/source management

### How to fetch the sources from git

#### first time for public, non contributing users

```bash
$ cd projects # or wherever you store your stuff
$ git clone https://github.com/nohkumado/ipxbridge.git .
$ cd ipxbridge/ # or wherever you store your stuff
$ dart run bin/ipxbot.dart --help
```

The last line is to check that all went well and the thing is working

#### first time for contributing users with configured (ssh keys!) git account

```bash
$ cd projects # or wherever you store your stuff
$ git clone git@github.com/nohkumado/ipxbridge.git .
$ cd ipxbridge/ # or wherever you store your stuff
$ dart run bin/ipxbot.dart --help
```

The last line is to check that all went well and the thing is working

### to refresh/rsync the sources with the git version

afterwards if you want to update the project to the actual active version you just need to
```
git pull
```

> **WARNING**: if you modified the source you will perhaps need to fix some merge errors!

### Installation/activation of the NohFibu executable

Once this runs, you can activate the project, for this you have to be in the root dir of the project:
> **You need to repeat this after updates  if some binaries are missing!**


### Activation from the sources
```bash
$ dart pub global activate --source path `pwd`
```

### Activation from pub.dev

A neat thing about dart is, you don't need to fetch the sources if you only want to use the program!
In this case, you use the https://pub.dev/packages/nohfibu version directly.

```bash
$ dart pub global activate ipxbridge
```

and after adding (don't forget the dart sdk path if you installed it locally)
`  export PATH="$PATH":"$HOME/.pub-cache/bin"`
to your `~/.bashrc` you can simply run e.g.


`ipxbot -u mybot -p use\_a\_good\_passwd -r #botsroom:matrix.org -i !gWOtdaUZZByMfTOVam:matrix.org -s "https://matrix.org" -m "Je suis là" -c ~/config/ipxbot/`

### Compilation

instead of activating the project, you can also precompile them, which makes them way faster!

```bash
mkdir ~/bin
dart compile exe  bin/ipxbot.dart -o ~/bin/ipxbot
```

