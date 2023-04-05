dn: cn=${name},ou=Groups,{{ LDAP_BASE_DN }}
cn: ${name}
description: ${description}
objectClass: top
objectClass: groupOfNames
%{ for user in users ~}
member: uid=${user},ou=People,{{ LDAP_BASE_DN }}
%{ endfor ~}