CLASS lhc_SalesHeader DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    "Status for Sales Order
    CONSTANTS: BEGIN OF mc_status,
                 open      TYPE zde_orderstatus_code_0573 VALUE 'O',
                 confirmed TYPE zde_orderstatus_code_0573 VALUE 'C',
                 shipped   TYPE zde_orderstatus_code_0573 VALUE 'S',
                 canceled  TYPE zde_orderstatus_code_0573 VALUE 'X',
               END OF mc_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR SalesHeader RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR SalesHeader RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR SalesHeader RESULT result.

    METHODS cancelOrder FOR MODIFY
      IMPORTING keys FOR ACTION SalesHeader~cancelOrder RESULT result.

    METHODS confirmOrder FOR MODIFY
      IMPORTING keys FOR ACTION SalesHeader~confirmOrder RESULT result.

    METHODS shipOrder FOR MODIFY
      IMPORTING keys FOR ACTION SalesHeader~shipOrder RESULT result.

    METHODS initSalesOrder FOR DETERMINE ON MODIFY
      IMPORTING keys FOR SalesHeader~initSalesOrder.

    METHODS validateMandatoryFields FOR VALIDATE ON SAVE
      IMPORTING keys FOR SalesHeader~validateMandatoryFields.
    METHODS GetDefaultsForShipOrder FOR READ
      IMPORTING keys FOR FUNCTION SalesHeader~GetDefaultsForShipOrder RESULT result.

    METHODS setSalesOrderID FOR DETERMINE ON SAVE
      IMPORTING keys FOR SalesHeader~setSalesOrderID.


ENDCLASS.

