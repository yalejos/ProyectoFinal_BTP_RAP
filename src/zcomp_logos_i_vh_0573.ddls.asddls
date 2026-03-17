@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Companies Logos - Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity Zcomp_logos_I_VH_0573
  as select from zcomp_logo_0573
{
      @UI.lineItem: [{ position: 10 }]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
  key company_id   as CompanyCode,

      @UI.lineItem: [{ position: 20 }]
      @Search.defaultSearchElement: true
      @Search.fuzzinessThreshold: 0.8
      @EndUserText.label: 'Company Name'
      company_name as CompanyName,

      @UI.hidden: true
      image_url    as ImageURL

}
