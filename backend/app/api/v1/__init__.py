from fastapi import APIRouter

from app.api.v1.endpoints import auth, complaints, members, notices, units, visitors

api_router = APIRouter(prefix="/api/v1")
api_router.include_router(auth.router)
api_router.include_router(complaints.router)
api_router.include_router(units.router)
api_router.include_router(members.router)
api_router.include_router(visitors.router)
api_router.include_router(notices.router)
