from fastapi import APIRouter, Body, Depends, HTTPException
from starlette.status import HTTP_201_CREATED, HTTP_400_BAD_REQUEST
import ldap
from app.api.dependencies.database import get_repository
from app.core.config import get_app_settings
from app.core.settings.app import AppSettings
from app.db.errors import EntityDoesNotExist
from app.db.repositories.users import UsersRepository
from app.models.schemas.users import (
    UserInCreate,
    UserInLogin,
    UserInResponse,
    UserWithToken,
)
from app.resources import strings
from app.services import jwt
from app.services.authentication import login   

router = APIRouter()


@router.post("/login", response_model=UserInResponse, name="auth:login")
async def login(
    user_login: UserInLogin = Body(..., embed=True, alias="user")
    #todo add params
) -> UserInResponse:
    wrong_login_error = HTTPException(
        status_code=HTTP_400_BAD_REQUEST,
        detail=strings.INCORRECT_LOGIN_INPUT,
    )

    try:
        #call auth service andtry:
        connect = ldap.initialize('ldaps://dc-01.tgm.ac.at:636')
        #connect.protocol_version = 3
        #connect.set_option(ldap.OPT_REFERRALS, 0)
        conn.simple_bind_s(username, password)
        #environment.put(Context.PROVIDER_URL, "");
    except INVALID_CREDENTIALS as existence_error:
        raise wrong_login_error from existence_error

    token = jwt.create_access_token_for_user(
        user,
        str(settings.secret_key.get_secret_value()),
    )
    return UserInResponse(
        user=UserWithToken(
            email=user.email,
            token=token,
        ),
    )


