<script>
import { ref } from "vue"

export default {
  props: { elements: Array },
  emits: ["update-element", "remove-element"],
  setup(props, { emit }) {
    const canvasRef = ref(null)
    const dragState = ref(null)

    function startDrag(item, event) {
      event.preventDefault()
      const canvasRect = canvasRef.value.getBoundingClientRect()
      dragState.value = {
        id: item.id,
        startX: event.clientX - canvasRect.left - parseInt(item.style.left),
        startY: event.clientY - canvasRect.top  - parseInt(item.style.top)
      }
    }

    function onMouseMove(event) {
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
    }

    return { startDrag, onMouseMove, onMouseUp, canvasRef }
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
        :style="{ ...item.style, position: 'absolute', border: '1px dashed #d1d5db', padding: '8px', cursor: 'move' }"
        @mousedown="startDrag(item, $event)"
      >
        <button
          @click.stop="$emit('remove-element', item.id)"
          style="position: absolute; top: -12px; right: -12px; width: 24px; height: 24px; border-radius: 50%; background: #ef4444; color: white; border: none; cursor: pointer; font-size: 14px; line-height: 1; display: flex; align-items: center; justify-content: center;"
        >×</button>
        <span v-if="item.type === 'text'">{{ item.props.text || 'Text' }}</span>
        <a v-else-if="item.type === 'button'" :href="item.props.href">{{ item.props.label || 'Button' }}</a>
        <img v-else-if="item.type === 'image'" :src="item.props.src" alt="" />
      </div>
    </div>
  </div>
</template>