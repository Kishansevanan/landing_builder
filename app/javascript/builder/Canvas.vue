<script>
import { ref } from "vue"

const HANDLES = [
  { dir: "nw", style: { top: "-5px",  left: "-5px",                                     cursor: "nw-resize" } },
  { dir: "n",  style: { top: "-5px",  left: "50%",  transform: "translateX(-50%)",       cursor: "n-resize"  } },
  { dir: "ne", style: { top: "-5px",  right: "-5px",                                     cursor: "ne-resize" } },
  { dir: "e",  style: { top: "50%",   right: "-5px", transform: "translateY(-50%)",      cursor: "e-resize"  } },
  { dir: "se", style: { bottom: "-5px", right: "-5px",                                   cursor: "se-resize" } },
  { dir: "s",  style: { bottom: "-5px", left: "50%", transform: "translateX(-50%)",      cursor: "s-resize"  } },
  { dir: "sw", style: { bottom: "-5px", left: "-5px",                                    cursor: "sw-resize" } },
  { dir: "w",  style: { top: "50%",   left: "-5px",  transform: "translateY(-50%)",      cursor: "w-resize"  } },
]

export default {
  props: { elements: Array, selectedId: String },
  emits: ["update-element", "remove-element", "select-element"],
  setup(props, { emit }) {
    const canvasRef = ref(null)
    const dragState = ref(null)
    const resizeState = ref(null)
    const elementRefs = {}

    function startDrag(item, event) {
      event.preventDefault()
      emit("select-element", item.id)
      const canvasRect = canvasRef.value.getBoundingClientRect()
      dragState.value = {
        id: item.id,
        startX: event.clientX - canvasRect.left - parseInt(item.style.left),
        startY: event.clientY - canvasRect.top  - parseInt(item.style.top)
      }
    }

    function startResize(item, direction, event) {
      event.preventDefault()
      event.stopPropagation()
      const domEl = elementRefs[item.id]
      const rect = domEl ? domEl.getBoundingClientRect() : null
      resizeState.value = {
        id: item.id,
        direction,
        startX: event.clientX,
        startY: event.clientY,
        initialWidth:  parseInt(item.style.width)  || (rect ? Math.round(rect.width)  : 200),
        initialHeight: parseInt(item.style.height) || (rect ? Math.round(rect.height) : 40),
        initialLeft:   parseInt(item.style.left)   || 0,
        initialTop:    parseInt(item.style.top)    || 0,
      }
    }

    function onMouseMove(event) {
      if (resizeState.value) {
        const { id, direction, startX, startY, initialWidth, initialHeight, initialLeft, initialTop } = resizeState.value
        const dx = event.clientX - startX
        const dy = event.clientY - startY
        const style = {}

        if (direction.includes("e")) {
          style.width = Math.max(40, initialWidth + dx) + "px"
        }
        if (direction.includes("w")) {
          const w = Math.max(40, initialWidth - dx)
          style.width = w + "px"
          style.left  = (initialLeft + initialWidth - w) + "px"
        }
        if (direction.includes("s")) {
          style.height = Math.max(20, initialHeight + dy) + "px"
        }
        if (direction.includes("n")) {
          const h = Math.max(20, initialHeight - dy)
          style.height = h + "px"
          style.top    = (initialTop + initialHeight - h) + "px"
        }

        emit("update-element", id, { style })
        return
      }

      if (!dragState.value) return
      const canvasRect = canvasRef.value.getBoundingClientRect()
      const { id, startX, startY } = dragState.value
      emit("update-element", id, {
        style: {
          left: (event.clientX - canvasRect.left - startX) + "px",
          top:  (event.clientY - canvasRect.top  - startY) + "px"
        }
      })
    }

    function onMouseUp() {
      dragState.value = null
      resizeState.value = null
    }

    function onCanvasClick(event) {
      if (event.target === canvasRef.value) emit("select-element", null)
    }

    return { startDrag, startResize, onMouseMove, onMouseUp, onCanvasClick, canvasRef, elementRefs, HANDLES }
  }
}
</script>

<template>
  <div style="flex: 1; background: #f0f0f0; overflow-y: auto; padding: 32px; border-left: 1px solid #e5e7eb;">
    <div
      ref="canvasRef"
      style="position: relative; background: white; border: 1px solid #d1d5db; min-height: 800px; width: 100%; box-shadow: 0 2px 8px rgba(0,0,0,0.08);"
      @mousemove="onMouseMove"
      @mouseup="onMouseUp"
      @mouseleave="onMouseUp"
      @mousedown="onCanvasClick"
    >
      <div
        v-if="!elements || elements.length === 0"
        style="position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; pointer-events: none;"
      >
        <div style="text-align: center;">
          <div style="font-size: 14px; font-weight: 500; margin-bottom: 4px; color: #6b7280;">Canvas is empty</div>
          <div style="font-size: 13px; color: #9ca3af;">Click an element type in the sidebar to add it</div>
        </div>
      </div>

      <div
        v-for="item in elements"
        :key="item.id"
        :ref="el => { if (el) elementRefs[item.id] = el; else delete elementRefs[item.id] }"
        :style="{
          ...item.style,
          position: 'absolute',
          border: item.id === selectedId ? '2px solid #0a7065' : '1px dashed #d1d5db',
          padding: '8px',
          cursor: 'move',
          boxSizing: 'border-box',
          userSelect: 'none',
        }"
        @mousedown="startDrag(item, $event)"
      >
        <!-- delete button -->
        <button
          @click.stop="$emit('remove-element', item.id)"
          style="position: absolute; top: -12px; right: -12px; width: 22px; height: 22px; border-radius: 50%; background: #ef4444; color: white; border: none; cursor: pointer; font-size: 13px; line-height: 1; display: flex; align-items: center; justify-content: center; z-index: 20;"
        >×</button>

        <!-- resize handles (selected only) -->
        <template v-if="item.id === selectedId">
          <div
            v-for="h in HANDLES"
            :key="h.dir"
            :style="{ position: 'absolute', width: '8px', height: '8px', background: 'white', border: '1.5px solid #0a7065', borderRadius: '2px', zIndex: 15, ...h.style }"
            @mousedown.stop="startResize(item, h.dir, $event)"
          />
        </template>

        <!-- element content -->
        <span
          v-if="item.type === 'text'"
          :style="{ fontSize: item.style.fontSize, color: item.style.color, fontWeight: item.style.fontWeight, display: 'block' }"
        >{{ item.props.text || "Text" }}</span>

        <a
          v-else-if="item.type === 'button'"
          :href="item.props.href"
          :style="{
            display: item.style.display || 'inline-block',
            padding: item.style.padding || '8px 16px',
            background: item.style.backgroundColor || '#0a7065',
            color: item.style.color || '#ffffff',
            borderRadius: item.style.borderRadius || '6px',
            fontSize: item.style.fontSize || '14px',
            textDecoration: item.style.textDecoration || 'none',
            fontWeight: item.style.fontWeight || '600',
            pointerEvents: 'none',
          }"
        >{{ item.props.label || "Button" }}</a>

        <img
          v-else-if="item.type === 'image'"
          :src="item.props.src"
          :alt="item.props.alt || ''"
          style="max-width: 100%; display: block;"
        />
      </div>
    </div>
  </div>
</template>
