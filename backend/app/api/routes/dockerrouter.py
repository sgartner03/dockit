from fastapi import APIRouter, Body, Depends, HTTPException
from starlette.status import HTTP_201_CREATED, HTTP_400_BAD_REQUEST

from app.api.dependencies.database import get_repository
from app.core.config import get_app_settings
from app.core.settings.app import AppSettings
from app.db.errors import EntityDoesNotExist
import app.services.docker_service as ds
router = APIRouter()


@router.get("/test", name="docker:test")
async def login():
    return {"sdsd": ds.getContext()}
