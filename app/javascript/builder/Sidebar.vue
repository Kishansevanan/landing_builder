vue
<script>
export default {
  emits: ["add-element"],
  setup(_, { emit }) {
    return {
      add: (type) => emit("add-element", type)
    }
  }
}
</script>

<template>
  <div class="sidebar w-48 bg-gray-100 p-4 flex flex-col gap-2">
    <p class="font-bold text-sm mb-2">Elements</p>
    <button @click="add('text')"   class="btn">+ Text</button>
    <button @click="add('button')" class="btn">+ Button</button>
    <button @click="add('image')"  class="btn">+ Image</button>
  </div>
</template>