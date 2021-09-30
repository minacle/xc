# xc

![$ xc](https://repository-images.githubusercontent.com/341888512/1b9ed300-ac65-11eb-93ab-f4ff98aa9ac7)

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

    xc [-a|--all] [-s|--specify <specifier>] [<paths> ...]
    xc [-b|--beta] [-s|--specify <specifier>] [<paths> ...]
    xc [-r|--release] [-s|--specify <specifier>] [<paths> ...]
    xc [-h|--help]
    xc list [-a|--all] [-s|--specify <specifier>]
    xc list [-b|--beta] [-s|--specify <specifier>]
    xc list [-r|--release] [-s|--specify <specifier>]
    xc list [-h|--help]

### subcommands

- `open`
  Open paths using most recent or specified version of Xcode app on the machine. _(default)_
- `list`
  List every or specified version of Xcode app(s) on the machine.

### arguments

- `<paths>`  
  Path list to be opened.  
  Swift packages are can be selected by package root directory.  
  Open as workspace if .xcodeproj and/or .xcworkspace bundle selected.  
  Otherwise selected file will be opened as independent file.

### options

- `-a`|`--all`  
  Search both beta and release version.
- `-b`|`--beta`  
  Search only beta version.
- `-r`|`--release`  
  Search only release version. _(default)_
- `-s <specifier>`|`--specify <specifier>`  
  Specify the build or version of Xcode to run.  
  To specify build 11E801a (for Xcode 11.7 GM), send `11E801a`.  
  To specify version 12.0.1 (for Xcode 12A7300 GM), send `12.0.1`.  
  To specify most recent version starts with 11, send `~>11.0`.  
  To specify most recent version starts with 8.3, send `~>8.3.0`.
- `-h`|`--help`  
  Show help information.

## copyright

[No](https://unlicense.org).
