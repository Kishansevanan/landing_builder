vue
<script>
import { reactive, ref, watch } from "vue"
import Sidebar from "./Sidebar.vue"
import Canvas from "./Canvas.vue"

function debounce(fn, delay) {
  let timer
  return (...args) => {
    clearTimeout(timer)
    timer = setTimeout(() => fn(...args), delay)
  }
}

export default {
  components: { Sidebar, Canvas },
  props: { pageId: String, initialLayout: Object, pageSlug: String, initialStatus: String },
  setup(props) {
    const layout = reactive(props.initialLayout)
    const publishStatus = ref("")
    const isPublished = ref(props.initialStatus === "published")

    const autosave = debounce(() => {
      fetch(`/pages/${props.pageId}`, {
        method: "PATCH",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        },
        body: JSON.stringify({ page: { layout } })
      })
    }, 800)

    watch(layout, autosave, { deep: true, immediate: false })

    const defaultProps = {
      text:   { text: "Text" },
      button: { label: "Button", href: "#" },
      image:  { src: "" }
    }

    function addElement(type) {
      const offset = layout.elements.length * 20
      layout.elements.push({
        id: crypto.randomUUID(),
        type,
        props: { ...defaultProps[type] },
        style: { top: `${20 + offset}px`, left: `${20 + offset}px`, width: "200px" }
      })
    }

    function updateElement(id, changes) {
      const el = layout.elements.find(e => e.id === id)
      Object.assign(el.style, changes.style || {})
      Object.assign(el.props, changes.props || {})
    }

    function removeElement(id) {
      const index = layout.elements.findIndex(e => e.id === id)
      if (index !== -1) layout.elements.splice(index, 1)
    }

    function publish() {
      publishStatus.value = "Publishing..."
      fetch(`/pages/${props.pageId}/publish`, {
        method: "POST",
        headers: {
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content
        }
      }).then(res => {
        if (res.ok) {
          publishStatus.value = "Published!"
          isPublished.value = true
        } else {
          publishStatus.value = "Publish failed."
        }
      })
    }

    return { layout, addElement, updateElement, removeElement, publish, publishStatus, isPublished }
  }
}
</script>

<template>
  <div style="display: flex; flex-direction: column; height: 100vh;">
    <div style="display: flex; align-items: center; justify-content: space-between; padding: 12px 20px; border-bottom: 1px solid #e5e7eb; background: white;">
      <div style="display: flex; align-items: center; gap: 14px;">
        <a href="/pages" style="font-size: 13px; color: #6b7280; text-decoration: none;">← My Pages</a>
        <span style="font-weight: 600; font-size: 15px;">Landing Page Builder</span>
      </div>
      <div style="display: flex; align-items: center; gap: 10px;">
        <span style="font-size: 13px; color: #6b7280;">{{ publishStatus }}</span>
        <a
          v-if="isPublished"
          :href="`/p/${pageSlug}`"
          target="_blank"
          style="padding: 8px 14px; background: white; color: #0a7065; border: 1px solid #A8DFD7; border-radius: 6px; font-size: 14px; font-weight: 600; text-decoration: none; cursor: pointer;"
        >View ↗</a>
        <button
          @click="publish"
          style="background: #0a7065; color: white; border: none; padding: 8px 18px; border-radius: 6px; cursor: pointer; font-size: 14px; font-weight: 600;"
        >Publish</button>
      </div>
    </div>
    <div style="display: flex; flex: 1; overflow: hidden;">
      <Sidebar @add-element="addElement" />
      <Canvas :elements="layout.elements" @update-element="updateElement" @remove-element="removeElement" />
    </div>
  </div>
</template>