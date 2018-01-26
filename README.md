# Многоꙮтех

Многоꙮтех (mnogootex) is a utility that parallelizes compilation
of a LaTeX document using different classes and offers a
meaningfully filtered output.

The motivating use case is maintaining a single preamble while
submitting a paper to many journals using their outdated or crummy
document classes.

## Installation

The only requirement is [Ruby](https://www.ruby-lang.org).

To install многоꙮтех execute

    $ gem install mnogootex
    
To setup its shell integration `mnogoo` add this to your shell profile

    [ -s $(mnogootex mnogoo) ] && source $(mnogootex mnogoo)

## Getting started

Set up your `LaTeX` project as usual.
Let's say its main file (i.e. the compilable one containing `\documentclass{...}`) is `~/project/main.tex`.

Create a configuration file `~/project_folder/.mnogootex.yml`
containing the list of document classes you want to compile your
project against:

    jobs:
      - book
      - article
      - scrartcl
      - scrbook
      
Run `mnogootex`:

    $ mnogootex go ~/project/main.tex
    Jobs: ⣾⣯⣷⣟
    Details:
      ✔ book
      ✔ article
      ✔ scrartcl
      ✔ scrbook
      
## Usage 



## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mnogootex. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the многоꙮтех project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/mnogootex/blob/master/CODE_OF_CONDUCT.md).
