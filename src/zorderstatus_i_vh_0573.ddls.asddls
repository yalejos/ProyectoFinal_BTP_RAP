@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Status - Value Help'
@ObjectModel.resultSet.sizeCategory: #XS
@Search.searchable: true
define view entity ZORDERSTATUS_I_VH_0573
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T (p_domain_name: 'ZDO_ORDERSTATUS_CODE_0573')
{
      @UI.hidden: true
  key domain_name    as DomainName,

      @UI.hidden: true
  key value_position as ValuePosition,

      @Search.defaultSearchElement: true
      @UI.hidden: true
  key value_low      as StatusID,

      @UI.lineItem: [{ position: 20 }]
      @Search.defaultSearchElement: true
      text           as Descripcion
}
where
      domain_name = 'ZDO_ORDERSTATUS_CODE_0573'
  and language    = $session.system_language
