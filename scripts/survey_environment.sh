#!/bin/bash

# Survey Environment Script
# Detects runtime environment and generates config/ENV_PROFILE.json
# Never fails — always degrades gracefully to manual mode.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="${1:-$(dirname "$SCRIPT_DIR")}"
TEMPLATE="$PROJECT_ROOT/config/ENV_PROFILE.template.json"
OUTPUT="$PROJECT_ROOT/config/ENV_PROFILE.json"

echo "=== Environment Survey ==="
echo "Project root: $PROJECT_ROOT"

if [ ! -f "$TEMPLATE" ]; then
  echo "WARNING: Template file not found: $TEMPLATE"
  echo "Falling back to minimal ENV_PROFILE.json generation."
  python3 -c "
import json, datetime
profile = {
    'project_name': '$(basename "$PROJECT_ROOT")',
    'project_root': '$PROJECT_ROOT',
    'environment': 'unknown',
    'bootstrap.mode': 'manual',
    'executor': 'unknown',
    'gateway.port': '18080',
    'gateway.host': '0.0.0.0',
    'openclaw.container': 'unknown',
    'created_at': datetime.datetime.utcnow().strftime('%Y-%m-%dT%H:%M:%S+00:00')
}
with open('$OUTPUT', 'w') as f:
    json.dump(profile, f, indent=2)
print('Generated minimal: $OUTPUT')
"
  exit 0
fi

# --- Detection functions ---

detect_environment() {
  local env="generic"
  if [ -d "/volume2" ] && command -v docker &>/dev/null; then
    env="nas_docker"
  elif command -v docker &>/dev/null; then
    env="docker"
  elif command -v python3 &>/dev/null; then
    env="python_only"
  fi
  echo "$env"
}

detect_executor() {
  local exec_name="unknown"
  if command -v qwen &>/dev/null 2>&1; then
    exec_name="qwen"
  elif command -v python3 &>/dev/null 2>&1; then
    exec_name="python3"
  elif command -v bash &>/dev/null 2>&1; then
    exec_name="bash"
  fi
  echo "$exec_name"
}

detect_git() {
  if command -v git &>/dev/null 2>&1; then
    echo "available"
  else
    echo "unavailable"
  fi
}

detect_docker() {
  if command -v docker &>/dev/null 2>&1; then
    if docker ps &>/dev/null 2>&1; then
      echo "available"
    else
      echo "daemon_not_running"
    fi
  else
    echo "unavailable"
  fi
}

detect_gateway_port() {
  local default_port="18080"
  local port="$default_port"
  # Check if something is already listening on 18080
  if command -v ss &>/dev/null 2>&1; then
    if ss -tlnp 2>/dev/null | grep -q ":18080 "; then
      port="18081"
    fi
  elif command -v netstat &>/dev/null 2>&1; then
    if netstat -tlnp 2>/dev/null | grep -q ":18080 "; then
      port="18081"
    fi
  fi
  echo "$port"
}

detect_openclaw_container() {
  local container="none_detected"
  if docker ps &>/dev/null 2>&1; then
    container=$(docker ps --filter "name=openclaw" --format '{{.Names}}' 2>/dev/null | head -1)
  fi
  [ -z "$container" ] && container="none_detected"
  echo "$container"
}

# --- Run detections ---

ENVIRONMENT=$(detect_environment)
EXECUTOR=$(detect_executor)
GIT_STATUS=$(detect_git)
DOCKER_STATUS=$(detect_docker)
GATEWAY_PORT=$(detect_gateway_port)
OPENCLAW_CONTAINER=$(detect_openclaw_container)
CREATED_AT=$(date -u +"%Y-%m-%dT%H:%M:%S+00:00")

# Determine bootstrap mode based on detected capabilities
BOOTSTRAP_MODE="manual"
if [ "$EXECUTOR" = "qwen" ]; then
  BOOTSTRAP_MODE="qwen"
elif [ "$EXECUTOR" = "python3" ] || [ "$EXECUTOR" = "bash" ]; then
  BOOTSTRAP_MODE="manual"
fi

echo ""
echo "Detection results:"
echo "  Environment:       $ENVIRONMENT"
echo "  Executor:          $EXECUTOR"
echo "  Git:               $GIT_STATUS"
echo "  Docker:            $DOCKER_STATUS"
echo "  Gateway port:      $GATEWAY_PORT"
echo "  OpenClaw container: $OPENCLAW_CONTAINER"
echo "  Bootstrap mode:    $BOOTSTRAP_MODE (auto-selected)"
echo ""

# --- Generate ENV_PROFILE.json ---

python3 -c "
import json

with open('$TEMPLATE') as f:
    template = json.load(f)

profile = {
    'project_name': '$(basename "$PROJECT_ROOT")',
    'project_root': '$PROJECT_ROOT',
    'environment': '$ENVIRONMENT',
    'bootstrap.mode': '$BOOTSTRAP_MODE',
    'executor': '$EXECUTOR',
    'gateway.port': '$GATEWAY_PORT',
    'gateway.host': '0.0.0.0',
    'openclaw.container': '$OPENCLAW_CONTAINER',
    'created_at': '$CREATED_AT'
}

with open('$OUTPUT', 'w') as f:
    json.dump(profile, f, indent=2)

print('Generated: $OUTPUT')
"

echo "=== Environment Survey Complete ==="
exit 0