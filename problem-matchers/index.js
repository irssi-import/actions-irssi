#!/usr/bin/env node

const path = require('path')
const matchersPath = path.join(__dirname, '.github')

console.log(`::add-matcher::${path.join(matchersPath, 'pm-compile-warning.json')}`)
console.log(`::add-matcher::${path.join(matchersPath, 'pm-launch-error.json')}`)
console.log(`2`)
