# Versioneer

[![Gem Version](https://badge.fury.io/rb/versioneer.svg)](https://badge.fury.io/rb/versioneer)
[![Build Status](https://travis-ci.org/binarybabel/gem-versioneer.svg?branch=master)](https://travis-ci.org/binarybabel/gem-versioneer)
[![Build status](https://ci.appveyor.com/api/projects/status/k3i9rbgy2q8xdl78/branch/master?svg=true)](https://ci.appveyor.com/project/babelop/gem-versioneer/branch/master)
[![Code Climate](https://codeclimate.com/github/binarybabel/gem-versioneer/badges/gpa.svg)](https://codeclimate.com/github/binarybabel/gem-versioneer)
[![Test Coverage](https://codeclimate.com/github/binarybabel/gem-versioneer/badges/coverage.svg)](https://codeclimate.com/github/binarybabel/gem-versioneer/coverage)

__Dynamic project versioning (alpha/beta/rc) from commits since last Git Tag.__

Versioneer **determines a project's version** from the latest source-control tag, then **adjusts automatically** by adding/bumping prereleases based on changes made since the last tagged release.

Integration tested on **UNIX/macOS and Windows**.

## Overview

Project versions update automatically based on VCS changes and where the code has been deployed. The table below depicts the default settings; the prerelease workflow is customizable through code or a project config file.

| VCS State | Last Tag/Release | Development Ver. | Production Ver. |
| --- | --- | --- | --- |
| No changes since last tag | v0.1.0 | `0.1.0` *Same as Tag* | `0.1.0` *Same as Tag* |
| Uncommitted changes | v0.1.0 | `0.2.alpha1` | `0.1.0` *Same as Tag* |
| First commit | v0.1.0 | `0.2.beta1` | `0.2.rc1` **or** `0.1.1` |
| First commit + Changes | v0.1.0 | `0.2.alpha2` | `0.2.rc1` **or** `0.1.1` |
| Second commit | v0.1.0 | `0.2.beta2` | `0.2.rc2` **or** `0.1.2` |
| Tag previous commit | v0.2.0 | `0.2.0` | `0.2.0` |

## Usage

* [Configuration options are documented in the Wiki.](https://github.com/binarybabel/gem-versioneer/wiki)
* The Versioneer environment is selected from the following system variables:
   * _Any value other than "production" is assumed to be "development"_

```
ENV['VERSIONEER_ENV'] || ENV['RAILS_ENV'] || ENV['RACK_ENV'] || ENV['ENV']
```

### Command-Line

CLI usage defaults to "production" mode.

```
$ git tag -am 'Release 0.1' v0.1
...
$ versioneer
0.1
...
$ git commit --allow-empty -m 'Some changes.'
...
$ versioneer
0.2.rc1
...
$ versioneer --help
```

### Ruby Project (Rails, Rack, etc.)

* Add Versioneer to your Gemfile

```
gem 'versioneer', '~> 0.1'
...
$ bundle install
```

* Generate a config file

```
$ bundle exec versioneer init
...
Generating config
+ .versioneer.yml
```

* Modify your project's version variable

```
require 'versioneer'
module MyApp
  VERSION = Versioneer::Config.new(Rails.root).version.to_s
end
```

## Settings & Customization

**[Check out the Versioneer Wiki for more information](https://github.com/binarybabel/gem-versioneer/wiki)**

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/binarybabel/gem-versioneer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
