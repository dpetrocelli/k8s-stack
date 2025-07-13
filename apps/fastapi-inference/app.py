import asyncio
import logging
import os
import time
from contextlib import asynccontextmanager
from typing import Dict, Optional

import httpx
import uvicorn
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Configuration
OLLAMA_URL = os.getenv("OLLAMA_URL", "http://ollama-runner:11434")
BEDROCK_FALLBACK = os.getenv("BEDROCK_FALLBACK", "true").lower() == "true"
DEFAULT_MODEL = os.getenv("DEFAULT_MODEL", "llama3")


# Request/Response models
class GenerateRequest(BaseModel):
    prompt: str = Field(..., description="The input prompt for text generation")
    model: str = Field(default=DEFAULT_MODEL, description="Model to use for generation")
    max_tokens: Optional[int] = Field(
        default=100, description="Maximum tokens to generate"
    )
    temperature: Optional[float] = Field(
        default=0.7, description="Sampling temperature"
    )
    stream: Optional[bool] = Field(
        default=False, description="Enable streaming response"
    )


class GenerateResponse(BaseModel):
    text: str
    model: str
    tokens_used: int
    latency_ms: float
    source: str = Field(description="ollama, bedrock, or huggingface")


class HealthResponse(BaseModel):
    status: str
    timestamp: float
    services: Dict[str, str]


# Global HTTP client
http_client: Optional[httpx.AsyncClient] = None


@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    global http_client
    http_client = httpx.AsyncClient(timeout=30.0)
    logger.info("🚀 FastAPI inference API started")
    yield
    # Shutdown
    if http_client:
        await http_client.aclose()
    logger.info("👋 FastAPI inference API stopped")


# Initialize FastAPI app
app = FastAPI(
    title="GenAI Inference API",
    description="Multi-model inference API with Ollama, "
    "HuggingFace, and Bedrock fallback",
    version="1.0.0",
    lifespan=lifespan,
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# Health check endpoint
@app.get("/health", response_model=HealthResponse)
async def health_check():
    """Health check endpoint for Kubernetes probes"""
    services = {}

    # Check Ollama connectivity
    try:
        response = await http_client.get(f"{OLLAMA_URL}/api/tags", timeout=5.0)
        services["ollama"] = "healthy" if response.status_code == 200 else "unhealthy"
    except Exception as e:
        services["ollama"] = f"unhealthy: {str(e)}"

    return HealthResponse(status="healthy", timestamp=time.time(), services=services)


# Root endpoint
@app.get("/")
async def root():
    """Root endpoint with API information"""
    return {
        "service": "GenAI Inference API",
        "version": "1.0.0",
        "endpoints": {
            "generate": "/generate",
            "health": "/health",
            "metrics": "/metrics",
        },
    }


async def generate_with_ollama(request: GenerateRequest) -> GenerateResponse:
    """Generate text using Ollama"""
    start_time = time.time()

    try:
        payload = {
            "model": request.model,
            "prompt": request.prompt,
            "stream": False,
            "options": {
                "num_predict": request.max_tokens,
                "temperature": request.temperature,
            },
        }

        response = await http_client.post(
            f"{OLLAMA_URL}/api/generate", json=payload, timeout=30.0
        )

        if response.status_code != 200:
            raise HTTPException(
                status_code=response.status_code,
                detail=f"Ollama error: {response.text}",
            )

        result = response.json()
        latency_ms = (time.time() - start_time) * 1000

        return GenerateResponse(
            text=result.get("response", ""),
            model=request.model,
            tokens_used=len(result.get("response", "").split()),
            latency_ms=latency_ms,
            source="ollama",
        )

    except Exception as e:
        logger.error(f"Ollama generation failed: {str(e)}")
        raise HTTPException(
            status_code=500, detail=f"Ollama generation failed: {str(e)}"
        )


async def generate_with_bedrock_fallback(request: GenerateRequest) -> GenerateResponse:
    """Fallback to AWS Bedrock (placeholder implementation)"""
    start_time = time.time()

    # This is a placeholder - in production, you'd use boto3 to call Bedrock
    await asyncio.sleep(0.1)  # Simulate API call

    fallback_response = f"[BEDROCK FALLBACK] Response to: {request.prompt}"
    latency_ms = (time.time() - start_time) * 1000

    return GenerateResponse(
        text=fallback_response,
        model="bedrock-claude",
        tokens_used=len(fallback_response.split()),
        latency_ms=latency_ms,
        source="bedrock",
    )


# Main generation endpoint
@app.post("/generate", response_model=GenerateResponse)
async def generate_text(request: GenerateRequest):
    """
    Generate text using available models with automatic fallback:
    1. Try Ollama first
    2. Fallback to Bedrock if enabled
    """
    logger.info(
        f"Generation request: model={request.model}, "
        f"prompt_length={len(request.prompt)}"
    )

    # Try Ollama first
    try:
        return await generate_with_ollama(request)
    except Exception as e:
        logger.warning(f"Ollama failed: {str(e)}")

        # Fallback to Bedrock if enabled
        if BEDROCK_FALLBACK:
            logger.info("Falling back to Bedrock")
            try:
                return await generate_with_bedrock_fallback(request)
            except Exception as bedrock_error:
                logger.error(f"Bedrock fallback failed: {str(bedrock_error)}")
                raise HTTPException(
                    status_code=500,
                    detail=f"All inference backends failed. "
                    f"Ollama: {str(e)}, Bedrock: {str(bedrock_error)}",
                )
        else:
            raise HTTPException(
                status_code=500,
                detail=f"Ollama failed and Bedrock fallback " f"disabled: {str(e)}",
            )


# Metrics endpoint for Prometheus
@app.get("/metrics")
async def metrics():
    """Prometheus metrics endpoint"""
    return {
        "requests_total": "# HELP requests_total Total requests\n"
        "# TYPE requests_total counter\nrequests_total 0",
        "request_duration_seconds": "# HELP request_duration_seconds "
        "Request duration\n# TYPE request_duration_seconds histogram",
    }


if __name__ == "__main__":
    uvicorn.run("app:app", host="0.0.0.0", port=8000, reload=True, log_level="info")
