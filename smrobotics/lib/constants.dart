import 'config.dart';

String baseURL = "https://theorangealliance.org/api/";

Map<String, String> requiredHeadersWithSeason = {
  "Content-Type":"application/json",
  "X-TOA-Key":apiKey,
  "X-Application-Origin":"SM Robotics",
  "season_key":currentSeason
};
Map<String, String> requiredHeadersWithoutSeason = {
  "Content-Type":"application/json",
  "X-TOA-Key":apiKey,
  "X-Application-Origin":"SM Robotics",
};

