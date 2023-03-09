// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:prodwo_timesheet/models/planting_detail.dart';

class Planting {
  String ranchBlock;
  String district;
  String ranch;
  String block;
  String season;
  String planting;
  String variety;
  String siteAcres;
  String commodityDesc;
  String commodityDescSpanish;
  PlantingDetail plantingDetail;

  Planting(
      {this.ranchBlock,
      this.district,
      this.ranch,
      this.block,
      this.season,
      this.planting,
      this.variety,
      this.siteAcres,
      this.commodityDesc,
      this.commodityDescSpanish,
      this.plantingDetail});

  @override
  String toString() {
    return 'Planting(ranchBlock: $ranchBlock, district: $district, ranch: $ranch, block: $block, season: $season, planting: $planting, plantingDetails: $plantingDetail, variety: $variety, siteAcres: $siteAcres, commodityDesc: $commodityDesc, commodityDescSpanish: $commodityDescSpanish)';
  }
}
