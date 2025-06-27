from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles

# routers
from routers import materials
from routers import materialbatches

app = FastAPI(title="Materials Service")

# include routers
app.include_router(materials.router, prefix='/materials', tags=['materials'])
app.include_router(materialbatches.router, prefix='/material-batches', tags=['material batches'])

# CORS setup to allow frontend and backend on ports
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        # IMS
        "https://bleu-ims.vercel.app",  # frontend

        # UMS
        "https://bleu-ums.onrender.com",  # auth service

        # POS
        "https://bleu-pos-eight.vercel.app",  # frontend

        # OOS
        "https://bleu-oos.vercel.app",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# run app
if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", port=8003, host="127.0.0.1", reload=True)
