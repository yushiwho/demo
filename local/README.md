# Dockerizing the Application

1. Create 2 container, 1 is for backend(api) and 2nd is for frontend(sys-stats)
2. Add Makefile to automatic everything: build, push, shell and run
    - build: Build Docker images
    - push: Push images to quay.io 
    - shell: Start a shell session inside a running container
    - run: Run the application
3. Upgrade frontend node version to v21.4.0
4. Add an run.sh as ENTRYPOINT
    - Use sed to replace placeholders in static files with the backend host from the BACKEND_HOST environment variable
    - Start nginx

# Run && Access
```
cd $(git rev-parse --show-toplevel)/local
docker compose up
```
[localhost](http://localhost:80)