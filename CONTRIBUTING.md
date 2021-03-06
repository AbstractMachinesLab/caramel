# Contributing to Caramel :candy:

First of all, thanks for taking the time to contribute! :heart::tada::+1:

[See the Caramel architecture drawing](./docs/caramel_arch.jpg)

## Getting started

You can bootstrap the system by running:

```sh
caramel $ make deps build
```

It relies on `opam` being installed, and `make deps` will take care of
installing all the necessary `opam` dependencies.

The target `make watch` will start the Dune build watcher, and recompile the
project as you save files.

You can run tests with `make install test`, and reformat the source code with `make
fmt`.

For a more in-depth description of what's happening, check the documentation of
each compilation pipeline.

## Codebase

The Caramel codebase is structured to explore a few things:

* `./caramel/bin` -- the `caramel` binary

* `./caramel/compiler` -- includes the compilation pipelines

* `./caramel/formatter` -- the code formatter

* `./caramel/lsp` -- the language server

* `./stdlib` -- the standard libraries shipped with Caramel


The libraries for manipulating Erlang from within OCaml are here:

* `./erlang` -- it has includes lexers, parsers, ASTs, printers

## Working with various ASTs

For better understanding of various structures that the compiler and libraries
manipulate, Caramel provides a `caramel parse` command. For example, to display
a textual representation of OCaml compiler's Typedtree for a `main.ml` file,
you can use this command:

```sh
caramel parse -l ml -t type main.ml
```

See `caramel parse --help` and `./caramel/bin/cmd_parse.ml` to learn more.

## Release Flow

Releasing Caramel should be pretty straightforward as most of the work is
automated.

* On every commit the CI workflows will publish intermediary artifacts that we
  can use to verify that the build is still good in case we made some large
  changes.

* If we make a new tag of the form `vX.Y.Z`, then the workflows will also create
  a release draft for us and publish all the appropriate artifacts there.

* After this we can manually edit the release name and contents and publish it.

Optionally, when publishing the OPAM libraries, we'd want to make sure the
`CHANGES.md` file contains a good overview of what has been changed. In turn,
keeping this file up to date also helps since most of it will overlap with the
release notes.

Then we can run `make opam-publish`, after the release has been tagged and
created on Github, to update the `opam-repository` fork and submit the libraries
to OPAM.

This process is not automated since I'd like Caramel to be released as often as
we can, but the OPAM libraries may not be updated on every release.
