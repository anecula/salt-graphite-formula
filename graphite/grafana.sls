{% if grains['os_family'] == 'RedHat' %}
# use upstream grafana repo
{% set repo = {
  'key_file': '/etc/pki/rpm-gpg/RPM-GPG-KEY-grafana',
  'key_source': 'https://grafanarel.s3.amazonaws.com/RPM-GPG-KEY-grafana',
  'key_hash': 'md5=a168ce249988397f7ec2561869ad5105',
} %}

grafana-pubkey:
  file.managed:
    - name: {{ repo.key_file }}
    - source: {{ repo.key_source }}
    - source_hash:  {{ repo.key_hash }}

grafana-repo:
  pkgrepo.managed:
    - name: grafana
    - humanname: Grafana
    - baseurl: https://packagecloud.io/grafana/stable/el/6/$basearch
    - gpgcheck: 1
    - gpgkey: file://{{ repo.key_file }}
    - require:
      - grafana-pubkey

{# else if Debian... TODO #}
{% endif %}

grafana-install:
  pkg.installed:
    - name: grafana
{% if grains['os_family'] == 'RedHat' %}
    - fromrepo: grafana
    - require:
      - grafana-repo

# keep the repo disabled
grafana-disable-repo:
  file.replace:
    - name: /etc/yum.repos.d/grafana.repo
    - pattern: '^enabled=[0,1]'
    - repl: 'enabled=0'
    - require:
      - grafana-repo
    - order: last

{% endif %}

grafana-service:
  service.running:
    - name: grafana-server.service
    - enable: True
    - require:
      - grafana-install
    - watch:
      - grafana-install
