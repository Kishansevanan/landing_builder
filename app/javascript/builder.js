import { createApp } from "vue"
import Builder from "./builder/Builder.vue"

document.addEventListener("DOMContentLoaded", () => {
  const el = document.getElementById("builder-root")
  if (!el) return
  createApp(Builder, {
    pageId: el.dataset.pageId,
    initialLayout: JSON.parse(el.dataset.layout),
    pageSlug: el.dataset.slug,
    initialPublished: el.dataset.published
  }).mount(el)
})