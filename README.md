# Многоꙮтех

[![CI tests status badge][build-shield]][build-url]
[![Latest release badge][rubygems-shield]][rubygems-url]
[![License badge][license-shield]][license-url]
[![Maintainability badge][cc-maintainability-shield]][cc-maintainability-url]
[![Test coverage badge][cc-coverage-shield]][cc-coverage-url]

[build-shield]: https://img.shields.io/github/workflow/status/paolobrasolin/mnogootex/CI/main?label=tests&logo=github
[build-url]: https://github.com/paolobrasolin/mnogootex/actions/workflows/main.yml "CI tests status"
[rubygems-shield]: https://img.shields.io/gem/v/mnogootex?logo=ruby
[rubygems-url]: https://rubygems.org/gems/mnogootex "Latest release"
[license-shield]: https://img.shields.io/github/license/paolobrasolin/mnogootex
[license-url]: https://github.com/paolobrasolin/mnogootex/blob/main/LICENSE "License"
[cc-maintainability-shield]: https://img.shields.io/codeclimate/maintainability/paolobrasolin/mnogootex?logo=codeclimate
[cc-maintainability-url]: https://codeclimate.com/github/paolobrasolin/mnogootex "Maintainability"
[cc-coverage-shield]: https://img.shields.io/codeclimate/coverage/paolobrasolin/mnogootex?logo=codeclimate&label=test%20coverage
[cc-coverage-url]: https://codeclimate.com/github/paolobrasolin/mnogootex/coverage "Test coverage"

Многоꙮтех (mnogootex) is a utility that parallelizes compilation
of a LaTeX document using different classes and offers a
meaningfully filtered output.

The motivating use case is maintaining a single preamble while
submitting a paper to many journals using their outdated or crummy
document classes.

## Getting started

### Prerequisites