CLASS lhc_SalesHeader IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
        ENTITY SalesHeader
          FIELDS ( Orderstatus ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_orders).

    result = VALUE #( FOR ls_order IN lt_orders (
        %tky = ls_order-%tky
        " No se puede cancelar ni confirmar algo ya enviado ('S') o cancelado ('X')
        %action-confirmOrder = COND #( WHEN ls_order-Orderstatus = mc_status-open
                                       THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %action-shipOrder    = COND #( WHEN ls_order-Orderstatus = mc_status-confirmed
                                       THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        %action-cancelOrder  = COND #( WHEN ls_order-Orderstatus = mc_status-shipped
                                       THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
        " Control de creación de ítems: solo si no está enviada o cancelada
        %assoc-_SalesItems   = COND #( WHEN ls_order-Orderstatus = mc_status-shipped OR ls_order-Orderstatus = mc_status-canceled
                                       THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
        " Bloquear el botón 'Edit' si el estatus NO es 'Open'
        %update = COND #( WHEN ls_order-Orderstatus = mc_status-open
                          THEN if_abap_behv=>fc-o-enabled ELSE if_abap_behv=>fc-o-disabled )
        "Solo permitimos DELETE si el status es es 'O' (Open)
         %delete              =  COND #( WHEN ls_order-Orderstatus = mc_status-open
                                      THEN if_abap_behv=>fc-o-enabled
                                      ELSE if_abap_behv=>fc-o-disabled )
    ) ).

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD cancelOrder.

    MODIFY ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
        ENTITY SalesHeader
          UPDATE FIELDS ( Orderstatus )
          WITH VALUE #( FOR key IN keys ( %tky = key-%tky Orderstatus = mc_status-canceled ) ) " 'X' = Cancelled
        REPORTED DATA(lt_reported).

    reported = CORRESPONDING #( DEEP lt_reported ).

    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesHeader ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_sales).
    result = VALUE #( FOR ls_sale IN lt_sales ( %tky = ls_sale-%tky %param = ls_sale ) ).

  ENDMETHOD.

  METHOD confirmOrder.

    TYPES: tt_items_indexed TYPE SORTED TABLE OF zsalesitem_r_0573
                WITH NON-UNIQUE KEY HeadUuid.

    DATA: lt_items_indexed TYPE tt_items_indexed,
          lt_to_modify     TYPE TABLE FOR UPDATE zsaleshead_r_0573.

    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesHeader BY \_SalesItems
        FIELDS ( ReleaseDate Name HeadUUID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    lt_items_indexed = CORRESPONDING #( lt_items ).

    " Validaciones
    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      DATA(lv_failed_this_order) = abap_false.

      LOOP AT lt_items_indexed INTO DATA(ls_item) WHERE HeadUuid = <ls_key>-HeadUuid.
      "No se puede confirmar, si existe un item sin fecha de lanzamiento
        IF ls_item-ReleaseDate IS INITIAL.
          lv_failed_this_order = abap_true.

          APPEND VALUE #( %tky = <ls_key>-%tky ) TO failed-salesheader.
          APPEND VALUE #( %tky = <ls_key>-%tky
                          %state_area = 'CONFIRM_ORDER'
                          %msg = NEW zcl_messages_sales_0573(
                                   textid   = zcl_messages_sales_0573=>release_date
                                   name     = ls_item-Name
                                   severity = if_abap_behv_message=>severity-error )
                        ) TO reported-salesheader.
          EXIT.
        ENDIF.
      ENDLOOP.

      " Si no falló
      IF lv_failed_this_order = abap_false.
        APPEND VALUE #( %tky        = <ls_key>-%tky
                        Orderstatus = mc_status-confirmed ) TO lt_to_modify.
      ENDIF.
    ENDLOOP.


    IF lt_to_modify IS NOT INITIAL.
      MODIFY ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
        ENTITY SalesHeader
          UPDATE FIELDS ( Orderstatus )
          WITH lt_to_modify
        REPORTED DATA(lt_reported_mod).

      reported-salesheader = CORRESPONDING #( BASE ( reported-salesheader ) lt_reported_mod-salesheader ).
    ENDIF.


    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesHeader ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_sales).

    result = VALUE #( FOR ls_sale IN lt_sales ( %tky = ls_sale-%tky %param = ls_sale ) ).

  ENDMETHOD.

  METHOD shipOrder.
    TYPES: tt_items_indexed TYPE SORTED TABLE OF zsalesitem_r_0573
               WITH NON-UNIQUE KEY HeadUuid.

    DATA: lt_items_indexed TYPE tt_items_indexed,
          lt_to_ship       TYPE TABLE FOR UPDATE zsaleshead_r_0573.


    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesHeader BY \_SalesItems
        FIELDS ( ReleaseDate DiscontinuedDate Name HeadUUID )
      WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    lt_items_indexed = CORRESPONDING #( lt_items ).
    DATA(lv_today) = cl_abap_context_info=>get_system_date( ).


    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).
      DATA(lv_failed_order) = abap_false.

      " Obtener fecha de entrega del parámetro del popup
      DATA(lv_delivery_date) = <ls_key>-%param-delivery_date.
      IF lv_delivery_date IS INITIAL.
        lv_delivery_date = lv_today.
      ENDIF.


      LOOP AT lt_items_indexed INTO DATA(ls_item) WHERE HeadUuid = <ls_key>-HeadUuid.

        "¿El producto tiene fecha de lanzamiento?
        IF ls_item-ReleaseDate IS INITIAL.
          lv_failed_order = abap_true.
          APPEND VALUE #( %tky = <ls_key>-%tky ) TO failed-salesheader.
          APPEND VALUE #( %tky = <ls_key>-%tky
                          %state_area = 'SHIP_ORDER'
                          %msg = NEW zcl_messages_sales_0573(
                                   textid   = zcl_messages_sales_0573=>release_date
                                   name     = ls_item-Name
                                   severity = if_abap_behv_message=>severity-error )
                        ) TO reported-salesheader.
          EXIT.
        ENDIF.

        "¿El producto se descatalogó después de confirmar la orden?
        IF ls_item-DiscontinuedDate IS NOT INITIAL AND ls_item-DiscontinuedDate <= lv_today.
          lv_failed_order = abap_true.
          APPEND VALUE #( %tky = <ls_key>-%tky ) TO failed-salesheader.
          APPEND VALUE #( %tky = <ls_key>-%tky
                         %state_area = 'SHIP_ORDER'
                          %msg = NEW zcl_messages_sales_0573(
                                   textid   = zcl_messages_sales_0573=>discontinued_date
                                   name     = ls_item-Name
                                   severity = if_abap_behv_message=>severity-error )
                        ) TO reported-salesheader.
          EXIT.
        ENDIF.
      ENDLOOP.

      "Si pasó los checks
      IF lv_failed_order = abap_false.
        APPEND VALUE #( %tky         = <ls_key>-%tky
                        Orderstatus  = mc_status-shipped
                        Deliverydate = lv_delivery_date ) TO lt_to_ship.
      ENDIF.
    ENDLOOP.


    IF lt_to_ship IS NOT INITIAL.
      MODIFY ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
        ENTITY SalesHeader
          UPDATE FIELDS ( Orderstatus Deliverydate )
          WITH lt_to_ship
        REPORTED DATA(lt_reported_modify).

      reported-salesheader = CORRESPONDING #( BASE ( reported-salesheader ) lt_reported_modify-salesheader ).
    ENDIF.


    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesHeader ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_sales).

    result = VALUE #( FOR ls_sale IN lt_sales ( %tky = ls_sale-%tky %param = ls_sale ) ).

  ENDMETHOD.

  METHOD initSalesOrder.

    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesHeader
        FIELDS ( Orderstatus Createon Deliverydate ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    DELETE lt_orders WHERE HeadID IS NOT INITIAL.

    CHECK lt_orders IS NOT INITIAL.


    MODIFY ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesHeader
        UPDATE FIELDS ( Orderstatus Createon Deliverydate )
        WITH VALUE #(  FOR ls_order IN lt_orders ( %tky = ls_order-%tky
                           Orderstatus  = mc_status-open
                           Createon     = cl_abap_context_info=>get_system_date( )
                           Deliverydate = cl_abap_context_info=>get_system_date( ) + 7 )  ).

  ENDMETHOD.

  METHOD validateMandatoryFields.

    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
    ENTITY SalesHeader
      FIELDS ( Email ) WITH CORRESPONDING #( keys )
    RESULT DATA(lt_orders).


    LOOP AT lt_orders ASSIGNING FIELD-SYMBOL(<order>).
