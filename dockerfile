# --- Etapa 1: Compilación (Build Stage) ---
# Usamos la imagen del SDK de .NET 8.0 para compilar la aplicación
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copiamos todos los archivos .csproj y restauramos las dependencias primero
# Esto aprovecha el cache de Docker para no tener que descargar todo cada vez
COPY ["src/API/lexico/Lexico.API.csproj", "src/API/lexico/"]
COPY ["src/Application/lexico/Lexico.Application.csproj", "src/Application/lexico/"]
COPY ["src/Domain/lexico/Lexico.Domain.csproj", "src/Domain/lexico/"]
COPY ["src/Infrastructure/lexico/Lexico.Infrastructure.csproj", "src/Infrastructure/lexico/"]
# Si tienes más proyectos, añádelos aquí...

# Copia los archivos de solución para restaurar paquetes a nivel de solución
COPY ["backend.sln", "."]
COPY ["global.json", "."]
RUN dotnet restore "backend.sln"

# Copiamos el resto del código fuente
COPY . .
WORKDIR "/src/src/API/lexico"
RUN dotnet build "Lexico.API.csproj" -c Release -o /app/build

# --- Etapa 2: Publicación (Publish Stage) ---
FROM build AS publish
RUN dotnet publish "Lexico.API.csproj" -c Release -o /app/publish /p:UseAppHost=false

# --- Etapa 3: Final (Final Stage) ---
# Usamos la imagen ligera de ASP.NET Runtime que no incluye el SDK
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Lexico.API.dll"]