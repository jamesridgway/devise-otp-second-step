# Pin npm packages by running ./bin/importmap

pin 'application', preload: true
pin '@hotwired/turbo-rails', to: 'turbo.min.js', preload: true

pin "bootstrap" # @5.3.8
# Bootstrap imports Popper, so it has to resolve even though this app uses no
# dropdowns or tooltips. Vendored from jsDelivr's bundled +esm build rather than
# via `bin/importmap pin`, which resolves to Popper's lib/index.js -- a barrel
# re-exporting several dozen relative paths that are not downloaded alongside
# it, so the import graph 404s at runtime and takes Bootstrap down with it.
pin "@popperjs/core", to: "@popperjs--core.js" # @2.11.8
pin "feather-icons" # @4.29.2
