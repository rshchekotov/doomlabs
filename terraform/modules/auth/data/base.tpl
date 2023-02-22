dn: ou=Groups,${base_dn}
ou: Groups
objectClass: top
objectClass: organizationalUnit

dn: ou=People,${base_dn}
ou: People
objectClass: top
objectClass: organizationalUnit

dn: cn=intimate,ou=Groups,${base_dn}
cn: intimate
gidNumber: 6001
objectClass: top
objectClass: posixGroup
%{ for user in intimate_friends ~}
memberUid: ${user}
%{ endfor ~}

dn: cn=close,ou=Groups,${base_dn}
cn: close
gidNumber: 6002
objectClass: top
objectClass: posixGroup
%{ for user in close_friends ~}
memberUid: ${user}
%{ endfor ~}

dn: cn=casual,ou=Groups,${base_dn}
cn: casual
gidNumber: 6003
objectClass: top
objectClass: posixGroup
%{ for user in casual_friends ~}
memberUid: ${user}
%{ endfor ~}

dn: cn=acquaintance,ou=Groups,${base_dn}
cn: acquaintance
gidNumber: 6004
objectClass: top
objectClass: posixGroup
%{ for user in acquaintances ~}
memberUid: ${user}
%{ endfor ~}

dn: cn=gitea,ou=Groups,${base_dn}
cn: gitea
gidNumber: 6005
objectClass: top
objectClass: posixGroup
%{ for user in gitea_users ~}
memberUid: ${user}
%{ endfor ~}