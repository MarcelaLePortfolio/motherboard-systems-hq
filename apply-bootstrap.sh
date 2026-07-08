
#!/bin/bash

FILE="public/index.html"

cp "$FILE" "$FILE.bak"

awk '

/<\/body>/ && !x {

  print "<script defer src=\"js/boot-sequence.js\"></script>"

  print "<script defer src=\"js/dom-owner.js\"></script>"

  print "<script defer src=\"js/app-bootstrap.js\"></script>"

  x=1

}

{ print }

' "$FILE.bak" > "$FILE"

echo "✅ index.html safely patched"

