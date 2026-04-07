# ppt-gateway

This service is the only business entry point for the PPT Agent system.

Current stage:
- bootstrap structure only
- mock API available
- no real banana integration yet

## Planned API
- POST /jobs
- GET /jobs/{id}
- GET /artifact

## Current Mock API File
- app/main.py

## Local Run Example
```bash
cd /volume2/ai/ppt_agent_factory/services/ppt-gateway
uvicorn app.main:app --host 0.0.0.0 --port 18080
```