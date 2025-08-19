#!/bin/bash
# File: test_cade_handlers.sh
# Usage: bash test_cade_handlers.sh

handlers=("generate" "summarize" "explain" "comment" "format" "refactor" "translate" "convert")

for action in "${handlers[@]}"; do
  echo
  echo "=== Testing handler: $action ==="

  case $action in
    generate)
      code='console.log("Hello World")'
      ;;
    summarize)
      code='function add(a,b){return a+b;}'
      ;;
    explain)
      code='let x = 42;'
      ;;
    comment)
      code='let y = 10;'
      ;;
    format)
      code='function foo(){return 1;}'
      ;;
    refactor)
      code='function sum(a,b){return a+b;}'
      ;;
    translate)
      code='console.log("hola")'
      ;;
    convert)
      code='const z = 5;'
      ;;
  esac

  npx tsx scripts/agents_full/cade.ts -e "cadeCommandRouter('$action', { code: '$code', comment: 'Example comment', from: 'js', to: 'python', type: 'es6-to-es5' }).then(result => console.dir(result, { depth: null })).catch(console.error)"
done

echo
echo "✅ All handlers tested."
