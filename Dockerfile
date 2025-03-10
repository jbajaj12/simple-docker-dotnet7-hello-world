FROM mcr.microsoft.com/dotnet/sdk:7.0
RUN apt-get update && apt-get install -y procps 
WORKDIR /App

# Set log pipeline for logs for trace IDs
LABEL "com.datadoghq.ad.logs"='[{"source": "csharp", "service": "simple-dotnet"}]'

# Copy everything
COPY . ./

# Restore as distinct layers
RUN dotnet restore dotnet-app.csproj
RUN dotnet dev-certs https --clean
RUN dotnet dev-certs https

# Build and publish a release
RUN dotnet publish -c Release -o out dotnet-app.csproj

RUN mkdir /var/log/datadog/

# Required environment variables for .NET Core datadog tracer
ENV CORECLR_ENABLE_PROFILING=1
ENV CORECLR_PROFILER={846F5F1C-F9AE-4B07-969E-05C26BC060D8}
ENV CORECLR_PROFILER_PATH=/opt/datadog/Datadog.Trace.ClrProfiler.Native.so
ENV DD_INTEGRATIONS=/opt/datadog/integrations.json
ENV DD_DOTNET_TRACER_HOME=/opt/datadog

ARG VERSION
ARG ARCH
RUN wget https://github.com/DataDog/dd-trace-dotnet/releases/download/v${VERSION}/datadog-dotnet-apm_${VERSION}_${ARCH}.deb && dpkg -i ./datadog-dotnet-apm_${VERSION}_${ARCH}.deb

# Build runtime image
EXPOSE 5555
