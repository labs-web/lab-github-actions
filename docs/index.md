---
layout : default
order : 1
---
# Lab github-actions


{%- assign chapitres = site.pages | sort: "order"  -%}
{% for chapitre in chapitres %}
    {{ chapitre.content }}
{% endfor %}  
</div>