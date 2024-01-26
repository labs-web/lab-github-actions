---
layout : default
order : 1
---
# review-pull-request


```yml
on:
  pull_request:
    types:
      - opened
    branches:
      - 'releases/**'
    paths:
      - '**.js
```