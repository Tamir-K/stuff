Some experiments in reimplementing the basic functionality of GNU nproc using more generalized tools.

Why?
1. nproc is an extremely specialized tool, it's interesting to see how its existence as a separate binary is justified.
2. It's fun.

Our baseline version, as expected, is nproc itself
```
#!/usr/bin/env bash
# nproc_bin.sh
nproc
```
looking at the [source code for nproc](https://github.com/coreutils/coreutils/blob/master/src/nproc.c),
it's nothing more than a wrapper for glibc's num_processors,
which itself uses sysconf on linux machines to get the number of cores on the computer.

A compiled binary performing a simple task, it should be quite fast.

For the rest of our options, we don't actually have a native method of getting the number of cores avaliable to us,
so we'll resort to a standard linux practice: reading a file (specifically, /proc/cpuinfo).

since from here on out, we're dealing with file processing, our next natural candidate is grep
```
#!/usr/bin/env bash
#nproc_grep.sh
grep -c 'processor' /proc/cpuinfo
```
To find the number of processors avaliable to us, we simply need to count the number of times the pattern "processor" appears in the cpuinfo file.
grep should have no problem dealing with that.

Another ususal suspect for this kind of pattern matching is awk
```
#!/usr/bin/env bash
# nproc_awk.sh
awk '/^processor/{count++} END{print count}' /proc/cpuinfo
```
awk is great at file processing and pattern matching, this seems to fit.

These are great solutions and all, but the main reason I began thinking about this is, as the title suggest,
reimplementing in bash, for which we have several examples.

The main reason I strive to reimplement things in bash, is the advantage it has as the shell I use to interface with my PC:
solutions built using bash native tools, without external binaries, run within the bash process that called them,
thus avoid the overhead of forking into another process
(Yes, I'm actually trying to achieve decent performance with bash,
at least decent enough to justify decluttering and getting rid of other specialized tools.
Crazy, I know).

For this, I wrote several variations:
```
#!/usr/bin/env bash
# nproc_bash_read.sh
count=0

while IFS= read -r line; do
    [[ $line == *processor* ]] && ((++count))
done < /proc/cpuinfo

echo $count
```
Using a classic bash approach for reading a file, we traverse each line in cpuinfo,
check if we get a pattern match, and if so, increment our count by 1. Nothing special.
Our pattern matching here works, as thankfully, /proc/cpuinfo only has a single field per line.
While this seems to be quite memory efficient, due to holding only a single line in memory at any given moment,
I think this would be the least performant implementation ut of the bunch.

```
#!/usr/bin/env bash
# nproc_bash_map.sh
count=0

mapfile </proc/cpuinfo file
for line in ${file[@]}; do
    [[ $line == *processor* ]] && ((++count))
done
echo $count
```
In this variation, we use mapfile to load the entire file into memory as an array.
/proc/cpuinfo is relatively small, so we can afford the memory,
but this still traverses the file line by line to find matches.
Still, at the cost of some memory we significantly reduced the number of syscalls required to read the file,
so we likely reduced our system time (and overall execution time).

```
#!/usr/bin/env bash
# nproc_bash_fork.sh
count=0

for line in $(</proc/cpuinfo); do
    [[ $line == *processor* ]] && ((++count))
done
echo $count
```
This time, we use command substitution with a redirection to load the entire file into memory as a string.
Using this approach, we lose the advantage of not forking into another process (though admittedly, it is a very light process),
but we don't deal with the complications of assigning and accessing an array.

I was actualy very surprised I couldn't find a way to read a file's content as a string in native bash without creating a new process.

Will this be better? I have no idea.

Being able to load cpuinfo's content as a string gave me another idea, and our last candidate for now:
```
#!/usr/bin/env bash
# nproc_bash_pattern_count_fork.sh
count=0
pattern='processor'
file=$(</proc/cpuinfo)
temp="${file//${pattern}/}"
((count += (${#file} - ${#temp}) / ${#pattern}))
echo $count
```
Rather than traverse the lines and check for a pattern match, we can directly count the number of matches we have in the file.
Seeing an implementation in bash without any loops is quite notable.

While a bit more verbose, we could apply the same principle to the version that loaded the file into an array, we'd just have to stringify the result
```
#!/usr/bin/env bash
# nproc_bash_pattern_count_map.sh
pattern='processor'
mapfile </proc/cpuinfo file
file="${file[*]}"
temp="${file//${pattern}/}"
(( count = (${#file} - ${#temp}) / ${#pattern} ))
echo $count
```

I ran a benchmark using [hyperfine](https://github.com/sharkdp/hyperfine) - this should be enough for exploratory data:
| Command | Mean [ms] | Min [ms] | Max [ms] | Relative |
|:---|---:|---:|---:|---:|
| `nproc_awk.sh` | 5.7 ± 3.6 | 2.8 | 20.1 | 1.82 ± 2.13 |
| `nproc_bash_fork.sh` | 5.6 ± 4.5 | 2.6 | 22.0 | 1.77 ± 2.24 |
| `nproc_bash_map.sh` | 6.3 ± 4.4 | 3.0 | 23.4 | 1.99 ± 2.40 |
| `nproc_bash_pattern_count_fork.sh` | 3.2 ± 3.1 | 1.2 | 15.2 | 1.00 |
| `nproc_bash_pattern_count_map.sh` | 3.3 ± 3.0 | 1.4 | 16.0 | 1.06 ± 1.40 |
| `nproc_bash_read.sh` | 15.8 ± 6.8 | 8.0 | 33.4 | 5.02 ± 5.41 |
| `nproc_bin.sh` | 3.7 ± 3.1 | 1.8 | 20.5 | 1.18 ± 1.53 |
| `nproc_grep.sh` | 4.0 ± 3.3 | 2.2 | 21.1 | 1.26 ± 1.63 |

- Most results are to be expected, but I most definetly didn't expect a bash version to overtake the nproc binary!
- grep actually performed quite similarily to nproc, meaning nproc's specialization doesn't help it much.
- As expected, the read based bash implementation is the worst performing.
- Interestingly, the command substitution bash reading seems faster in every case, compared to the non-forking array loading.
- The awk version performed reasonably well, being slightly more consistant than some bash versions, but overall is neither here nor there.

One thing worth noting: /proc/cpuinfo is quite short on my machine, as it has only 4 cores.
It'd be interesting to see the results on a machine with more resources.
