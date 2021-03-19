# xc

The best command to run most recent version of Xcode app on your machine.

## distinction

- **Short!** This command is short as `cd` and `ls` that use frequently!
- **Fast!** This command is blazingly fast to find and sort Xcode apps on the machine!
- **Easy!** This command is too easy to type and memorise so can even run Xcode app unconsciously!

## installing

You can install **xc** using [Mint 🌱](https://github.com/yonaskolb/Mint).

```sh
mint install minacle/xc
```

## usage

```
xc [-r|-gm|--release-only] [-l|--list] [<paths> ...]
xc [-b|-beta|--allow-beta] [-l|--list] [<paths> ...]
xc [-h|--help]
```

### arguments

- `<paths>`  
  Path list to be opened.  
  Swift packages are can be selected by package root directory.  
  Open as workspace if .xcodeproj and/or .xcworkspace bundle selected.  
  Otherwise selected file will be opened as independent file.

### options

- `-b`|`-beta`|`--allow-beta`  
  Allow beta version.
- `-r`|`-gm`|`--release-only`  
  Disallow beta version. _(default)_
- `-l`|`--list`  
  List every found Xcode apps.
- `-h`|`--help`  
  Show help information.

## copyright

[No](https://unlicense.org).
