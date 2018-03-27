#!/bin/bash

set -e

THINGSBOARD_HOST=${THINGSBOARD_HOST:-"demo.thingsboard.io"}
DEVICE_ACCESS_TOKEN=${DEVICE_ACCESS_TOKEN:-""}
MINIMUM_TEMPERATURE=${MINIMUM_TEMPERATURE:-'17.5'}
MAXIMUM_TEMPERATURE=${MAXIMUM_TEMPERATURE:-'30'}
MINIMUM_HUMIDITY=${MINIMUM_TEMPERATURE:-'12'}
MAXIMUM_HUMIDITY=${MAXIMUM_TEMPERATURE:-'90'}
FIRMWARE_VERSION=${FIRMWARE_VERSION:-"$(uname -s)"}
SERIAL_NUMBER=${SERIAL_NUMBER:-"$(uname -r)"}
FREQUENCY=${FREQUENCY:-"1000"}
VARIABILITY=${VARIABILITY:-"0.03"}
MINIMUM_LATITUDE=${MINIMUM_LATITUDE:-'48.8534100'}
MAXIMUM_LATITUDE=${MAXIMUM_LATITUDE:-'48.856438'}
MINIMUM_LONGITUDE=${MINIMUM_LONGITUDE:-'2.3488000'}
MAXIMUM_LONGITUDE=${MAXIMUM_LONGITUDE:-'2.352456'}

cat << EOF > /usr/share/thingsboard/demo-tools.js
var mqtt = require('mqtt');

// Don't forget to update accessToken constant with your device access token
const thingsboardHost = "${THINGSBOARD_HOST}";
const accessToken = "${DEVICE_ACCESS_TOKEN}";
const minTemperature = ${MINIMUM_TEMPERATURE}, maxTemperature = ${MAXIMUM_TEMPERATURE}, minHumidity = ${MINIMUM_HUMIDITY}, maxHumidity = ${MAXIMUM_HUMIDITY};
const minLatitude = ${MINIMUM_LATITUDE}, maxLatitude = ${MAXIMUM_LATITUDE}, minLongitude = ${MINIMUM_LONGITUDE}, maxLongitude = ${MAXIMUM_LONGITUDE};

// Initialization of temperature, humidity, latitude and longitude data with random values
var data = {
    temperature: minTemperature + (maxTemperature - minTemperature) * Math.random() ,
    humidity: minHumidity + (maxHumidity - minHumidity) * Math.random() ,
    latitude: minLatitude + (maxLatitude - minLatitude) * Math.random() ,
    longitude: minLongitude + (maxLongitude - minLongitude) * Math.random()
};

// Initialization of mqtt client using Thingsboard host and device access token
console.log('Connecting to: %s using access token: %s', thingsboardHost, accessToken);
var client  = mqtt.connect('mqtt://'+ thingsboardHost, { username: accessToken });

// Triggers when client is successfully connected to the Thingsboard server
client.on('connect', function () {
    console.log('Client connected!');
    // Uploads firmware version and serial number as device attributes using 'v1/devices/me/attributes' MQTT topic
    client.publish('v1/devices/me/attributes', JSON.stringify({"firmware_version":"${FIRMWARE_VERSION}", "serial_number":"${SERIAL_NUMBER}"}));
    // Schedules telemetry data upload once per second
    console.log('Uploading temperature and humidity data every ${FREQUENCY} milliseconds ...');
    setInterval(publishTelemetry, ${FREQUENCY});
});

// Uploads telemetry data using 'v1/devices/me/telemetry' MQTT topic
function publishTelemetry() {
    data.temperature = genNextValue(data.temperature, minTemperature, maxTemperature);
    data.humidity = genNextValue(data.humidity, minHumidity, maxHumidity);
    data.latitude = genNextGPS(data.latitude, minLatitude, maxLatitude);
    data.longitude = genNextGPS(data.longitude, minLongitude, maxLongitude);
    client.publish('v1/devices/me/telemetry', JSON.stringify(data));
}

// Generates new random value that is within 3% range from previous value
function genNextValue(prevValue, min, max) {
    var value = prevValue + ((max - min) * (Math.random() - 0.5)) * ${VARIABILITY};
    value = Math.max(min, Math.min(max, value));
    return Math.round(value * 10) / 10;
}

// Generates new random GPS Coordinate
function genNextGPS(prevValue, min, max) {
    var value = prevValue + ((max - min) * (Math.random() - 0.5)) * ${VARIABILITY};
    value = Math.max(min, Math.min(max, value));
    var coordinate = ((value * 10) / 10);
    // console.log((value.toPrecision(8) * 10) / 10);
    return ((value.toPrecision(11) * 10) / 10);
}

//Catches ctrl+c event
process.on('SIGINT', function () {
    console.log();
    console.log('Disconnecting...');
    client.end();
    console.log('Exited!');
    process.exit(2);
});

process.on('SIGTERM', function () {
    console.log();
    console.log('Disconnecting...');
    client.end();
    console.log('Exited!');
    process.exit(2);
});

//Catches uncaught exceptions
process.on('uncaughtException', function(e) {
    console.log('Uncaught Exception...');
    console.log(e.stack);
    process.exit(99);
});
EOF


exec "$@"