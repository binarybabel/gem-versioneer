# Versioneer

[![Build Status](https://travis-ci.org/binarybabel/gem-versioneer.svg?branch=master)](https://travis-ci.org/binarybabel/gem-versioneer)
[![Build status](https://ci.appveyor.com/api/projects/status/k3i9rbgy2q8xdl78/branch/master?svg=true)](https://ci.appveyor.com/project/babelop/gem-versioneer/branch/master)

__Dynamic project versioning (alpha/beta/rc) from commits since last Git Tag.__

Versioneer **determines a project's version** from the latest source-control tag, then **adjusts automatically** by adding/bumping prereleases based on changes made since the last tagged release.

Integration tested on **UNIX/MacOS and Windows**.

## Overview

#### Non-production environments (default settings)

* No changes since last VCS Tag (Ex. v0.1.0)
  - **Same as Tag** `0.1.0`
* Uncommitted changes
  - **Minor Bump + Alpha** `0.2.alpha1`
* First commit
  - **Minor Bump + Beta** `0.2.beta1`
* First commit with uncommitted changes
  - **Minor Bump + Alpha2** `0.2.alpha2`

#### In production

* No changes since last VCS Tag (Ex. v0.1.0)
  - **Same as Tag** `0.1.0`
* Uncommitted changes
  - **Ignored in Production** `0.1.0`
* First commit past VCS Tag
  - **Minor Bump + Release Candidate** `0.2.rc1`
  - Optionally, patches can be used instead of "rc" in production:
  - **Minor Bump + Patch** `0.1.1`

## Usage

### Ruby Project (Rails, Rack, etc.)

TODO

### Command-Line

CLI usage defaults to "production" mode, unless otherwise given by ENV variable.

```
$ git tag -am 'Release 0.1' v0.1

$ versioneer
0.1

$ git commit --allow-empty -m 'Some changes.'

$versioneer
0.2.rc1
```


## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/binarybabel/gem-versioneer.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
