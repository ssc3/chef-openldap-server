template '/tmp/db.ldif' do
  source node['openldap-server'][:db_ldif]
  owner 'root'
  group 'root'
  mode '0644'
  only_if { node['openldap-server']['no_configuration'] == 'true' }
  notifies :run, 'execute[create_db]'
end

template '/tmp/db_update.ldif' do
  source node['openldap-server'][:update_ldif]
  owner 'root'
  group 'root'
  mode '0644'
  only_if { node['openldap-server']['no_configuration'] == 'false' }
  notifies :run, 'execute[update_db]'
end

execute 'create_db' do
  command 'sudo ldapadd -Y EXTERNAL -H ldapi:/// -f /tmp/db.ldif'
  creates '/etc/ldap/slapd.d/cn=config/olcDatabase={1}hdb.ldif'
  action :nothing
end

execute "update_db" do
  command "ldapadd -x -c -D #{node['openldap-server'][:rootDN]} -w #{node['openldap-server'][:rootpw]} -v -f /tmp/db_update.ldif"
  creates '/etc/ldap/slapd.d/cn=config/olcDatabase={2}hdb.ldif'
  action :nothing
  returns [0,68]
end
