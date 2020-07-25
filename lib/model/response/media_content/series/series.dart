import 'package:ombiapp/contracts/media_content.dart';
import 'package:ombiapp/contracts/media_content_type.dart';
import 'package:ombiapp/model/response/media_content/series/seasone.dart';
import 'package:ombiapp/utils/content_utilizer.dart';

class SeriesContent extends MediaContent {
  /// Is show running
  String _status, _network, _runtime;
  List<Season> _seasons;

  List<Season> get seasons => _seasons;

  get runtime => _runtime;

  get network => _network;

  String get status => _status;

  //TODO - Check if another wrapper class "SeriesExtended" is required to fetch the second part of data(extended) or just leave it here(does the api request contains those values via search query).
  SeriesContent.fromJson(Map<String, dynamic> json) {
    this.title = json['title'];
    this.overview = json['overview'];
    this.banner = MediaContentConverter.optimizeBanner(json['banner'], MediaContentType.SERIES);
    this.background = MediaContentConverter.optimizeBanner(json['banner'], MediaContentType.SERIES);
    this.id = json['id'];
    //TODO - Maybe load the background image when opening a series OR use the banner as the background as well.

//    this.voteRating = double.parse(json['rating']) / 10;
    this._status = json['status'];
//    this.contentStatus
    this.releaseDate = MediaContentConverter.toDate(json['firstAired'], MediaContentType.SERIES) ;
    this._network = json['network'];
    this._runtime = json['runTime'];
    this._seasons = List();
    json['seasonRequests'].forEach((s) => _seasons.add(Season.fromJson(s)));
  }
}
