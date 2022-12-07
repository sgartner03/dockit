from datetime import datetime

from pydantic import BaseModel


class Container(BaseModel):
    name: str
    container_id: str
    description: str
    created_at: datetime
    student: str

