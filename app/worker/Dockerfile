# syntax=docker/dockerfile:1
# MULTI-STAGE BUILD: stage 1 has the full .NET SDK (~800 MB) to compile.
# Stage 2 only has the runtime (~200 MB) plus the compiled output. The SDK never ships.

# ---- Stage 1: build ----
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Restore (download NuGet packages) with only the project file present -> cached layer,
# same trick as requirements.txt / package.json in the other services.
COPY Worker.csproj .
RUN dotnet restore

# Now the source, then compile a Release build into /out.
# --no-restore: packages were already restored above.
COPY . .
RUN dotnet publish -c Release -o /out --no-restore

# ---- Stage 2: runtime ----
# "runtime" (not "aspnet") because the worker is a console app with no web server.
FROM mcr.microsoft.com/dotnet/runtime:10.0
WORKDIR /app

# Copy ONLY the compiled output from the build stage.
COPY --from=build /out .

# Microsoft's images (.NET 8+) define APP_UID (=1654), an unprivileged user that already exists.
USER $APP_UID

# No EXPOSE: the worker doesn't listen on any port. It pulls from Redis and writes to Postgres.
ENTRYPOINT ["dotnet", "Worker.dll"]
