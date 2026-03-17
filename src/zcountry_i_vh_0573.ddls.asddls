@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Countries Entity'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
define view entity ZCOUNTRY_I_VH_0573
  as select from zcountry_0573
{
      @UI.lineItem: [{ position: 10 }]
  key country_id   as CountryId,

      @UI.lineItem: [{ position: 20 }]
      @Search.defaultSearchElement: true
      country_name as CountryName
}