*      APPEND VALUE #( %tky = <order>-%tky
*            %state_area = 'VALIDATE_SALES' ) TO reported-salesheader.

      "Mandatory Email
      IF <order>-Email IS INITIAL.
        APPEND VALUE #( %tky = <order>-%tky ) TO failed-salesheader.
        APPEND VALUE #( %tky = <order>-%tky
                          %state_area = 'VALIDATE_SALES'

                          %msg = NEW zcl_messages_sales_0573(
                                   textid   = zcl_messages_sales_0573=>mandatory_fields
                                   severity = if_abap_behv_message=>severity-error
                                  )
                          %element-Email = if_abap_behv=>mk-on
                        ) TO reported-salesheader.
        RETURN.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD GetDefaultsForShipOrder.

    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
        ENTITY SalesHeader
          FIELDS ( Deliverydate ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_orders).

    result = VALUE #( FOR ls_order IN lt_orders (
                       %tky   = ls_order-%tky
                       %param = VALUE #( delivery_date = ls_order-Deliverydate )
                     ) ).

  ENDMETHOD.



  METHOD setSalesOrderID.

    "Buscar el último ID numérico en la tabla de base de datos
    SELECT MAX( head_id ) FROM zsaleshead_0573 INTO @DATA(lv_max_id).

    " Extraer el número del formato SO-000000
    DATA(lv_number) = substring( val = lv_max_id off = 3 ).
    DATA(lv_next_number) = CONV i( lv_number ).


    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesHeader
        FIELDS ( HeadID  ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_orders).

    DELETE lt_orders WHERE HeadID IS NOT INITIAL.

    CHECK lt_orders IS NOT INITIAL.


    MODIFY ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesHeader
        UPDATE FIELDS ( HeadID  )
        WITH VALUE #( FOR ls_order IN lt_orders INDEX INTO i ( %tky     = ls_order-%tky
                          HeadID       = |SO-{ lv_next_number + i WIDTH = 6 ALIGN = RIGHT PAD = '0' }| ) ).
  ENDMETHOD.



ENDCLASS.

CLASS lhc_SalesItem DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    CONSTANTS: BEGIN OF mc_status,
                 open      TYPE zde_orderstatus_code_0573 VALUE 'O',
                 confirmed TYPE zde_orderstatus_code_0573 VALUE 'C',
                 shipped   TYPE zde_orderstatus_code_0573 VALUE 'S',
                 canceled  TYPE zde_orderstatus_code_0573 VALUE 'X',
               END OF mc_status.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR SalesItem RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR SalesItem RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR SalesItem RESULT result.

    METHODS discontinueProduct FOR MODIFY
      IMPORTING keys FOR ACTION SalesItem~discontinueProduct RESULT result.

    METHODS releaseProduct FOR MODIFY
      IMPORTING keys FOR ACTION SalesItem~releaseProduct RESULT result.

    METHODS validatePrice FOR VALIDATE ON SAVE
      IMPORTING keys FOR SalesItem~validatePrice.

    METHODS GetDefaultsForReleaseProduct FOR READ
      IMPORTING keys FOR FUNCTION SalesItem~GetDefaultsForReleaseProduct RESULT result.
    METHODS initSalesItem FOR DETERMINE ON MODIFY
      IMPORTING keys FOR SalesItem~initSalesItem.
    METHODS updateHeaderTotal FOR DETERMINE ON MODIFY
      IMPORTING keys FOR SalesItem~updateHeaderTotal.

ENDCLASS.

