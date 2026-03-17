@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Header - Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity ZSALESHEAD_I_VH_0573
  as select from zsaleshead_0573
{
      @UI.hidden: true
  key head_uuid,
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key head_id   as SalesOrderID,

      @Search.defaultSearchElement: true
      firstname as CustomerName,

      @Search.defaultSearchElement: true
      lastname  as CustomerLastName
}
