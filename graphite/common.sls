# {% if grains['os_family'] == 'RedHat' %}
# include:
#   - epel
# {% endif %}
 
graphite-common-dependencies:
  pkg.installed:
    - name: python-pip
