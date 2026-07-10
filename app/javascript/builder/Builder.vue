<script>
import { reactive, ref, computed, watch, nextTick, onMounted, onUnmounted } from "vue"
import Sidebar from "./Sidebar.vue"
import Canvas from "./Canvas.vue"
import PropertiesPanel from "./PropertiesPanel.vue"

function debounce(fn, delay) {
  let timer
  return (...args) => {
    clearTimeout(timer)
    timer = setTimeout(() => fn(...args), delay)
  }
}

export default {
  components: { Sidebar, Canvas, PropertiesPanel },
  props: { pageId: String, initialLayout: Object, pageSlug: String, initialStatus: String },
  setup(props) {
    const layout = reactive(props.initialLayout)
    const publishStatus = ref("")
    const isPublished = ref(props.initialStatus === "published")
    const selectedId = ref(null)

    const selectedElement = computed(() =>
      layout.elements.find(e => e.id === selectedId.value) || null
    )

    // ── Autosave ──────────────────────────────────────────────────────────────
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

    // ── History (undo / redo) ─────────────────────────────────────────────────
    const history = ref([JSON.stringify(layout.elements)])
    const historyIndex = ref(0)
    const isUndoRedo = ref(false)

    const pushHistory = debounce(() => {
      const snapshot = JSON.stringify(layout.elements)
      if (snapshot === history.value[historyIndex.value]) return
      history.value = history.value.slice(0, historyIndex.value + 1)
      history.value.push(snapshot)
      if (history.value.length > 50) history.value.shift()
      historyIndex.value = history.value.length - 1
    }, 400)

    watch(layout, () => {
      if (!isUndoRedo.value) pushHistory()
    }, { deep: true, immediate: false })

    const canUndo = computed(() => historyIndex.value > 0)
    const canRedo = computed(() => historyIndex.value < history.value.length - 1)

    function undo() {
      if (!canUndo.value) return
      isUndoRedo.value = true
      historyIndex.value--
      const elements = JSON.parse(history.value[historyIndex.value])
      layout.elements.splice(0, layout.elements.length, ...elements)
      if (selectedId.value && !elements.find(e => e.id === selectedId.value)) {
        selectedId.value = null
      }
      nextTick(() => { isUndoRedo.value = false })
      autosave()
    }

    function redo() {
      if (!canRedo.value) return
      isUndoRedo.value = true
      historyIndex.value++
      const elements = JSON.parse(history.value[historyIndex.value])
      layout.elements.splice(0, layout.elements.length, ...elements)
      nextTick(() => { isUndoRedo.value = false })
      autosave()
    }

    function onKeyDown(e) {
      const mod = /Mac|iPhone|iPad/.test(navigator.platform) ? e.metaKey : e.ctrlKey
      if (!mod) return
      if (e.key === "z" && !e.shiftKey) { e.preventDefault(); undo() }
      if ((e.key === "z" && e.shiftKey) || e.key === "y") { e.preventDefault(); redo() }
    }

    onMounted(() => document.addEventListener("keydown", onKeyDown))
    onUnmounted(() => document.removeEventListener("keydown", onKeyDown))

    // ── Elements ──────────────────────────────────────────────────────────────
    const defaultProps = {
      text:   { text: "Text" },
      button: { label: "Button", href: "#" },
      image:  { src: "", alt: "" }
    }

    const defaultStyles = {
      text:   { fontSize: "16px", color: "#1a1a17", fontWeight: "400" },
      button: {
        backgroundColor: "#0a7065", color: "#ffffff",
        borderRadius: "6px", fontSize: "14px", fontWeight: "600",
        padding: "8px 16px", textDecoration: "none", display: "inline-block"
      },
      image:  {}
    }

    function addElement(type) {
      const offset = layout.elements.length * 20
      const id = crypto.randomUUID()
      layout.elements.push({
        id,
        type,
        props: { ...defaultProps[type] },
        style: { top: `${20 + offset}px`, left: `${20 + offset}px`, width: "200px", ...defaultStyles[type] }
      })
      selectedId.value = id
    }

    function updateElement(id, changes) {
      const el = layout.elements.find(e => e.id === id)
      Object.assign(el.style, changes.style || {})
      Object.assign(el.props, changes.props || {})
    }

    function removeElement(id) {
      const index = layout.elements.findIndex(e => e.id === id)
      if (index !== -1) layout.elements.splice(index, 1)
      if (selectedId.value === id) selectedId.value = null
    }

    const isPublishing = ref(false)

    async function publish() {
      if (isPublishing.value) return
      isPublishing.value = true
      publishStatus.value = "Saving..."
      const csrf = document.querySelector('meta[name="csrf-token"]').content

      // Flush any pending autosave first so the DB has the latest layout
      await fetch(`/pages/${props.pageId}`, {
        method: "PATCH",
        headers: { "Content-Type": "application/json", "X-CSRF-Token": csrf },
        body: JSON.stringify({ page: { layout } })
      })

      const res = await fetch(`/pages/${props.pageId}/publish`, {
        method: "POST",
        headers: { "X-CSRF-Token": csrf }
      })

      if (!res.ok) {
        publishStatus.value = "Publish failed."
        isPublishing.value = false
        return
      }

      const { queued_at } = await res.json()
      publishStatus.value = "Processing..."

      const poll = setInterval(async () => {
        const r = await fetch(`/pages/${props.pageId}/publication_status`)
        const { published_at } = await r.json()
        if (published_at && new Date(published_at) >= new Date(queued_at)) {
          clearInterval(poll)
          publishStatus.value = "Published!"
          isPublished.value = true
          isPublishing.value = false
        }
      }, 1000)
    }

    return {
      layout, addElement, updateElement, removeElement,
      publish, publishStatus, isPublished, isPublishing,
      selectedId, selectedElement,
      undo, redo, canUndo, canRedo
    }
  }
}
</script>

