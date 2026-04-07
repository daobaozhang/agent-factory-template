#!/bin/bash

# Create Project Script
# Creates a new Agent Factory instance from the template.
#
# Usage:
#   bash create_project.sh <project_name> [target_path] [--no-bootstrap] [--bootstrap-mode=<mode>]
#
# Examples:
#   bash create_project.sh my_agent ./output
#   bash create_project.sh my_agent ./output --no-bootstrap
#   bash create_project.sh my_agent ./output --bootstrap-mode=qwen

set -euo pipefail

# --- Parse arguments ---

PROJECT_NAME=""
TARGET_PATH=""
NO_BOOTSTRAP=false
BOOTSTRAP_MODE_OVERRIDE=""

for arg in "$@"; do
  case "$arg" in
    --no-bootstrap)
      NO_BOOTSTRAP=true
      ;;
    --bootstrap-mode=*)
      BOOTSTRAP_MODE_OVERRIDE="${arg#--bootstrap-mode=}"
      ;;
    -*)
      echo "ERROR: Unknown option: $arg"
      echo "Usage: $0 <project_name> [target_path] [--no-bootstrap] [--bootstrap-mode=<mode>]"
      exit 1
      ;;
    *)
      if [ -z "$PROJECT_NAME" ]; then
        PROJECT_NAME="$arg"
      elif [ -z "$TARGET_PATH" ]; then
        TARGET_PATH="$arg"
      else
        echo "ERROR: Unexpected argument: $arg"
        exit 1
      fi
      ;;
  esac
done

if [ -z "$PROJECT_NAME" ]; then
  echo "ERROR: Project name is required."
  echo "Usage: $0 <project_name> [target_path] [--no-bootstrap] [--bootstrap-mode=<mode>]"
  exit 1
fi

# --- Determine paths ---

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEMPLATE_ROOT="$(dirname "$SCRIPT_DIR")"

if [ -z "$TARGET_PATH" ]; then
  TARGET_DIR="$PROJECT_NAME"
else
  TARGET_DIR="$TARGET_PATH/$PROJECT_NAME"
fi

echo "========================================"
echo "  Agent Factory — Create Project"
echo "========================================"
echo ""
echo "Project name:  $PROJECT_NAME"
echo "Target dir:    $TARGET_DIR"
echo "Template root: $TEMPLATE_ROOT"
echo "No bootstrap:  $NO_BOOTSTRAP"
echo "Bootstrap mode override: ${BOOTSTRAP_MODE_OVERRIDE:-auto}"
echo ""

# --- Step 0: Validate template ---

if [ ! -f "$TEMPLATE_ROOT/config/template_version.json" ]; then
  echo "ERROR: Template not found at $TEMPLATE_ROOT"
  echo "Expected: config/template_version.json"
  exit 1
fi

TEMPLATE_VERSION=$(python3 -c "import json; print(json.load(open('$TEMPLATE_ROOT/config/template_version.json'))['template_version'])")
echo "Template version: $TEMPLATE_VERSION"
echo ""

# --- Step 1: Copy template directory ---

echo ">>> Step 1: Copying template to $TARGET_DIR"

if [ -d "$TARGET_DIR" ]; then
  echo "WARNING: Target directory already exists: $TARGET_DIR"
  echo "Continuing (existing files may be overwritten)..."
fi

mkdir -p "$TARGET_DIR"

# Copy all template files EXCEPT config/ENV_PROFILE.json (instance-specific)
rsync -a --exclude='config/ENV_PROFILE.json' \
          --exclude='runtime/status/' \
          --exclude='runtime/artifacts/' \
          --exclude='runtime/jobs/' \
          --exclude='__pycache__/' \
          --exclude='.git/' \
  "$TEMPLATE_ROOT/" "$TARGET_DIR/" 2>/dev/null || \
cp -r "$TEMPLATE_ROOT/." "$TARGET_DIR/" 2>/dev/null || \
{
  # Fallback if rsync unavailable
  find "$TEMPLATE_ROOT" -maxdepth 1 -mindepth 1 | while read src; do
    base=$(basename "$src")
    # Skip instance-specific files
    case "$base" in
      runtime)
        mkdir -p "$TARGET_DIR/runtime/status"
        mkdir -p "$TARGET_DIR/runtime/artifacts"
        mkdir -p "$TARGET_DIR/runtime/jobs"
        mkdir -p "$TARGET_DIR/runtime/schemas"
        mkdir -p "$TARGET_DIR/runtime/scripts"
        ;;
      *)
        if [ -d "$src" ] && [ "$base" = "config" ]; then
          mkdir -p "$TARGET_DIR/config"
          cp "$src/template_version.json" "$TARGET_DIR/config/" 2>/dev/null || true
          cp "$src/ENV_PROFILE.template.json" "$TARGET_DIR/config/" 2>/dev/null || true
          # Do NOT copy ENV_PROFILE.json
        elif [ -d "$src" ]; then
          cp -r "$src" "$TARGET_DIR/"
        else
          cp "$src" "$TARGET_DIR/"
        fi
        ;;
    esac
  done
}

