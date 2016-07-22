{% from "graphite/map.jinja" import settings with context %}

include:
  - graphite.common

graphite-api-dependencies:
  pkg.installed:
    - pkgs:
        # install cairo stuff system-wide, saves lots of compiling
        - python-cairocffi
        # TODO: see pip editable below
        - git
  pip.installed:
    # TODO: make uwsgi an option... sometime
    - name: gunicorn
    - user: {{ settings.user }}
    - bin_env: {{ settings.home }}
    - require:
      - graphite-virtualenv

graphite-api-install:
  pip.installed:
    # TODO: handle graphite-api[cache]
    - name: graphite-api
    # TODO: make this configurable / remove it on new release
    - editable: git+https://github.com/brutasse/graphite-api.git#egg=graphite-api
    - user: {{ settings.user }}
    - bin_env: {{ settings.home }}
    - require:
      - graphite-api-dependencies

{% set service_file = "/etc/systemd/system/graphite-api.service" %}

api-service:
  file.managed:
    - name: {{ service_file }}
    - source: salt://graphite/files/graphite-api.service
    - template: jinja
    - context:
        settings: {{ settings|json }}
    - require:
        - graphite-api-install
  module.wait:
    - name: service.systemctl_reload
    - watch:
      - file: {{ service_file }}
      - pip: graphite-api-install
  service.running:
    - name: graphite-api.service
    - enable: True
    - require:
      - file: {{ service_file }}
    - watch:
      - file: {{ service_file }}
