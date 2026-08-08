// Entry point for the application bundle, loaded via importmap.
import '@hotwired/turbo-rails'
import feather from 'feather-icons'

// Bootstrap wires up its own data-api handlers on import, which is what drives
// the dismissable flash alerts. Nothing here needs its exports directly.
import 'bootstrap'

// Swap the <span data-feather="..."> placeholders for real SVGs. This has to run
// on every Turbo visit, not just the first page load: Turbo replaces the body
// without a full navigation, so anything that decorates the DOM must re-run.
document.addEventListener('turbo:load', () => feather.replace())
