# LDAP Setup
## Commands
- Check for the Org. Units in the LDAP Server
```bash
ldapsearch -H ldap://localhost -b "dc=ldap,dc=localhost" -D "cn=admin,dc=ldap,dc=localhost" -W
```