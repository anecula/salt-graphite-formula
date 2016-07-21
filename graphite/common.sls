{% from "graphite/map.jinja" import settings with context %}

include:
{% if grains['os_family'] == 'RedHat' %}
  - epel
{% endif %}
  - pip
  - pip.extensions

graphite-dependencies:
  pip.installed:
    - pkgs:
      - virtualenv
    - require:
      - pip
      - pip_extensions

graphite-group:
  group.present:
    - name: {{ settings.group }}

graphite-user:
  user.present:
    - name: {{ settings.user }}
    - gid: {{ settings.group }}
    - home: {{ settings.home }}
    - require:
      - graphite-group

graphite-virtualenv:
  virtualenv.managed:
    - name: {{ settings.home }}
    - system_site_packages: true
    - user: {{ settings.user }}
    - require:
      - graphite-user
      - graphite-dependencies
