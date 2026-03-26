@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Header- Entity Root'
@Metadata.ignorePropagatedAnnotations: true
/*+[hideWarning] { "IDS" : [ "CARDINALITY_CHECK" ]  } */
define root view entity zsaleshead_r_0573
  as select from zsaleshead_0573
  composition [0..*] of zsalesitem_r_0573      as _SalesItems
  association [1..1] to zcountry_0573          as _Country     on $projection.Country = _Country.country_id
  association [1..1] to ZORDERSTATUS_I_VH_0573 as _OrderStatus on $projection.Orderstatus = _OrderStatus.StatusID
{
  key head_uuid                as HeadUuid,
      head_id                  as HeadID,
      email                    as Email,
      firstname                as Firstname,
      lastname                 as Lastname,
      @ObjectModel.text.element: ['CountryName']
      @ObjectModel.text.association: '_Country'
      country                  as Country,
      _Country.country_name    as CountryName,
      createon                 as Createon,
      deliverydate             as Deliverydate,
      @ObjectModel.text.element: ['OrderStatusName']
      @ObjectModel.text.association: '_OrderStatus'
      orderstatus              as Orderstatus,
      _OrderStatus.Descripcion as OrderStatusName,
      @Semantics.largeObject: {
      mimeType: 'MimeType',
      fileName: 'FileName',
      contentDispositionPreference: #INLINE
      }
      @Semantics.imageUrl: true
      imageurl                 as ImageURL,
      @Semantics.mimeType: true
      mimetype                 as MimeType,
      filename                 as FileName,
      total_amount             as totalAmount,


      @Semantics.user.createdBy: true
      local_created_by         as LocalCreatedBy,
      @Semantics.systemDateTime.createdAt: true
      local_created_at         as LocalCreatedAt,
      @Semantics.user.localInstanceLastChangedBy: true
      local_last_changed_by    as LocalLastChangedBy,

      //Local ETAG
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at    as LocalLastChangedAt,

      //Total ETAG
      @Semantics.systemDateTime.lastChangedAt: true
      last_changed_at          as LastChangedAt,

      // _Associations
      _SalesItems,
      _Country,
      _OrderStatus
}
