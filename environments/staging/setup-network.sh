#!/bin/bash
# Create Docker network for StreamForge media services
# Run this once before first deployment

set -e  # Exit on any error

NETWORK_NAME="media_network"

if docker network inspect "$NETWORK_NAME" >/dev/null 2>&1; then
    echo "✓ Network '$NETWORK_NAME' already exists"
else
    echo "Creating network '$NETWORK_NAME'..."
    docker network create "$NETWORK_NAME"
    echo "✓ Network '$NETWORK_NAME' created"
fi