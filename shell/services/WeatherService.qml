pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool loaded: false
    property string locationName: ""
    property real temp: 0
    property real feelsLike: 0
    property real humidity: 0
    property real windSpeed: 0
    property int weatherCode: 0
    property string condition: "fetching..."

    readonly property bool imperial: Config.weather.units === "imperial"
    readonly property string tempUnit: imperial ? "\u00b0F" : "\u00b0C"
    readonly property string windUnit: imperial ? "mph" : "km/h"
    property string glyph: ""

    // Each entry: { date, code, glyph, condition, max, min, precipProb }
    property var daily: []

    function iconFor(code) {
        if (code === 0) return "";
        if (code === 1 || code === 2) return "";
        if (code === 3 || code === 45 || code === 48) return "";
        if (code >= 51 && code <= 67) return "";
        if (code >= 71 && code <= 86 && code !== 80 && code !== 81 && code !== 82) return "";
        if (code === 80 || code === 81 || code === 82) return "";
        if (code >= 95) return "";
        return "";
    }

    function describeCode(code) {
        const table = {
            0: "Clear sky", 1: "Mainly clear", 2: "Partly cloudy", 3: "Overcast",
            45: "Fog", 48: "Rime fog",
            51: "Light drizzle", 53: "Drizzle", 55: "Dense drizzle",
            56: "Freezing drizzle", 57: "Freezing drizzle",
            61: "Light rain", 63: "Rain", 65: "Heavy rain",
            66: "Freezing rain", 67: "Freezing rain",
            71: "Light snow", 73: "Snow", 75: "Heavy snow", 77: "Snow grains",
            80: "Rain showers", 81: "Rain showers", 82: "Heavy showers",
            85: "Snow showers", 86: "Snow showers",
            95: "Thunderstorm", 96: "Thunderstorm w/ hail", 99: "Severe thunderstorm",
        };
        return table[code] || "Unknown";
    }

    function refresh() {
        if (Config.weather.hasLocation) {
            fetchForecast(Config.weather.lat, Config.weather.lon, Config.weather.location);
        } else {
            ipLookup.running = true;
        }
    }

    function fetchForecast(lat, lon, name) {
        root.locationName = name;
        const units = root.imperial ? "&temperature_unit=fahrenheit&wind_speed_unit=mph" : "";
        forecast.command = ["curl", "-s", "-m", "10",
            "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon +
            "&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code" +
            "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max" +
            "&timezone=auto&forecast_days=7" + units];
        forecast.running = true;
    }

    // Resolves a free-text location name to coordinates via Open-Meteo's own
    // geocoding API. On success, persists it via Config.setLocation and
    // immediately refreshes so the change is visible right away.
    function geocode(query, onError) {
        root.geocodeError = false;
        geocodeProc.onErrorCallback = onError || null;
        geocodeProc.command = ["curl", "-s", "-m", "10",
            "https://geocoding-api.open-meteo.com/v1/search?count=1&name=" + encodeURIComponent(query)];
        geocodeProc.running = true;
    }

    property bool geocodeError: false

    Timer {
        interval: 30 * 60 * 1000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refresh()
    }

    // Fallback when no explicit location is configured: resolve the user's
    // approximate location from their IP, same behavior wttr.in used to
    // give for free. Not persisted — re-resolved each refresh.
    Process {
        id: ipLookup
        command: ["curl", "-s", "-m", "8", "http://ip-api.com/json/"]
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    if (data.status === "success") {
                        root.fetchForecast(data.lat, data.lon, data.city || "");
                    } else if (!root.loaded) {
                        root.condition = "unavailable";
                    }
                } catch (e) {
                    if (!root.loaded) root.condition = "unavailable";
                }
            }
        }
    }

    Process {
        id: forecast
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    const cur = data.current;
                    root.temp = cur.temperature_2m;
                    root.feelsLike = cur.apparent_temperature;
                    root.humidity = cur.relative_humidity_2m;
                    root.windSpeed = cur.wind_speed_10m;
                    root.weatherCode = cur.weather_code;
                    root.condition = root.describeCode(cur.weather_code);
                    root.glyph = root.iconFor(cur.weather_code);

                    const d = data.daily;
                    const days = [];
                    for (let i = 0; i < d.time.length; i++) {
                        days.push({
                            date: d.time[i],
                            code: d.weather_code[i],
                            glyph: root.iconFor(d.weather_code[i]),
                            condition: root.describeCode(d.weather_code[i]),
                            max: d.temperature_2m_max[i],
                            min: d.temperature_2m_min[i],
                            precipProb: d.precipitation_probability_max[i],
                        });
                    }
                    root.daily = days;
                    root.loaded = true;
                } catch (e) {
                    if (!root.loaded) root.condition = "unavailable";
                }
            }
        }
    }

    Process {
        id: geocodeProc
        property var onErrorCallback: null
        stdout: StdioCollector {
            waitForEnd: true
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    const results = data.results;
                    if (!results || results.length === 0) {
                        root.geocodeError = true;
                        if (geocodeProc.onErrorCallback) geocodeProc.onErrorCallback("no matching location");
                        return;
                    }
                    const r = results[0];
                    const label = r.name + (r.admin1 ? ", " + r.admin1 : "") + (r.country ? ", " + r.country : "");
                    Config.setLocation(label, r.latitude, r.longitude);
                    root.refresh();
                } catch (e) {
                    root.geocodeError = true;
                    if (geocodeProc.onErrorCallback) geocodeProc.onErrorCallback("lookup failed");
                }
            }
        }
    }
}
