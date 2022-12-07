"""import ldap


async def login(username: str,password: str) -> bool:
    try:
        connect = ldap.initialize('ldaps://dc-01.tgm.ac.at:636')
        #connect.protocol_version = 3
        #connect.set_option(ldap.OPT_REFERRALS, 0)
        conn.simple_bind_s(username, password)
        return True
         environment.put(Context.PROVIDER_URL, "");
    except EntityDoesNotExist:
        return False
    return False"""