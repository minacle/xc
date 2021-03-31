# xc

The best command to run Xcode app what you want.

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

    xc [-r|-gm|--release-only] [-l|--list] [<paths> ...]  
    xc [-b|-beta|--allow-beta] [-l|--list] [<paths> ...]  
    xc [-r|-gm|--release-only] [-s|--specify] [<paths> ...]  
    xc [-b|-beta|--allow-beta] [-s|--specify] [<paths> ...]  
    xc [-h|--help]  

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
- `-s <specifier>`|`--specify` `<specifier>`  
  Specify the build or version of Xcode to run.  
  To specify build 11E801a (for Xcode 11.7 GM), send "11E801a".  
  To specify version 12.0.1 (for Xcode 12A7300 GM), send "12.0.1".  
  To specify most recent version starts with 11, send "~>11.0".  
  To specify most recent version starts with 8.3, send "~>8.3.0".
- `-h`|`--help`  
  Show help information.

## copyright

[No](https://unlicense.org).
