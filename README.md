# Example main autograder repository

> [!WARNING]
> By default, the `main` branch of this repository is pulled live from
> Gradescope to run autograder tests.  If you have autograder changes
> that you do not want to be live on Gradescope, make a branch and
> then merge the changes to `main` when you are ready.


This repository is an example "main" autograder repository for use
with a Gradescope autograder loader.  For instructions on how to use
it, see the README
[here](https://github.com/browncs-course-tools/gradescope-ag-loader/).  

## Repository organization

This repository is organized as follows:
 - `config/`:  Contains per-assignment configuration for this
   autograder.  See the README in this directory for details.
 - `do_run.sh`:  Example script first run by the loader.  This is one
   option you can extend to run your own autograder code--take a look
   at this file for details on how you can use/extend it.
 - `common.sh`:  Bash helpers for manipulating `results.json`.  You
   can use this to add extra autograder tests to your results file.
   

