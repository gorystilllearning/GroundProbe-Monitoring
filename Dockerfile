FROM zabbix/zabbix-web-apache-mysql:ubuntu-6.4-latest

USER root

# Inject Custom Theme
COPY zabbix-liquid-glass.css /tmp/custom.css
RUN cat /tmp/custom.css >> /usr/share/zabbix/assets/styles/dark-theme.css && \
    cp /usr/share/zabbix/assets/styles/dark-theme.css /usr/share/zabbix/assets/styles/blue-theme.css && \
    rm /tmp/custom.css

# Inject Company Logo
COPY logo.png /usr/share/zabbix/assets/img/company-logo.png

# Revert to zabbix user
USER 1997