Многоꙮтех is written in [**Ruby**](https://www.ruby-lang.org) and requires version `>=2.5` (earlier ones are untested).
You can check whether it's installed by running `ruby --version`.
For installation instructions you can refer to the [official documentation](https://www.ruby-lang.org/en/documentation/installation/).


Многоꙮтех heavily relies on [**`latexmk`**](https://ctan.org/pkg/latexmk).
You can check whether it's installed by running `latexmk --version`.
If you are missing it, follow the documentation of your specific LaTeX distribution and install the `latexmk` package.

### Installation

To install многоꙮтех execute

```bash
gem install mnogootex
```

If you're upgrading from a previous version, execute

```bash
gem update mnogootex
```

and remove any mention of `mnogootex` from your shell profile (it's not needed anymore).

### Quick start

First you write a LaTeX document:

```latex
% ~/demo/main.tex
\documentclass{scrarticle}
\begin{document}
  \abstract{Simply put, my article is awesome.}
  Let's port my \KOMAScript\ article to other classes!
\end{document}
```

Then you list the desided classes in a Многоꙮтех configuration file:

```yaml
# ~/demo/.mnogootexrc
jobs:
  - scrartcl
  - article
  - book
```

Finally you run `mnogootex build` and enjoy the technicolor:

![A user types `mnogootex build main.tex` in the console. Some spinners indicating progress appear. Then the outcome for each class is presented. Failing ones include abridged and color coded logs, to pinpoint the errors.](demo/demo.gif?raw=true "TTY demo GIF")

## Usage

A Многоꙮтех run does the following:
1. copy the _source_ folder of a project to many _target_ folders, one for each _job_;
2. replace the document class in the source of each _target_ folder with the name of the relative _job_;
3. call `latexmk` in parallel on each _target_ folder to compile the documents (or do other tasks);
4. wait for the outcomes and print the logs, filtered and colour-coded in a meaningful way.

Its convenience lies in the fact that it
* automates the setup process,
* parallelizes compilation,
* improves the readability of the infamous waterfall logs.

Многоꙮтех can be invoked from CLI using `mnogootex`.
It accepts various [commands](#mnogootex-commands) detailed below.

To leverage the full power of this tool you will need to learn writing [`mnogootex` configurations](#mnogootex-configuration) and ['latexmk' configurations](#latexmk-configuration).
It might sound daunting but they're really just a few lines.

### `mnogootex` commands

> **Notation:** `[FOO]` means that _`FOO` is optional_ while `FOO ...` means _one or more `FOO`s_.

All commands except `help` accept the same parameters, so let's examine them in advance to avoid repeating ourselves later.
Here is their syntax:

```bash
mnogootex COMMAND [JOB ...] [FLAG ...] ROOT
```

`JOB`s are the names of the document classes to compile your document with.
Zero or more can be provided, and when none is given the job list is loaded from the [configuration](#jobs).

`FLAG`s are `latexmk` options.
Zero or more can be provided to override the behaviour of the `latexmk` call underlying the `mnogootex` command.
You can obtain a list of available options with the inline help `latexmk --help`, and the full documentation with `man latexmk`.
Generally speaking, if you find yourself always using a `FLAG` you should properly [configure `latexmk`](#latexmk-configuration) instead.

The last mandatory parameter is the `ROOT` file for compiling of your document.

Let's examine the details of each command now.

#### `help [COMMAND]`

This command prints the help for `COMMAND` (or all commands if none is given).

#### `exec [JOB ...] [FLAG ...] ROOT`

This command simply runs `latexmk` on the `ROOT` document for each of your `JOB`s passing the given `FLAG`s.

All other commands below are specializations of this one.
However you'll seldom use it unless you're debugging.

#### `build [JOB ...] [FLAG ...] ROOT`

This command builds your document.

It is equivalent to `exec [JOB ...] -interaction=nonstopmode ROOT`.

You will probably need to pass some `FLAG`s (e.g. to use the correct engine) but it is not recommended: [configure `latexmk`](#latexmk-configuration) instead.

#### `open [JOB ...] [FLAG ...] ROOT`

This command opens the final compilation artifact (after running the build if necessary).

It is equivalent to `exec [JOB ...] -pv -interaction=nonstopmode ROOT`.

You might need to pass some `FLAG`s (e.g. to use the correct viewer) but it is not recommended: [configure `latexmk`](#latexmk-configuration) instead.

#### `clean [JOB ...] [FLAG ...] ROOT`

This command deletes all nonessential build files while keeping the compiled artifacts.

It is equivalent to `exec [JOB ...] -c ROOT`.

#### `clobber [JOB ...] [FLAG ...] ROOT`

This command deletes all nonessential build files including the compiled artifacts.

It is equivalent to `exec [JOB ...] -C ROOT`.

### `mnogootex` configuration

`mnogootex` is configured through [`YAML`](https://learnxinyminutes.com/docs/yaml/)
files named `.mnogootexrc` put into your projects' root directory.

When `mnogootex` loads a configuration it also looks up for `.mnogootexrc`
files in all parent directories to merge then together (from the
shallowest to the deepest path).  This means that e.g. you can keep
a configuration file in your home folder and use it as a global
configuration for all you projects, while overwriting only specific
options in the configuration files of each one.

`mnogootex` currently accepts three options.

#### `jobs`

This option represents the `JOB`s to build your document (when none are given via CLI).

It must contain valid document class names, given as a list of strings.

By default there are no `JOB`s:

```yaml
# Default value:
jobs: []
```

Here is a slightly more interesting example:

```yaml
jobs:
  - scrartcl
  - article
  - book
```

#### `work_path`

This option is the folder where all elaboration happens.

It must be a well formed path, given as a string.

By default none is given, meaning that each run of any given job happens in a dedicated temporary folder:

```yaml
# Default value:
work_path: null
```

Overriding this allows you to have easier access to the compilation artifacts.
A good choice is setting it to `./build` and keep everything below your source folder:

```yaml
work_path: ./build
```

#### `spinner`

This option is the spinner animation shown by the CLI.

It is a series of frames given as characters of a string.

By default it's a hole looping around in a blister:

```yaml
# Default value:
spinner: ⣾⣽⣻⢿⡿⣟⣯⣷
```

Here is a couple more in case your terminal doesn't like Unicode:

```yaml
# A wriggly ASCII worm:
spinner: )}]|[{({[|]}
# An extended ASCII boomerang:
spinner: ╒┍┌┎╓╖┒┐┑╕╛┙┘┚╜╙┖└┕╘
```

Feel free to get creative!

### `latexmk` configuration

`latexmk` is configured through [`Perl`](https://www.perl.org/)
files named `.latexmkrc` put into your projects' root directory.

When `latexmk` loads a configuration it also looks up for `.latexmkrc`
files in all parent directories to merge then together (from the
shallowest to the deepest path).  This means that e.g. you can keep
a configuration file in your home folder and use it as a global
configuration for all you projects, while overwriting only specific
options in the configuration files of each one.

`latexmk` has a gazillion of options.
We'll just skim over the most common ones here.

First of all, one must pick the correct engine.
Assuming you want to produce a PDF artifact, you have a few choices:

```perl
$pdf_mode = 1; # create PDF with pdflatex
# $pdf_mode = 2; # create PDF with ps2pdf (via PS)
# $pdf_mode = 3; # create PDF with dvipdf (via DVI)
# $pdf_mode = 4; # create PDF with lualatex
# $pdf_mode = 5; # create PDF with xelatex
```

Then, if your PDF previewer is not being detected, you might need to configure it.
Assuming you want to use evince:

```perl
$pdf_previewer = 'start evince';
```

Most people won't probably need anything more than that.
However, for further details read the documentation in the commandline with `man latexmk` or on [CTAN](https://ctan.mirror.garr.it/mirrors/ctan/support/latexmk/latexmk.txt)

## Acknowledgements

* Thanks to [@tetrapharmakon](https://github.com/tetrapharmakon) for being the first tester and user.
