# ---------- build ----------
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY . .
# ir directo al proyecto de la API (que referencia los otros proyectos)
WORKDIR /src/backend/src/API/lexico
RUN dotnet restore
RUN dotnet publish -c Release -o /out

# ---------- runtime ----------
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /out .
# La app ya agrega en Program.cs: puerto = $PORT o 8080
# Exponemos 8080 (usaremos ese al generar el dominio en Railway)
EXPOSE 8080
CMD ["dotnet", "Lexico.API.dll"]
