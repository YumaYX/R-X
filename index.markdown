---
layout: default
---

This project is a record of verification using a distribution derived from Red Hat Enterprise Linux.
Here, commonly used commands and configuration collections are introduced.

{% for category in  site.categories %}
## {{ forloop.index }} {{ category[0] }}
{% for post in site.posts reversed %}{% if post.category == category[0] %}1. [{{ index }} {{ post.title }}]({{ site.baseurl }}{{ post.url }})
{% endif %}{% endfor %}{% endfor %}

### Appendix

* [Testing Report of AlmaLinux 9](https://yumayx.github.io/Workshop/)
* [Command CheatSheet](https://yumayx.github.io/docs/#commands)
