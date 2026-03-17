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
          lv_timestamp TYPE timestampl,
          lv_logo_url  tyPE zde_imageurl_0573.

    " Listas para datos reales
    DATA: lt_firstnames TYPE TABLE OF string,
          lt_lastnames  TYPE TABLE OF string,
          lt_products   TYPE TABLE OF string,
          lt_comp_ids   TYPE TABLE OF zde_company_code_0573.

    " 1. Llenar diccionarios de datos "reales"
    lt_firstnames = VALUE #( ( `Carlos` ) ( `María` ) ( `Juan` ) ( `Ana` ) ( `Luis` ) ( `Elena` ) ( `Diego` ) ( `Lucía` ) ).
    lt_lastnames  = VALUE #( ( `García` ) ( `Rodríguez` ) ( `Pérez` ) ( `Martínez` ) ( `López` ) ( `Sánchez` ) ( `González` ) ).
    lt_products   = VALUE #( ( `Laptop Pro 15` ) ( `Monitor 4K` ) ( `Teclado Mecánico` ) ( `Mouse Ergonómico` ) ( `Auriculares Noise Cancelling` ) ( `Disco SSD 1TB` ) ).
    lt_comp_ids = VALUE #( ( 'VEN' ) ( 'APP' ) ( 'TEL' ) ( 'BIM' ) ( 'AVI' ) ( 'MER' ) ( 'LAT' ) ( 'PET' ) ).



    TRY.
        " Limpiar datos previos
        DELETE FROM zsaleshead_0573.
        DELETE FROM zsalesitem_0573.
        DELETE FROM zcountry_0573.
        DELETE FROM zunit_0573.
        DELETE FROM zcomp_logo_0573.

        GET TIME STAMP FIELD lv_timestamp.

        " Generadores de números aleatorios para los índices de las listas
        DATA(lo_rand_name) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( ) min = 1 max = lines( lt_firstnames ) ).
        DATA(lo_rand_last) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( ) min = 1 max = lines( lt_lastnames ) ).
        DATA(lo_rand_prod) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( ) min = 1 max = lines( lt_products ) ).
        DATA(lo_rand_price) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( ) min = 50 max = 1500 ).
        DATA(lo_rand_comp) = cl_abap_random_int=>create( seed = cl_abap_random=>seed( ) min = 1 max = lines( lt_comp_ids ) ).

        " --- GENERAR 10 CABECERAS ---
        DO 10 TIMES.
          DATA(lv_idx) = sy-index.
          DATA(lv_fname) = lt_firstnames[ lo_rand_name->get_next( ) ].
          DATA(lv_lname) = lt_lastnames[ lo_rand_last->get_next( ) ].

          .

          " Elegimos un ID de compañía de la lista
          DATA(lv_comp_id) = lt_comp_ids[ lo_rand_comp->get_next( ) ].

          " Buscamos el logo correspondiente (basándonos en la misma lógica que usaremos para insertar abajo)
         lv_logo_url = |https://ui-avatars.com/api/?name={ lv_comp_id }&background=random&color=fff&size=128&font-size=0.5|.

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
            company_code          = lv_comp_id
            imageurl              = lv_logo_url
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

        " 2. Preparar tabla interna de logos
      INSERT zcomp_logo_0573 FROM TABLE @( VALUE #(
          ( client = sy-mandt company_id = 'VEN' company_name = 'Ventas Nacionales' image_url = 'https://ui-avatars.com/api/?name=VEN&background=0D47A1&color=fff' )
          ( client = sy-mandt company_id = 'APP' company_name = 'Apple Store'      image_url = 'https://ui-avatars.com/api/?name=APP&background=333333&color=fff' )
          ( client = sy-mandt company_id = 'TEL' company_name = 'Telefónica Corp'  image_url = 'https://ui-avatars.com/api/?name=TEL&background=003245&color=fff' )
          ( client = sy-mandt company_id = 'BIM' company_name = 'Bimbo Alimentos'  image_url = 'https://ui-avatars.com/api/?name=BIM&background=E21237&color=fff' )
          ( client = sy-mandt company_id = 'AVI' company_name = 'Avianca'          image_url = 'https://ui-avatars.com/api/?name=AVI&background=D81E05&color=fff' )
          ( client = sy-mandt company_id = 'MER' company_name = 'Mercado Libre'    image_url = 'https://ui-avatars.com/api/?name=MER&background=FFF159&color=333' )
          ( client = sy-mandt company_id = 'LAT' company_name = 'LATAM Airlines'   image_url = 'https://ui-avatars.com/api/?name=LAT&background=1B0088&color=fff' )
          ( client = sy-mandt company_id = 'PET' company_name = 'Petróleos Global' image_url = 'https://ui-avatars.com/api/?name=PET&background=008542&color=fff' )
        ) ).

        out->write( '¡Éxito! Datos generados correctamente.' ).

      CATCH cx_root INTO DATA(lx_error).
        out->write( lx_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
