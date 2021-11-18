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

## Installation

The only requirement is [Ruby](https://www.ruby-lang.org) (>=2.5 as earlier versions are untested).

To install многоꙮтех execute

    gem install mnogootex
    
## Quick start

Set up your `LaTeX` project as usual - let's say its main file is `~/project/main.tex` and contains `\documentclass{...}`.

Create a configuration file `~/project/.mnogootex.yml`
containing the list of document classes you want to compile your
project against:

    jobs:
      - scrartcl
      - article
      - book
      
Run `mnogootex go ~/project/main.tex` and enjoy the technicolor:

![Demo TTY GIF](tty.gif?raw=true "Demo TTY GIF")

## Usage

In essence, Многоꙮтех
1. takes the _source_ directory of a project, 
2. clones it into _target_ directories (one for each _job_),
3. applies a different source code transformation to each one and then
4. attempts to compile them.

Its convenience lies in the fact that it
* automates the setup process,
* parallelizes compilation,
* filters and colour codes the infamous waterfall logs and
* allows you to easily navigate through targets/source folders. 

Многоꙮтех can be invoked from commandline in two ways: `mnogootex` and `mnogoo`.
The latter is more powerful and requires an extra [installation](#installation) step.

Commands listed below can be passed to both unless otherwise stated.

### Commands

> **NOTATION:** `[FOO]` means that _`FOO` is optional_ while `FOO ...` means _one or more `FOO`s_. 

#### `help [COMMAND]`

Prints the help for `COMMAND` (or all commands if none is given).

#### `go [JOB ...] [MAIN]`

Run given compilation `JOB`s for the `MAIN` document.

If no `JOB` list is given then all of them are run.
They are deduced from the [configuration](#configuration).

If no `MAIN` document is given then it's deduced from either
your current working directory or the [configuration](#configuration).

#### `dir [JOB] [MAIN]`

Print `JOB`'s temporary directory for the `MAIN` document.

If no `JOB` is given then it prints the source directory.

If no `MAIN` document is given then it's deduced from either
your current working directory or the [configuration](#configuration).

#### `clobber`

Deletes all temporary files.
Useful to free up some space from time to time.

#### `pdf [JOB ...] [MAIN]`

Print `JOB`'s output PDF path for the `MAIN` document.

If no `JOB` list is given then all their output PDFs paths are printed.
They are deduced from the [configuration](#configuration).

If no `MAIN` document is given then it's deduced from either
your current working directory or the [configuration](#configuration).

#### `open [JOB ...] [MAIN]`

Open `JOB`'s output PDF for the `MAIN` document with your default viewer.

If no `JOB` list is given then all their output PDFs are opened.
They are deduced from the [configuration](#configuration).

If no `MAIN` document is given then it's deduced from either
your current working directory or the [configuration](#configuration).

### Configuration

Многоꙮтех is configured through [`YAML`](https://learnxinyminutes.com/docs/yaml/)
files named `.mnogootex.yml` put into your projects' root directory.

When  loads a configuration it also looks up for `.mnogootex.yml`
files in all parent directories to merge then together (from the
shallowest to the deepest path).  This means that e.g. you can keep
a configuration file in your home folder and use it as a global
configuration for all you projects, while overwriting only specific
options in the configuration files of each one.

Многоꙮтех currently accepts three options.

#### `spinner`

This option is a string whose characters are the frames used to
animate the spinners for the command line interface.

    # Default value:
    spinner: ⣾⣽⣻⢿⡿⣟⣯⣷

#### `commandline`

This option is an array of the components for the commandline used
to compile documents.

    # Default value:
    commandline:
      - latexmk
      - -pdf
      - --interaction=nonstopmode

#### `work_path`

This option is an override for the path where compilation happens.

    # Default value:
    work_path: null

By default each run happens in a new empty folder. Overriding this allows you to easily reach the compilation artifacts, but leaves handling cleanup and conflicts with previous runs up to you.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/paolobrasolin/mnogootex. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the многоꙮтех project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/paolobrasolin/mnogootex/blob/master/CODE_OF_CONDUCT.md).
