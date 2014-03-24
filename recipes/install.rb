
package 'slapd' do
  action :install
  response_file 'slapd.seed.erb'
  ignore_failure true
  notifies :enable, 'service[slapd]'
end

cookbook_file 'slapd_config' do
  backup false
  source 'slapd.tar.gz'
  path '/tmp/slapd.tar.gz'
  only_if { node['openldap-server']['no_configuration'] == 'true' }
end

execute 'place_base_slapd_config' do
  command 'cd /etc/ldap && sudo tar -zxvf /tmp/slapd.tar.gz && sudo chown -R openldap:openldap /etc/ldap/slapd.d'
  creates '/etc/ldap/slap.d'
  creates '/etc/ldap/slapd.d'
  notifies :start, 'service[slapd]', :immediately
  only_if { File.exists?("/tmp/slapd.tar.gz") }
end

package 'ldap-utils' do
  action :install
  ignore_failure true
end

template '/etc/default/slapd' do
  source 'default_slapd.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables( {
    slapd_conf_file: node['openldap-server'][:default_config][:slapd_conf_file],
    slapd_user: node['openldap-server'][:default_config][:slapd_user],
    slapd_group: node['openldap-server'][:default_config][:slapd_group],
    slapd_pidfile:  node['openldap-server'][:default_config][:slapd_pidfile],
    slapd_services: node['openldap-server'][:default_config][:slapd_services],
    slapd_nostart: node['openldap-server'][:default_config][:slapd_nostart],
    slapd_sentinel_file: node['openldap-server'][:default_config][:slapd_sentinel_file],
    slapd_kerb_file:  node['openldap-server'][:default_config][:slapd_kerb_file],
    slapd_options:  node['openldap-server'][:default_config][:slapd_options]
  })
  notifies :reload, "service[slapd]"
end

service 'slapd' do
  action [:start]
end
