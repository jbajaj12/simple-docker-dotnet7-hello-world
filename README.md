# .NET 7 hello world

## Instructions

This spins up a dotnet 7 application on port 8080. 

The agent is containerized. Make sure that in your `~` directory, you have a file called sandbox.docker.env that contains:

```DD_API_KEY=<Your API Key>```

This is where the agent will read the API key.

Heads up to the fact that this sandbox was made on an M1 computer, so the architecture is `arm64`. If you are on an Intel computer, you will need to change the architecture to amd.

The architecture can be changed in the docker-compose.yaml file under `services.simple-dotnet.build.args.ARCH` (`arm64` for arm, and `amd64` for amd).

Launch with `./run.sh`. This runs the application in detached mode.

Then connect to:
[http://localhost:8080](http://localhost:8080).
![image](https://user-images.githubusercontent.com/65819327/215056628-af71cac8-f96f-459f-911c-f8f50d111304.png)

Example screenshots of what traces you should expect are given in the **Endpoints** section.

The version of the agent in use is 7.41.1. It can be changed in the `docker-compose.yaml` file under `services.datadog-simple-dotnet.image`.

The version of the tracer in use is 2.20.0, and the tracer used is for arm architecture. The version can be changed in the `docker-compose.yaml` file under `services.simple-dotnet.build.args.VERSION`. 

You can run an interactive shell on the container with:

```docker exec -it simple-dotnet sh```

You can set the tracer to debug by changing `DD_TRACE_DEBUG` to `true` in the `docker-compose.yaml` under `simple-dotnet.environment`. 

To find the logs, you first need to exec inside the container with `docker exec -it simple-dotnet bash` and then search under `/var/log/datadog/dotnet/`.

The content should look as follow:
```
root@41bda1846f43:/var/log/datadog/dotnet# ls
DD-DotNet-Profiler-Native-dotnet-1.log       dotnet-native-loader-dotnet-1.log       dotnet-tracer-loader-dotnet-1.log       dotnet-tracer-managed-dotnet-20230320.log      dotnet-tracer-native-dotnet-47.log
DD-DotNet-Profiler-Native-dotnet-47.log      dotnet-native-loader-dotnet-47.log      dotnet-tracer-loader-dotnet-47.log      dotnet-tracer-managed-dotnet-app-20230320.log  dotnet-tracer-native-dotnet_app-82.log
DD-DotNet-Profiler-Native-dotnet_app-82.log  dotnet-native-loader-dotnet_app-82.log  dotnet-tracer-loader-dotnet-app-82.log  dotnet-tracer-native-dotnet-1.log
```

## Endpoints

Endpoints are defined in the `Program.cs` file:
* `/`: this endpoints returns a hello world, and generate a trace with no custom instrumentation.
![image](https://user-images.githubusercontent.com/65819327/215058934-fa2a9c6f-cad2-49c5-8534-c7ee0d3ddf8a.png)

* `/add-tag`: here, using custom instrumentation, we add a tag to the active span, with the date.
![image](https://user-images.githubusercontent.com/65819327/215059213-4e2f6276-0d8a-412d-9ed9-6bf8b1e1d282.png)

* `/exception`: here we add an exception on the current span.
![image](https://user-images.githubusercontent.com/65819327/215059264-f567c0eb-01e6-439d-8884-c888780cfd7d.png)

* `/manual-span`: we create two manual spans in the trace, a parent and a child one.
![image](https://user-images.githubusercontent.com/65819327/215059288-50b42442-6ca6-413d-84cc-6ff0a7430564.png)

## Tear down

Run `docker-compose down`
