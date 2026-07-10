<script>
export default {
  props: { element: Object }
}
</script>

<template>
  <div style="width: 224px; min-width: 224px; border-left: 1px solid #e5e7eb; background: white; overflow-y: auto; display: flex; flex-direction: column;">

    <div v-if="!element" style="padding: 20px 16px; color: #9ca3af; font-size: 13px; text-align: center; margin-top: 40px;">
      <div style="margin-bottom: 6px; font-size: 20px;">☝️</div>
      Click an element to edit its properties
    </div>

    <template v-else>
      <div style="padding: 12px 16px; border-bottom: 1px solid #e5e7eb; display: flex; align-items: center;">
        <span style="font-size: 11px; font-weight: 600; color: #6b7280; text-transform: uppercase; letter-spacing: 0.06em;">{{ element.type }}</span>
      </div>

      <div style="padding: 16px; display: flex; flex-direction: column; gap: 14px;">

        <!-- TEXT -->
        <template v-if="element.type === 'text'">
          <div class="field">
            <label class="label">Content</label>
            <textarea :value="element.props.text" @input="element.props.text = $event.target.value" rows="3" class="input" style="resize: vertical;" />
          </div>
          <div class="field">
            <label class="label">Font size</label>
            <div style="display: flex; align-items: center; gap: 6px;">
              <input type="number" min="8" max="120" :value="parseInt(element.style.fontSize) || 16" @input="element.style.fontSize = $event.target.value + 'px'" class="input" style="width: 72px;" />
              <span class="unit">px</span>
            </div>
          </div>
          <div class="field">
            <label class="label">Color</label>
            <div style="display: flex; align-items: center; gap: 8px;">
              <input type="color" :value="element.style.color || '#1a1a17'" @input="element.style.color = $event.target.value" class="swatch" />
              <input type="text" :value="element.style.color || '#1a1a17'" @input="element.style.color = $event.target.value" class="input mono" placeholder="#1a1a17" />
            </div>
          </div>
          <div class="field">
            <label class="label">Font weight</label>
            <select :value="element.style.fontWeight || '400'" @change="element.style.fontWeight = $event.target.value" class="input">
              <option value="400">Regular</option>
              <option value="500">Medium</option>
              <option value="600">Semibold</option>
              <option value="700">Bold</option>
            </select>
          </div>
        </template>

        <!-- BUTTON -->
        <template v-else-if="element.type === 'button'">
          <div class="field">
            <label class="label">Label</label>
            <input type="text" :value="element.props.label" @input="element.props.label = $event.target.value" class="input" />
          </div>
          <div class="field">
            <label class="label">Link URL</label>
            <input type="text" :value="element.props.href" @input="element.props.href = $event.target.value" class="input" placeholder="https://" />
          </div>
          <div class="field">
            <label class="label">Background</label>
            <div style="display: flex; align-items: center; gap: 8px;">
              <input type="color" :value="element.style.backgroundColor || '#0a7065'" @input="element.style.backgroundColor = $event.target.value" class="swatch" />
              <input type="text" :value="element.style.backgroundColor || '#0a7065'" @input="element.style.backgroundColor = $event.target.value" class="input mono" placeholder="#0a7065" />
            </div>
          </div>
          <div class="field">
            <label class="label">Text color</label>
            <div style="display: flex; align-items: center; gap: 8px;">
              <input type="color" :value="element.style.color || '#ffffff'" @input="element.style.color = $event.target.value" class="swatch" />
              <input type="text" :value="element.style.color || '#ffffff'" @input="element.style.color = $event.target.value" class="input mono" placeholder="#ffffff" />
            </div>
          </div>
          <div class="field">
            <label class="label">Border radius</label>
            <div style="display: flex; align-items: center; gap: 6px;">
              <input type="number" min="0" max="999" :value="parseInt(element.style.borderRadius) || 6" @input="element.style.borderRadius = $event.target.value + 'px'" class="input" style="width: 72px;" />
              <span class="unit">px</span>
            </div>
          </div>
          <div class="field">
            <label class="label">Font size</label>
            <div style="display: flex; align-items: center; gap: 6px;">
              <input type="number" min="8" max="72" :value="parseInt(element.style.fontSize) || 14" @input="element.style.fontSize = $event.target.value + 'px'" class="input" style="width: 72px;" />
              <span class="unit">px</span>
            </div>
          </div>
        </template>

        <!-- IMAGE -->
        <template v-else-if="element.type === 'image'">
          <div class="field">
            <label class="label">Image URL</label>
            <input type="text" :value="element.props.src" @input="element.props.src = $event.target.value" class="input" placeholder="https://..." />
          </div>
          <div v-if="element.props.src" style="border: 1px solid #e3e3df; border-radius: 6px; overflow: hidden; background: #f5f5f2;">
            <img :src="element.props.src" :alt="element.props.alt || ''" style="width: 100%; display: block; max-height: 120px; object-fit: cover;" />
          </div>
          <div class="field">
            <label class="label">Alt text</label>
            <input type="text" :value="element.props.alt || ''" @input="element.props.alt = $event.target.value" class="input" placeholder="Describe the image" />
          </div>
        </template>

        <!-- COMMON: dimensions -->
        <div style="border-top: 1px solid #f0f0ee; padding-top: 14px; display: flex; flex-direction: column; gap: 10px;">
          <div class="field">
            <label class="label">Width</label>
            <div style="display: flex; align-items: center; gap: 6px;">
              <input type="number" min="20" :value="parseInt(element.style.width) || 200" @input="element.style.width = $event.target.value + 'px'" class="input" style="width: 80px;" />
              <span class="unit">px</span>
            </div>
          </div>
          <div class="field">
            <label class="label">Height <span style="font-weight:400; color: #b0b0b0;">(auto if empty)</span></label>
            <div style="display: flex; align-items: center; gap: 6px;">
              <input type="number" min="20" :value="parseInt(element.style.height) || ''" @input="element.style.height = $event.target.value ? $event.target.value + 'px' : undefined" class="input" style="width: 80px;" placeholder="auto" />
              <span class="unit">px</span>
            </div>
          </div>
        </div>

      </div>
    </template>
  </div>
</template>

<style scoped>
.field { display: flex; flex-direction: column; gap: 5px; }
.label { font-size: 12px; font-weight: 500; color: #6b7280; }
.input { padding: 6px 9px; border: 1px solid #e3e3df; border-radius: 5px; font-size: 13px; color: #1a1a17; background: white; outline: none; width: 100%; box-sizing: border-box; font-family: inherit; }
.input:focus { border-color: #0a7065; box-shadow: 0 0 0 2px rgba(10,112,101,0.1); }
.mono { font-family: monospace; width: 88px; }
.swatch { width: 32px; height: 28px; border: 1px solid #e3e3df; border-radius: 4px; padding: 2px; cursor: pointer; flex-shrink: 0; }
.unit { font-size: 12px; color: #9ca3af; }
</style>
