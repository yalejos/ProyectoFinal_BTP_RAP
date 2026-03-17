@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Unit of measure - Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity ZUNITOFMEASURE_I_VH_0573
  as select from zunit_0573
{
     @UI.lineItem: [{ position: 10 }]
  key unit_id   as UnitId,

      @UI.lineItem: [{ position: 20 }]
      @Search.defaultSearchElement: true
      unit_text as UnitName
}
