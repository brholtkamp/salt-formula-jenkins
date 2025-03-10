{%- from "jenkins/map.jinja" import master with context %}

{{ master.home }}/updates:
  file.directory:
  - user: jenkins
  - group: nogroup

setup_jenkins_cli:
  cmd.run:
  - names:
    - wget http://{{ master.http.network }}:{{ master.http.port }}/jnlpJars/jenkins-cli.jar
  - unless: "[ -f /root/jenkins-cli.jar ]"
  - cwd: /root
  - require:
    - cmd: jenkins_service_running

{%- set master_username = master.user.admin.get('username', 'admin') %}
{%- for plugin in master.plugins %}

install_jenkins_plugin_{{ plugin.name }}:
  cmd.run:
  - name: >
      java -jar jenkins-cli.jar -s http://{{ master.http.network }}:{{ master.http.port }} -auth {{ master_username }}:{{ master.user.admin.password }} install-plugin {{ plugin.name }}
  - unless: "[ -d {{ master.home }}/plugins/{{ plugin.name }} ]"
  - cwd: /root
  - require:
    - cmd: setup_jenkins_cli
    - cmd: jenkins_service_running

{%- endfor %}
