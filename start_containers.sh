#!/bin/bash
docker run --name local-postgres -e POSTGRES_PASSWORD=password -p "5432:5432" -d postgres:9.5