echo "  [OK] Template copied"

# --- Step 2: Ensure config/template_version.json exists ---

echo ">>> Step 2: Verifying config/template_version.json"

if [ ! -f "$TARGET_DIR/config/template_version.json" ]; then
  mkdir -p "$TARGET_DIR/config"
  cat > "$TARGET_DIR/config/template_version.json" <<EOF
{
  "template_name": "agent_factory_template",
  "template_version": "$TEMPLATE_VERSION",
  "phase_baseline": "phase3_stable",
  "compatible_bootstrap_modes": ["qwen", "manual", "openclaw_minimal"]
}
EOF
fi

echo "  [OK] template_version.json verified"

# --- Step 3: Run survey_environment.sh → generate ENV_PROFILE.json ---

echo ">>> Step 3: Surveying environment"

bash "$TARGET_DIR/scripts/survey_environment.sh" "$TARGET_DIR"
echo "  [OK] ENV_PROFILE.json generated"

# --- Step 4: Apply bootstrap mode override if specified ---

if [ -n "$BOOTSTRAP_MODE_OVERRIDE" ]; then
  case "$BOOTSTRAP_MODE_OVERRIDE" in
    qwen|manual|openclaw_minimal)
      echo ">>> Step 4: Overriding bootstrap.mode to '$BOOTSTRAP_MODE_OVERRIDE'"
      python3 -c "
import json
f=open('$TARGET_DIR/config/ENV_PROFILE.json')
d=json.load(f)
d['bootstrap.mode']='$BOOTSTRAP_MODE_OVERRIDE'
json.dump(d, open('$TARGET_DIR/config/ENV_PROFILE.json','w'), indent=2)
"
      echo "  [OK] bootstrap.mode set to $BOOTSTRAP_MODE_OVERRIDE"
      ;;
    *)
      echo "WARNING: Unknown bootstrap mode '$BOOTSTRAP_MODE_OVERRIDE', using auto-detected value."
      ;;
  esac
fi

# --- Step 5: Initialize git (if available) ---

echo ">>> Step 5: Initializing git (if available)"

if command -v git &>/dev/null 2>&1; then
  cd "$TARGET_DIR"
  if [ ! -d ".git" ]; then
    git init -q 2>/dev/null && echo "  [OK] Git repository initialized" || echo "  [WARN] Git init failed (non-fatal)"
  else
    echo "  [SKIP] Git repository already exists"
  fi
else
  echo "  [SKIP] Git not available"
fi

# --- Step 6: Call init_current_sprint.sh ---

echo ">>> Step 6: Initializing sprint state"

bash "$TARGET_DIR/scripts/init_current_sprint.sh" "$TARGET_DIR"
echo "  [OK] Sprint state initialized"

# --- Step 7: Bootstrap or skip ---

echo ""
echo "========================================"
echo "  Project Created: $PROJECT_NAME"
echo "  Location:        $TARGET_DIR"
echo "========================================"
echo ""

if [ "$NO_BOOTSTRAP" = true ]; then
  echo ">>> --no-bootstrap flag set. Skipping automatic bootstrap."
  echo ""
  echo "Manual next steps:"
  echo "  1. cd $TARGET_DIR"
  echo "  2. Review config/ENV_PROFILE.json"
  echo "  3. Edit bootstrap.mode if needed: qwen | manual | openclaw_minimal"
  echo "  4. Run: bash scripts/entrypoint.sh"
  echo ""
  echo "Project is ready for manual operation."
else
  echo ">>> Running entrypoint bootstrap..."
  echo ""
  bash "$TARGET_DIR/scripts/entrypoint.sh"
  RC=$?
  echo ""
  if [ $RC -eq 0 ]; then
    echo "========================================"
    echo "  Project $PROJECT_NAME is READY"
    echo "========================================"
  else
    echo "WARNING: Entrypoint exited with code $RC."
    echo "Project files are created but bootstrap did not complete."
    echo "Run 'bash scripts/entrypoint.sh' manually to retry."
  fi
fi

exit 0