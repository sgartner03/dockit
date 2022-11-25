from fastapi import APIRouter
import logging

from app.api.routes import authentication, dockerrouter
router = APIRouter()
router.include_router(authentication.router, tags=["authentication"], prefix="/users")
router.include_router(dockerrouter.router,tags=["dockerrouter"],prefix="/docker")
