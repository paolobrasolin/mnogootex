# Многоꙮтех

[![Build Status](https://travis-ci.org/paolobrasolin/mnogootex.svg?branch=master)](https://travis-ci.org/paolobrasolin/mnogootex)
[![Gem Version](https://badge.fury.io/rb/mnogootex.svg)](https://badge.fury.io/rb/mnogootex)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

[![Code Climate](https://codeclimate.com/github/paolobrasolin/mnogootex/badges/gpa.svg)](https://codeclimate.com/github/paolobrasolin/mnogootex)
[![Test Coverage](https://codeclimate.com/github/paolobrasolin/mnogootex/badges/coverage.svg)](https://codeclimate.com/github/paolobrasolin/mnogootex/coverage)
[![Inline docs](http://inch-ci.org/github/paolobrasolin/mnogootex.svg?branch=master)](http://inch-ci.org/github/paolobrasolin/mnogootex)
[![Issue Count](https://codeclimate.com/github/paolobrasolin/mnogootex/badges/issue_count.svg)](https://codeclimate.com/github/paolobrasolin/mnogootex)

Многоꙮтех (mnogootex) is a utility that parallelizes compilation
of a LaTeX document using different classes and offers a
meaningfully filtered output.

The motivating use case is maintaining a single preamble while
submitting a paper to many journals using their outdated or crummy
document classes.

## Installation

The only requirement is [Ruby](https://www.ruby-lang.org) (>=2.3).

To install многоꙮтех execute

    gem install mnogootex
    
To install `mnogoo` (strongly recommended shell integration) add this to your shell profile

    [ -s "$(mnogootex mnogoo)" ] && . "$(mnogootex mnogoo)"

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

<!-- ## Usage  -->


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/paolobrasolin/mnogootex. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the многоꙮтех project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/paolobrasolin/mnogootex/blob/master/CODE_OF_CONDUCT.md).
