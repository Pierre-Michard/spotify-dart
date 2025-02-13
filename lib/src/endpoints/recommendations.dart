part of '../../spotify.dart';

class RecommendationsEndpoint extends EndpointBase {
  @override
  String get _path => 'v1/recommendations';

  RecommendationsEndpoint(super.api);

  /// Generates a list of size [limit] of tracks based on
  /// [seedArtists], [seedGenres], [seedTracks] spotify IDs
  /// [min] [max] and [target] sets Tunable Track attributes limitations
  /// (see https://developer.spotify.com/documentation/web-api/reference/browse/get-recommendations/)
  Future<Recommendations> get(
      {Iterable<String>? seedArtists,
      Iterable<String>? seedGenres,
      Iterable<String>? seedTracks,
      int limit = 20,
      Market? market,
      Map<String, num>? max,
      Map<String, num>? min,
      Map<String, num>? target}) async {
    assert(limit >= 1 && limit <= 100, 'limit should be 1 <= limit <= 100');
    final seedsNum = (seedArtists?.length ?? 0) +
        (seedGenres?.length ?? 0) +
        (seedTracks?.length ?? 0);
    assert(
        seedsNum >= 1 && seedsNum <= 5,
        'Up to 5 seed values may be provided in any combination of seed_artists,'
        ' seed_tracks and seed_genres.');
    final parameters = <String, String>{'limit': limit.toString()};
    final _ = {
      'seed_artists': seedArtists,
      'seed_genres': seedGenres,
      'seed_tracks': seedTracks
    }.forEach((key, list) => _addList(parameters, key, list ?? []));
    if (market != null) parameters['market'] = market.name;
    _addTunableTrackMap(parameters, min, TunablePrefixes.min);
    _addTunableTrackMap(parameters, max, TunablePrefixes.max);
    _addTunableTrackMap(parameters, target, TunablePrefixes.target);
    final pathQuery = Uri(path: _path, queryParameters: parameters)
        .toString()
        .replaceAll(RegExp(r'%2C'), ',');
    final result = jsonDecode(await _api._get(pathQuery));
    return Recommendations.fromJson(result);
  }

  /// gets [parameters], a map of the request's uri parameters,
  /// and [tunableTrackMap] a map of tunable Track Attributes.
  /// adds the attributes to [parameters]
  void _addTunableTrackMap(Map<String, String> parameters,
      Map<String, num>? tunableTrackMap, TunablePrefixes prefix) {
    if (tunableTrackMap != null) {
      parameters.addAll(tunableTrackMap.map<String, String>((k, v) => MapEntry(
          '${prefix}_$k', v is int ? v.toString() : v.toStringAsFixed(2))));
    }
  }

  /// gets [parameters], a map of the request's uri parameters and
  /// adds an entry with [key] and value of [paramList] as comma separated list
  void _addList(
      Map<String, String> parameters, String key, Iterable<String> paramList) {
    if (paramList.isNotEmpty) {
      parameters[key] = paramList.join(',');
    }
  }
}

class TunablePrefixes {
  final String value;

  const TunablePrefixes._internal(this.value);

  static const TunablePrefixes min = TunablePrefixes._internal('min');
  static const TunablePrefixes max = TunablePrefixes._internal('max');
  static const TunablePrefixes target = TunablePrefixes._internal('target');

  static const List<TunablePrefixes> values = [min, max, target];

  @override
  String toString() => value;
}
