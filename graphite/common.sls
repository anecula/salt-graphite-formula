include:
{% if grains['os_family'] == 'RedHat' %}
  - epel
{% endif %}
  - pip
  - pip.extensions

graphite-common-dependencies:
  pip.installed:
    - pkgs:
      - virtualenv
    - require:
      - pip
