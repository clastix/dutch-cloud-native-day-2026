<!-- Section divider. Frontmatter: `number` (e.g. "01"). -->
<script setup lang="ts">
defineProps<{ number?: string }>()
</script>

<template>
  <div class="slidev-layout cx-dark cx-section">
    <img class="cx-ghost" src="/brand/clastix_symbol_ghost.svg" alt="" aria-hidden="true">
    <div class="cx-section-body">
      <p v-if="number" class="cx-section-number">{{ number }}</p>
      <slot />
    </div>
  </div>
</template>
