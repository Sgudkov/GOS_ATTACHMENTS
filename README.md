# GOS_ATTACHMENTS
## Get all attachmetns of business objects

### This example show how you can retrieve all attachments of any business object.

#### How use.

1. Run method *SET_OBJECT*. This method define what kind of attachmetns do you want to retrieve.
- [x] ATTACHMENTS - retrieve all attachmetns of BO.
- [x] NOTES - retrieve all notes of BO.
- [x] URLS - retrieve all urls of BO.

*Want to get all urls of BO FMBU*
```abap  
  DATA: lo_attachments TYPE REF TO lcl_gos_attachments,
        ls_object      TYPE lcl_gos_attachments=>mty_s_borid,
        lt_attachmetns TYPE lcl_gos_attachments=>mty_t_borid,
        lo_witem       TYPE REF TO cl_browser_item,
		lo_msg_item    TYPE REF TO cl_msg_al_item,
		lv_typid       TYPE swo_typeid,
		lv_url         TYPE string,
		lv_docid       TYPE so_entryid,
		ls_borident    TYPE borident.
		
  CREATE OBJECT lo_attachments.	
  
  ls_object-objkey  = '0400000004'.
  ls_object-objtype = 'FMBU'.
  ls_object-urls    = 'X'.

  lo_attachments->set_object(
   EXPORTING
     is_object = ls_object
   ).   
```  
> Method *SET_OBJECT* allow to set list of objects, see interface of method.

2. Run method *GET_ATTACHMENTS* to retrieve all uploaded data for BO for those attachments which you selected in step 1.

*Get requested attachments*
```abap 
  lt_attachmetns = lo_attachments->get_attachments( ).
``` 
   
> This is what method returned

![alt text](https://github.com/Sgudkov/GOS_ATTACHMENTS/blob/main/attachments_main1.jpg)

> Table has field with table type where store all attachments which are represented like instance of class *CL_MSG_AL_ITEM*.

![alt text](https://github.com/Sgudkov/GOS_ATTACHMENTS/blob/main/attachments_bitem1.jpg)


*This is how you can get attachments data*

```abap 
  LOOP AT lt_attachmetns ASSIGNING <ls_boitem>.
    LOOP AT <ls_boitem>-t_bitem INTO lo_witem.
      TRY.
          lo_msg_item ?= lo_witem.
        CATCH cx_sy_move_cast_error.
          CONTINUE.
      ENDTRY.

      CONCATENATE lo_msg_item->gs_folder lo_msg_item->gs_document INTO lv_docid.
      lv_url = lo_attachments->get_object_content( lv_docid ).
    ENDLOOP.
  ENDLOOP.
```  

*This is how you can display and edit attachments*

```abap 
  LOOP AT lt_attachmetns ASSIGNING <ls_boitem>.
    LOOP AT <ls_boitem>-t_bitem INTO lo_witem.
      TRY.
          lo_msg_item ?= lo_witem.
        CATCH cx_sy_move_cast_error.
          CONTINUE.
      ENDTRY.

      "Edit trigger commit work even if you cancel changed data
      lo_msg_item->execute( cl_gos_attachments=>gc_cmd_edit ).

      "Just display
      lo_msg_item->execute( cl_gos_attachments=>gc_cmd_display ).

    ENDLOOP.
  ENDLOOP.
```

*Another way display, edit, create and export attachments*

```abap 
  MOVE-CORRESPONDING ls_object TO ls_borident.  

  "Allow to create attachemtns, note, urls. Need to use commit after creation.
  "See more variants in class CL_GOS_DOCUMENT_SERVICE
  lo_attachments->mo_services->create( EXPORTING is_object = ls_borident  ).

  LOOP AT lt_attachmetns ASSIGNING <ls_boitem>.
    LOOP AT <ls_boitem>-t_bitem INTO lo_witem.
      TRY.
          lo_msg_item ?= lo_witem.
        CATCH cx_sy_move_cast_error.
          CONTINUE.
      ENDTRY.

      "Display single row
      CONCATENATE lo_msg_item->gs_folder lo_msg_item->gs_document INTO lv_typid.
      lo_attachments->mo_services->display_attachment( EXPORTING ip_attachment = lv_typid  ).

      "Edit single row
      lo_attachments->mo_services->edit_attachment( EXPORTING ip_attachment = lv_typid  ).
      
      "Just export attachments
      lo_attachments->mo_services->export_attachment( EXPORTING ip_attachment = lv_typid ).
      
    ENDLOOP.
  ENDLOOP.
 
```  

*This is how you can display all attachments in ALV*

> Need to call go_attachments->display_all( '0400000004' ). in PBO
> Popup screen with ALV will be created

```abap 
CLASS: lcl_gos_attachments DEFINITION DEFERRED.

DATA go_attachments TYPE REF TO lcl_gos_attachments.


MODULE status_0900 OUTPUT.
*  SET PF-STATUS 'xxxxxxxx'.
*  SET TITLEBAR 'xxx'.

  go_attachments->display_all( '0400000000' ).

ENDMODULE.                 " STATUS_0900  OUTPUT

``` 