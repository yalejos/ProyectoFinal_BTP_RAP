@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sales Items - Consumption Entity'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

define view entity ZSALESITEM_c_0573
  as projection on zsalesitem_r_0573
{
  key ItemUUID,
      HeadUUID,
      ItemID,
      Name,
      Description,
      ReleaseDate,
      DiscontinuedDate,
      Price,
      @Semantics.quantity.unitOfMeasure : 'UnitOfMeasure'
      Height,
      @Semantics.quantity.unitOfMeasure : 'UnitOfMeasure'
      Width,
      Depth,
      Quantity,
      UnitOfMeasure,
      LocalLastChangedAt,
      /* Associations */
      _SalesHeader: redirected to parent ZSALESHEAD_c_0573
}
