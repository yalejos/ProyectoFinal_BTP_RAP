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
          @Semantics.largeObject: {
          mimeType: 'MimeType',
          fileName: 'FileName',
          contentDispositionPreference: #INLINE
          }
          ImageURL,
          @Semantics.largeObject: {
          mimeType: 'MimeType',
          fileName: 'FileName',
          contentDispositionPreference: #INLINE
          }
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_SALES_LOGO_CALC'
          @Semantics.imageUrl: true
  virtual ImageRenderUrl : abap.rawstring(0),
          MimeType,
          FileName,
          totalAmount,

          LocalCreatedBy,
          LocalCreatedAt,
          LocalLastChangedBy,
          LocalLastChangedAt,
          LastChangedAt,
          /* Associations */
          _Country,
          _OrderStatus,
          _SalesItems : redirected to composition child ZSALESITEM_c_0573
}
