---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: default
---

{% for category in  site.categories %}
## {{ forloop.index }} {{ category[0] }}
{% for post in site.posts reversed %}{% if post.category == category[0] %}1. [{{ index }} {{ post.title }}]({{ site.baseurl }}{{ post.url }})
{% endif %}{% endfor %}{% endfor %}

