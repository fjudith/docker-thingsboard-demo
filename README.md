
# ThingsBoard Demo

This container image aims to simulate temperature and humidity sensors metrics sent by a device via MQTT protocol to ThingsBoard.

[ThingsBoard](https://thingsboard.io/docs/) is an open-source IoT platform for data collection, processing, visualization, and device management.
it supports various messaging protocols such as:

* MQTT
* CoAP
* HTTP
* OPC-UA [(ThingsBoard IoT Gateway)](https://thingsboard.io/docs/iot-gateway/)
* Sigfox [(ThingsBoard IoT Gateway)](https://thingsboard.io/docs/iot-gateway/)

## Description

The Dockerfile builds from the official Node.js image "amd64/node:latest" (see https://hub.docker.com/r/amd64/node/)

> This image does not leverage embedded database nor persistent data.

### Quick Start

Create a device from the ThingsBoard dashboard and copy the access token from the `credential` panel.
Run the following command with the appropriates host name and access token.

```bash
docker container run --rm --name=tbdemo \
-e THINGSBOARD_HOST='thingsboard.example.com' \
-e DEVICE_ACCESS_TOKEN='v3ry1nS3cur3T0k3n' \
-e FREQUENCY="100" \
fjudith/thingsboard-demo
```

Metrics will be shipped to ThingsBoard's MQTT listener every 100 milliseconds.

### Environment variables

Variable | Description | Default value
-------- | ----------- | -------------
**THINGSBOARD_HOST**    | Hostname, IP address or Fully Qualified name of the ThingsBoard MQTT listener | `demo.thingsboard.io`
**DEVICE_ACCESS_TOKEN** | Access token provisionned from the Thingsboard **Devices** pannel | _empty_
**MINIMUM_TEMPERATURE** | Simulated minimum temperature | `17.5`
**MAXIMUM_TEMPERATURE** | Simulated maximum temperature | `30`
**MINIMUM_HUMIDITY** | Simulated minimum humidity | `12`
**MAXIMUM_HUMIDITY** | Simulated maximum humidity | `90`
**FIRMWARE_VERSION** | Custom firmware version | `$(uname -r)`
**SERIAL_NUMBER** | Custom serial number | `$(uname -r)`
**FREQUENCY** | Metrics publishing frequency in milliseconds | `1000` (1s)
**VARIABILITY** | Percent of randomization between min. and max | `0.03` (3%)

### Reference

* https://www.youtube.com/watch?v=dIKXFxpfB_Q