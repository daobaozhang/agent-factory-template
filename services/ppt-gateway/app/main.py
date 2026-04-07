from fastapi import FastAPI
from pydantic import BaseModel
from uuid import uuid4

app = FastAPI()

class JobRequest(BaseModel):
    topic: str

jobs = {}

@app.post("/jobs")
def create_job(req: JobRequest):
    job_id = str(uuid4())
    jobs[job_id] = {
        "id": job_id,
        "topic": req.topic,
        "status": "created"
    }
    return jobs[job_id]

@app.get("/jobs/{job_id}")
def get_job(job_id: str):
    return jobs.get(job_id, {"error": "not found"})

@app.get("/artifact/{job_id}")
def get_artifact(job_id: str):
    if job_id not in jobs:
        return {"error": "not found"}
    return {
        "job_id": job_id,
        "artifact": "mock_ppt_placeholder"
    }
