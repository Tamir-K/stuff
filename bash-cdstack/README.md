Inspired by http://daveeddy.com/2013/09/14/directory-management-with-cd/ .
Little did I know, a day later I ran into [this article](https://nxnjz.net/2019/09/navigating-directories-efficiently-on-linux/) about the bash dir stack builtins - neat (and pretty old) stuff.

```
alias cd='pushd'
alias p='popd'
alias s='dirs -v'
```

Should achieve similar results. I think it's cool.
