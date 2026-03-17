@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Item - Entity Root'
@Metadata.ignorePropagatedAnnotations: true
define view entity zsalesitem_r_0573
  as select from zsalesitem_0573
  association to parent zsaleshead_r_0573 as _SalesHeader on $projection.HeadUUID = _SalesHeader.HeadUuid
{
  key item_uuid             as ItemUUID,
      head_uuid             as HeadUUID,
      item_id               as ItemID,
      name                  as Name,
      description           as Description,
      release_date          as ReleaseDate,
      discontinued_date     as DiscontinuedDate,
      price                 as Price,
      @Semantics.quantity.unitOfMeasure : 'UnitOfMeasure'
      height                as Height,
      @Semantics.quantity.unitOfMeasure : 'UnitOfMeasure'
      width                 as Width,
      depth                 as Depth,
      quantity              as Quantity,
      unit_of_measure       as UnitOfMeasure,

      //Local ETAG
      @Semantics.systemDateTime.localInstanceLastChangedAt: true
      local_last_changed_at as LocalLastChangedAt,

      //_Associations
      _SalesHeader


}
