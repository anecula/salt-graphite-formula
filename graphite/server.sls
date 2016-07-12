{% from "graphite/map.jinja" import settings with context %}

include:
  - graphite.common

carbon-dependencies:
  pip.installed:
    - pkgs:
      - virtualenv
      # install whisper system-wide
      - whisper
    - require:
      - graphite-common-dependencies
  pkg.installed:
    - pkgs:
      - gcc
      - {{ settings.packages['python-dev'] }}

carbon-group:
  group.present:
    - name: {{ settings.group }}

carbon-user:
  user.present:
    - name: {{ settings.user }}
    - gid: {{ settings.group }}
    - home: {{ settings.home }}
    - require:
      - carbon-group

carbon-virtualenv:
  virtualenv.managed:
    - name: {{ settings.home }}
    - system_site_packages: true
    - user: {{ settings.user }}
    - require:
      - carbon-user
      - carbon-dependencies

carbon-install:
  pip.installed:
    - name: carbon
    - user: {{ settings.user }}
    - bin_env: {{ settings.home }}
    # needed because otherwise graphite's files end up in strange places
    # (actually, this doesn't work because it never made it to the 0.9.x branch)
    #- env_vars:
    #    GRAPHITE_NO_PREFIX: "1"
    # this one's total crap but it works
    - install_options:
        - --install-lib={{ settings.home }}/lib/python2.7/site-packages
    - require:
      - carbon-virtualenv

{% set service_file = "/etc/systemd/system/graphite.service" %}

carbon-service:
  file.managed:
    - name: {{ service_file }}
    - source: salt://graphite/files/graphite.service
    - template: jinja
    - context:
        settings: {{ settings|json }}
  module.wait:
    - name: service.systemctl_reload
    - watch:
      - file: {{ service_file }}
  service.running:
    - name: graphite.service
    - enable: True
    - require:
      - file: {{ service_file }}
    - watch:
      - file: {{ service_file }}