CLASS lhc_SalesItem IMPLEMENTATION.

  METHOD get_instance_features.


    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
        ENTITY SalesItem
          FIELDS ( ReleaseDate DiscontinuedDate HeadUUID )
          WITH CORRESPONDING #( keys )
        RESULT DATA(lt_items).


    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
        ENTITY SalesHeader
          FIELDS ( Orderstatus )
          WITH VALUE #( FOR ls_item IN lt_items ( %tky = CORRESPONDING #( ls_item-%tky ) ) )
        RESULT DATA(lt_parent_headers).


    LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>).


      READ TABLE lt_parent_headers WITH KEY entity
        COMPONENTS HeadUuid = <ls_item>-HeadUUID
        ASSIGNING FIELD-SYMBOL(<ls_parent>).

      DATA(lv_update_control) = if_abap_behv=>fc-o-disabled.
      DATA(lv_delete_control) = if_abap_behv=>fc-o-disabled.

    " Si ls_parent no se encuentra (sy-subrc != 0), es un nuevo ítem en un nuevo objeto: PERMITIR.
      IF sy-subrc <> 0 OR <ls_parent>-Orderstatus = mc_status-open OR <ls_parent>-Orderstatus IS INITIAL.
        lv_update_control = if_abap_behv=>fc-o-enabled.
        lv_delete_control = if_abap_behv=>fc-o-enabled.
      ENDIF.

      "Control de la Acción 'Discontinue' (Solo si YA tiene fecha)
      DATA(lv_disc_control) = if_abap_behv=>fc-o-disabled.
      IF <ls_item>-ReleaseDate IS NOT INITIAL AND <ls_item>-DiscontinuedDate IS INITIAL.
        lv_disc_control = if_abap_behv=>fc-o-enabled.
      ENDIF.

      "Control de la Acción 'Release' (Solo si NO tiene fecha)
      DATA(lv_release_control) = if_abap_behv=>fc-o-disabled.
      IF <ls_item>-ReleaseDate IS INITIAL.
         lv_release_control = if_abap_behv=>fc-o-enabled.
      ENDIF.

      APPEND VALUE #(
          %tky                       = <ls_item>-%tky
          %update                    = lv_update_control
          %delete                    = lv_delete_control
          %action-discontinueProduct = lv_disc_control
          %action-releaseProduct     = lv_release_control
      ) TO result.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD discontinueProduct.

    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesItem
        FIELDS ( ReleaseDate DiscontinuedDate Name ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).
      IF ls_item-ReleaseDate IS INITIAL.
        " Si alguien intenta forzar la acción sin fecha de lanzamiento
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-salesitem.
        APPEND VALUE #( %tky = ls_item-%tky
                         %state_area = 'VALIDATE_SALES'
                         %msg = NEW zcl_messages_sales_0573(
                                  textid   = zcl_messages_sales_0573=>discontinued_without_release
                                  name     = ls_item-Name
                                  severity = if_abap_behv_message=>severity-error
                                 )
                       ) TO reported-salesitem.


        " Error: Fecha de retiro es anterior al lanzamiento
      ELSEIF ls_item-DiscontinuedDate IS NOT INITIAL AND ls_item-ReleaseDate IS NOT INITIAL
         AND ls_item-DiscontinuedDate < ls_item-ReleaseDate.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-salesitem.
        APPEND VALUE #( %tky = ls_item-%tky
                         %state_area = 'VALIDATE_SALES'
                         %msg = NEW zcl_messages_sales_0573(
                                  textid   = zcl_messages_sales_0573=>discontinued_without_release
                                  name     = ls_item-Name
                                  severity = if_abap_behv_message=>severity-error
                                 )
                       ) TO reported-salesitem.

      ELSE.
        " Si está OK, actualizamos
        MODIFY ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
          ENTITY SalesItem
            UPDATE FIELDS ( DiscontinuedDate )
            WITH VALUE #( ( %tky = ls_item-%tky
                            DiscontinuedDate = cl_abap_context_info=>get_system_date( ) ) ).
      ENDIF.
    ENDLOOP.


    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesItem ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items_res).
    result = VALUE #( FOR ls_res IN lt_items_res ( %tky = ls_res-%tky %param = ls_res ) ).

  ENDMETHOD.

  METHOD releaseProduct.

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_key>).

      DATA(lv_chosen_date) = <ls_key>-%param-release_date.

      IF lv_chosen_date IS INITIAL.
        APPEND VALUE #( %tky = <ls_key>-%tky ) TO failed-salesitem.
        APPEND VALUE #( %tky = <ls_key>-%tky
                         %state_area = 'VALIDATE_SALES'
                         %msg = NEW zcl_messages_sales_0573(
                                  textid   = zcl_messages_sales_0573=>invalid_date
                                  severity = if_abap_behv_message=>severity-error
                                 )
                       ) TO reported-salesitem.

        CONTINUE.
      ENDIF.


      MODIFY ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
        ENTITY SalesItem
          UPDATE FIELDS ( ReleaseDate )
          WITH VALUE #( ( %tky = <ls_key>-%tky ReleaseDate = lv_chosen_date ) )
        FAILED DATA(lt_failed)
        REPORTED DATA(lt_reported).


      failed-salesitem = CORRESPONDING #( DEEP lt_failed-salesitem ).
      reported-salesitem = CORRESPONDING #( DEEP lt_reported-salesitem ).
    ENDLOOP.


    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesItem ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items).

    result = VALUE #( FOR ls_item IN lt_items ( %tky = ls_item-%tky %param = ls_item ) ).

  ENDMETHOD.

  METHOD validatePrice.

    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
        ENTITY SalesItem FIELDS ( Name Price ) WITH CORRESPONDING #( keys )
        RESULT DATA(lt_items).

    LOOP AT lt_items INTO DATA(ls_item).
      IF ls_item-Price <= 0.
        APPEND VALUE #( %tky = ls_item-%tky ) TO failed-salesitem.
        APPEND VALUE #( %tky = ls_item-%tky
                          %state_area = 'VALIDATE_SALES'
                          %msg = NEW zcl_messages_sales_0573(
                                   textid   = zcl_messages_sales_0573=>invalid_price
                                   name     = ls_item-Name
                                   severity = if_abap_behv_message=>severity-error
                                  )
                        ) TO reported-salesitem.

      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD GetDefaultsForReleaseProduct.

    result = VALUE #( FOR key IN keys (
                       %tky   = key-%tky
                       %param = VALUE #( release_date = cl_abap_context_info=>get_system_date( ) )
                     ) ).
  ENDMETHOD.

  METHOD initSalesItem.

    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesItem
        FIELDS ( HeadUUID ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_items_with_parent).


    LOOP AT lt_items_with_parent ASSIGNING FIELD-SYMBOL(<ls_item>).

        READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
        ENTITY SalesHeader BY \_SalesItems
          FIELDS ( ItemID  ) WITH VALUE #( ( %is_draft = <ls_item>-%is_draft
                                            HeadUuid  = <ls_item>-HeadUUID ) )
        RESULT DATA(lt_existing_items).

      "Calcular el siguiente número
      DATA: lv_next_number TYPE i VALUE 1.

      IF lt_existing_items IS NOT INITIAL.
        SORT lt_existing_items BY ItemID DESCENDING.
        " Buscamos el primer ItemID que tenga el formato IT-
        DATA(lv_last_id) = lt_existing_items[ 1 ]-ItemID.

        IF lv_last_id IS NOT INITIAL AND lv_last_id CP 'IT-*'.
          DATA(lv_numeric_part) = substring( val = lv_last_id off = 3 ).
          lv_next_number = CONV i( lv_numeric_part ) + 1.
        ENDIF.
      ENDIF.


      MODIFY ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
        ENTITY SalesItem
          UPDATE FIELDS ( ItemID UnitOfMeasure )
          WITH VALUE #( ( %tky   = <ls_item>-%tky
                          ItemID = |IT-{ lv_next_number  WIDTH = 6 ALIGN = RIGHT PAD = '0' }|
                          UnitOfMeasure =  'ST' ) ).
    ENDLOOP.

  ENDMETHOD.
  METHOD updateHeaderTotal.


    READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
      ENTITY SalesItem
      BY \_SalesHeader
      ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_headers).

    LOOP AT lt_headers ASSIGNING FIELD-SYMBOL(<ls_header>).
      DATA(lv_total_header) = 0.


      READ ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
        ENTITY SalesHeader BY \_SalesItems
        FIELDS ( Price Quantity )
        WITH VALUE #( ( %tky = <ls_header>-%tky ) )
        RESULT DATA(lt_items).


      LOOP AT lt_items ASSIGNING FIELD-SYMBOL(<ls_item>).
        lv_total_header += ( <ls_item>-Price * <ls_item>-Quantity ).
      ENDLOOP.


      MODIFY ENTITIES OF zsaleshead_r_0573 IN LOCAL MODE
        ENTITY SalesHeader
        UPDATE FIELDS ( TotalAmount )
        WITH VALUE #( ( %tky        = <ls_header>-%tky
                        TotalAmount = lv_total_header ) ).
    ENDLOOP.

  ENDMETHOD.

ENDCLASS.
