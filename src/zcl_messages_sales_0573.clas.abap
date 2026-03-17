CLASS zcl_messages_sales_0573 DEFINITION
  PUBLIC
  INHERITING FROM cx_static_check
  FINAL
  CREATE PUBLIC .


  PUBLIC SECTION.

    INTERFACES if_t100_message .
    INTERFACES if_t100_dyn_msg .
    INTERFACES if_abap_behv_message .

    CONSTANTS:

      gc_msgid TYPE symsgid VALUE 'ZMC_SALES_MESSG_0573',

      BEGIN OF discontinued_lt_release,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '001',
        attr1 TYPE scx_attrname VALUE 'MV_NAME',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF discontinued_lt_release,

      BEGIN OF release_date,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '002',
        attr1 TYPE scx_attrname VALUE 'MV_NAME',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF release_date,

      BEGIN OF user_unauthorized,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '003',
        attr1 TYPE scx_attrname VALUE 'MV_NONAUT',
        attr2 TYPE scx_attrname VALUE 'MV_INCIDENTID',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF user_unauthorized,

      BEGIN OF discontinued_date,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '004',
        attr1 TYPE scx_attrname VALUE 'MV_NAME',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF discontinued_date,

      BEGIN OF invalid_price,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '005',
        attr1 TYPE scx_attrname VALUE 'MV_NAME',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_price,

      BEGIN OF mandatory_fields,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '006',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF mandatory_fields,

      BEGIN OF discontinued_without_release,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '007',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF discontinued_without_release,

      BEGIN OF invalid_date,
        msgid TYPE symsgid VALUE gc_msgid,
        msgno TYPE symsgno VALUE '008',
        attr1 TYPE scx_attrname VALUE '',
        attr2 TYPE scx_attrname VALUE '',
        attr3 TYPE scx_attrname VALUE '',
        attr4 TYPE scx_attrname VALUE '',
      END OF invalid_date.

    DATA: mv_msgv1      TYPE msgv1,
          mv_msgv2      TYPE msgv1,
          mv_msgv3      TYPE msgv1,
          mv_msgv4      TYPE msgv1,
          mv_name       TYPE zde_name_0573,
          mv_nonaut     TYPE zde_responsible_yas,
          mv_incidentid TYPE zde_incident_id_yas.

    METHODS constructor
      IMPORTING
        !textid   LIKE if_t100_message=>t100key OPTIONAL
        !previous LIKE previous OPTIONAL
        msgv1     TYPE msgv1 OPTIONAL
        msgv2     TYPE msgv1 OPTIONAL
        msgv3     TYPE msgv1 OPTIONAL
        msgv4     TYPE msgv1 OPTIONAL
        name      TYPE zde_name_0573 OPTIONAL
        severity  TYPE if_abap_behv_message=>t_severity OPTIONAL.

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_messages_sales_0573 IMPLEMENTATION.

  METHOD constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
    previous = previous
    ).
    CLEAR me->textid.
    IF textid IS INITIAL.
      if_t100_message~t100key = if_t100_message=>default_textid.
    ELSE.
      if_t100_message~t100key = textid.
    ENDIF.

    me->mv_msgv1 = msgv1.
    me->mv_msgv2 = msgv2.
    me->mv_msgv3 = msgv3.
    me->mv_msgv4 = msgv4.
    me->mv_name = name.

    if_abap_behv_message~m_severity = severity.
  ENDMETHOD.
ENDCLASS.