<template>
  <div style="display: flex; flex-direction: column; height: 100vh;">
    <div style="display: flex; align-items: center; justify-content: space-between; padding: 0 20px; height: 52px; border-bottom: 1px solid #E3E3DF; background: white;">

      <!-- Left: nav + title -->
      <div style="display: flex; align-items: center; gap: 12px; min-width: 0;">
        <a href="/pages" style="font-size: 13px; color: #6B6B64; text-decoration: none; white-space: nowrap; flex-shrink: 0;">← My Pages</a>
        <span style="width: 1px; height: 16px; background: #E3E3DF; flex-shrink: 0;"></span>
        <span style="font-weight: 600; font-size: 14px; color: #1A1A17; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Landing Page Builder</span>
      </div>

      <!-- Center: undo / redo -->
      <div style="display: flex; align-items: center; gap: 4px;">
        <button @click="undo" :disabled="!canUndo" :class="['hist-btn', { 'hist-btn--active': canUndo }]" title="Undo ⌘Z">Undo</button>
        <button @click="redo" :disabled="!canRedo" :class="['hist-btn', { 'hist-btn--active': canRedo }]" title="Redo ⌘⇧Z">Redo</button>
      </div>

      <!-- Right: status + actions -->
      <div style="display: flex; align-items: center; gap: 8px;">
        <span style="font-size: 12px; color: #6B6B64;">{{ publishStatus }}</span>
        <a
          v-if="isPublished"
          :href="`/p/${pageSlug}`"
          target="_blank"
          style="padding: 7px 13px; background: white; color: #0a7065; border: 1px solid #A8DFD7; border-radius: 6px; font-size: 13px; font-weight: 600; text-decoration: none;"
        >View ↗</a>
        <button
          @click="publish"
          :disabled="isPublishing"
          :style="`background: ${isPublishing ? '#6B6B64' : '#0a7065'}; color: white; border: none; padding: 7px 16px; border-radius: 6px; cursor: ${isPublishing ? 'not-allowed' : 'pointer'}; font-size: 13px; font-weight: 600;`"
        >Publish</button>
      </div>
    </div>

    <div style="display: flex; flex: 1; overflow: hidden;">
      <Sidebar @add-element="addElement" />
      <Canvas
        :elements="layout.elements"
        :selectedId="selectedId"
        @update-element="updateElement"
        @remove-element="removeElement"
        @select-element="selectedId = $event"
      />
      <PropertiesPanel :element="selectedElement" />
    </div>
  </div>
</template>

<style scoped>
.hist-btn {
  padding: 6px 10px;
  background: transparent;
  border: none;
  border-radius: 6px;
  cursor: not-allowed;
  color: #E3E3DF;
  font-size: 13px;
  font-weight: 600;
  font-family: inherit;
  transition: background 0.1s, color 0.1s;
}
.hist-btn--active { cursor: pointer; color: #6B6B64; }
.hist-btn--active:hover { background: #E3E3DF; color: #1A1A17; }
.hist-btn--active:active { background: #d8d8d3; color: #1A1A17; }
</style>
