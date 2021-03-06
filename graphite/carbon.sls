{% from "graphite/map.jinja" import settings with context %}

include:
  - graphite.common

carbon-dependencies:
  pip.installed:
    - pkgs:
      # install whisper system-wide
      - whisper
    - require:
      - graphite-dependencies

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
      - graphite-virtualenv
      - carbon-dependencies


{% for daemon in ['cache', 'aggregator'] %}
{% set service_file = "/etc/systemd/system/carbon-" + daemon + ".service" %}

carbon-{{ daemon }}-service:
  file.managed:
    - name: {{ service_file }}
    - source: salt://graphite/files/carbon.service
    - template: jinja
    - context:
        settings: {{ settings|json }}
        daemon: {{ daemon }}
    - require:
      - carbon-install
  module.wait:
    - name: service.systemctl_reload
    - watch:
      - file: {{ service_file }}
  service.running:
    - name: carbon-{{ daemon }}.service
    - enable: True
    - require:
      - file: {{ service_file }}
    - watch:
      - file: {{ service_file }}

{% endfor %}
