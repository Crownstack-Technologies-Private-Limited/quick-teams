// Browser side of the `data-reflex` actions (replaces StimulusReflex; see app/reflexes/application_reflex.rb).
//
//   <button data-reflex="click->ProjectStatus#change" data-project-id="1" data-status-id="2">
//
// A matching event is cancelled (as StimulusReflex did) and the element's data attributes are posted to
// /:account/reflex_actions. Turbo Stream responses are applied by @rails/request.js; an empty response
// means "page morph": the current page is fetched again and morphed in place. With
// data-reflex-dataset="combined" the data attributes of all ancestors are sent too.
import { post } from "@rails/request.js"
import { Turbo } from "@hotwired/turbo-rails"

const SKIPPED_ATTRIBUTES = /^data-(reflex|action$|controller$|turbo)/

function reflexFor(element, eventType) {
  const declarations = (element.getAttribute("data-reflex") || "").trim().split(/\s+/)
  const match = declarations.find((declaration) => declaration.split("->")[0] === eventType)
  return match && match.split("->")[1]
}

function datasetFor(element) {
  const elements = [element]
  if (element.getAttribute("data-reflex-dataset") === "combined") {
    for (let parent = element.parentElement; parent; parent = parent.parentElement) elements.push(parent)
  }

  const dataset = {}
  // Outermost first, so the element's own attributes win.
  for (const el of elements.reverse()) {
    for (const attribute of el.attributes) {
      if (attribute.name.startsWith("data-") && !SKIPPED_ATTRIBUTES.test(attribute.name)) {
        dataset[attribute.name.slice(5)] = attribute.value
      }
    }
  }
  return dataset
}

function accountPath() {
  const meta = document.querySelector("meta[name='current-account']")
  return meta ? `/${meta.getAttribute("content")}` : ""
}

async function morphPage() {
  const response = await fetch(window.location.href, { headers: { Accept: "text/html" }, cache: "no-store", credentials: "same-origin" })
  if (!response.ok) return

  const newDocument = new DOMParser().parseFromString(await response.text(), "text/html")
  Turbo.morphChildren(document.body, newDocument.body, {
    callbacks: { beforeNodeMorphed: (currentElement) => !currentElement.hasAttribute?.("data-reflex-permanent") }
  })
  document.dispatchEvent(new CustomEvent("reflex-actions:morphed"))
}

async function perform(element, reflex) {
  const [name, action] = reflex.split("#")
  document.documentElement.setAttribute("data-reflex-busy", "")
  try {
    const response = await post(`${accountPath()}/reflex_actions`, {
      body: JSON.stringify({ reflex: name, reflex_action: action, dataset: datasetFor(element), page_path: window.location.pathname }),
      contentType: "application/json",
      responseKind: "turbo-stream"
    })
    if (response.statusCode === 204) await morphPage()
  } finally {
    document.documentElement.removeAttribute("data-reflex-busy")
  }
}

for (const eventType of ["click"]) {
  // Capture phase, so it runs before (and stops) other handlers, as StimulusReflex's action did.
  document.addEventListener(eventType, (event) => {
    const element = event.target.closest?.("[data-reflex]")
    const reflex = element && reflexFor(element, event.type)
    if (!reflex) return

    event.preventDefault()
    event.stopPropagation()
    perform(element, reflex)
  }, true)
}
