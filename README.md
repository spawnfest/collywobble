# Collywobble

Collywobble is an experiment in collaborative editing of content
using LiveView.

## Usage

This application assumes that `asdf` is used to install Erlang and
Elixir. Setup the application locally using the following commands:

```shell
bin/dev/doctor
bin/dev/start
```

1. Open two browsers to `http://localhost:4000`. In one browser, enter a
   pad id, for example `my-note`.
1. Copy the url.
1. Paste the url into the second browser.
1. Edit/add text in each browser. Updates should appear in the other browser.
1. Select text in each browser. Cursor/highlights should appear in the other
   browser.

## Known issues

- Adding empty lines of text causes the current cursor to jump around.
- Sometimes the JS for getting the current selection gives back data that
  doesn't seem to work, either in the current browser or in observing
  browsers.

## Development

```shell
bin/dev/doctor
bin/dev/start
bin/dev/update
bin/dev/shipit
```
