#!/bin/bash

HTML_FILE="index.html"
PROJECT_FILE="project1.txt"

# Read project info from text file
read -r TITLE < <(sed -n '1p' "$PROJECT_FILE")
read -r DESC < <(sed -n '2p' "$PROJECT_FILE")
read -r LINK < <(sed -n '3p' "$PROJECT_FILE")

# Prepare the new HTML block
PROJECT_HTML=$(cat <<EOF
    <div class="project">
      <h3>$TITLE</h3>
      <p>$DESC</p>
      <a href="$LINK" target="_blank">View Project</a>
    </div>
EOF
)

# Backup the HTML file
cp "$HTML_FILE" "$HTML_FILE.bak"

# Insert the block before the last </div> inside the projects section
awk -v block="$PROJECT_HTML" '
  BEGIN { in_projects = 0; last_div_line = 0 }
  /<section[^>]*class="projects"[^>]*>/ { in_projects = 1 }
  in_projects && /<\/div>/ { last_div_line = NR }  # Track last </div> inside section
  /<\/section>/ { in_projects = 0 }
  { lines[NR] = $0 }
  END {
    for (i = 1; i <= NR; i++) {
      if (i == last_div_line) print block
      print lines[i]
    }
  }
' "$HTML_FILE.bak" > "$HTML_FILE"
