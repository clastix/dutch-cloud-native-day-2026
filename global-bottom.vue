<!-- Footer on every content slide; dark layouts carry their own branding. -->
<script setup lang="ts">
import { computed } from 'vue'
import { useNav } from '@slidev/client'

const { currentLayout, currentPage, total } = useNav()
const visible = computed(() => !['cover', 'section', 'end'].includes(currentLayout.value))
</script>

<template>
  <footer v-if="visible" class="cx-footer">
    <img src="/brand/clastix_symbol_fullcolor.svg" alt="CLASTIX">
    <span>Dutch Cloud Native Days 2026 · Utrecht</span>
    <span class="cx-footer-page">{{ currentPage }} / {{ total }}</span>
  </footer>
</template>
