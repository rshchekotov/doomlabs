dn: uid=${uid},ou=People,${base_dn}
uid: ${uid}
cn: ${first_name} ${last_name}
sn: ${last_name}
givenName: ${first_name}
mail: ${email}
userPassword: ${password}
description: User Account for ${first_name} ${last_name}
o: ${ldap_org}
ou: People
uidNumber: ${id}
gidNumber: ${id}
homeDirectory: /home/${uid}
loginShell: /bin/bash
st: ${state}
l: ${city} ${country}
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: top
objectClass: shadowAccount
objectClass: organizationalPerson
objectClass: person
