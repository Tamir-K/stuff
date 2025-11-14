Just a small tought experiment in implementing basic commands with bash built-ins to avoid forking.
Performance is horrendous compared to GNU ls for anything above 1,000 files (though it is slightly faster for small numbers of files).

A lazy version of this could be made to avoid pulling all filenames to memory (though performance would liekly tank)
