import ldap


async def login(username: str,password: str) -> bool:
    try:
        connect = ldap.initialize('ldap://our-ldap.server')
    except EntityDoesNotExist:
        return False

    return True
