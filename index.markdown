---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: default
---

This project is a record of verification using a distribution derived from Red Hat Enterprise Linux.
Here, commonly used commands and configuration collections are introduced.

### Testing Report of AlmaLinux 9

The following link leads to the page documenting the verification performed on AlmaLinux 9. It provides detailed information regarding the scope, methodologies, and results of the tests conducted.

- <https://yumayx.github.io/Workshop/>

{% for category in  site.categories %}
## {{ forloop.index }} {{ category[0] }}
{% for post in site.posts reversed %}{% if post.category == category[0] %}1. [{{ index }} {{ post.title }}]({{ site.baseurl }}{{ post.url }})
{% endif %}{% endfor %}{% endfor %}

