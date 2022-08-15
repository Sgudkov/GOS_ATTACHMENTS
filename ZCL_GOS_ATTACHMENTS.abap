*----------------------------------------------------------------------*
*       CLASS lcl_gos_attachments DEFINITION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_gos_attachments DEFINITION.

  PUBLIC SECTION.

    TYPES:
      BEGIN OF mty_s_borid.
            INCLUDE TYPE borident.
    TYPES attachments TYPE sgs_flag.
    TYPES notes       TYPE sgs_flag.
    TYPES urls        TYPE sgs_flag.
    TYPES t_bitem     TYPE bitem_t.
    TYPES t_boritem   TYPE bitem_t.
    TYPES o_att_list  TYPE REF TO cl_gos_attachments.
    TYPES END OF  mty_s_borid .
    TYPES:
      mty_t_borid TYPE STANDARD TABLE OF mty_s_borid WITH DEFAULT KEY .

    DATA:
      mt_objects        TYPE TABLE OF mty_s_borid,
      mo_services       TYPE REF TO cl_gos_document_service,
      mo_gos_att_list   TYPE REF TO cl_gos_attachments.


    METHODS:
      constructor,
      set_object
        IMPORTING
          is_object   TYPE mty_s_borid OPTIONAL
          it_objects  TYPE mty_t_borid OPTIONAL,
       get_attachments RETURNING value(rt_attachments) TYPE mty_t_borid,
       get_object_content
         IMPORTING
           iv_docid TYPE so_entryid
           RETURNING value(rv_content) TYPE string,
       display_all
         IMPORTING
           iv_objkey    TYPE swo_typeid.


ENDCLASS.                    "lcl_gos_attachments DEFINITION


*----------------------------------------------------------------------*
*       CLASS lcl_gos_attachments IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_gos_attachments IMPLEMENTATION.

  METHOD constructor.
    CREATE OBJECT mo_services.
  ENDMETHOD.                    "constructor

  METHOD display_all.

    DATA:
      lo_mitem TYPE REF TO cl_container_item,
      lo_bitem TYPE REF TO cl_browser_item.

    FIELD-SYMBOLS: <ls_borid> TYPE mty_s_borid.

    READ TABLE mt_objects ASSIGNING <ls_borid>
     WITH KEY objkey = iv_objkey.
    CHECK sy-subrc = 0.

    IF <ls_borid>-o_att_list IS NOT BOUND.

      CREATE OBJECT lo_mitem.
      CALL METHOD lo_mitem->if_container_item~set_items
        EXPORTING
          it_bitem = <ls_borid>-t_boritem.

      TRY.
          lo_bitem ?= lo_mitem.
        CATCH cx_sy_move_cast_error.
          RETURN.
      ENDTRY.

      CREATE OBJECT <ls_borid>-o_att_list
        EXPORTING
          io_object      = lo_bitem
          ip_mode        = 'D'
          ip_notes       = <ls_borid>-notes
          ip_attachments = <ls_borid>-attachments
          ip_urls        = <ls_borid>-urls.

    ENDIF.

    <ls_borid>-o_att_list->display( ).


  ENDMETHOD.                    "display_all

  METHOD set_object.

    IF is_object IS NOT INITIAL.
      APPEND is_object TO mt_objects.
    ELSE.
      mt_objects = it_objects.
    ENDIF.

  ENDMETHOD.                    "set_object

  METHOD get_attachments.

    DATA: lo_boritem  TYPE REF TO cl_sobl_bor_item,
          ls_borident TYPE borident.

    DATA: li_service  TYPE REF TO if_link_service,
          lo_service  TYPE REF TO if_link_service,
          lo_msgsrv   TYPE REF TO cl_msg_al_linksrv,
          lt_services TYPE lsrvc_t.

    FIELD-SYMBOLS: <ls_borid> TYPE mty_s_borid.

    CREATE OBJECT li_service TYPE cl_msg_al_linksrv.
    APPEND li_service TO lt_services.

    LOOP AT mt_objects ASSIGNING <ls_borid>.

      CLEAR: ls_borident.

      TRY.
          lo_msgsrv ?= li_service.
        CATCH cx_sy_move_cast_error.
          RETURN.
      ENDTRY.

      lo_msgsrv->gp_attachments = <ls_borid>-attachments.
      lo_msgsrv->gp_notes       = <ls_borid>-notes.
      lo_msgsrv->gp_urls        = <ls_borid>-urls.

      MOVE-CORRESPONDING <ls_borid> TO ls_borident.

      CREATE OBJECT lo_boritem
        EXPORTING
          is_bor = ls_borident.

      APPEND lo_boritem TO <ls_borid>-t_boritem.

      READ TABLE lt_services INTO lo_service INDEX 1.
      CHECK sy-subrc = 0.

      CALL METHOD lo_service->get_item_links
        EXPORTING
          io_bitem            = lo_boritem
          ip_load_restriction = 0
        IMPORTING
          et_partner          = <ls_borid>-t_bitem.

    ENDLOOP.

    rt_attachments = mt_objects.

  ENDMETHOD.                    "get_attachments

  METHOD get_object_content.
    DATA lt_obj_content TYPE TABLE OF solisti1.

    FIELD-SYMBOLS: <ls_conent> TYPE solisti1.

    CALL FUNCTION 'SO_DOCUMENT_READ_API1'
      EXPORTING
        document_id                = iv_docid
      TABLES
        object_content             = lt_obj_content
      EXCEPTIONS
        document_id_not_exist      = 1
        operation_no_authorization = 2
        x_error                    = 3
        OTHERS                     = 4.

    READ TABLE lt_obj_content ASSIGNING <ls_conent> INDEX 1.
    IF sy-subrc = 0 AND <ls_conent>-line(5) = '&KEY&'.
      rv_content = <ls_conent>-line+5.
    ENDIF.
  ENDMETHOD.                    "get_object_content

ENDCLASS.                    "lcl_gos_attachments IMPLEMENTATION
