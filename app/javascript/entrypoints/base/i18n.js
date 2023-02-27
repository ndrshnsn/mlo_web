import locales from "@/base/locales/locales.js"

export default {
  t(keys) {
    const current = document.querySelector("body").getAttribute("data-locale")
    return keys.split('.').reduce((translation_hash, value) => translation_hash[value], locales[current])
  }
}