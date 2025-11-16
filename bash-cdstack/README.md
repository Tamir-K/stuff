Inspired by http://daveeddy.com/2013/09/14/directory-management-with-cd/ .
Little did I know, a day later I ran into [this article](https://nxnjz.net/2019/09/navigating-directories-efficiently-on-linux/) about the bash dir stack builtins - neat (and pretty old) stuff.

```
alias cd='pushd'
alias p='popd'
alias s='dirs -v'
```

Should achieve similar results. I think it's cool.

**Update:** After experimenting a bit, I managed to expand on this idea:
```
cd() {
    pushd ${*:-~}
}

s() {
    if [[ -z $1 ]]; then
        dirs -v
        return 0
    fi

    local paths=($(dirs))
    cd ${paths[$1]/#\~/$HOME}
}

alias p='popd'
```
By using a function rather than an alias, we actualy override the built-in cd in priority
(`type` will show our function first, built-in second),
so now it also works with features like `autocd`.
This makes the dir stack a history of all directories we visited in the current bash session (`popd`/`p` not withstanding).
The s function now gives the utility of jumping to a directory in the stack by number.

I'm sure this is useful somehow, I just haven't found how yet.
