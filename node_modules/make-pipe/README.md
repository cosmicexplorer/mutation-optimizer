make-pipe
=========

Makes pipes easier to use in makefiles by quitting and returning a nonzero exit status if any of the constituent commands return nonzero.

# Usage

Replace where you'd put a pipe with a string containing only the pipe character.

```
make-pipe echo 'heya' '|' cat '|' grep -Eo '[ea]'
# outputs:
# e
# a
```

If you want to pipe data into `make-pipe`, set the environment variable `LISTEN`. This can be useful for handing off a pipeline you don't control into your own pipeline which will fail if any of its constituent commands fails.

```
echo hey | LISTEN=y make-pipe cat '|' cat
# outputs:
# hey
```

# Install

`npm install -g make-pipe`

# Examples

This was made for use in [a bioinformatics project](https://github.com/cosmicexplorer/mutation-optimizer).
