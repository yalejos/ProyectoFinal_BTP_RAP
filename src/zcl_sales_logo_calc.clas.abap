CLASS zcl_sales_logo_calc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_sadl_exit_calc_element_read.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_sales_logo_calc IMPLEMENTATION.
  METHOD if_sadl_exit_calc_element_read~calculate.


    DATA lt_header TYPE STANDARD TABLE OF zsaleshead_c_0573 WITH DEFAULT KEY.
    lt_header = CORRESPONDING #( it_original_data ).

    LOOP AT lt_header ASSIGNING FIELD-SYMBOL(<ls_header>).
      IF <ls_header>-ImageURL IS NOT INITIAL.
        <ls_header>-ImageRenderUrl = <ls_header>-ImageURL.
      ENDIF.
    ENDLOOP.

    " 3. Devolvemos los datos calculados
    ct_calculated_data = CORRESPONDING #( lt_header ).
  ENDMETHOD.

  METHOD if_sadl_exit_calc_element_read~get_calculation_info.

    IF iv_entity = 'ZSALESHEAD_C_0573'.
      LOOP AT it_requested_calc_elements INTO DATA(ls_cal_elemnt).
        IF ls_cal_elemnt = 'IMAGERENDERURL'.
          APPEND 'IMAGEURL' TO et_requested_orig_elements.
        ENDIF.
      ENDLOOP.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
