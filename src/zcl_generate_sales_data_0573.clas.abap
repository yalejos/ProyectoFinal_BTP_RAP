CLASS zcl_generate_sales_data_0573 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_generate_sales_data_0573 IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA: lt_headers   TYPE TABLE OF zsaleshead_0573,
          lt_items     TYPE TABLE OF zsalesitem_0573,
          ls_header    TYPE zsaleshead_0573,
          lv_timestamp TYPE timestampl.

    " Listas para datos reales
    DATA: lt_firstnames TYPE TABLE OF string,
          lt_lastnames  TYPE TABLE OF string,
          lt_products   TYPE TABLE OF string.

    " 1. Llenar diccionarios de datos "reales"
    lt_firstnames = VALUE #( ( `Carlos` ) ( `María` ) ( `Juan` ) ( `Ana` ) ( `Luis` ) ( `Elena` ) ( `Diego` ) ( `Lucía` ) ).
    lt_lastnames  = VALUE #( ( `García` ) ( `Rodríguez` ) ( `Pérez` ) ( `Martínez` ) ( `López` ) ( `Sánchez` ) ( `González` ) ).
    lt_products   = VALUE #( ( `Laptop Pro 15` ) ( `Monitor 4K` ) ( `Teclado Mecánico` ) ( `Mouse Ergonómico` ) ( `Auriculares Noise Cancelling` ) ( `Disco SSD 1TB` ) ).




    TRY.
        " Limpiar datos previos
        DELETE FROM zsaleshead_0573.
        DELETE FROM zsalesitem_0573.
        DELETE FROM zcountry_0573.
        DELETE FROM zunit_0573.


        GET TIME STAMP FIELD lv_timestamp.

        " Generadores de números aleatorios para los índices de las listas
        DATA(lo_rand_name) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( ) min = 1 max = lines( lt_firstnames ) ).
        DATA(lo_rand_last) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( ) min = 1 max = lines( lt_lastnames ) ).
        DATA(lo_rand_prod) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( ) min = 1 max = lines( lt_products ) ).
        DATA(lo_rand_price) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( ) min = 50 max = 1500 ).


        " --- GENERAR 10 CABECERAS ---
        DO 10 TIMES.
          DATA(lv_idx) = sy-index.
          DATA(lv_fname) = lt_firstnames[ lo_rand_name->get_next( ) ].
          DATA(lv_lname) = lt_lastnames[ lo_rand_last->get_next( ) ].


          CLEAR ls_header.
          ls_header = VALUE #(
            client                = sy-mandt
            head_uuid             = cl_system_uuid=>create_uuid_x16_static( )
            head_id               = |SO-{ lv_idx WIDTH = 6 ALIGN = RIGHT PAD = '0' }|
            email                 = to_lower( |{ lv_fname }.{ lv_lname }@mail.com| )
            firstname             = lv_fname
            lastname              = lv_lname
            country               = 'VEN'
            createon              = cl_abap_context_info=>get_system_date( )
            deliverydate          = cl_abap_context_info=>get_system_date( ) + 7
            orderstatus           = 'O'
            local_created_by      = sy-uname
            local_created_at      = lv_timestamp
            local_last_changed_at = lv_timestamp
            last_changed_at       = lv_timestamp
          ).
          APPEND ls_header TO lt_headers.

          " --- GENERAR ÍTEMS ---
          DO 3 TIMES.
            DATA(lv_pname) = lt_products[ lo_rand_prod->get_next( ) ].
            APPEND VALUE #(
              client                = sy-mandt
              item_uuid             = cl_system_uuid=>create_uuid_x16_static( )
              head_uuid             = ls_header-head_uuid
              item_id               = |IT-{ sy-index * 10 WIDTH = 6 ALIGN = RIGHT PAD = '0' }|
              name                  = lv_pname
              description           = |Garantía extendida para { lv_pname }|
              price                 = lo_rand_price->get_next( )
              quantity              = 1
              unit_of_measure       = 'ST' " Código estándar para 'Pieza'
              local_created_by      = sy-uname
              local_created_at      = lv_timestamp
              local_last_changed_at = lv_timestamp
              last_changed_at       = lv_timestamp
            ) TO lt_items.
          ENDDO.
        ENDDO.

        " Insertar en tablas
        INSERT zsaleshead_0573 FROM TABLE @lt_headers.
        INSERT zsalesitem_0573 FROM TABLE @lt_items.

        " Llenar tablas maestras (Countries & Units)
        INSERT zunit_0573 FROM TABLE @( VALUE #(
            ( client = sy-mandt unit_id = 'ST' unit_text = 'Pieza' )
            ( client = sy-mandt unit_id = 'KG' unit_text = 'Kilogramo' )
            ( client = sy-mandt unit_id = 'M' unit_text = 'Metro' )
            ( client = sy-mandt unit_id = 'UN' unit_text = 'Unidad' )
        ) ).

        "Countries
        INSERT zcountry_0573 FROM TABLE @( VALUE #(
          ( client = sy-mandt country_id = 'ARG' country_name = 'Argentina' )
         ( client = sy-mandt country_id = 'BRA' country_name = 'Brasil' )
         ( client = sy-mandt country_id = 'CHL' country_name = 'Chile' )
         ( client = sy-mandt country_id = 'COL' country_name = 'Colombia' )
         ( client = sy-mandt country_id = 'ESP' country_name = 'España' )
         ( client = sy-mandt country_id = 'MEX' country_name = 'México' )
         ( client = sy-mandt country_id = 'PAN' country_name = 'Panamá' )
         ( client = sy-mandt country_id = 'PER' country_name = 'Perú' )
         ( client = sy-mandt country_id = 'USA' country_name = 'Estados Unidos' )
         ( client = sy-mandt country_id = 'VEN' country_name = 'Venezuela' )
       ) ).



        out->write( '¡Éxito! Datos generados correctamente.' ).

      CATCH cx_root INTO DATA(lx_error).
        out->write( lx_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
