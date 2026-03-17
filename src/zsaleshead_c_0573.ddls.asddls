@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Header - Consumption Entity'
@Metadata.ignorePropagatedAnnotations: true
@Search.searchable: true
@Metadata.allowExtensions: true

@ObjectModel.semanticKey: [ 'HeadID' ]
define root view entity ZSALESHEAD_c_0573
  provider contract transactional_query
  as projection on zsaleshead_r_0573

{
  key     HeadUuid,
          @Search.defaultSearchElement: true
          HeadID,
          Email,
          Firstname,
          Lastname,
          @ObjectModel.text.element: ['CountryName']
          Country,
          CountryName,
          Createon,
          Deliverydate,
          @ObjectModel.text.element: ['OrderStatusName']
          Orderstatus,
          OrderStatusName,
          @ObjectModel.text.element: ['CompanyName']
          CompanyCode,
          CompanyName,
          @Semantics.imageUrl: true
          ImageURL,
  //        @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_ELEM_SADL_0573'
 // virtual TotalPrice : zde_price_0573,
          LocalCreatedBy,
          LocalCreatedAt,
          LocalLastChangedBy,
          LocalLastChangedAt,
          LastChangedAt,
          /* Associations */
          _Country,
          _Logos,
          _OrderStatus,
          _SalesItems : redirected to composition child ZSALESITEM_c_0573
}
