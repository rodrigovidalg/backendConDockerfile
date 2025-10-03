# --- Etapa 1: Compilación (Build Stage) ---
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiamos todos los archivos .csproj y de solución, respetando la estructura de carpetas
COPY ["backend.sln", "."]
COPY ["global.json", "."]
COPY ["BACKEND/src/API/lexico/Lexico.API.csproj", "BACKEND/src/API/lexico/"]
COPY ["BACKEND/src/Application/lexico/Lexico.Application.csproj", "BACKEND/src/Application/lexico/"]
COPY ["BACKEND/src/Domain/lexico/Lexico.Domain.csproj", "BACKEND/src/Domain/lexico/"]
COPY ["BACKEND/src/Infrastructure/lexico/Lexico.Infrastructure.csproj", "BACKEND/src/Infrastructure/lexico/"]

# Restauramos las dependencias a nivel de solución
RUN dotnet restore "backend.sln"

# Copiamos todo el resto del código
COPY . .

# Publicamos la aplicación
WORKDIR "/src/BACKEND/src/API/lexico"
RUN dotnet publish "Lexico.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# --- Etapa 2: Final (Final Stage) ---
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "Lexico.API.dll"]