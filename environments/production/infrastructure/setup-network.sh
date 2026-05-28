#!/bin/bash
# Create Docker production network for infrastructure
# Run this once before first deployment

set -e  # Exit on any error

NETWORK_NAME="infra_network_prod"

if docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo "✓ Network '$NETWORK_NAME' already exists"
else
    echo "Creating network '$NETWORK_NAME'..."
    docker network create --subnet 172.32.0.0/16 "$NETWORK_NAME" 
    echo "✓ Network '$NETWORK_NAME' created"
fi