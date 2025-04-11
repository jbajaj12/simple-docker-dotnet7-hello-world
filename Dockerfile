# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:7.0 AS build
WORKDIR /App

# Copy everything
COPY . ./

# Restore and build
RUN dotnet restore dotnet-app.csproj
RUN dotnet dev-certs https --clean
RUN dotnet dev-certs https
RUN dotnet publish -c Release -o out dotnet-app.csproj

# Runtime Stage
FROM mcr.microsoft.com/dotnet/aspnet:7.0
WORKDIR /App
COPY --from=build /App/out ./

# Create Datadog directory
RUN mkdir -p /var/log/datadog/

# Required environment variables for .NET Core datadog tracer
ENV CORECLR_ENABLE_PROFILING=1
ENV CORECLR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8}
ENV CORECLR_PROFILER_PATH=/opt/datadog/Datadog.Trace.ClrProfiler.Native.so
ENV DD_INTEGRATIONS=/opt/datadog/integrations.json
ENV DD_DOTNET_TRACER_HOME=/opt/datadog

# Install necessary packages and Datadog APM
RUN apt-get update && apt-get install -y wget procps
ARG VERSION
ARG ARCH
RUN wget https://github.com/DataDog/dd-trace-dotnet/releases/download/v${VERSION}/datadog-dotnet-apm_${VERSION}_${ARCH}.deb && \
    dpkg -i ./datadog-dotnet-apm_${VERSION}_${ARCH}.deb

# Set log pipeline for logs for trace IDs
LABEL "com.datadoghq.ad.logs"='[{"source": "csharp", "service": "simple-dotnet"}]'

EXPOSE 5555

# Command to run the application
CMD ["dotnet", "dotnet-app.dll"]
