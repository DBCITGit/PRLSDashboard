// ignore_for_file: public_member_api_docs, sort_constructors_first
class PlantingDetail {
  String wetDate;
  String plantingDate;
  String currHarvestDate;
  String commodityDesc;
  String commodityDescSpanish;
  PlantingDetail({
    this.wetDate,
    this.plantingDate,
    this.currHarvestDate,
    this.commodityDesc,
    this.commodityDescSpanish,
  });

  @override
  String toString() {
    return 'PlantingDetail(wetDate: $wetDate, plantingDate: $plantingDate, currHarvestDate: $currHarvestDate, commodityDesc: $commodityDesc, commodityDescSpanish: $commodityDescSpanish)';
  }
}
